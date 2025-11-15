// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// On watchOS 26+ we disable SVG for better compatibility.
private let disableSVG: Bool = {
    #if os(watchOS)
    if #unavailable(watchOS 10.0) {
        return true
    } else {
        return false
    }
    #else
    return false
    #endif
}()

// MARK: - Asset Icons (SVG)

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame? {
    public var unavailableAssetSVG: Image {
        Image("icon.info.unavailable", bundle: .module)
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

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    /// 主要玩家体力。
    public var primaryStaminaAssetSVG: Image {
        if disableSVG {
            let sfSymbol: SFSymbol = switch self {
            case .genshinImpact: .moonFill
            case .starRail: .line3CrossedSwirlCircleFill
            case .zenlessZone: .minusPlusBatteryblock
            }
            return Image(systemSymbol: sfSymbol)
        }
        let assetName = switch self {
        case .genshinImpact: "icon.resin"
        case .starRail: "icon.trailblazePower"
        case .zenlessZone: "icon.zzzBattery"
        }
        return Image(assetName, bundle: .module)
    }

    public var dailyTaskAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .listStar)
        }
        let assetName = switch self {
        case .genshinImpact: "icon.dailyTask.gi"
        case .starRail: "icon.dailyTask.hsr"
        case .zenlessZone: "icon.dailyTask.zzz"
        }
        return Image(assetName, bundle: .module)
    }

    public var expeditionAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .flag)
        }
        let assetName = switch self {
        case .genshinImpact: "icon.expedition.gi"
        case .starRail: "icon.expedition.hsr"
        case .zenlessZone: "icon.expedition.gi"
        }
        return Image(assetName, bundle: .module)
    }

    public var giTransformerAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .arrowLeftArrowRightSquare)
        }
        return Image("icon.transformer", bundle: .module)
    }

    public var giRealmCurrencyAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .dollarsignCircle)
        }
        return Image("icon.homeCoin", bundle: .module)
    }

    public var giTrounceBlossomAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .leaf)
        }
        return Image("icon.trounceBlossom", bundle: .module)
    }

    public var hsrEchoOfWarAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .headphones)
        }
        return Image("icon.echoOfWar", bundle: .module)
    }

    public var hsrSimulatedUniverseAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .pc)
        }
        return Image("icon.simulatedUniverse", bundle: .module)
    }

    public var zzzVHSStoreAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .film)
        }
        return
            Image("icon.zzzVHSStore", bundle: .module)
    }

    public var zzzScratchCardAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .giftcard)
        }
        return Image("icon.zzzScratch", bundle: .module)
    }

    public var zzzBountyAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .scope)
        }
        return Image("icon.zzzBounty", bundle: .module)
    }

    public var zzzInvestigationPointsAssetSVG: Image {
        if disableSVG {
            return Image(systemSymbol: .magnifyingglass)
        }
        return Image("icon.zzzInvestigation", bundle: .module)
    }
}
