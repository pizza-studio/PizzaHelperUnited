// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI
import WebKit

// MARK: - HoYoMapView

struct HoYoMapView: View {
    // MARK: Public

    public static let navTitle = "tools.hoyoMap.navTitle".i18nPZHelper

    public var body: some View {
        let region = currentRegion
        Group {
            switch (region, region.game) {
            case (.hoyoLab, .genshinImpact):
                HoYoMapWebView(region: region).tag(region)
            case (.miyoushe, .genshinImpact):
                HoYoMapWebView(region: region).tag(region)
            case (.hoyoLab, .starRail):
                HoYoMapWebView(region: region).tag(region)
            case (.miyoushe, .starRail):
                HoYoMapWebView(region: region).tag(region)
            case (.hoyoLab, .zenlessZone): EmptyView()
            case (.miyoushe, .zenlessZone): EmptyView()
            }
        }
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.inline)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .toolbar(.hidden, for: .tabBar)
        #endif
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Image(systemSymbol: .map)
                        Picker("".description, selection: $isMiyoushe.animation()) {
                            Text(HoYo.AccountRegion.miyoushe(game).localizedDescription)
                                .tag(true)
                            Text(HoYo.AccountRegion.hoyoLab(game).localizedDescription)
                                .tag(false)
                        }
                        .pickerStyle(.segmented)
                        Picker("".description, selection: $game.animation()) {
                            Text(Pizza.SupportedGame.genshinImpact.localizedShortName)
                                .tag(Pizza.SupportedGame.genshinImpact)
                            Text(Pizza.SupportedGame.starRail.localizedShortName)
                                .tag(Pizza.SupportedGame.starRail)
                        }
                        .pickerStyle(.segmented)
                    }
                    .fixedSize()
                }
            }
    }

    // MARK: Private

    @State private var game: Pizza.SupportedGame = appGame ?? .genshinImpact
    @State private var isMiyoushe: Bool = Locale.isUILanguageSimplifiedChinese

    private var currentRegion: HoYo.AccountRegion {
        isMiyoushe ? .miyoushe(game) : .hoyoLab(game)
    }
}

extension HoYo.AccountRegion {
    fileprivate var hoyoMapURL: URL? {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact):
            "https://act.hoyolab.com/ys/app/interactive-map/index.html".asURL
        case (.miyoushe, .genshinImpact):
            "https://webstatic.mihoyo.com/ys/app/interactive-map/index.html".asURL
        case (.hoyoLab, .starRail):
            "https://act.hoyolab.com/sr/app/interactive-map/index.html".asURL
        case (.miyoushe, .starRail):
            "https://webstatic.mihoyo.com/sr/app/interactive-map/index.html".asURL
        case (.hoyoLab, .zenlessZone):
            "https://act.hoyolab.com/zzz/app/interactive-map/index.html".asURL // 乱填的。
        case (.miyoushe, .zenlessZone):
            "https://webstatic.mihoyo.com/zzz/app/interactive-map/index.html".asURL // 乱填的。
        }
    }

    fileprivate func menuTitle(showEmoji: Bool) -> String {
        var localizedTitle = localizedMapTitle
        if showEmoji {
            switch self {
            case .hoyoLab: localizedTitle.append(" 🇨🇳")
            case .miyoushe: localizedTitle.append(" 🌏")
            }
        }
        return localizedTitle
    }

    private var localizedMapTitle: String {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact): "tools.hoyoMap.os.gi"
        case (.miyoushe, .genshinImpact): ""
        case (.hoyoLab, .starRail): ""
        case (.miyoushe, .starRail): ""
        case (.hoyoLab, .zenlessZone): ""
        case (.miyoushe, .zenlessZone): ""
        }
    }
}

#if !canImport(UIKit) && canImport(AppKit)
typealias UIView = NSView
typealias UIViewRepresentable = NSViewRepresentable
#endif

// MARK: - HoYoMapWebView

private struct HoYoMapWebView: UIViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: HoYoMapWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: HoYoMapWebView

        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            var jsStr = ""
            jsStr.append("let timer = setInterval(() => {")
            jsStr
                .append(
                    "const bar = document.getElementsByClassName('mhy-bbs-app-header')[0];"
                )
            jsStr
                .append(
                    "const hoyolabBar = document.getElementsByClassName('mhy-hoyolab-app-header')[0];"
                )
            jsStr.append("bar?.parentNode.removeChild(bar);")
            jsStr.append("hoyolabBar?.parentNode.removeChild(hoyolabBar);")
            jsStr.append("}, 300);")
            jsStr
                .append(
                    "setTimeout(() => {clearInterval(timer);timer = null}, 10000);"
                )
            webView.evaluateJavaScript(jsStr)
        }
    }

    @State var region: HoYo.AccountRegion

    @MainActor
    func makeUIView(context: Context) -> OPWebView {
        guard let url = region.hoyoMapURL
        else {
            return OPWebView()
        }
        let request = URLRequest(url: url)

        let webview = OPWebView()
        webview.configuration.userContentController.removeAllUserScripts() // 对提瓦特地图禁用自动 dark mode 支持。
        webview.navigationDelegate = context.coordinator
        Task { webview.load(request) }
        return webview
    }

    @MainActor
    func updateUIView(_ uiView: OPWebView, context: Context) {
        if let url = region.hoyoMapURL {
            let request = URLRequest(url: url)
            Task { uiView.load(request) }
        }
    }

    @MainActor
    func makeNSView(context: Context) -> OPWebView {
        guard let url = region.hoyoMapURL
        else {
            return OPWebView()
        }
        let request = URLRequest(url: url)

        let webview = OPWebView()
        webview.configuration.userContentController.removeAllUserScripts() // 对提瓦特地图禁用自动 dark mode 支持。
        webview.navigationDelegate = context.coordinator
        Task { webview.load(request) }
        return webview
    }

    @MainActor
    func updateNSView(_ nsView: OPWebView, context: Context) {
        if let url = region.hoyoMapURL {
            let request = URLRequest(url: url)
            Task { nsView.load(request) }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
