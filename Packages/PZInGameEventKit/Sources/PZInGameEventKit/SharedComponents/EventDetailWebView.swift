// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZBaseKit
import SafariServices
import SwiftUI
import WebKit

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

    let webView = OPWebView()
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
    class Coordinator: NSObject, WKScriptMessageHandler, WKUIDelegate {
        // MARK: Lifecycle

        init(_ parent: EventDetailWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: EventDetailWebView

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
                    parent.webView.evaluateJavaScript(inputJS)
                }
            default:
                break
            }
        }

        func makeView() -> OPWebView {
            parent.webView.configuration.userContentController.add(
                self,
                name: "getArticleInfoBeforeLoaded"
            )
            return parent.webView
        }

        func updateView(_ webView: OPWebView) {
            webView.uiDelegate = self
            if let startPageURL = Bundle.module.url(
                forResource: "article",
                withExtension: "html"
            ) {
                webView.loadFileURL(
                    startPageURL,
                    allowingReadAccessTo: Bundle.module.bundleURL
                )
            }
        }
    }
}

#if os(macOS)

@available(iOS 15.0, macCatalyst 15.0, *)
extension EventDetailWebView: NSViewRepresentable {
    static func dismantleNSView(_ nsView: OPWebView, coordinator: Coordinator) {
        nsView.removeJSMsgHandler("getArticleInfoBeforeLoaded")
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
