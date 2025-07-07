// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - Gacha DS Generator.

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo {
    static func getDSTokenForGachaRecords(region: HoYo.AccountRegion) -> String {
        /// The following salts are LK2. Intelligence provided by Snap.Hutao.
        /// LK2 is at least dedicated for tasks related to gacha records.
        let s = switch region {
        case .miyoushe: "dp8QUFKPYSOzIokdsW9mkxSLyA2FtF8y"
        case .hoyoLab: "rk4xg2hakoi26nljpr099fv9fck1ah10"
        }
        let t = String(Int(Date().timeIntervalSince1970))
        let lettersAndNumbers = "abcdefghijklmnopqrstuvwxyz1234567890"
        let r = String((0 ..< 6).map { _ in
            lettersAndNumbers.randomElement()!
        })
        let c = "salt=\(s)&t=\(t)&r=\(r)".md5
        print(t + "," + r + "," + c)
        print("salt=\(s)&t=\(t)&r=\(r)")
        return t + "," + r + "," + c
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension URLRequestConfig {
    static func xRPCAppVersion4Gacha(region: HoYo.AccountRegion) -> String {
        switch region {
        case .miyoushe: "2.83.1" // 跟 SnapGenshin Internal 一致。
        case .hoyoLab: "2.54.0" // 跟 SnapGenshin Internal 一致。
        }
    }

    static func gachaRecordAPIPath(game: Pizza.SupportedGame) -> String {
        switch game {
        case .starRail: "/common/gacha_record/api/getGachaLog"
        case .genshinImpact: "/gacha_info/api/getGachaLog"
        case .zenlessZone: "/gacha_info/api/getGachaLog"
        }
    }
}
