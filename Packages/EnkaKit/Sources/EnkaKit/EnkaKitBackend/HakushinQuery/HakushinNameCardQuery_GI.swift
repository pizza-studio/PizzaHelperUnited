// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// Hakushin 仅用来查询线上角色素材网址。
// 由于用来查询的论据（角色 ID、道具 ID、服装 ID 等）并不出自内鬼泄漏的内容，
// 所以 App 据此在 Hakushin 只能拿到公开正式版游戏的结果。

import Alamofire
import Foundation
import PZBaseKit

// MARK: - HakushinCharacter4GI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
private struct HakushinCharacter4GI: Codable {
    // MARK: - CharaInfo

    struct CharaInfo: Codable {
        // MARK: - Namecard

        struct Namecard: Codable {
            let id: Int?
            let icon: String?
        }

        let namecard: Namecard?
    }

    let name: String
    let charaInfo: CharaInfo
    let icon: String
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HakushinCharacter4GI {
    public static func queryNameCardURLStr(charIDStr: String) async throws -> String {
        let fallbackAnswer = "https://api.hakush.in/gi/UI/UI_NameCardIcon_Bp2.webp"
        return (try? await Self.query(charIDStr: charIDStr).namecardURLStr()) ?? fallbackAnswer
    }

    private static func query(charIDStr: String) async throws -> Self {
        var initID = charIDStr.prefix(8).description
        if charIDStr.count > 8 {
            initID += "-\(charIDStr.suffix(1))"
        }
        let urlStr = "https://api.hakush.in/gi/data/en/character/\(initID).json"

        // 同时使用 Alamofire 的 responseDecodable 直接解析 JSON
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase

        return try await AF.request(urlStr)
            .serializingDecodable(Self.self, decoder: decoder)
            .value
    }

    private func namecardURLStr() -> String {
        let fileNameStem = charaInfo.namecard?.icon ?? "UI_NameCardIcon_Bp2"
        return "https://api.hakush.in/gi/UI/\(fileNameStem).webp"
    }
}
