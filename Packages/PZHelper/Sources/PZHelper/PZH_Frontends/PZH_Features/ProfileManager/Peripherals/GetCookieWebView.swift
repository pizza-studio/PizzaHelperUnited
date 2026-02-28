// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WebKit

private func getAccountPageLoginURL(region: HoYo.AccountRegion) -> String {
    /// 国际服尽量避免使用 HoYoLab 论坛社区的页面，免得 Apple 审核员工瞎基蔔乱点之后找事。
    switch (region, region.game) {
    case (.miyoushe, _): "https://user.mihoyo.com/#/login/captcha"
    case (.hoyoLab, .genshinImpact): "https://act.hoyolab.com/app/community-game-records-sea/m.html#/ys"
    case (.hoyoLab, .starRail): "https://act.hoyolab.com/app/community-game-records-sea/rpg/m.html#/hsr"
    case (.hoyoLab, .zenlessZone): "https://act.hoyolab.com/app/zzz-game-record/index.html#/zzz"
    }
}

private func getHTTPHeaderFields(region: HoYo.AccountRegion) -> [String: String] {
    let theUA: String
    if #available(iOS 17, macCatalyst 17, *) {
        theUA = """
                    Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) \
                    AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 \
                    Safari/604.1
        """
    } else {
        theUA = """
                    Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) \
                    AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 \
                    Safari/604.1
        """
    }
    return switch region {
    case .miyoushe:
        [
            "Accept": """
            text/html,application/xhtml+xml,application/xml;q=0.9,\
            image/webp,image/apng,*/*;q=0.8,\
            application/signed-exchange;v=b3;q=0.9
            """,
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6",
            "Connection": "keep-alive",
            "Accept-Encoding": "gzip, deflate, br",
            "User-Agent": theUA,
            "cache-control": "max-age=0",
        ]
    case .hoyoLab:
        [
            "accept": """
            text/html,application/xhtml+xml,\
            application/xml;q=0.9,\
            image/webp,image/apng,*/*;q=0.8,\
            application/signed-exchange;v=b3;q=0.9
            """,
            "accept-language": "zh-CN,zh-Hans;q=0.9",
            "accept-encoding": "gzip, deflate, br",
            "User-Agent": theUA,
            "cache-control": "max-age=0",
        ]
    }
}

// MARK: - GetCookieWebView

@available(iOS 16.2, macCatalyst 16.2, *)
struct GetCookieWebView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @Binding var cookie: String

    let region: HoYo.AccountRegion

    var dataStore: WKWebsiteDataStore = .default()

    @State var showAlert: Bool = true

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                CookieGetterWebView(
                    url: getAccountPageLoginURL(region: region),
                    dataStore: dataStore,
                    httpHeaderFields: getHTTPHeaderFields(region: region)
                )
                .autocorrectionDisabled(true)
                #if os(iOS) && !targetEnvironment(macCatalyst)
                    .onReceive(keyboardPublisher) { keyboardComesOut in
                        withAnimation {
                            isKeyboardVisible = keyboardComesOut
                        }
                    }
                #endif
                if !isKeyboardVisible {
                    VStack(alignment: .leading) {
                        Text("profileMgr.accountLogin.instruction".i18nPZHelper)
                            .font(.footnote)
                        Text("profileMgr.accountLogin.instruction.specialWarning".i18nPZHelper)
                            .font(.footnote)
                            .fontWeight(.medium)
                            .foregroundStyle(.orange)
                            .padding(.bottom)
                    }
                    .fontWidth(.condensed)
                    .padding()
                }
            }
            .navigationTitle("profileMgr.accountLogin.pleaseFinish.title".i18nPZHelper)
            .navBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("sys.done".i18nBaseKit) {
                        Task(priority: .userInitiated) {
                            await getCookieFromDataStore()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("sys.cancel".i18nBaseKit) {
                        Task.detached { @MainActor in
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
        .trackCanvasSize { newSize in
            pageWidth = newSize.width
        }
        .overlay {
            renderOverlayAlertInstructions()
        }
    }

    @MainActor
    private func getCookieFromDataStore() async {
        defer { presentationMode.wrappedValue.dismiss() }
        cookie = ""
        let cookies = await dataStore.httpCookieStore.allCookies()

        func getFromCookies(_ fieldName: String) -> String? {
            cookies.first(where: { $0.name == fieldName })?.value
        }

        switch region {
        case .miyoushe:
            let loginTicket = getFromCookies("login_ticket") ?? ""
            let loginUid = getFromCookies("login_uid") ?? ""
            let multiToken = try? await HoYo.getMultiTokenByLoginTicket(
                region: region,
                loginTicket: loginTicket,
                loginUid: loginUid
            )
            if let multiToken = multiToken {
                cookie += "stuid=" + loginUid + "; "
                cookie += "stoken=" + multiToken.stoken + "; "
                cookie += "ltuid=" + loginUid + "; "
                cookie += "ltoken=" + multiToken.ltoken + "; "
            }
        case .hoyoLab:
            cookies.forEach {
                cookie += "\($0.name)=\($0.value); "
            }
        }
    }

    @State private var isKeyboardVisible = false

    @ViewBuilder
    private func renderOverlayAlertInstructions() -> some View {
        if $showAlert.animation().wrappedValue {
            ZStack(alignment: .center) {
                Color.black.opacity(0.5)
                    .blurMaterialBackground()
                Color.clear
                    .frame(minWidth: 320, maxWidth: Swift.max(0.8 * pageWidth, 320))
                    .overlay {
                        VStack(alignment: .center, spacing: 12) {
                            Text("profileMgr.accountLogin.attention.title".i18nPZHelper)
                                .font(.largeTitle)
                            Text("profileMgr.accountLogin.instruction".i18nPZHelper)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("profileMgr.accountLogin.instruction.specialWarning".i18nPZHelper)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.orange)
                                .fontWeight(.medium)
                            Text(
                                "profileMgr.accountLogin.instruction.specialWarning.exceptionallyAllowedMethods"
                                    .i18nPZHelper
                            )
                            .multilineTextAlignment(.leading)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(.secondary)
                            .fontWeight(.medium)
                            Text("profileMgr.accountLogin.instruction.passwordInputSafetyExplanation".i18nPZHelper)
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                                .fontWeight(.medium)
                            Button {
                                Task.detached { @MainActor in
                                    showAlert = false
                                }
                            } label: {
                                Text("sys.affirmative".i18nBaseKit)
                                    .frame(minWidth: 60)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .fontWidth(.condensed)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                        .background {
                            Color.colorSysBackground
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .shadow(radius: 8)
                        }
                    }
            }
            .environment(\.colorScheme, .dark)
        }
    }

    @State private var pageWidth: CGFloat = 320
}

// MARK: - CookieGetterWebView

@MainActor
struct CookieGetterWebView {
    // MARK: Lifecycle

    init(
        url: String,
        cleanCookies: Bool = true,
        dataStore: WKWebsiteDataStore,
        httpHeaderFields: [String: String]
    ) {
        self.url = url
        self.cleanCookies = cleanCookies
        self.dataStore = dataStore
        self.httpHeaderFields = httpHeaderFields
    }

    // MARK: Internal

    func makeURLRequest() -> URLRequest? {
        guard let url = URL(string: url) else { return nil }
        let timeoutInterval: TimeInterval = 10
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: timeoutInterval
        )
        request.allHTTPHeaderFields = httpHeaderFields
        return request
    }

    func makeViewWithoutLoad() -> OPWebView {
        if cleanCookies {
            let typesOfCookies = WKWebsiteDataStore.allWebsiteDataTypes()
            dataStore.removeData(
                ofTypes: typesOfCookies,
                modifiedSince: .distantPast
            ) {}

            // 在非 MainActor 環境中清除系統級 cookies
            Task.detached {
                HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
            }
        }
        let webview = OPWebView()
        webview.configuration.websiteDataStore = dataStore
        return webview
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: Private

    private var url: String = ""
    private let cleanCookies: Bool
    private let dataStore: WKWebsiteDataStore
    private let httpHeaderFields: [String: String]
}

// MARK: CookieGetterWebView.Coordinator

extension CookieGetterWebView {
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        // MARK: Lifecycle

        init(_ parent: CookieGetterWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: CookieGetterWebView

        /// 追蹤 target="_blank" 開啟的子 WKWebView（OAuth 彈窗等）。
        weak var popupWebView: WKWebView?

        func webView(
            _ webView: WKWebView,
            didFinish _: WKNavigation!
        ) {
            let jsonScript = """
            let timer = setInterval(() => {
            var m = document.getElementById("driver-page-overlay");
            m.parentNode.removeChild(m);
            }, 300);
            setTimeout(() => {clearInterval(timer);timer = null}, 10000);
            """
            webView.evaluateJavaScript(jsonScript)
        }

        // MARK: WKUIDelegate

        /// 處理 target="_blank" 彈窗（Sign-with-Apple / Sign-with-Google 等 OAuth 流程）。
        /// 在 App 內建立一個子 WKWebView（共享 processPool），疊加於父 WebView 上方，
        /// 使 OAuth 完成後能正確回傳 session / cookie 至父頁面。
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        )
            -> WKWebView? {
            let popup = WKWebView(frame: webView.bounds, configuration: configuration)
            #if os(macOS)
            popup.autoresizingMask = [.width, .height]
            #else
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            #endif
            popup.uiDelegate = self
            webView.addSubview(popup)
            popupWebView = popup
            return popup
        }

        /// 子 WKWebView 呼叫 window.close() 時觸發（OAuth 完成後），移除彈窗。
        func webViewDidClose(_ webView: WKWebView) {
            if webView === popupWebView {
                webView.removeFromSuperview()
                popupWebView = nil
            }
        }

        func makeView() -> OPWebView {
            guard let request = parent.makeURLRequest() else { return OPWebView() }
            let webview = parent.makeViewWithoutLoad()
            webview.navigationDelegate = self
            webview.uiDelegate = self
            Task { webview.load(request) }
            return webview
        }

        func updateView(_ webview: OPWebView) {
            if let url = URL(string: parent.url) {
                let timeoutInterval: TimeInterval = 10
                var request = URLRequest(
                    url: url,
                    cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                    timeoutInterval: timeoutInterval
                )
                request.httpShouldHandleCookies = false
                request.allHTTPHeaderFields = parent.httpHeaderFields
                print(request.description)
                Task { webview.load(request) }
            }
        }
    }
}

#if canImport(AppKit) && !canImport(UIKit)
extension CookieGetterWebView: NSViewRepresentable {
    static func dismantleNSView(_ nsView: OPWebView, coordinator: Coordinator) {
        coordinator.popupWebView?.removeFromSuperview()
        coordinator.popupWebView = nil
    }

    func makeNSView(context: Context) -> OPWebView {
        context.coordinator.makeView()
    }

    func updateNSView(_ nsView: OPWebView, context: Context) {
        context.coordinator.updateView(nsView)
    }
}

#elseif canImport(UIKit)
@available(iOS 16.2, macCatalyst 16.2, *)
extension CookieGetterWebView: UIViewRepresentable {
    static func dismantleUIView(_ uiView: OPWebView, coordinator: Coordinator) {
        coordinator.popupWebView?.removeFromSuperview()
        coordinator.popupWebView = nil
    }

    func makeUIView(context: Context) -> OPWebView {
        context.coordinator.makeView()
    }

    func updateUIView(_ uiView: OPWebView, context: Context) {
        context.coordinator.updateView(uiView)
    }
}
#endif

#if os(iOS) && !targetEnvironment(macCatalyst)
@available(iOS 16.2, macCatalyst 16.2, *)
extension GetCookieWebView: KeyboardReadable {}
#endif
