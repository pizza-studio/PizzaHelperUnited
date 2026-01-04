// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import os
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
    case cosmicStrife = "icon.cosmicStrife"
    case zzzVHSStore = "icon.zzzVHSStore"
    case zzzVHSStoreInOperation = "icon.zzzVHSStore.inOperation"
    case zzzVHSStoreSleeping = "icon.zzzVHSStore.sleeping"
    case zzzScratch = "icon.zzzScratch"
    case zzzScratchDone = "icon.zzzScratch.done"
    case zzzScratchAvailable = "icon.zzzScratch.available"
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
        case .cosmicStrife: .pc
        case .zzzVHSStore: .film
        case .zzzVHSStoreInOperation: .clockBadge
        case .zzzVHSStoreSleeping: .bedDoubleCircle
        case .zzzScratch: .giftcard
        case .zzzScratchDone: .envelopeOpen
        case .zzzScratchAvailable: .envelopeBadgeFill
        case .zzzBounty: .scope
        case .zzzInvestigation: .magnifyingglass
        }
    }

    public var rawSymbol: Image {
        // watchOS Embedded Widgets 的素材只能放到 main bundle 内。
        #if canImport(AppKit) && !targetEnvironment(macCatalyst)
        guard nil != Self.assetBundle.image(forResource: rawValue) else {
            return Image(systemSymbol: fallbackSymbol)
        }
        #elseif canImport(UIKit)
        guard nil != UIImage(named: rawValue, in: Self.assetBundle, with: nil) else {
            return Image(systemSymbol: fallbackSymbol)
        }
        #endif
        let content = Image(rawValue, bundle: Self.assetBundle)
            .renderingMode(.template)
            .resizable()
        return content
    }

    @MainActor
    public func resolvedImage() -> Image {
        requestPrecompilationIfNeeded()
        let cache = SVGIconImageCache.shared
        // 若允许预编译且快取中有已预编译图像，则优先使用快取图像。
        if !shouldDisableSVG(cache: cache), let image = cache.image(for: self) {
            return image
        }
        // 否则使用原始符号作为回退。
        return rawSymbol
    }

    @MainActor
    public func inlineText() -> Text {
        // 内嵌文字直接使用原始符号（预编译预设停用）。
        Text(rawSymbol)
    }

    // MARK: Internal

    @MainActor
    func shouldDisableSVG(cache: SVGIconImageCache = .shared) -> Bool {
        cache.hasImage(for: self) == false
    }

    // MARK: Private

    private static var assetBundle: Bundle {
        let result: Bundle
        #if os(watchOS)
        result = .main
        #else
        result = .module
        #endif
        return result
    }

    @MainActor
    private func requestPrecompilationIfNeeded() {
        guard SVGIconsCompiler.isPrecompileAllowed else { return }
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
        guard Self.isPrecompileAllowed else {
            os_log("Skipping precompileAll: precompilation disabled by gating", log: Self.svgLog, type: .info)
            return
        }
        os_log("Precompile all requested", log: Self.svgLog, type: .info)
        for icon in SVGIconAsset.allCases {
            await precompile(icon: icon)
        }
    }

    public func precompile(icon: SVGIconAsset) async {
        guard Self.isPrecompileAllowed else {
            os_log("Skipping precompile: precompilation disabled by gating", log: Self.svgLog, type: .debug)
            return
        }
        guard SVGIconsCompiler.assetIsAccessible(for: icon) else {
            os_log(
                "Skipping precompile: asset not accessible for %{public}s",
                log: Self.svgLog,
                type: .debug,
                icon.rawValue
            )
            return
        }
        let signpostID = OSSignpostID(log: Self.svgLog)
        os_signpost(
            .begin,
            log: Self.svgLog,
            name: "SVGPrecompile",
            signpostID: signpostID,
            "%{public}s",
            icon.rawValue
        )
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
        os_signpost(.end, log: Self.svgLog, name: "SVGPrecompile", signpostID: signpostID, "%{public}s", icon.rawValue)
    }

    // MARK: Internal

    /// 判断当前 process/平台是否允许执行 runtime 预编译。
    /// watchOS 与 app extension 预设停用。
    static var isPrecompileAllowed: Bool {
        // 允许透过环境变数明确覆写（方便 TestFlight/build 的 A/B 测试）。
        if ProcessInfo.processInfo.environment["ENABLE_SVG_PRECOMPILE"] == "1" { return true }
        // 若透过环境变数明确禁用，则停用。
        if ProcessInfo.processInfo.environment["DISABLE_SVG_PRECOMPILE"] == "1" { return false }
        #if os(watchOS)
        // watchOS（含 complication）：由于记忆体/CPU 限制，runtime 预编译预设停用。
        return false
        #else
        // App extension（.appex）不应尝试执行预编译，以避免短命进程进行大量运算。
        if Bundle.main.bundlePath.hasSuffix(".appex") { return false }
        // 在其余情形下准许 SVG 预编译。
        return true
        #endif
    }

    /// 检查当前进程是否能存取该图示资源（module 与 main bundle 的差异）。
    static func assetIsAccessible(for icon: SVGIconAsset) -> Bool {
        #if os(watchOS)
        // watchOS complications 通常无法可靠地从 `Bundle.module` 读取；仅能使用 `Bundle.main`。
        return UIImage(named: icon.rawValue, in: Bundle.main, with: nil) != nil
        #elseif canImport(UIKit)
        // UIKit：先尝试 `Bundle.module`，若失败再尝试 `Bundle.main`。
        let moduleBundle = Bundle.module
        if UIImage(named: icon.rawValue, in: moduleBundle, with: nil) != nil { return true }
        if UIImage(named: icon.rawValue, in: Bundle.main, with: nil) != nil { return true }
        return false
        #elseif canImport(AppKit)
        let moduleBundle = Bundle.module
        if moduleBundle.image(forResource: icon.rawValue) != nil { return true }
        if Bundle.main.image(forResource: icon.rawValue) != nil { return true }
        return false
        #else
        return false
        #endif
    }

    // MARK: Fileprivate

    fileprivate static let svgLog = OSLog(
        subsystem: Bundle.main.bundleIdentifier ?? "com.pizzastudio.PizzaHelper",
        category: "SVGPrecompile"
    )

    // MARK: Private

    @MainActor
    private static func renderImage(for icon: SVGIconAsset) -> SendableImagePtr? {
        let content = icon.rawSymbol.aspectRatio(contentMode: .fit)
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
        guard SVGIconsCompiler.isPrecompileAllowed else {
            os_log(
                "Prewarm: precompilation disabled by gating; marking as completed.",
                log: SVGIconsCompiler.svgLog,
                type: .info
            )
            hasCompletedPrewarm = true
            inFlightTask = nil
            return
        }
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

    @MainActor public var hsrCosmicStrifeAssetSVG: Image {
        SVGIconAsset.cosmicStrife.resolvedImage()
    }

    @MainActor public var hsrCosmicStrifeSVGAsInlineText: Text {
        SVGIconAsset.cosmicStrife.inlineText()
    }

    @MainActor public var zzzVHSStoreAssetSVG: Image {
        SVGIconAsset.zzzVHSStore.resolvedImage()
    }

    @MainActor public var zzzVHSStoreSVGAsInlineText: Text {
        SVGIconAsset.zzzVHSStore.inlineText()
    }

    @MainActor
    public func zzzVHSStoreStateAssetSVG(isSleeping: Bool) -> Image {
        (
            isSleeping
                ? SVGIconAsset.zzzVHSStoreSleeping
                : SVGIconAsset.zzzVHSStoreInOperation
        ).resolvedImage()
    }

    @MainActor
    public func zzzVHSStoreStateAssetSVGAsInlineText(isSleeping: Bool) -> Text {
        (
            isSleeping
                ? SVGIconAsset.zzzVHSStoreSleeping
                : SVGIconAsset.zzzVHSStoreInOperation
        ).inlineText()
    }

    @MainActor public var zzzScratchCardAssetSVG: Image {
        SVGIconAsset.zzzScratch.resolvedImage()
    }

    @MainActor
    public func zzzScratchCardStateAssetSVG(isDone: Bool) -> Image {
        (
            isDone
                ? SVGIconAsset.zzzScratchDone
                : SVGIconAsset.zzzScratchAvailable
        ).resolvedImage()
    }

    @MainActor
    public func zzzScratchCardStateAssetSVGAsInlineText(isDone: Bool) -> Text {
        (
            isDone
                ? SVGIconAsset.zzzScratchDone
                : SVGIconAsset.zzzScratchAvailable
        ).inlineText()
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
