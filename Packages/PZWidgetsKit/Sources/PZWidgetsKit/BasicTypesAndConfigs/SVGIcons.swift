// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - Asset Icons (SVG)

extension Pizza.SupportedGame? {
    public var unavailableAssetSVG: Image {
        Image("icon.info.unavailable", bundle: .main)
    }

    public var primaryStaminaAssetSVG: Image {
        self?.primaryStaminaAssetSVG ?? unavailableAssetSVG
    }

    public var dailyTaskAssetSVG: Image {
        self?.dailyTaskAssetSVG ?? unavailableAssetSVG
    }

    public var expeditionAssetSVG: Image {
        guard let this = self, this != .zenlessZone else { return unavailableAssetSVG }
        return this.expeditionAssetSVG
    }
}

extension Pizza.SupportedGame {
    /// 主要玩家体力。
    public var primaryStaminaAssetSVG: Image {
        let assetName = switch self {
        case .genshinImpact: "icon.resin"
        case .starRail: "icon.trailblazePower"
        case .zenlessZone: "icon.zzzBattery"
        }
        return Image(assetName)
    }

    public var dailyTaskAssetSVG: Image {
        let assetName = switch self {
        case .genshinImpact: "icon.dailyTask.gi"
        case .starRail: "icon.dailyTask.hsr"
        case .zenlessZone: "icon.dailyTask.zzz"
        }
        return Image(assetName)
    }

    public var expeditionAssetSVG: Image {
        let assetName = switch self {
        case .genshinImpact: "icon.expedition.gi"
        case .starRail: "icon.expedition.hsr"
        case .zenlessZone: "icon.expedition.gi"
        }
        return Image(assetName)
    }

    public var giTransformerAssetSVG: Image {
        Image("icon.transformer", bundle: .main)
    }

    public var giRealmCurrencyAssetSVG: Image {
        Image("icon.homeCoin", bundle: .main)
    }

    public var giTrounceBlossomAssetSVG: Image {
        Image("icon.trounceBlossom", bundle: .main)
    }

    public var hsrEchoOfWarAssetSVG: Image {
        Image("icon.echoOfWar", bundle: .main)
    }

    public var hsrSimulatedUniverseAssetSVG: Image {
        Image("icon.simulatedUniverse", bundle: .main)
    }

    public var zzzVHSStoreAssetSVG: Image {
        Image("icon.zzzVHSStore", bundle: .main)
    }

    public var zzzScratchCardAssetSVG: Image {
        Image("icon.zzzScratch", bundle: .main)
    }

    public var zzzBountyAssetSVG: Image {
        Image("icon.zzzBounty", bundle: .main)
    }

    public var zzzInvestigationPointsAssetSVG: Image {
        Image("icon.zzzInvestigation", bundle: .main)
    }
}
