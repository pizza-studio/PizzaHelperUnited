// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension Pizza.SupportedGame {
    public init?(intentConfig: some WidgetConfigurationIntent) {
        let uuid: String?
        switch intentConfig {
        case let intentConfig as SelectOnlyAccountIntent:
            uuid = intentConfig.account?.id
        case let intentConfig as SelectAccountIntent:
            uuid = intentConfig.accountIntent?.id
        case let intentConfig as SelectAccountAndShowWhichInfoIntent:
            uuid = intentConfig.account?.id
        default:
            uuid = nil
        }
        guard let uuid, let profile = Defaults[.pzProfiles][uuid] else { return nil }
        self = profile.game
    }

    public static func initFromDualProfileConfig(
        intent: SelectDualProfileIntent
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
