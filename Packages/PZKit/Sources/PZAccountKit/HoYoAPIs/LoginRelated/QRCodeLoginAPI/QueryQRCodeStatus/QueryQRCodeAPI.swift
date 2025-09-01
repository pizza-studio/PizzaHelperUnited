// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import Foundation
import PZBaseKit
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

extension HoYo {
    private static let sharedURLSessionCfg4QRCodeStatus: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.background(
            withIdentifier: sharedBundleIDHeader + ".qrCodeSession"
        )
        configuration.timeoutIntervalForRequest = 120 // 设置请求超时
        configuration.timeoutIntervalForResource = 240 // 设置资源超时
        configuration.allowsCellularAccess = true // 允许蜂窝网络访问
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true
        return configuration
    }()

    private static let qrCodeStatusDelegate = QRCodeStatusCheckDelegate()
    private static let qrCodeStatusRootQueue = DispatchQueue(
        label: sharedBundleIDHeader + ".qrCodeSessionQueue"
    )

    private static let sharedURLSession4QRCodeStatus = URLSession(
        configuration: sharedURLSessionCfg4QRCodeStatus,
        delegate: qrCodeStatusDelegate,
        delegateQueue: OperationQueue()
    )

    // 添加一个标准的 URLSessionConfiguration 用于前台定期轮询
    private static let sharedURLSessionCfg4QRCodeForeground: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 15 // 轮询使用较短的超时
        configuration.allowsCellularAccess = true
        return configuration
    }()

    // 标准 Session 用于前台轮询，添加重试机制
    private static let foregroundSession4QRCodeStatus: Session = {
        let interceptor = QRCodeRetryPolicy()
        let configuration = sharedURLSessionCfg4QRCodeForeground
        return Session(configuration: configuration, interceptor: interceptor)
    }()

    static public func queryQRCodeStatus(deviceId: UUID, ticket: String) async throws -> QueryQRCodeStatus {
        struct Body: Encodable {
            let appId: String
            let device: String
            let ticket: String
        }

        let parameters = Body(appId: QRCodeShared.appID, device: deviceId.uuidString, ticket: ticket)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        // 创建请求
        var request = URLRequest(url: QRCodeShared.url4Query)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try encoder.encode(parameters)

        // 使用基于代理的方法进行后台请求
        return try await withCheckedThrowingContinuation { continuation in
            qrCodeStatusDelegate.setContinuation(continuation, for: request.hashValue)
            let task = sharedURLSession4QRCodeStatus.dataTask(with: request)
            task.taskDescription = String(request.hashValue)
            task.resume()
        }
    }

    // 新增前台轮询版本，用于 View 中的定期检查，添加错误处理
    static public func queryQRCodeStatusForeground(deviceId: UUID, ticket: String) async throws -> QueryQRCodeStatus {
        struct Body: Encodable {
            let appId: String
            let device: String
            let ticket: String
        }

        let parameters = Body(appId: QRCodeShared.appID, device: deviceId.uuidString, ticket: ticket)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            let data = try await foregroundSession4QRCodeStatus.request(
                QRCodeShared.url4Query,
                method: .post,
                parameters: parameters,
                encoder: JSONParameterEncoder(encoder: encoder)
            )
            .validate()
            .serializingData()
            .value

            return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.queryQRCodeStatusForeground()")
        } catch {
            // 转换错误为更明确的用户友好错误
            if let afError = error as? AFError, case let .sessionTaskFailed(urlError as URLError) = afError {
                switch urlError.code {
                case .networkConnectionLost, .notConnectedToInternet:
                    throw NSError(
                        domain: "com.pizzastudio.network",
                        code: urlError.code.rawValue,
                        userInfo: [NSLocalizedDescriptionKey: "网路连线暂时中断，请稍后再试。"]
                    )
                default:
                    throw error
                }
            } else {
                throw error
            }
        }
    }

    // 添加一个任务管理系统，以便能够在需要时取消任务
    nonisolated(unsafe) private static var activeForegroundTasks: [UUID: Task<Void, Never>] = [:]
    private static let taskLock = NSLock()

    // 注册前台轮询任务，返回一个标识符，用于后续取消任务
    static public func registerQRCodePollingTask(_ task: Task<Void, Never>) -> UUID {
        let taskId = UUID()
        taskLock.lock()
        activeForegroundTasks[taskId] = task
        taskLock.unlock()
        return taskId
    }

    // 取消特定的轮询任务
    static public func cancelQRCodePollingTask(taskId: UUID) {
        taskLock.lock()
        if let task = activeForegroundTasks[taskId] {
            task.cancel()
            activeForegroundTasks.removeValue(forKey: taskId)
        }
        taskLock.unlock()
    }

    // 取消所有轮询任务
    static public func cancelAllQRCodePollingTasks() {
        taskLock.lock()
        for (_, task) in activeForegroundTasks {
            task.cancel()
        }
        activeForegroundTasks.removeAll()
        taskLock.unlock()
    }
}

// 添加自动重试策略
final class QRCodeRetryPolicy: RequestInterceptor {
    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        // 只有在特定错误条件下重试
        if let urlError = error as? URLError,
           [URLError.networkConnectionLost, URLError.notConnectedToInternet].contains(urlError.code),
           request.retryCount < 3 {
            // 指数退避策略：1秒, 2秒, 4秒
            let retryDelay = pow(2.0, Double(request.retryCount)) * 1.0
            completion(.retryWithDelay(TimeInterval(retryDelay)))
        } else {
            completion(.doNotRetry)
        }
    }
}

// MARK: - HoYo.QRCodeStatusCheckDelegate

extension HoYo {
    public final class QRCodeStatusCheckDelegate: NSObject, URLSessionDataDelegate, @unchecked Sendable {
        // MARK: Public

        public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
            guard let taskID = dataTask.taskDescription.flatMap({ Int($0) }) else { return }

            lock.lock()
            defer { lock.unlock() }

            if var existingData = responseData[taskID] {
                existingData.append(data)
                responseData[taskID] = existingData
            } else {
                responseData[taskID] = data
            }
        }

        public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
            guard let taskID = task.taskDescription.flatMap({ Int($0) }) else { return }

            lock.lock()
            let continuation = continuations.removeValue(forKey: taskID)
            let data = responseData.removeValue(forKey: taskID)
            lock.unlock()

            if let error = error {
                continuation?.resume(throwing: error)
                return
            }

            guard let data = data,
                  let response = task.response as? HTTPURLResponse else {
                continuation?.resume(throwing: AFError.responseSerializationFailed(reason: .inputDataNilOrZeroLength))
                return
            }

            // 检查回应状态
            guard (200 ... 299).contains(response.statusCode) else {
                continuation?
                    .resume(
                        throwing: AFError
                            .responseValidationFailed(reason: .unacceptableStatusCode(code: response.statusCode))
                    )
                return
            }

            do {
                let result = try QueryQRCodeStatus.decodeFromMiHoYoAPIJSONResult(
                    data: data,
                    debugTag: "HoYo.queryQRCodeStatus()"
                )
                continuation?.resume(returning: result)
            } catch {
                continuation?.resume(throwing: error)
            }
        }

        // 新增处理背景会话事件的方法
        public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
            // 当背景任务完成时，此方法会被呼叫
            Task { @MainActor in
                if let backgroundCompletionHandler {
                    backgroundCompletionHandler()
                    self.backgroundCompletionHandler = nil
                }
            }
        }

        // 新增设置背景完成处理器的方法
        public func setBackgroundCompletionHandler(_ handler: @escaping () -> Void) {
            backgroundCompletionHandler = handler
        }

        // MARK: Internal

        func setContinuation(_ continuation: CheckedContinuation<QueryQRCodeStatus, Error>, for requestID: Int) {
            lock.lock()
            defer { lock.unlock() }
            continuations[requestID] = continuation
        }

        // MARK: Private

        private var continuations: [Int: CheckedContinuation<QueryQRCodeStatus, Error>] = [:]
        private var responseData: [Int: Data] = [:]
        private let lock = NSLock()

        private var backgroundCompletionHandler: (() -> Void)?
    }
}

// 新增获取背景URLSession的方法，供App使用
extension HoYo {
    static public func backgroundURLSession(withIdentifier identifier: String) -> URLSession? {
        if identifier == sharedBundleIDHeader + ".qrCodeSession" {
            return sharedURLSession4QRCodeStatus
        }
        return nil
    }

    static public func handleBackgroundSessionEvents(identifier: String, completionHandler: @escaping () -> Void) {
        if identifier == sharedBundleIDHeader + ".qrCodeSession" {
            qrCodeStatusDelegate.setBackgroundCompletionHandler(completionHandler)
        }
    }
}

#endif // !os(watchOS)
