// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import Intents
import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    public init?(intentConfig: some AppIntent) {
        let uuid: String?
        switch intentConfig {
        case let intentConfig as PZEmbeddedIntent4ProfileOnly:
            uuid = intentConfig.account?.id
        case let intentConfig as PZDesktopIntent4SingleProfile:
            uuid = intentConfig.accountIntent?.id
        case let intentConfig as PZEmbeddedIntent4ProfileMisc:
            uuid = intentConfig.account?.id
        default:
            uuid = nil
        }
        guard let uuid, let profile = Defaults[.pzProfiles][uuid] else { return nil }
        self = profile.game
    }

    public init?(intentConfigIN: some INIntent) {
        let uuid: String?
        switch intentConfigIN {
        case let intentConfig as SelectOnlyAccountIntent:
            uuid = intentConfig.account?.identifier
        case let intentConfig as SelectAccountIntent:
            uuid = intentConfig.accountIntent?.identifier
        case let intentConfig as SelectAccountAndShowWhichInfoIntent:
            uuid = intentConfig.account?.identifier
        default:
            uuid = nil
        }
        guard let uuid, let profile = Defaults[.pzProfiles][uuid] else { return nil }
        self = profile.game
    }

    public static func initFromDualProfileConfig(
        intent: PZDesktopIntent4DualProfiles
    )
        -> (slot1: Self?, slot2: Self?) {
        var game1: Self?
        var game2: Self?
        if let uuid1 = intent.profileSlot1?.id {
            game1 = Defaults[.pzProfiles][uuid1]?.game
        }
        if let uuid2 = intent.profileSlot2?.id {
            game2 = Defaults[.pzProfiles][uuid2]?.game
        }
        return (game1, game2)
    }
}
