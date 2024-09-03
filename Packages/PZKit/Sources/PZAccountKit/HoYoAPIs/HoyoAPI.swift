// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - HoYo

public enum HoYo {}

extension HoYo {
    /// Generate `api-takumi-record.mihoyo.com` / `bbs-api-os.hoyolab.com` request for miHoYo API
    /// - Parameters:
    ///   - httpMethod: http method of request. Default `GET`.
    ///   - region: region of account
    ///   - path: path of api.
    ///   - queryItems: an array of `QueryItem` of request
    ///   - body: `Body` of request.
    ///   - cookie: cookie of request.
    /// - Returns: `URLRequest`
    public static func generateRecordAPIRequest(
        httpMethod: HTTPMethod = .get,
        region: HoYo.AccountRegion,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil,
        deviceID: String? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws
        -> URLRequest {
        try await generateRequest(
            httpMethod: httpMethod,
            region: region,
            host: URLRequestConfig.recordURLAPIHost(region: region),
            path: path,
            queryItems: queryItems,
            body: body,
            cookie: cookie,
            deviceID: deviceID,
            additionalHeaders: additionalHeaders
        )
    }

    /// Generate `api-takumi.mihoyo.com` / `api-account-os.hoyolab.com` request for miHoYo API
    /// - Parameters:
    ///   - httpMethod: http method of request. Default `GET`.
    ///   - region: region of account
    ///   - path: path of api.
    ///   - queryItems: an array of `QueryItem` of request
    ///   - body: `Body` of request.
    ///   - cookie: cookie of request.
    /// - Returns: `URLRequest`
    public static func generateAccountAPIRequest(
        httpMethod: HTTPMethod = .get,
        region: HoYo.AccountRegion,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil,
        deviceID: String? = nil,
        additionalHeaders: [String: String]? = nil
    ) async throws
        -> URLRequest {
        try await generateRequest(
            httpMethod: httpMethod,
            region: region,
            host: URLRequestConfig.accountAPIURLHost(region: region),
            path: path,
            queryItems: queryItems,
            body: body,
            cookie: cookie,
            deviceID: deviceID,
            additionalHeaders: additionalHeaders
        )
    }

    /// Generate request for miHoYo API
    /// - Parameters:
    ///   - httpMethod: http method of request. Default `GET`.
    ///   - region: region of account
    ///   - host: host of api. If nil, default host will apply.
    ///   - path: path of api.
    ///   - queryItems: an array of `QueryItem` of request
    ///   - body: `Body` of request.
    ///   - cookie: cookie of request.
    /// - Returns: `URLRequest`
    public static func generateRequest(
        httpMethod: HTTPMethod = .get,
        region: HoYo.AccountRegion,
        host: String,
        path: String,
        queryItems: [URLQueryItem],
        body: Data? = nil,
        cookie: String? = nil,
        deviceID: String? = nil,
        additionalHeaders: [String: String]?
    ) async throws
        -> URLRequest {
        var components = URLComponents()

        components.scheme = "https"

        components.host = host

        components.path = path

        components.queryItems = queryItems

        guard let url = components.url else {
            let unknownErrorRetcode = -9999
            throw MiHoYoAPIError(retcode: unknownErrorRetcode, message: "Unknown error. Please contact developer. ")
        }

        var request = URLRequest(url: url)

        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData

        request.httpMethod = httpMethod.rawValue

        request.allHTTPHeaderFields = try await URLRequestConfig.defaultHeaders(
            region: region,
            deviceID: deviceID,
            additionalHeaders: additionalHeaders
        )

        if let cookie = cookie {
            request.setValue(cookie, forHTTPHeaderField: "Cookie")
        }

        request.setValue(
            URLRequestHelper.getDS(region: region, query: url.query ?? "", body: body),
            forHTTPHeaderField: "DS"
        )
        if let body = body {
            request.httpBody = body
            request.setValue(
                "\(body.count)",
                forHTTPHeaderField: "Content-Length"
            )
        }

        return request
    }

    public enum HTTPMethod: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
    }
}
