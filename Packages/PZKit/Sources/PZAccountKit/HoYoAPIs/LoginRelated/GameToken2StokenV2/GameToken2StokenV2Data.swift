// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - GameToken2StokenV2Data

public struct GameToken2StokenV2Data: Decodable, DecodableFromMiHoYoAPIJSONResult {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tokenData = try container.decode(Token.self, forKey: .token)
        self.stoken = tokenData.token
        let userInfo = try container.decode(UserInfo.self, forKey: .userInfo)
        self.mid = userInfo.mid
    }

    // MARK: Public

    public let stoken: String
    public let mid: String

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case token
        case userInfo = "user_info"
    }

    struct Token: Decodable {
        let token: String
    }

    struct UserInfo: Decodable {
        let mid: String
    }
}

// MARK: - Stoken2LTokenV1Data

public struct Stoken2LTokenV1Data: Decodable, DecodableFromMiHoYoAPIJSONResult {
    public let ltoken: String
}
