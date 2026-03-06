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
        theUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) "
            + "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 "
            + "Safari/604.1"
    } else {
        theUA = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_6 like Mac OS X) "
            + "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.6 Mobile/15E148 "
            + "Safari/604.1"
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
                                .font(.title)
                            Text("profileMgr.accountLogin.instruction".i18nPZHelper)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.caption)
                            Text("profileMgr.accountLogin.instruction.specialWarning".i18nPZHelper)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.orange)
                                .fontWeight(.medium)
                                .font(.caption)
                            let mkdnStrSiwA =
                                "profileMgr.accountLogin.instruction.specialWarning.exceptionallyAllowedMethods"
                                    .i18nPZHelper
                            let attrStrSiwA: AttributedString = {
                                (try? AttributedString(markdown: mkdnStrSiwA))
                                    ?? AttributedString(mkdnStrSiwA)
                            }()
                            Text(attrStrSiwA)
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.red)
                            Text("profileMgr.accountLogin.instruction.passwordInputSafetyExplanation".i18nPZHelper)
                                .multilineTextAlignment(.leading)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
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
        webview.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webview.customUserAgent = httpHeaderFields["User-Agent"]
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
    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler {
        // MARK: Lifecycle

        init(_ parent: CookieGetterWebView) {
            self.parent = parent
        }

        // MARK: Internal

        var parent: CookieGetterWebView

        /// 追蹤 target="_blank" 開啟的子 WKWebView（OAuth 彈窗等）。
        weak var popupWebView: WKWebView?

        /// 用於在 OAuth 回呼時載入回呼 URL 或轉發 postMessage。
        weak var parentWebView: WKWebView?

        /// 用於取消舊的 parent reload 排程，避免重複重載。
        var parentReloadScheduleID: Int = 0

        // MARK: - WKNavigationDelegate

        func webView(
            _ webView: WKWebView,
            didFinish _: WKNavigation!
        ) {
            // 移除 driver-page-overlay（僅父 WebView 需要）。
            if webView !== popupWebView {
                let jsonScript = """
                let timer = setInterval(() => {
                var m = document.getElementById("driver-page-overlay");
                m.parentNode.removeChild(m);
                }, 300);
                setTimeout(() => {clearInterval(timer);timer = null}, 10000);
                """
                webView.evaluateJavaScript(jsonScript)
            }
            // 安全網：若 popup 已載入 HoYoLAB 域的頁面（表示 OAuth callback
            // 已在 popup 中完成），則移除 popup 並 reload 父頁以取得 session cookie。
            if webView === popupWebView,
               let host = webView.url?.host?.lowercased(),
               Self.isOAuthCallbackHost(host) {
                let parentRef = parentWebView
                cleanupPopup()
                scheduleParentReloads(parentRef, reason: "popup finished callback host")
            }
        }

        /// iOS（非 macOS）上不改寫 Apple 授權 URL、不攔截回呼提交。
        /// Apple 的 `web_message` 回呼依賴 popup 中的 window.opener.postMessage，
        /// 實際轉發由 bridge script + WKScriptMessageHandler 處理。
        func webView(
            _ webView: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @MainActor @escaping @Sendable (WKNavigationActionPolicy) -> Void
        ) {
            decisionHandler(.allow)
        }

        // MARK: - WKUIDelegate

        /// 處理 target="_blank" 彈窗（Sign-with-Apple 等 OAuth 流程）。
        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        )
            -> WKWebView? {
            parentWebView = webView
            let bridgeScript = WKUserScript(
                source: Self.oauthBridgeJS,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            configuration.userContentController.addUserScript(bridgeScript)
            configuration.userContentController.removeScriptMessageHandler(forName: Self.bridgeName)
            configuration.userContentController.add(self, name: Self.bridgeName)
            let popup = WKWebView(frame: webView.bounds, configuration: configuration)
            #if os(macOS)
            popup.autoresizingMask = [.width, .height]
            #else
            popup.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            #endif
            popup.navigationDelegate = self
            popup.uiDelegate = self
            popup.customUserAgent = webView.customUserAgent
            webView.addSubview(popup)
            popupWebView = popup
            return popup
        }

        /// 子 WKWebView 呼叫 window.close() 時觸發（OAuth 完成後），移除彈窗。
        func webViewDidClose(_ webView: WKWebView) {
            if webView === popupWebView {
                let parentRef = parentWebView
                cleanupPopup()
                scheduleParentReloads(parentRef, reason: "popup window.close")
            }
        }

        // MARK: - WKScriptMessageHandler

        nonisolated func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            MainActor.assumeIsolated {
                guard message.name == Self.bridgeName,
                      let body = message.body as? [String: Any],
                      let type = body["type"] as? String
                else { return }

                if type == "bridgeState" { return }

                guard type == "postMessage",
                      let payload = body["payload"] as? String,
                      let senderOrigin = body["senderOrigin"] as? String
                else { return }

                let targetOrigin = (body["targetOrigin"] as? String) ?? ""
                let payloadB64 = Data(payload.utf8).base64EncodedString()
                let senderOriginB64 = Data(senderOrigin.utf8).base64EncodedString()
                let targetOriginB64 = Data(targetOrigin.utf8).base64EncodedString()

                let js = """
                (function(){
                    var payloadText = atob('\(payloadB64)');
                    var senderOrigin = atob('\(senderOriginB64)');
                    var targetOrigin = atob('\(targetOriginB64)');
                    var packet = {
                        __pzSIWARelay__: true,
                        payload: payloadText,
                        senderOrigin: senderOrigin,
                        targetOrigin: targetOrigin
                    };
                    try { window.postMessage(packet, '*'); } catch (e) {}
                    for (var i = 0; i < window.frames.length; i++) {
                        try { window.frames[i].postMessage(packet, '*'); } catch (e) {}
                    }
                })();
                """
                parentWebView?.evaluateJavaScript(js)
            }
        }

        // MARK: - View lifecycle

        func makeView() -> OPWebView {
            guard let request = parent.makeURLRequest() else { return OPWebView() }
            let webview = parent.makeViewWithoutLoad()
            let relayScript = WKUserScript(
                source: Self.parentRelayJS,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: false
            )
            webview.configuration.userContentController.addUserScript(relayScript)
            webview.navigationDelegate = self
            webview.uiDelegate = self
            Task { webview.load(request) }
            return webview
        }

        func updateView(_ webview: OPWebView) {
            // SwiftUI may call updateUIView/updateNSView many times during state updates.
            // Re-loading here can reset OAuth callback state and drop login continuity on iOS.
            webview.navigationDelegate = self
            webview.uiDelegate = self
            webview.customUserAgent = parent.httpHeaderFields["User-Agent"]
        }

        func cleanupPopup() {
            guard let popup = popupWebView else { return }
            popup.configuration.userContentController
                .removeScriptMessageHandler(forName: Self.bridgeName)
            popup.removeFromSuperview()
            popupWebView = nil
            parentWebView = nil
        }

        /// 在不同時間點重載 parent，避免慢機上 callback/cookie 落地延遲造成未登入狀態。
        /// 若偵測到疑似已落地的授權 cookies，則停止後續重載。
        func scheduleParentReloads(_ parentRef: WKWebView?, reason: String) {
            guard let parentRef else { return }
            parentReloadScheduleID += 1
            let scheduleID = parentReloadScheduleID
            let probeDelays: [TimeInterval] = [0.8, 1.8, 3.2, 5.2, 8.0]

            for (index, delay) in probeDelays.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self, weak parentRef] in
                    guard let self, let parentRef, parentReloadScheduleID == scheduleID else { return }
                    Task { @MainActor [weak self, weak parentRef] in
                        guard let self, let parentRef, parentReloadScheduleID == scheduleID else { return }
                        let cookieReady = await hasLikelyHoYoAuthCookies()
                        #if DEBUG
                        print(
                            "[SIWA] parent cookie probe=\(index + 1) reason=\(reason) delay=\(delay) ready=\(cookieReady)"
                        )
                        #endif

                        if cookieReady {
                            parentReloadScheduleID += 1
                            #if DEBUG
                            print("[SIWA] auth cookies settled, reload parent once")
                            #endif
                            parentRef.reloadFromOrigin()
                            return
                        }

                        if index == probeDelays.count - 1 {
                            #if DEBUG
                            let cookieNames = await hoyoCookieNameSnapshot()
                            print("[SIWA] final cookie names snapshot=\(cookieNames)")
                            #endif
                            parentReloadScheduleID += 1
                            #if DEBUG
                            print("[SIWA] auth cookies not detected after probes, perform fallback reload")
                            #endif
                            parentRef.reloadFromOrigin()
                        }
                    }
                }
            }
        }

        /// 嘗試判斷 HoYo 授權 cookies 是否已落地。
        func hasLikelyHoYoAuthCookies() async -> Bool {
            let cookies = await parent.dataStore.httpCookieStore.allCookies()
            let names = Set(cookies.map { $0.name.lowercased() })

            // HoYoLab overseas v2 cookies (from real-world capture).
            let hasV2Token = names.contains("ltoken_v2") || names.contains("cookie_token_v2")
            let hasV2UID = names.contains("account_id_v2") || names.contains("ltuid_v2")
            if hasV2Token, hasV2UID { return true }

            // Legacy/other region cookies.
            let hasLegacyToken = names.contains("ltoken") || names.contains("stoken") || names.contains("login_ticket")
            let hasLegacyUID = names.contains("ltuid") || names.contains("stuid") || names.contains("login_uid")
            if hasLegacyToken, hasLegacyUID { return true }

            // Additional overseas fallback cluster.
            let hasAccountCluster = names.contains("account_id_v2") && names.contains("account_mid_v2")
            let hasRegionSignal = names.contains("ma_passport_region") || names.contains("ltmid_v2")
            if hasAccountCluster, hasRegionSignal { return true }

            return false
        }

        /// DEBUG 專用：回傳目前 dataStore 中的 cookie 名稱快照（不含 cookie 值）。
        func hoyoCookieNameSnapshot() async -> [String] {
            let cookies = await parent.dataStore.httpCookieStore.allCookies()
            let names = Set(cookies.map { $0.name.lowercased() })
            return names.sorted()
        }

        // MARK: Private

        private static let bridgeName = "__pzOAuthBridge__"

        /// 在 popup 內 patch window.opener，
        /// 將 Apple SIWA 的 opener.postMessage() 中轉到 native 再轉發給父 WebView。
        private static let oauthBridgeJS: String = """
        (function(){
            if(window.__pzOAuthBridgeInstalled__)return;
            window.__pzOAuthBridgeInstalled__=true;

            function parseRedirectOrigin(){
                try{
                    var params=new URLSearchParams(window.location.search||'');
                    var raw=params.get('redirect_uri');
                    if(!raw)return '';
                    return new URL(decodeURIComponent(raw)).origin||'';
                }catch(e){
                    return '';
                }
            }

            var redirectOrigin=parseRedirectOrigin();
            var fakeOpener={
                closed:false,
                focus:function(){},
                close:function(){},
                location:{
                    href:redirectOrigin,
                    origin:redirectOrigin
                },
                postMessage:function(payload,targetOrigin){
                    try{
                        var rawPayload='';
                        if(typeof payload==='string'){
                            rawPayload=payload;
                        }else{
                            try{
                                rawPayload=JSON.stringify(payload);
                            }catch(e0){
                                rawPayload=String(payload);
                            }
                        }
                        window.webkit.messageHandlers.__pzOAuthBridge__.postMessage({
                            type:'postMessage',
                            payload:rawPayload,
                            senderOrigin:window.location.origin||'',
                            targetOrigin:targetOrigin||''
                        });
                    }catch(e){}
                }
            };

            var patched=false;
            try{
                Object.defineProperty(window,'opener',{
                    configurable:true,
                    enumerable:false,
                    get:function(){return fakeOpener;}
                });
                patched=true;
            }catch(e1){
                try{
                    window.opener=fakeOpener;
                    patched=true;
                }catch(e2){}
            }

            try{
                window.webkit.messageHandlers.__pzOAuthBridge__.postMessage({
                    type:'bridgeState',
                    patched:patched,
                    redirectOrigin:redirectOrigin,
                    locationOrigin:window.location.origin||''
                });
            }catch(e3){}
        })();
        """

        /// 在 parent 與其所有 iframe 中安裝 relay listener，
        /// 將 native 注入的 `__pzSIWARelay__` 封包轉回標準 MessageEvent。
        private static let parentRelayJS: String = """
        (function(){
            if(window.__pzSIWAParentRelayInstalled__)return;
            window.__pzSIWAParentRelayInstalled__=true;

            window.addEventListener('message',function(evt){
                var packet=evt&&evt.data;
                if(!packet||packet.__pzSIWARelay__!==true)return;

                var payloadText=packet.payload||'';
                var senderOrigin=packet.senderOrigin||'';
                // Apple JS SDK expects event.data to be a JSON string and then
                // calls JSON.parse(event.data) internally. Keep it as raw string.
                var data=payloadText;

                window.dispatchEvent(new MessageEvent('message',{
                    data:data,
                    origin:senderOrigin,
                    source:window
                }));
            },false);
        })();
        """

        /// 判斷 host 是否為 HoYoLAB / miHoYo 系的域名（OAuth callback redirect 目標）。
        private static func isOAuthCallbackHost(_ host: String) -> Bool {
            let domains = ["hoyolab.com", "hoyoverse.com", "mihoyo.com", "miyoushe.com"]
            return domains.contains { host == $0 || host.hasSuffix(".\($0)") }
        }
    }
}

#if canImport(AppKit) && !canImport(UIKit)
extension CookieGetterWebView: NSViewRepresentable {
    static func dismantleNSView(_ nsView: OPWebView, coordinator: Coordinator) {
        coordinator.cleanupPopup()
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
        coordinator.cleanupPopup()
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
