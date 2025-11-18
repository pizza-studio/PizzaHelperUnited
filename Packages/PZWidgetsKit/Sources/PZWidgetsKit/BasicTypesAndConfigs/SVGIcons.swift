// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - SVGIconAsset

@available(iOS 16.2, macCatalyst 16.2, *)
public enum SVGIconAsset: String, CaseIterable, Identifiable, Sendable {
    case infoUnavailable = "icon.info.unavailable"
    case resin = "icon.resin"
    case trailblazePower = "icon.trailblazePower"
    case zzzBattery = "icon.zzzBattery"
    case dailyTaskGI = "icon.dailyTask.gi"
    case dailyTaskHSR = "icon.dailyTask.hsr"
    case dailyTaskZZZ = "icon.dailyTask.zzz"
    case expeditionGI = "icon.expedition.gi"
    case expeditionHSR = "icon.expedition.hsr"
    case transformer = "icon.transformer"
    case homeCoin = "icon.homeCoin"
    case trounceBlossom = "icon.trounceBlossom"
    case echoOfWar = "icon.echoOfWar"
    case simulatedUniverse = "icon.simulatedUniverse"
    case zzzVHSStore = "icon.zzzVHSStore"
    case zzzScratch = "icon.zzzScratch"
    case zzzBounty = "icon.zzzBounty"
    case zzzInvestigation = "icon.zzzInvestigation"

    // MARK: Public

    public var id: String { rawValue }

    public var fallbackSymbol: SFSymbol {
        switch self {
        case .infoUnavailable: .questionmark
        case .resin: .moonFill
        case .trailblazePower: .line3CrossedSwirlCircleFill
        case .zzzBattery: .minusPlusBatteryblock
        case .dailyTaskGI, .dailyTaskHSR, .dailyTaskZZZ: .listStar
        case .expeditionGI, .expeditionHSR: .flag
        case .transformer: .arrowLeftArrowRightSquare
        case .homeCoin: .dollarsignCircle
        case .trounceBlossom: .leaf
        case .echoOfWar: .headphones
        case .simulatedUniverse: .pc
        case .zzzVHSStore: .film
        case .zzzScratch: .giftcard
        case .zzzBounty: .scope
        case .zzzInvestigation: .magnifyingglass
        }
    }

    @MainActor
    public func resolvedImage() -> Image {
        let image = assetImage() ?? Image(systemSymbol: fallbackSymbol)
        return image
            .renderingMode(.template)
            .resizable()
    }

    // MARK: Private

    @MainActor
    private func assetImage() -> Image? {
        #if os(watchOS)
        if #unavailable(watchOS 10.0) {
            return nil
        }
        #endif
        return Image(rawValue, bundle: .module)
    }
}

// MARK: - Syntax Sugar for Asset Icons (SVG)

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame? {
    @MainActor public var unavailableAssetSVG: Image {
        SVGIconAsset.infoUnavailable.resolvedImage()
    }

    @MainActor public var primaryStaminaAssetSVG: Image {
        self?.primaryStaminaAssetSVG ?? unavailableAssetSVG
    }

    @MainActor public var dailyTaskAssetSVG: Image {
        self?.dailyTaskAssetSVG ?? unavailableAssetSVG
    }

    @MainActor public var expeditionAssetSVG: Image {
        guard let this = self, this != .zenlessZone else { return unavailableAssetSVG }
        return this.expeditionAssetSVG
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    /// 主要玩家体力。
    @MainActor public var primaryStaminaAssetSVG: Image {
        primaryStaminaIcon.resolvedImage()
    }

    @MainActor public var dailyTaskAssetSVG: Image {
        dailyTaskIcon.resolvedImage()
    }

    @MainActor public var expeditionAssetSVG: Image {
        expeditionIcon.resolvedImage()
    }

    @MainActor public var giTransformerAssetSVG: Image {
        SVGIconAsset.transformer.resolvedImage()
    }

    @MainActor public var giRealmCurrencyAssetSVG: Image {
        SVGIconAsset.homeCoin.resolvedImage()
    }

    @MainActor public var giTrounceBlossomAssetSVG: Image {
        SVGIconAsset.trounceBlossom.resolvedImage()
    }

    @MainActor public var hsrEchoOfWarAssetSVG: Image {
        SVGIconAsset.echoOfWar.resolvedImage()
    }

    @MainActor public var hsrSimulatedUniverseAssetSVG: Image {
        SVGIconAsset.simulatedUniverse.resolvedImage()
    }

    @MainActor public var zzzVHSStoreAssetSVG: Image {
        SVGIconAsset.zzzVHSStore.resolvedImage()
    }

    @MainActor public var zzzScratchCardAssetSVG: Image {
        SVGIconAsset.zzzScratch.resolvedImage()
    }

    @MainActor public var zzzBountyAssetSVG: Image {
        SVGIconAsset.zzzBounty.resolvedImage()
    }

    @MainActor public var zzzInvestigationPointsAssetSVG: Image {
        SVGIconAsset.zzzInvestigation.resolvedImage()
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Image {
    @MainActor
    func iconOnlyLabel() -> some View {
        aspectRatio(contentMode: .fit)
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    fileprivate var primaryStaminaIcon: SVGIconAsset {
        switch self {
        case .genshinImpact: .resin
        case .starRail: .trailblazePower
        case .zenlessZone: .zzzBattery
        }
    }

    fileprivate var dailyTaskIcon: SVGIconAsset {
        switch self {
        case .genshinImpact: .dailyTaskGI
        case .starRail: .dailyTaskHSR
        case .zenlessZone: .dailyTaskZZZ
        }
    }

    fileprivate var expeditionIcon: SVGIconAsset {
        switch self {
        case .genshinImpact, .zenlessZone: .expeditionGI
        case .starRail: .expeditionHSR
        }
    }
}
