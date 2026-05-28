// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - QueryQRCodeStatus

public enum QueryQRCodeStatus: Decodable, Sendable {
    case unscanned
    case scanned
    case confirmed(accountId: String, stoken: String, mid: String)

    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let statusKeys: StatusCodingKeys = try container.decode(StatusCodingKeys.self, forKey: .status)
        switch statusKeys {
        case .created, .unscanned:
            self = .unscanned
        case .scanned:
            self = .scanned
        case .confirmed:
            let tokens = try container.decodeIfPresent([TokenItem].self, forKey: .tokens) ?? []
            let userInfo = try container.decode(UserInfo.self, forKey: .userInfo)
            let stoken = tokens.first?.token ?? ""
            self = .confirmed(
                accountId: userInfo.aid ?? userInfo.uid ?? userInfo.accountId ?? "",
                stoken: stoken,
                mid: userInfo.mid ?? ""
            )
        }
    }

    // MARK: Public

    public struct ParsedResult: Sendable {
        public let accountId: String
        public let stoken: String
        public let ltoken: String
        public let mid: String
    }

    public func parsed() async throws -> ParsedResult? {
        guard case let .confirmed(accountId, stoken, mid) = self else { return nil }
        // 新版 API 直接返回 stoken，ltoken 同 stoken（参照 TRSS-Plugin 实作）
        return .init(
            accountId: accountId,
            stoken: stoken,
            ltoken: stoken,
            mid: mid
        )
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case status
        case tokens
        case userInfo = "user_info"
    }

    enum StatusCodingKeys: String, Decodable {
        case unscanned = "Init"
        case scanned = "Scanned"
        case confirmed = "Confirmed"
        case created = "Created"
    }

    struct TokenItem: Decodable {
        enum CodingKeys: String, CodingKey {
            case tokenType = "token_type"
            case token
        }

        let tokenType: Int
        let token: String
    }

    struct UserInfo: Decodable {
        enum CodingKeys: String, CodingKey {
            case aid
            case uid
            case accountId = "account_id"
            case mid
        }

        let aid: String?
        let uid: String?
        let accountId: String?
        let mid: String?
    }
}

// MARK: DecodableFromMiHoYoAPIJSONResult

extension QueryQRCodeStatus: DecodableFromMiHoYoAPIJSONResult {}
