// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import SwiftUI

/// iOS 14-compatible version: 使用 Combine + DispatchQueue 代替 Swift Concurrency/Task。
///
/// OS21 = [iOS14, macOS11]
@MainActor
@preconcurrency
open class TaskManagedVM4OS21: ObservableObject {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public enum State: String, Hashable, Identifiable {
        case busy
        case standby

        // MARK: Public

        public var id: String { rawValue }
    }

    @Published public var taskState: State = .standby
    @Published public var currentError: Error?
    /// 这是能够用来干涉父 class 里面的 errorHanler 的唯一途径。
    public var assignableErrorHandlingTask: ((Error) -> Void) = { _ in }

    public func forceStopTheTask() {
        workItem?.cancel()
        taskState = .standby
    }

    public func handleError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            withAnimation {
                this.currentError = error
            }
            this.assignableErrorHandlingTask(error)
            this.forceStopTheTask()
        }
    }

    /// iOS 14 不支持 async/await 和 variadic generics。
    /// 这里的 givenTask 必须是非 async 的同步闭包。调用异步 API 需自行封装为 completion handler。
    public func fireTask<T>(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)? = nil,
        animatedPreparationTask: (() -> Void)? = nil,
        cancelPreviousTask: Bool = true,
        givenTask: @escaping (@escaping (Result<T?, Error>) -> Void) -> Void,
        completionHandler: ((T?) -> Void)? = nil,
        errorHandler: ((Error) -> Void)? = nil
    ) {
        if let prerequisite = prerequisite, !prerequisite.condition {
            if let notMetHandler = prerequisite.notMetHandler {
                DispatchQueue.main.async { [weak self] in
                    guard self != nil else { return }
                    withAnimation {
                        notMetHandler()
                    }
                }
            }
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            withAnimation {
                this.currentError = nil
                this.taskState = .busy
                animatedPreparationTask?()
            }
        }

        // 取消旧任务
        if cancelPreviousTask {
            workItem?.cancel()
        }

        let item = DispatchWorkItem { [weak self] in
            guard self != nil else { return }
            givenTask { [weak self] result in
                guard self != nil else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let this = self else { return }
                    switch result {
                    case let .success(value):
                        withAnimation {
                            completionHandler?(value)
                            this.currentError = nil
                            this.taskState = .standby
                        }
                    case let .failure(error):
                        (errorHandler ?? this.handleError)(error)
                        this.taskState = .standby
                    }
                    // 注意：taskState 状态恢复交给调用者自己处理
                }
            }
        }
        workItem = item

        DispatchQueue.main.async(execute: item)
    }

    // MARK: Private

    private var workItem: DispatchWorkItem?
}
