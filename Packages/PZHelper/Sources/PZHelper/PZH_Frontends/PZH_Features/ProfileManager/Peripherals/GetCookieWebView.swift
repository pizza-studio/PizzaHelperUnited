// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SafariServices
import SwiftUI
import WebKit

@available(iOS 17.0, macCatalyst 17.0, *)
private func getAccountPageLoginURL(region: HoYo.AccountRegion) -> String {
    /// 国际服尽量避免使用 HoYoLab 论坛社区的页面，免得 Apple 审核员工瞎基蔔乱点之后找事。
    switch (region, region.game) {
    case (.miyoushe, _): "https://user.mihoyo.com/#/login/captcha"
    case (.hoyoLab, .genshinImpact): "https://act.hoyolab.com/app/community-game-records-sea/m.html#/ys"
    case (.hoyoLab, .starRail): "https://act.hoyolab.com/app/community-game-records-sea/rpg/m.html#/hsr"
    case (.hoyoLab, .zenlessZone): "https://act.hoyolab.com/app/zzz-game-record/index.html#/zzz"
    }
}

// MARK: - GetCookieWebView

@available(iOS 17.0, macCatalyst 17.0, *)
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
                    .padding()
                }
            }
            .navigationTitle("profileMgr.accountLogin.pleaseFinish.title".i18nPZHelper)
            .navBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
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
                    .frame(minWidth: 400, maxWidth: 0.8 * pageWidth)
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

    @State private var screenVM: ScreenVM = .shared

    private var pageWidth: CGFloat {
        screenVM.mainColumnCanvasSizeObserved.width
    }
}

// MARK: - CookieGetterWebView

#if canImport(AppKit) && !canImport(UIKit)
struct CookieGetterWebView: NSViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: CookieGetterWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: CookieGetterWebView

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
    }

    var url: String = ""
    let dataStore: WKWebsiteDataStore
    let httpHeaderFields: [String: String]

    @MainActor
    func makeNSView(context: Context) -> OPWebView {
        guard let url = URL(string: url)
        else {
            return OPWebView()
        }
        dataStore
            .fetchDataRecords(
                ofTypes: WKWebsiteDataStore
                    .allWebsiteDataTypes()
            ) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default()
                        .removeData(
                            ofTypes: record.dataTypes,
                            for: [record],
                            completionHandler: {}
                        )
                    #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                    #endif
                }
            }
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let timeoutInterval: TimeInterval = 10
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: timeoutInterval
        )
        request.allHTTPHeaderFields = httpHeaderFields
        let webview = OPWebView()
        webview.configuration.websiteDataStore = dataStore
        webview.navigationDelegate = context.coordinator
        Task { webview.load(request) }
        return webview
    }

    @MainActor
    func updateNSView(_ nsView: OPWebView, context _: Context) {
        if let url = URL(string: url) {
            let timeoutInterval: TimeInterval = 10
            var request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: timeoutInterval
            )
            request.httpShouldHandleCookies = false
            request.allHTTPHeaderFields = httpHeaderFields
            print(request.description)
            Task { nsView.load(request) }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

#elseif canImport(UIKit)
@available(iOS 17.0, macCatalyst 17.0, *)
struct CookieGetterWebView: UIViewRepresentable {
    final class Coordinator: NSObject, WKNavigationDelegate {
        // MARK: Lifecycle

        init(_ parent: CookieGetterWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: CookieGetterWebView

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
    }

    var url: String = ""
    let dataStore: WKWebsiteDataStore
    let httpHeaderFields: [String: String]

    @MainActor
    func makeUIView(context: Context) -> OPWebView {
        guard let url = URL(string: url)
        else {
            return OPWebView()
        }
        dataStore
            .fetchDataRecords(
                ofTypes: WKWebsiteDataStore
                    .allWebsiteDataTypes()
            ) { records in
                records.forEach { record in
                    WKWebsiteDataStore.default()
                        .removeData(
                            ofTypes: record.dataTypes,
                            for: [record],
                            completionHandler: {}
                        )
                    #if DEBUG
                    print("WKWebsiteDataStore record deleted:", record)
                    #endif
                }
            }
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        let timeoutInterval: TimeInterval = 10
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: timeoutInterval
        )
        request.allHTTPHeaderFields = httpHeaderFields
        let webview = OPWebView()
        webview.configuration.websiteDataStore = dataStore
        webview.navigationDelegate = context.coordinator
        Task { webview.load(request) }
        return webview
    }

    @MainActor
    func updateUIView(_ uiView: OPWebView, context _: Context) {
        if let url = URL(string: url) {
            let timeoutInterval: TimeInterval = 10
            var request = URLRequest(
                url: url,
                cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                timeoutInterval: timeoutInterval
            )
            request.httpShouldHandleCookies = false
            request.allHTTPHeaderFields = httpHeaderFields
            print(request.description)
            Task { uiView.load(request) }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
#endif

@available(iOS 17.0, macCatalyst 17.0, *)
private func getHTTPHeaderFields(region: HoYo.AccountRegion) -> [String: String] {
    switch region {
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
            "User-Agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 \
            Safari/604.1
            """,
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
            "user-agent": """
            Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) \
            AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 \
            Safari/604.1
            """,
            "cache-control": "max-age=0",
        ]
    }
}

#if os(iOS) && !targetEnvironment(macCatalyst)
import Combine
import UIKit

/// Publisher to read keyboard changes.
@available(iOS 17.0, macCatalyst 17.0, *)
private protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension KeyboardReadable {
    fileprivate var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension GetCookieWebView: KeyboardReadable {}

#endif
