// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZBaseKit
import SafariServices
import SwiftUI
import WebKit

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
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

#if os(macOS)

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
extension EventDetailWebView: NSViewRepresentable {
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
    }

    static func dismantleNSView(_ nsView: OPWebView, coordinator: Coordinator) {
        nsView.configuration.userContentController
            .removeScriptMessageHandler(forName: "getArticleInfoBeforeLoaded")
    }

    func makeNSView(context: Context) -> OPWebView {
        webView.configuration.userContentController.add(
            makeCoordinator(),
            name: "getArticleInfoBeforeLoaded"
        )
        return webView
    }

    func updateNSView(_ nsView: OPWebView, context: Context) {
        nsView.uiDelegate = context.coordinator
        if let startPageURL = Bundle.module.url(
            forResource: "article",
            withExtension: "html"
        ) {
            nsView.loadFileURL(
                startPageURL,
                allowingReadAccessTo: Bundle.module.bundleURL
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#elseif os(iOS) || targetEnvironment(macCatalyst)

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
extension EventDetailWebView: UIViewRepresentable {
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
    }

    static func dismantleUIView(_ uiView: OPWebView, coordinator: Coordinator) {
        uiView.configuration.userContentController
            .removeScriptMessageHandler(forName: "getArticleInfoBeforeLoaded")
    }

    func makeUIView(context: Context) -> OPWebView {
        webView.configuration.userContentController.add(
            makeCoordinator(),
            name: "getArticleInfoBeforeLoaded"
        )
        return webView
    }

    func updateUIView(_ uiView: OPWebView, context: Context) {
        uiView.uiDelegate = context.coordinator
        if let startPageURL = Bundle.module.url(
            forResource: "article",
            withExtension: "html"
        ) {
            uiView.loadFileURL(
                startPageURL,
                allowingReadAccessTo: Bundle.module.bundleURL
            )
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#endif
#endif
