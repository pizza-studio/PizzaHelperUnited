// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - GetCookieQRCodeView

@available(iOS 17.0, macCatalyst 17.0, *)
struct GetCookieQRCodeView: View {
    // MARK: Lifecycle

    init(game: Pizza.SupportedGame, cookie: Binding<String>, deviceFP: Binding<String>, deviceID: Binding<String>) {
        self.game = game
        self._cookie = cookie
        self._deviceFP = deviceFP
        self._deviceID = deviceID
    }

    // MARK: Public

    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    errorView()
                    if viewModel.qrCodeAndTicket != nil, let qrImage = qrImage {
                        qrImageView(qrImage)
                        if viewModel.isCheckingScannedStatusManually {
                            WinUI3ProgressRing()
                        } else {
                            Button("profileMgr.account.qr_code_login.check_scanned".i18nPZHelper) {
                                viewModel.checkScannedStatusManually()
                            }
                        }
                    } else {
                        WinUI3ProgressRing()
                    }
                    if shouldShowRetryButton {
                        Button("profileMgr.account.qr_code_login.regenerate_qrcode".i18nPZHelper) {
                            simpleTaptic(type: .light)
                            viewModel.reCreateQRCode()
                        }
                    }
                    if Self.isMiyousheInstalled {
                        Link(destination: URL(string: Self.miyousheHeader + "me")!) {
                            Text("profileMgr.account.qr_code_login.open_miyoushe".i18nPZHelper)
                        }
                    } else {
                        Link(destination: URL(string: Self.miyousheStorePage)!) {
                            Text("profileMgr.account.qr_code_login.open_miyoushe_mas_page".i18nPZHelper)
                        }
                    }
                } footer: {
                    Text("profileMgr.account.qr_code_login.footer".i18nPZHelper)
                }
            }
            .formStyle(.grouped).disableFocusable()
            .alert(
                "profileMgr.account.qr_code_login.not_scanned_alert".i18nPZHelper,
                isPresented: $viewModel.isNotScannedAlertShown
            ) {
                Button("sys.done".i18nBaseKit) {
                    viewModel.isNotScannedAlertShown.toggle()
                }
            }
            .navigationTitle("profileMgr.account.qr_code_login.title".i18nPZHelper)
            .navBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("sys.cancel".i18nBaseKit) {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                viewModel.onQRCodeConfirmed = { parsedResult in
                    try await parseGameToken(game: game, from: parsedResult, dismiss: true)
                }
                viewModel.onAppear()
            }
            .onDisappear {
                // 确保在视图消失时取消所有任务
                viewModel.onDisappear()
            }
        }
    }

    // MARK: Internal

    @State var viewModel = GetCookieQRCodeViewModel.shared
    @Binding var cookie: String
    @Binding var deviceFP: String
    @Binding var deviceID: String

    let game: Pizza.SupportedGame

    // MARK: Private

    private static var isMiyousheInstalled: Bool {
        #if !canImport(UIKit)
        false
        #else
        UIApplication.shared.canOpenURL(URL(string: miyousheHeader)!)
        #endif
    }

    private static var miyousheHeader: String { "mihoyobbs://" }

    private static var miyousheStorePage: String {
        "https://apps.apple.com/cn/app/id1470182559"
    }

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    private var qrWidth: CGFloat {
        OS.type == .macOS ? 340 : 280
    }

    private var qrImage: Image? {
        guard let qrCodeAndTicket = viewModel.qrCodeAndTicket else { return nil }
        let newSize = CGSize(width: qrWidth, height: qrWidth)
        guard let imgResized = qrCodeAndTicket.qrCode.directResized(
            size: newSize,
            quality: .none
        ) else { return nil } // 应该不会出现这种情况。
        return Image(decorative: imgResized, scale: 1)
    }

    private var shouldShowRetryButton: Bool {
        viewModel.qrCodeAndTicket != nil || viewModel.error != nil
    }

    @ViewBuilder
    private func errorView() -> some View {
        if let error = viewModel.error {
            Label {
                Text(error.localizedDescription)
            } icon: {
                Image(systemSymbol: .exclamationmarkCircle)
                    .foregroundStyle(.red)
            }.onAppear {
                viewModel.qrCodeAndTicket = nil
            }
        }
    }

    @ViewBuilder
    private func qrImageView(_ image: Image) -> some View {
        HStack(alignment: .center) {
            Spacer()
            ShareLink(
                item: image,
                preview: SharePreview(
                    "profileMgr.account.qr_code_login.shared_qr_code_title".i18nPZHelper,
                    image: image
                )
            ) {
                image
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: qrWidth, height: qrWidth + 12, alignment: .top)
                    .padding()
            }
            Spacer()
        }
        .overlay(alignment: .bottom) {
            Text("profileMgr.account.qr_code_login.click_qr_to_save".i18nPZHelper).font(.footnote)
                .padding(4)
                .background(Capsule().foregroundTint(.primary.opacity(0.05)))
        }
    }

    private func parseGameToken(
        game: Pizza.SupportedGame,
        from parsedResult: QueryQRCodeStatus.ParsedResult,
        dismiss shouldDismiss: Bool = true
    ) async throws {
        var cookie = ""
        cookie += "stuid=" + parsedResult.accountId + "; "
        cookie += "stoken=" + parsedResult.stoken + "; "
        cookie += "ltuid=" + parsedResult.accountId + "; "
        cookie += "ltoken=" + parsedResult.ltoken + "; "
        cookie += "mid=" + parsedResult.mid + "; "
        // 新版 passport API 需透过 getCookieAccountInfoBySToken 获取 cookie_token
        let stokenCookie = "stuid=\(parsedResult.accountId); stoken=\(parsedResult.stoken); mid=\(parsedResult.mid)"
        let cookieTokenResult = try await HoYo.cookieToken(
            game: game,
            cookie: stokenCookie
        )
        cookie += "cookie_token=" + cookieTokenResult.cookieToken + "; "
        cookie += "account_id=" + cookieTokenResult.uid + "; "
        try await extraCookieProcess(cookie: &cookie)
        self.cookie = cookie
        if shouldDismiss {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - GetCookieQRCodeViewModel

// Credit: Bill Haku for the fix.
@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
final class GetCookieQRCodeViewModel {
    // MARK: Lifecycle

    init() {
        self.taskId = .init()
    }

    // MARK: Public

    public func onAppear() {
        if let ticket = qrCodeAndTicket?.ticket, error == nil {
            // 恢复前台：沿用现有 QR 码继续轮询，避免更换 ticket 导致米游社扫码结果作废。
            // 轮询若已在进行，则沿用现有轮询任务，不打断其可能正在完成的登入流程。
            if pollingTask == nil {
                startAutoPolling(ticket: ticket)
            }
        } else {
            taskId = .init()
            reCreateQRCode()
        }
    }

    public func onDisappear() {
        cancelAllConfirmationTasks()
    }

    public func reCreateQRCode() {
        taskId = .init()
        cancelAllConfirmationTasks()
        Task { @MainActor in
            do {
                self.qrCodeAndTicket = try await HoYo.generateLoginQRCode(deviceId: self.taskId)
                self.error = nil
                guard let ticket = self.qrCodeAndTicket?.ticket else { return }
                startAutoPolling(ticket: ticket)
            } catch {
                self.error = error
            }
        }
    }

    /// 对应「已扫描，请检查」按钮。
    ///
    /// 这里刻意不再取消既有的轮询任务：该任务随时可能在完成登入（换取 cookie_token 与装置指纹），
    /// 一旦将其取消，原本会成功的登入就会失败、且该轮询自此不再恢复。手动检查只负责立刻多查一次；
    /// 无论结果是什么，轮询都会照旧持续到登入完成或 QR 码失效为止。
    public func checkScannedStatusManually() {
        guard let ticket = qrCodeAndTicket?.ticket else { return }
        // 同一个按钮的重复触发，沿用手上这一份检查就够了。
        guard manualCheckTask == nil else { return }
        // 轮询任务若已不在（例如刚经历过一次错误），则重新建立它。
        if pollingTask == nil {
            startAutoPolling(ticket: ticket)
        }
        isCheckingScannedStatusManually = true
        let token = UUID()
        let task = Task { @MainActor [weak self] in
            defer {
                if self?.manualCheckTask?.token == token {
                    self?.manualCheckTask = nil
                    self?.isCheckingScannedStatusManually = false
                }
            }
            guard let self else { return }
            do {
                let status = try await fetchQRCodeStatusOnce(deviceId: taskId, ticket: ticket)
                if let parsedResult = try await status.parsed() {
                    do {
                        try await fireLogin(with: parsedResult)
                    } catch {
                        // 登入失败要立刻让使用者看到，否则这边只会留下一个无声的进度圈。
                        if !Task.isCancelled { self.error = error }
                    }
                } else if case .unscanned = status {
                    // 米游社那边还没扫到这个 QR 码，给使用者一个明确的提示。
                    isNotScannedAlertShown = true
                }
                // 其余情况（已扫描但尚未在米游社确认）继续等待即可，轮询会接手。
            } catch {
                // 查询阶段的暂时性失败不该让整个 QR 码流程报废；持续性的错误由轮询任务负责回报。
            }
        }
        manualCheckTask = (token: token, task: task)
    }

    // MARK: Internal

    static var shared: GetCookieQRCodeViewModel = .init()

    var qrCodeAndTicket: (qrCode: CGImage, ticket: String)?
    var taskId: UUID
    var isCheckingScannedStatusManually: Bool = false
    var isNotScannedAlertShown: Bool = false
    var pollingTaskId: UUID? // 新增：跟踪注册的轮询任务ID

    @ObservationIgnored var onQRCodeConfirmed: ((QueryQRCodeStatus.ParsedResult) async throws -> Void)?

    var error: Error? {
        didSet {
            if error != nil {
                qrCodeAndTicket = nil
            }
        }
    }

    func cancelAllConfirmationTasks() {
        ongoingStatusQuery?.task.cancel()
        ongoingStatusQuery = nil
        manualCheckTask?.task.cancel()
        manualCheckTask = nil
        loginTask?.cancel()
        loginTask = nil
        pollingTask?.task.cancel()
        pollingTask = nil
        isCheckingScannedStatusManually = false
        // `lastStatusQueryStart` 刻意不在此时清掉：即便换了 ticket，
        // 两次真正送出的查询仍要维持最小间隔，免得刚重开流程就立刻再查一次。
        if let pollingTaskId {
            HoYo.cancelQRCodePollingTask(taskId: pollingTaskId)
            self.pollingTaskId = nil
        }
    }

    // MARK: Private

    /// 同一张 ticket 上两次状态查询之间的最小间隔。手动检查若来得太密，就在这里补足时间差，
    /// 免得米游社伺服器把过密的轮询当成异常流量而直接回错。
    private static let minStatusQueryInterval: Duration = .seconds(1)

    /// 轮询与手动检查的任务都带 token 标记归属，避免收尾中的旧任务盖掉新任务的状态。
    private var pollingTask: (token: UUID, task: Task<Void, Never>)?
    private var manualCheckTask: (token: UUID, task: Task<Void, Never>)?
    private var loginTask: Task<Void, Error>?
    private var ongoingStatusQuery: (token: UUID, task: Task<QueryQRCodeStatus, Error>)?

    private let clock = ContinuousClock()

    /// 最近一次状态查询的起算时刻。
    private var lastStatusQueryStart: ContinuousClock.Instant?

    private func startAutoPolling(ticket: String) {
        cancelAllConfirmationTasks()
        let token = UUID()
        let task = Task { @MainActor [weak self] in
            defer {
                if self?.pollingTask?.token == token {
                    self?.pollingTask = nil
                    if let pollingTaskId = self?.pollingTaskId {
                        HoYo.cancelQRCodePollingTask(taskId: pollingTaskId)
                        self?.pollingTaskId = nil
                    }
                }
            }
            var counter = 0
            loopTask: while !Task.isCancelled {
                guard let self else { break loopTask }
                do {
                    let status = try await fetchQRCodeStatusOnce(deviceId: taskId, ticket: ticket)
                    if let parsedResult = try await status.parsed() {
                        try await fireLogin(with: parsedResult)
                        break loopTask
                    }
                    counter = 0
                } catch {
                    if Task.isCancelled || error is CancellationError { break loopTask }
                    if error._code != NSURLErrorNetworkConnectionLost || counter >= 20 {
                        self.error = error
                        counter = 0
                        break loopTask
                    } else {
                        counter += 1
                    }
                }
                try? await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3sec.
            }
        }
        pollingTask = (token: token, task: task)
        pollingTaskId = HoYo.registerQRCodePollingTask(task)
    }

    /// 同一个 ticket 的状态查询只会实际送出一份：自动轮询与手动检查共用同一份结果，
    /// 且两次查询之间保证最小间隔，避免手动检查让轮询频率变得过密。
    private func fetchQRCodeStatusOnce(deviceId: UUID, ticket: String) async throws -> QueryQRCodeStatus {
        if let ongoingStatusQuery { return try await ongoingStatusQuery.task.value }
        try await waitForMinimumStatusQueryInterval()
        // 等待期间可能已经有别的查询上路（例如轮询刚好轮到），直接沿用它的结果。
        if let ongoingStatusQuery { return try await ongoingStatusQuery.task.value }
        lastStatusQueryStart = clock.now
        let token = UUID()
        let task = Task { try await HoYo.queryQRCodeStatusForeground(deviceId: deviceId, ticket: ticket) }
        ongoingStatusQuery = (token: token, task: task)
        defer {
            if ongoingStatusQuery?.token == token {
                ongoingStatusQuery = nil
            }
        }
        return try await task.value
    }

    /// 补足与上一次状态查询之间的最小间隔。
    private func waitForMinimumStatusQueryInterval() async throws {
        guard let lastStatusQueryStart else { return }
        let remaining = Self.minStatusQueryInterval - (clock.now - lastStatusQueryStart)
        guard remaining > .zero else { return }
        try await Task.sleep(for: remaining)
    }

    /// 登入流程同样只会跑一份：无论自动轮询或手动检查先看到 `Confirmed`，都只会真的登入一次。
    /// 这份任务会保留到流程重新开始为止，以免稍后的轮询又触发第二次登入。
    private func fireLogin(with parsedResult: QueryQRCodeStatus.ParsedResult) async throws {
        if let loginTask {
            try await loginTask.value
            return
        }
        guard onQRCodeConfirmed != nil else { return }
        let task = Task { @MainActor [weak self] in
            guard let self else { return }
            try await onQRCodeConfirmed?(parsedResult)
        }
        loginTask = task
        try await task.value
    }
}

// MARK: - HoYo.HandleBackgroundSessionsModifier

extension HoYo {
    /// 用于在 SwiftUI App 生命周期中处理背景 URL Session 事件的修饰器
    public struct HandleBackgroundSessionsModifier: ViewModifier {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public func body(content: Content) -> some View {
            content
                .onBackgroundURLSessionEvents { identifier, completionHandler in
                    HoYo.handleBackgroundSessionEvents(identifier: identifier, completionHandler: completionHandler)
                }
        }
    }
}

extension View {
    /// 添加处理 HoYo 背景 URL Session 事件的能力
    @ViewBuilder
    public func handleHoYoBackgroundSessions() -> some View {
        modifier(HoYo.HandleBackgroundSessionsModifier())
    }
}

extension View {
    @ViewBuilder
    fileprivate func onBackgroundURLSessionEvents(
        perform action: @Sendable @escaping (String, @escaping () -> Void) -> Void
    )
        -> some View {
        background(BackgroundURLSessionHandler(handler: action))
    }
}

#if os(macOS) && !targetEnvironment(macCatalyst)
private typealias UIViewRepresentable = NSViewRepresentable
private typealias UIView = NSView

extension BackgroundURLSessionHandler {
    func makeNSView(context: Context) -> NSView {
        makeUIView(context: context)
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif

// MARK: - BackgroundURLSessionHandler

private struct BackgroundURLSessionHandler: UIViewRepresentable {
    final class Coordinator: NSObject, URLSessionDelegate {
        // MARK: Lifecycle

        init(handler: @Sendable @escaping (String, @escaping () -> Void) -> Void) {
            self.handler = handler
            super.init()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleBackgroundSessionEvent(_:)),
                name: Notification.Name("BackgroundURLSessionEvent"),
                object: nil
            )
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        // MARK: Internal

        let handler: @Sendable (String, @Sendable @escaping () -> Void) -> Void

        @objc
        func handleBackgroundSessionEvent(_ notification: Notification) {
            guard let userInfo = notification.userInfo,
                  let identifier = userInfo["identifier"] as? String,
                  let completionHandler = userInfo["completionHandler"] as? @Sendable () -> Void else {
                return
            }
            handler(identifier, completionHandler)
        }
    }

    let handler: @Sendable (String, @escaping () -> Void) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isHidden = true
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 更新不需要做任何事
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(handler: handler)
    }
}

// 为了支持在 SwiftUI 中捕获背景 session 事件
extension HoYo {
    /// 在 SceneDelegate 或其他地方接收到背景 URL Session 事件时调用此方法
    public static func postBackgroundSessionEventNotification(
        identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        NotificationCenter.default.post(
            name: Notification.Name("BackgroundURLSessionEvent"),
            object: nil,
            userInfo: [
                "identifier": identifier,
                "completionHandler": completionHandler,
            ]
        )
    }
}
