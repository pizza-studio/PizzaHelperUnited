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

    @MainActor
    public func inlineText() -> Text {
        Text(Image(rawValue, bundle: .module).renderingMode(.template))
    }

    // MARK: Internal

    @MainActor
    func shouldDisableSVG(cache: SVGIconImageCache = .shared) -> Bool {
        cache.hasImage(for: self) == false
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
        // 這些任務得逐一完成。
        for icon in SVGIconAsset.allCases {
            await precompile(icon: icon)
        }
    }

    public func precompile(icon: SVGIconAsset) async {
        _ = await Task { @MainActor in
            let cache = SVGIconImageCache.shared
            if cache.hasImage(for: icon) {
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
        // watchOS Embedded Widgets 的素材只能放到 main bundle 内。
        #if canImport(AppKit)
        guard nil != Bundle.module.image(forResource: icon.rawValue) else { return nil }
        #elseif canImport(UIKit)
        guard nil != UIImage(named: icon.rawValue, in: .main, with: nil) else { return nil }
        #endif
        let content = Image(icon.rawValue, bundle: .main)
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fit)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 1
        renderer.isOpaque = false
        renderer.proposedSize = ProposedViewSize(width: 48, height: 48)
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

// MARK: - SVGIconPrewarmCoordinator

@available(iOS 16.2, macCatalyst 16.2, *)
public actor SVGIconPrewarmCoordinator {
    // MARK: Public

    public static let shared = SVGIconPrewarmCoordinator()

    public func ensurePrecompiled() async {
        if hasCompletedPrewarm {
            return
        }
        if let task = inFlightTask {
            await task.value
            return
        }
        let task = Task(priority: .userInitiated) {
            await SVGIconsCompiler.shared.precompileAllIfNeeded()
        }
        inFlightTask = task
        await task.value
        hasCompletedPrewarm = true
        inFlightTask = nil
    }

    // MARK: Private

    private var inFlightTask: Task<Void, Never>?
    private var hasCompletedPrewarm = false
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

    @MainActor public var primaryStaminaSVGAsInlineText: Text {
        self?.primaryStaminaSVGAsInlineText ?? SVGIconAsset.infoUnavailable.inlineText()
    }

    @MainActor public var dailyTaskSVGAsInlineText: Text {
        self?.dailyTaskSVGAsInlineText ?? SVGIconAsset.infoUnavailable.inlineText()
    }

    @MainActor public var expeditionSVGAsInlineText: Text {
        guard let this = self, this != .zenlessZone else {
            return SVGIconAsset.infoUnavailable.inlineText()
        }
        return this.expeditionSVGAsInlineText
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Pizza.SupportedGame {
    /// 主要玩家体力。
    @MainActor public var primaryStaminaAssetSVG: Image {
        primaryStaminaIcon.resolvedImage()
    }

    @MainActor public var primaryStaminaSVGAsInlineText: Text {
        primaryStaminaIcon.inlineText()
    }

    @MainActor public var dailyTaskAssetSVG: Image {
        dailyTaskIcon.resolvedImage()
    }

    @MainActor public var dailyTaskSVGAsInlineText: Text {
        dailyTaskIcon.inlineText()
    }

    @MainActor public var expeditionAssetSVG: Image {
        expeditionIcon.resolvedImage()
    }

    @MainActor public var expeditionSVGAsInlineText: Text {
        expeditionIcon.inlineText()
    }

    @MainActor public var giTransformerAssetSVG: Image {
        SVGIconAsset.transformer.resolvedImage()
    }

    @MainActor public var giTransformerSVGAsInlineText: Text {
        SVGIconAsset.transformer.inlineText()
    }

    @MainActor public var giRealmCurrencyAssetSVG: Image {
        SVGIconAsset.homeCoin.resolvedImage()
    }

    @MainActor public var giRealmCurrencySVGAsInlineText: Text {
        SVGIconAsset.homeCoin.inlineText()
    }

    @MainActor public var giTrounceBlossomAssetSVG: Image {
        SVGIconAsset.trounceBlossom.resolvedImage()
    }

    @MainActor public var giTrounceBlossomSVGAsInlineText: Text {
        SVGIconAsset.trounceBlossom.inlineText()
    }

    @MainActor public var hsrEchoOfWarAssetSVG: Image {
        SVGIconAsset.echoOfWar.resolvedImage()
    }

    @MainActor public var hsrEchoOfWarSVGAsInlineText: Text {
        SVGIconAsset.echoOfWar.inlineText()
    }

    @MainActor public var hsrSimulatedUniverseAssetSVG: Image {
        SVGIconAsset.simulatedUniverse.resolvedImage()
    }

    @MainActor public var hsrSimulatedUniverseSVGAsInlineText: Text {
        SVGIconAsset.simulatedUniverse.inlineText()
    }

    @MainActor public var zzzVHSStoreAssetSVG: Image {
        SVGIconAsset.zzzVHSStore.resolvedImage()
    }

    @MainActor public var zzzVHSStoreSVGAsInlineText: Text {
        SVGIconAsset.zzzVHSStore.inlineText()
    }

    @MainActor public var zzzScratchCardAssetSVG: Image {
        SVGIconAsset.zzzScratch.resolvedImage()
    }

    @MainActor public var zzzScratchCardSVGAsInlineText: Text {
        SVGIconAsset.zzzScratch.inlineText()
    }

    @MainActor public var zzzBountyAssetSVG: Image {
        SVGIconAsset.zzzBounty.resolvedImage()
    }

    @MainActor public var zzzBountySVGAsInlineText: Text {
        SVGIconAsset.zzzBounty.inlineText()
    }

    @MainActor public var zzzInvestigationPointsAssetSVG: Image {
        SVGIconAsset.zzzInvestigation.resolvedImage()
    }

    @MainActor public var zzzInvestigationPointsSVGAsInlineText: Text {
        SVGIconAsset.zzzInvestigation.inlineText()
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
