// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import SwiftUI
import WebKit

// MARK: - GeetestValidateCoordinator

class GeetestValidateCoordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
    // MARK: Lifecycle

    init(_ parent: GeetestValidateView) {
        self.parent = parent
    }

    // MARK: Internal

    nonisolated static var geetestURL: URL? {
        Bundle.currentSPM.url(forResource: "geetest", withExtension: "html")
    }

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

    func makeView(_ webView: WKWebView) -> WKWebView {
        webView.navigationDelegate = self
        webView.configuration.userContentController.removeAllScriptMessageHandlers()
        webView.configuration.userContentController.add(self, name: "callbackHandler")
        webView.customUserAgent = """
        Mozilla/5.0 (iPhone; CPU iPhone OS 16_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148
        """
        return webView
    }

    func updateView(_ webView: WKWebView, challenge: String, gt: String) {
        guard let url = Self.geetestURL else { return }
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

        Task { webView.load(request) }
    }
}

// MARK: - GeetestValidateView

struct GeetestValidateView: View {
    typealias Body = Never
    typealias Coordinator = GeetestValidateCoordinator

    let challenge: String
    // swiftlint:disable:next identifier_name
    let gt: String

    let webView = WKWebView()
    // @State private var isValidationObtained = false // 标识是否已获取到 validate.value 的内容

    @State var completion: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func finishWithValidate(_ validate: String) {
        completion(validate)
    }
}

#if canImport(AppKit) && !canImport(UIKit)
extension GeetestValidateView: NSViewRepresentable {
    @MainActor
    func makeNSView(context: Context) -> WKWebView {
        context.coordinator.makeView(webView)
    }

    @MainActor
    func updateNSView(_ nsView: WKWebView, context: Context) {
        context.coordinator.updateView(nsView, challenge: challenge, gt: gt)
    }
}

#elseif canImport(UIKit)
@available(iOS 16.2, macCatalyst 16.2, *)
extension GeetestValidateView: UIViewRepresentable {
    @MainActor
    func makeUIView(context: Context) -> WKWebView {
        context.coordinator.makeView(webView)
    }

    @MainActor
    func updateUIView(_ uiView: WKWebView, context: Context) {
        context.coordinator.updateView(uiView, challenge: challenge, gt: gt)
    }
}

#endif
