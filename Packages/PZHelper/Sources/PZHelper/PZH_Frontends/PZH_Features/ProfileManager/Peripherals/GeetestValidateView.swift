// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftUI
import WebKit

// MARK: - GeetestValidateCoordinator

@available(iOS 17.0, macCatalyst 17.0, *)
class GeetestValidateCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    // MARK: Lifecycle

    init(_ parent: GeetestValidateView) {
        self.parent = parent
    }

    // MARK: Internal

    var parent: GeetestValidateView

    // Receive message from website
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        if message.name == "callbackHandler" {
            if let messageBody = message.body as? String {
                print("validate: \(messageBody)")
                parent.finishWithValidate(messageBody)
            }
        }
    }
}

#if canImport(AppKit) && !canImport(UIKit)
struct GeetestValidateView: NSViewRepresentable {
    typealias Coordinator = GeetestValidateCoordinator

    let challenge: String
    // swiftlint:disable:next identifier_name
    let gt: String

    let webView = WKWebView()
    @State private var isValidationObtained = false // 标识是否已获取到 validate.value 的内容

    @State var completion: (String) -> Void

    @MainActor
    func makeNSView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        webView.configuration.userContentController.add(context.coordinator, name: "callbackHandler")
        webView.customUserAgent = """
        Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        """
        return webView
    }

    @MainActor
    func updateNSView(_ nsView: WKWebView, context: Context) {
        let url = URL(string: "https://gi.pizzastudio.org/geetest/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "challenge", value: challenge),
            URLQueryItem(name: "gt", value: gt),
        ]
        guard let finalURL = components?.url else {
            return
        }

        var request = URLRequest(url: finalURL)
        request.allHTTPHeaderFields = [
            "Referer": "https://webstatic.mihoyo.com",
        ]

        Task { nsView.load(request) }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func finishWithValidate(_ validate: String) {
        completion(validate)
    }
}

#elseif canImport(UIKit)
@available(iOS 17.0, macCatalyst 17.0, *)
struct GeetestValidateView: UIViewRepresentable {
    typealias Coordinator = GeetestValidateCoordinator

    let challenge: String
    // swiftlint:disable:next identifier_name
    let gt: String

    let webView = WKWebView()
    @State private var isValidationObtained = false // 标识是否已获取到 validate.value 的内容

    @State var completion: (String) -> Void

    @MainActor
    func makeUIView(context: Context) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        webView.configuration.userContentController.add(context.coordinator, name: "callbackHandler")
        webView.customUserAgent = """
        Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        """
        return webView
    }

    @MainActor
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let url = URL(string: "https://gi.pizzastudio.org/geetest/")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.queryItems = [
            URLQueryItem(name: "challenge", value: challenge),
            URLQueryItem(name: "gt", value: gt),
        ]
        guard let finalURL = components?.url else {
            return
        }

        var request = URLRequest(url: finalURL)
        request.allHTTPHeaderFields = [
            "Referer": "https://webstatic.mihoyo.com",
        ]

        Task { uiView.load(request) }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func finishWithValidate(_ validate: String) {
        completion(validate)
    }
}

#endif
