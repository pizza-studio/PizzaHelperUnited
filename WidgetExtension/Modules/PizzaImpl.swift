// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

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

    public init?(dailyNoteResult: Result<any DailyNoteProtocol, any Error>) {
        switch dailyNoteResult {
        case let .success(data): self = data.game
        case .failure: return nil
        }
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
