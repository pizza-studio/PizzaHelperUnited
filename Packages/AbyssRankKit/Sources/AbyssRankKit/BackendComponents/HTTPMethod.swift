// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZBaseKit

// MARK: - HttpMethod

@MainActor
struct HttpMethod<T: Decodable & Sendable>: Sendable {
    // MARK: - Method

    enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
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
        paramDict: [String: String] = [:]
    ) async throws
        -> T {
        // 完整 URL 字串
        let fullURLString = baseHost + urlStr

        // 准备请求头
        var headers: HTTPHeaders = [
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
            "User-Agent": "Genshin-Pizza-Helper/3.0",
        ]

        // 添加自订请求头
        for (key, value) in headersDict {
            headers[key] = value
        }

        // 开始 Alamofire 请求
        do {
            // 使用 AF.request 并转换为 async/await
            let afRequest = AF.request(
                fullURLString,
                method: HTTPMethod(rawValue: method.rawValue),
                parameters: paramDict.isEmpty ? nil : paramDict,
                encoding: paramDict.isEmpty ? JSONEncoding.default : URLEncoding.queryString,
                headers: headers,
                requestModifier: { request in
                    if let body = body {
                        request.httpBody = body
                    }
                }
            )

            // 使用 Alamofire 的 serializingDecodable 直接解码到目标类型
            let response = afRequest
                .validate(statusCode: 200 ... 200) // 仅接受 200 状态码
                .serializingString() // 先获取字串以便处理 NaN

            // 处理 NaN 问题
            let cleanedString = try await response.value.replacingOccurrences(of: "\"NaN\"", with: "0")
            guard let cleanedData = cleanedString.data(using: .utf8) else {
                throw RequestError.decodeError("无法将处理后的字串转换回 Data")
            }
            let resp = await response.response
            print("状态码: \(resp.response?.statusCode ?? 0)")
            print("响应内容: \(cleanedString)")

            // 手动解码处理过的数据
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: cleanedData)
            } catch {
                print(error)
                throw RequestError.decodeError("\(error)")
            }
        } catch {
            print("Alamofire 请求错误: \(error)")

            // 将 Alamofire 错误转换为自定义错误
            if let afError = error as? AFError {
                if afError.isResponseValidationError {
                    throw RequestError.responseError
                } else if afError.isResponseSerializationError {
                    throw RequestError.decodeError("\(afError)")
                }
            }

            throw RequestError.dataTaskError("\(error)")
        }
    }
}
