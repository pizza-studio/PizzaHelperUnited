// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - Shared Structs for Gacha URL Generation.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HoYo {
    // MARK: - GetCookieTokenResult

    struct GetCookieTokenResult: Codable {
        @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
        struct GetCookieTokenData: Codable {
            let uid: String
            let cookieToken: String
        }

        let retcode: Int
        let message: String
        let data: GetCookieTokenData?
    }

    // MARK: - GenAuthKeyParam

    struct GenAuthKeyParam: Encodable {
        // MARK: Internal

        let authAppid: String = "webview_gacha"
        let gameUid: String
        let serverRawValue: String
        let gameBiz: String

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(authAppid, forKey: .authAppid)
            try container.encode(gameUid, forKey: .gameUid)
            try container.encode(serverRawValue, forKey: .serverRawValue)
            try container.encode(gameBiz, forKey: .gameBiz)
        }

        // MARK: Private

        @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
        private enum CodingKeys: String, CodingKey {
            case authAppid
            case gameUid
            case serverRawValue = "region"
            case gameBiz
        }
    }

    // MARK: - GenAuthKeyResult

    struct GenAuthKeyResult: Codable {
        // MARK: Public

        @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
        public struct GenAuthKeyData: Codable {
            let authkeyVer: Int
            let signType: Int
            let authkey: String
        }

        // MARK: Internal

        let retcode: Int
        let message: String
        let data: GenAuthKeyData?
    }
}
