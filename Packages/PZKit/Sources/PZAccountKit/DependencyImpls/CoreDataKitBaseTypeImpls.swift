// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import PZCoreDataKitShared

extension PZCoreDataKit.CDStoredGame {
    public var asSupportedGame: Pizza.SupportedGame {
        switch self {
        case .genshinImpact: .genshinImpact
        case .starRail: .starRail
        }
    }
}

extension Pizza.SupportedGame {
    public var asCDSupportedGame: PZCoreDataKit.CDStoredGame? {
        switch self {
        case .genshinImpact: .genshinImpact
        case .starRail: .starRail
        case .zenlessZone: nil
        }
    }
}
