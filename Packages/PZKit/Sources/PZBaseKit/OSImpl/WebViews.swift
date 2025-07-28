// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

//  封装了使用WKWebView的各种网页

#if !os(watchOS)

import SafariServices
import SwiftUI
import WebKit

// MARK: - WebBrowserView

public struct WebBrowserView: View {
    // MARK: Lifecycle

    public init(url: String) {
        self.url = url
    }

    // MARK: Public

    public typealias Body = Never

    public var url: String = ""

    public func makeView() -> OPWebView {
        guard let url = URL(string: url)
        else {
            return OPWebView()
        }
        let request = URLRequest(url: url)
        let webview = OPWebView()
        Task { webview.load(request) }
        return webview
    }

    public func updateView(_ webView: WKWebView) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            Task { webView.load(request) }
        }
    }
}

#if os(macOS)
extension WebBrowserView: NSViewRepresentable {
    @MainActor
    public func makeNSView(context: Context) -> WKWebView {
        makeView()
    }

    @MainActor
    public func updateNSView(_ nsView: WKWebView, context: Context) {
        updateView(uiView)
    }
}

#elseif os(iOS) || targetEnvironment(macCatalyst)
extension WebBrowserView: UIViewRepresentable {
    @MainActor
    public func makeUIView(context: Context) -> WKWebView {
        makeView()
    }

    @MainActor
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        updateView(uiView)
    }
}
#endif

// MARK: - OPWebView

public final class OPWebView: WKWebView {
    // MARK: Lifecycle

    override public init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: Self.makeMobileConfig())
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: Public

    public func removeJSMsgHandler(_ name: String) {
        configuration.userContentController.removeScriptMessageHandler(forName: name)
    }

    // MARK: Internal

    static let jsForDarkmodeAwareness: String = {
        let cssString = """
        @media (prefers-color-scheme: dark) {
          body {
            background: #333; color: white;
          }
          :root {
              --active-file-bg-color: #fff3f0;
              --active-file-border-color: #f22f27;
              --active-file-text-color: #d0ccc6;
              --control-text-color: #777777;
              --primary-color: #f22f27;
              --select-text-bg-color: #faa295;
              --side-bar-bg-color: #ffffff;
              --mid-1: #e8e6e3;
              --mid-2: #fafafa;
              --mid-3: #f5f5f5;
              --mid-4: #f0f0f0;
              --mid-5: #d9d9d9;
              --mid-6: #bfbfbf;
              --mid-7: #9f978b;
              --mid-8: #b0a99f;
              --mid-9: #beb8b0;
              --mid-10: #d0ccc6;
              --mid-11: #1f1f1f;
              --mid-12: #141414;
              --mid-13: #000000;
              --main-1: #fff3f0;
              --main-2: #ffd4cc;
              --main-3: #ffafa3;
              --main-4: #ff7e6f;
              --main-5: #ff5e53;
              --main-6: #f33f38;
              --main-7: #eb4242;
              --main-8: #a60a0f;
              --main-9: #80010a;
              --main-10: #590009;
              --main-11: #fff143;
          }
        }
        """
        let cssStringCleaned = cssString.replacingOccurrences(of: "\n", with: "")
        var jsString = "var style = document.createElement('style');"
        jsString.append(" style.innerHTML = '\(cssStringCleaned)';")
        jsString.append(" document.head.appendChild(style);")
        return jsString
    }()

    static func makeMobileConfig() -> WKWebViewConfiguration {
        let userScript = WKUserScript(
            source: OPWebView.jsForDarkmodeAwareness,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        let userContentController = WKUserContentController()
        userContentController.addUserScript(userScript)

        let result = WKWebViewConfiguration()
        let pagePref = WKWebpagePreferences()
        let viewPref = WKPreferences()
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 14.5, *) {
            viewPref.isTextInteractionEnabled = true
        }
        #elseif os(iOS)
        if #available(iOS 14.5, *) {
            viewPref.isTextInteractionEnabled = true
        }
        #endif
        // 防止 iPad 用户受困于登入网页所显示的荧幕旋转提示。
        pagePref.preferredContentMode = .mobile
        result.defaultWebpagePreferences = pagePref
        result.preferences = viewPref
        result.userContentController = userContentController
        return result
    }
}

#endif
