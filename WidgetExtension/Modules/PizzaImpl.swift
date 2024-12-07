// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit

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
}
