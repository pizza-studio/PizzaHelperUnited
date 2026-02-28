// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZBaseKit
import SafariServices
import SwiftUI
import WebKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(iOS 15.0, macCatalyst 15.0, *)
@MainActor
struct EventDetailWebView {
    // MARK: Lifecycle

    init(banner: String, nameFull: String, content: String) {
        self.banner = banner
        self.nameFull = nameFull
        self.content = content
    }

    // MARK: Internal

    @Environment(\.colorScheme) var colorScheme

    let banner: String
    let nameFull: String
    let content: String
    var articleDic = [
        // 主题颜色：亮色：""，暗色："bg-amberDark-500 text-amberHalfWhite"
        "themeClass": "",
        "banner": "",
        "nameFull": "",
        "description": "",
    ]

    func getArticleDic() -> [String: String] {
        if colorScheme == .dark {
            let articleDic = [
                "themeClass": "bg-amberDark-800 text-amberHalfWhite", // 主题颜色
                "banner": banner,
                "nameFull": nameFull,
                "description": content,
            ]
            return articleDic
        } else {
            let articleDic = [
                "themeClass": "", // 主题颜色
                "banner": banner,
                "nameFull": nameFull,
                "description": content,
            ]
            return articleDic
        }
    }
}

@available(iOS 15.0, macCatalyst 15.0, *)
extension EventDetailWebView {
    class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: EventDetailWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: EventDetailWebView
        /// WKWebView 必須在主線程創建和操作，故在 Coordinator 中懶加載。
        lazy var webView: OPWebView = .init()

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            print("message: \(message.name)")
            switch message.name {
            case "getArticleInfoBeforeLoaded":
                if let articleData = try? JSONSerialization.data(
                    withJSONObject: parent.getArticleDic(),
                    options: JSONSerialization.WritingOptions.prettyPrinted
                ) {
                    let articleInfo = String(
                        data: articleData,
                        encoding: String.Encoding.utf8
                    )

                    let inputJS = "updateArticleInfo(\(articleInfo ?? ""))"
                    print(inputJS)
                    webView.evaluateJavaScript(inputJS)
                }
            case "openURLInSafari":
                if let urlString = message.body as? String,
                   let url = URL(string: urlString) {
                    Self.openURLExternally(url)
                }
            default:
                break
            }
        }

        func makeView() -> OPWebView {
            let ucc = webView.configuration.userContentController
            ucc.add(self, name: "getArticleInfoBeforeLoaded")
            ucc.add(self, name: "openURLInSafari")
            // 注入 JS 腳本，在頁面載入完成後攔截所有連結點擊。
            let userScript = WKUserScript(
                source: Self.linkInterceptJS,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: false
            )
            ucc.addUserScript(userScript)
            webView.navigationDelegate = self
            return webView
        }

        func updateView(_ theWebView: OPWebView) {
            theWebView.uiDelegate = self
            if let startPageURL = Bundle.currentSPM.url(
                forResource: "article",
                withExtension: "html"
            ) {
                webView.loadFileURL(
                    startPageURL,
                    allowingReadAccessTo: Bundle.currentSPM.bundleURL
                )
            }
        }

        // MARK: WKNavigationDelegate

        /// 作為後備方案：若某些連結不經由 JS 層攔截，仍可在此補攔。
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy) -> Void
        ) {
            if let url = navigationAction.request.url,
               let scheme = url.scheme,
               scheme.hasPrefix("http") {
                Self.openURLExternally(url)
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        }

        // MARK: WKUIDelegate

        /// 處理 target="_blank" 等要開新視窗的連結。
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        )
            -> WKWebView? {
            if let url = navigationAction.request.url {
                Self.openURLExternally(url)
            }
            return nil
        }

        // MARK: Private

        /// 注入至 WebView 的 JavaScript。
        /// 1. 提供 `miHoYoGameJSSDK.openInBrowser` stub —— 米哈遊公告中的連結
        ///    使用 `javascript:miHoYoGameJSSDK.openInBrowser('URL', true)` 來開啟外部瀏覽器，
        ///    但該 SDK 物件在 WKWebView 中不存在，故需由我們自行注入。
        /// 2. 對所有 `<a>` 點擊事件做 capture-phase 攔截，處理標準 `http(s)` 連結。
        private static let linkInterceptJS: String = """
        if (!window.miHoYoGameJSSDK) {
            window.miHoYoGameJSSDK = {};
        }
        window.miHoYoGameJSSDK.openInBrowser = function(url) {
            if (url && (typeof url === 'string') && url.indexOf('http') === 0) {
                window.webkit.messageHandlers.openURLInSafari.postMessage(url);
            }
        };
        document.addEventListener('click', function(e) {
            var target = e.target;
            while (target && target.tagName !== 'A') {
                target = target.parentElement;
            }
            if (target && target.href) {
                if (target.href.indexOf('http') === 0) {
                    e.preventDefault();
                    e.stopPropagation();
                    window.webkit.messageHandlers.openURLInSafari.postMessage(target.href);
                }
            }
        }, true);
        """

        private static func openURLExternally(_ url: URL) {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            UIApplication.shared.open(url)
            #endif
        }
    }
}

#if os(macOS)

@available(iOS 15.0, macCatalyst 15.0, *)
extension EventDetailWebView: NSViewRepresentable {
    static func dismantleNSView(_ nsView: OPWebView, coordinator: Coordinator) {
        nsView.removeJSMsgHandler("getArticleInfoBeforeLoaded")
        nsView.removeJSMsgHandler("openURLInSafari")
    }

    func makeNSView(context: Context) -> OPWebView {
        context.coordinator.makeView()
    }

    func updateNSView(_ nsView: OPWebView, context: Context) {
        context.coordinator.updateView(nsView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#elseif os(iOS) || targetEnvironment(macCatalyst)

@available(iOS 15.0, macCatalyst 15.0, *)
extension EventDetailWebView: UIViewRepresentable {
    static func dismantleUIView(_ uiView: OPWebView, coordinator: Coordinator) {
        uiView.removeJSMsgHandler("getArticleInfoBeforeLoaded")
        uiView.removeJSMsgHandler("openURLInSafari")
    }

    func makeUIView(context: Context) -> OPWebView {
        context.coordinator.makeView()
    }

    func updateUIView(_ uiView: OPWebView, context: Context) {
        context.coordinator.updateView(uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#endif
#endif
