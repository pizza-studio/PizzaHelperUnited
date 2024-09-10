// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - RequestError

enum RequestError: Error, LocalizedError {
    case dataTaskError(String)
    case noResponseData
    case responseError
    case decodeError(String)
    case errorWithCode(Int)

    // MARK: Internal

    var localizedDescription: String {
        switch self {
        case let .dataTaskError(string):
            return "[PZReqErr] Data Task Error:\n=======\n\(string)\n=======\n"
        case .noResponseData: return "[PZReqErr] Data is not attached in the HTTP response."
        case .responseError: return "[PZReqErr] HTTP Response Error. (RequestError.responseError)"
        case let .decodeError(string):
            return "[PZReqErr] JSON Decode Error. Raw Contents:\n=======\n\(string)\n=======\n"
        case let .errorWithCode(int): return "[PZReqErr] Request Error (Code \(int))."
        }
    }
}

// MARK: - HttpMethod

@MainActor
struct HttpMethod<T: Decodable & Sendable>: Sendable {
    // MARK: - Method

    enum Method {
        case post
        case get
        case put
    }

    /// 返回OPServer的请求的结果接口
    /// - Parameters:
    ///   - method:Method, http方法的类型
    ///   - url:String，请求的路径
    ///   - completion:异步返回处理好的data以及报错的类型
    ///
    ///  需要自己传URL类型的url过来
    static func homeServerRequest(
        _ method: Method,
        baseHost: String = "http://81.70.76.222",
        urlStr: String,
        body: Data? = nil,
        headersDict: [String: String] = [:],
        parasDict: [String: String] = [:],
        completion: @escaping @Sendable ((Result<T, RequestError>) -> Void)
    ) async {
        // 请求url前缀，后跟request的类型
        let baseStr: String = baseHost
        // 由前缀和后缀共同组成的url
        var url = URLComponents(string: baseStr + urlStr)!
        var urlQueryItems: [URLQueryItem] = url.queryItems ?? []
        for para in parasDict {
            urlQueryItems
                .append(URLQueryItem(name: para.key, value: para.value))
        }
        url.queryItems = urlQueryItems

        // 初始化请求
        var request = URLRequest(url: url.url!)
        // 设置请求头
        request.allHTTPHeaderFields = [
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
        ]

        request.setValue(
            "Genshin-Pizza-Helper/3.0",
            forHTTPHeaderField: "User-Agent"
        )
        for header in headersDict {
            request.setValue(
                header.value,
                forHTTPHeaderField: header.key
            )
        }
        // http方法
        switch method {
        case .post:
            request.httpMethod = "POST"
        case .get:
            request.httpMethod = "GET"
        case .put:
            request.httpMethod = "PUT"
        }
        // request body
        if let body = body {
            request.httpBody = body
            request.setValue(
                "\(body.count)",
                forHTTPHeaderField: "Content-Length"
            )
        }
        //                print(request)
        //                print(request.allHTTPHeaderFields!)
        //                print(String(data: request.httpBody!, encoding: .utf8)!)
        // 开始请求
        do {
            var (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(.responseError))
                print("response error")
                return
            }
            let statusCode = response.statusCode.description
            guard let stringData = String(
                data: data,
                encoding: .utf8
            ) else {
                completion(
                    .failure(
                        .decodeError(
                            "fail convert data to .utf8 string"
                        )
                    )
                ); return
            }
            print(stringData)
            data = stringData.replacingOccurrences(of: "\"NaN\"", with: "0").data(using: .utf8)!
            let decoder = JSONDecoder()
            print(statusCode)
            print(stringData)

            do {
                let requestResult = try decoder.decode(
                    T.self,
                    from: data
                )
                completion(.success(requestResult))
            } catch {
                print(error)
                completion(.failure(.decodeError(
                    error
                        .localizedDescription
                )))
            }

        } catch {
            print(error)
            completion(.failure(.dataTaskError(
                error
                    .localizedDescription
            )))
            print(
                "DataTask error in General HttpMethod: \(error)\n"
            )
        }
    }
}
