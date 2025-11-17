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
        requestPrecompilationIfNeeded()
        let cache = SVGIconImageCache.shared
        guard !shouldDisableSVG(cache: cache), let image = cache.image(for: self) else {
            return Image(systemSymbol: fallbackSymbol)
        }
        return image
    }

    // MARK: Internal

    @MainActor
    func shouldDisableSVG(cache: SVGIconImageCache = .shared) -> Bool {
        #if os(watchOS)
        if #unavailable(watchOS 10.0) {
            return true
        }
        #endif
        return cache.hasImage(for: self) == false
    }

    // MARK: Private

    @MainActor
    private func requestPrecompilationIfNeeded() {
        if SVGIconImageCache.shared.hasImage(for: self) {
            return
        }
        Task.detached(priority: .utility) {
            await SVGIconsCompiler.shared.precompile(icon: self)
        }
    }
}

// MARK: - SVGIconImageCache

@available(iOS 16.2, macCatalyst 16.2, *)
@MainActor
final class SVGIconImageCache {
    // MARK: Lifecycle

    private init() {}

    // MARK: Internal

    static let shared = SVGIconImageCache()

    func image(for icon: SVGIconAsset) -> Image? {
        storage[icon]?.img
    }

    func store(_ image: SendableImagePtr, for icon: SVGIconAsset) {
        storage[icon] = image
    }

    func hasImage(for icon: SVGIconAsset) -> Bool {
        storage[icon] != nil
    }

    // MARK: Private

    private var storage: [SVGIconAsset: SendableImagePtr] = [:]
}

// MARK: - SVGIconsCompiler

@available(iOS 16.2, macCatalyst 16.2, *)
public actor SVGIconsCompiler {
    // MARK: Public

    public static let shared = SVGIconsCompiler()

    public func precompileAllIfNeeded() async {
        await withTaskGroup(of: Void.self) { group in
            for icon in SVGIconAsset.allCases {
                group.addTask { await self.precompile(icon: icon) }
            }
            await group.waitForAll()
        }
    }

    public func precompile(icon: SVGIconAsset) async {
        _ = await Task { @MainActor in
            let cache = SVGIconImageCache.shared
            let alreadyCached = await MainActor.run { cache.hasImage(for: icon) }
            if alreadyCached {
                return
            }
            guard let rendered = Self.renderImage(for: icon) else {
                return
            }
            await MainActor.run {
                cache.store(rendered, for: icon)
            }
        }
        .value
    }

    // MARK: Private

    @MainActor
    private static func renderImage(for icon: SVGIconAsset) -> SendableImagePtr? {
        let content = Image(icon.rawValue, bundle: .module)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        renderer.isOpaque = false
        renderer.proposedSize = ProposedViewSize(width: 96, height: 96)
        #if canImport(UIKit)
        guard let platformImage = renderer.uiImage else { return nil }
        let templated = Image(uiImage: platformImage).renderingMode(.template)
        #elseif canImport(AppKit)
        guard let platformImage = renderer.nsImage else { return nil }
        let templated = Image(nsImage: platformImage).renderingMode(.template)
        #else
        return nil
        #endif
        return SendableImagePtr(img: templated)
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
        switch self {
        case .genshinImpact:
            return SVGIconAsset.resin.resolvedImage()
        case .starRail:
            return SVGIconAsset.trailblazePower.resolvedImage()
        case .zenlessZone:
            return SVGIconAsset.zzzBattery.resolvedImage()
        }
    }

    @MainActor public var dailyTaskAssetSVG: Image {
        let icon: SVGIconAsset = switch self {
        case .genshinImpact: .dailyTaskGI
        case .starRail: .dailyTaskHSR
        case .zenlessZone: .dailyTaskZZZ
        }
        return icon.resolvedImage()
    }

    @MainActor public var expeditionAssetSVG: Image {
        let icon: SVGIconAsset = switch self {
        case .genshinImpact, .zenlessZone: .expeditionGI
        case .starRail: .expeditionHSR
        }
        return icon.resolvedImage()
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
