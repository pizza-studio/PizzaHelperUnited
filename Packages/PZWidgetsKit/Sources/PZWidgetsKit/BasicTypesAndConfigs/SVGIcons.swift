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

// MARK: - EmbeddedIcons

@available(iOS 16.2, macCatalyst 16.2, *)
public enum EmbeddedIcons: String, CaseIterable, Identifiable, Sendable {
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
    public func resolvedImage() -> some View {
        let image = assetImage() ?? Image(systemSymbol: fallbackSymbol)
        return image
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaledToFit()
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

// MARK: - Syntax Sugar for Asset Icons (4Embedded)

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame? {
    @MainActor public var unavailableAsset4Embedded: some View {
        EmbeddedIcons.infoUnavailable.resolvedImage()
    }

    @MainActor @ViewBuilder public var primaryStaminaAsset4Embedded: some View {
        if let this = self {
            this.primaryStaminaAsset4Embedded
        } else {
            unavailableAsset4Embedded
        }
    }

    @MainActor @ViewBuilder public var dailyTaskAsset4Embedded: some View {
        if let this = self {
            this.dailyTaskAsset4Embedded
        } else {
            unavailableAsset4Embedded
        }
    }

    @MainActor @ViewBuilder public var expeditionAsset4Embedded: some View {
        if let this = self, this != .zenlessZone {
            this.expeditionAsset4Embedded
        } else {
            unavailableAsset4Embedded
        }
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    /// 主要玩家体力。
    @MainActor public var primaryStaminaAsset4Embedded: some View {
        primaryStaminaIcon.resolvedImage()
    }

    @MainActor public var dailyTaskAsset4Embedded: some View {
        dailyTaskIcon.resolvedImage()
    }

    @MainActor public var expeditionAsset4Embedded: some View {
        expeditionIcon.resolvedImage()
    }

    @MainActor public var giTransformerAsset4Embedded: some View {
        EmbeddedIcons.transformer.resolvedImage()
    }

    @MainActor public var giRealmCurrencyAsset4Embedded: some View {
        EmbeddedIcons.homeCoin.resolvedImage()
    }

    @MainActor public var giTrounceBlossomAsset4Embedded: some View {
        EmbeddedIcons.trounceBlossom.resolvedImage()
    }

    @MainActor public var hsrEchoOfWarAsset4Embedded: some View {
        EmbeddedIcons.echoOfWar.resolvedImage()
    }

    @MainActor public var hsrSimulatedUniverseAsset4Embedded: some View {
        EmbeddedIcons.simulatedUniverse.resolvedImage()
    }

    @MainActor public var zzzVHSStoreAsset4Embedded: some View {
        EmbeddedIcons.zzzVHSStore.resolvedImage()
    }

    @MainActor public var zzzScratchCardAsset4Embedded: some View {
        EmbeddedIcons.zzzScratch.resolvedImage()
    }

    @MainActor public var zzzBountyAsset4Embedded: some View {
        EmbeddedIcons.zzzBounty.resolvedImage()
    }

    @MainActor public var zzzInvestigationPointsAsset4Embedded: some View {
        EmbeddedIcons.zzzInvestigation.resolvedImage()
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    fileprivate var primaryStaminaIcon: EmbeddedIcons {
        switch self {
        case .genshinImpact: .resin
        case .starRail: .trailblazePower
        case .zenlessZone: .zzzBattery
        }
    }

    fileprivate var dailyTaskIcon: EmbeddedIcons {
        switch self {
        case .genshinImpact: .dailyTaskGI
        case .starRail: .dailyTaskHSR
        case .zenlessZone: .dailyTaskZZZ
        }
    }

    fileprivate var expeditionIcon: EmbeddedIcons {
        switch self {
        case .genshinImpact, .zenlessZone: .expeditionGI
        case .starRail: .expeditionHSR
        }
    }
}
