// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

/// Abstract class help generate api url request
enum URLRequestHelper {
    /// Calculate the DS used in url request headers
    /// - Parameters:
    ///   - region: the region of account. `.china` for miyoushe and `.global` for hoyolab.
    ///   - queries: query items of url request
    ///   - body: body of this url request
    /// - Returns: `ds` used in url request headers
    public static func getDS(region: HoYo.AccountRegion, query: String, body: Data? = nil) -> String {
        let salt: String = URLRequestConfig.salt(region: region)

        let time = String(Int(Date().timeIntervalSince1970))
        let randomNumber = String(Int.random(in: 100_000 ..< 200_000))

        let bodyString: String
        if let body = body {
            bodyString = String(data: body, encoding: .utf8) ?? ""
        } else {
            bodyString = ""
        }

        let verification = "salt=\(salt)&t=\(time)&r=\(randomNumber)&b=\(bodyString)&q=\(query)".md5

        return time + "," + randomNumber + "," + verification
    }
}
