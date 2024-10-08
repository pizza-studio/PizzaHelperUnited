// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - Verification

public struct Verification: Decodable, DecodableFromMiHoYoAPIJSONResult, Sendable {
    // MARK: Lifecycle

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.challenge = try container.decode(String.self, forKey: .challenge)
        self.gt = try container.decode(String.self, forKey: .gt)
        self.newCaptcha = try container.decode(Int.self, forKey: .newCaptcha)
        self.success = try container.decode(Int.self, forKey: .success)
    }

    // MARK: Public

    public let challenge: String
    // swiftlint:disable:next identifier_name
    public let gt: String
    public let newCaptcha: Int
    public let success: Int

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case challenge
        // swiftlint:disable:next identifier_name
        case gt
        case newCaptcha = "new_captcha"
        case success
    }
}

// MARK: - VerifyVerification

public struct VerifyVerification: Decodable, DecodableFromMiHoYoAPIJSONResult, Sendable {
    let challenge: String
}
