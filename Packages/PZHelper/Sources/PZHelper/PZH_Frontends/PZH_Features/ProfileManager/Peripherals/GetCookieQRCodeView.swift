// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - GetCookieQRCodeView

struct GetCookieQRCodeView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State var viewModel = GetCookieQRCodeViewModel.shared
    @Binding var cookie: String
    @Binding var deviceFP: String
    @Binding var deviceID: String

    private var qrWidth: CGFloat {
        #if os(macOS) || targetEnvironment(macCatalyst)
        340
        #else
        280
        #endif
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

    private var shouldShowRetryButton: Bool {
        viewModel.qrCodeAndTicket != nil || viewModel.error != nil
    }

    private func fireAutoCheckScanningConfirmationStatus() async {
        guard !viewModel.scanningConfirmationStatus.isBusy else { return }
        guard let ticket = viewModel.qrCodeAndTicket?.ticket else { return }
        let task = Task { @MainActor [weak viewModel] in
            var counter = 0
            loopTask: while case let .automatically(task) = viewModel?.scanningConfirmationStatus, !task.isCancelled {
                guard let viewModel = viewModel else { break loopTask }
                do {
                    let status = try await HoYo.queryQRCodeStatusForeground(
                        deviceId: viewModel.taskId,
                        ticket: ticket
                    )
                    if let parsedResult = try await status.parsed() {
                        try await parseGameToken(from: parsedResult, dismiss: true)
                        break loopTask
                    }
                    try await Task.sleep(nanoseconds: 3 * 1_000_000_000) // 3sec.
                } catch {
                    if error._code != NSURLErrorNetworkConnectionLost || counter >= 20 {
                        viewModel.error = error
                        counter = 0
                        break loopTask
                    } else {
                        counter += 1
                    }
                }
            }
            viewModel?.scanningConfirmationStatus = .idle
        }
        // 注册任务并保存ID
        viewModel.pollingTaskId = HoYo.registerQRCodePollingTask(task)
        viewModel.scanningConfirmationStatus = .automatically(task)
    }

    private func loginCheckScannedButtonDidPress(ticket: String) async {
        viewModel.cancelAllConfirmationTasks(resetState: false)
        let task = Task { @MainActor in
            do {
                let status = try await HoYo.queryQRCodeStatusForeground(
                    deviceId: viewModel.taskId,
                    ticket: ticket
                )
                if let parsedResult = try await status.parsed() {
                    try await parseGameToken(from: parsedResult, dismiss: true)
                } else {
                    viewModel.isNotScannedAlertShown = true
                }
            } catch {
                viewModel.error = error
            }
            viewModel.scanningConfirmationStatus = .idle
        }
        // 注册任务并保存ID
        viewModel.pollingTaskId = HoYo.registerQRCodePollingTask(task)
        viewModel.scanningConfirmationStatus = .manually(task)
    }

    private func parseGameToken(
        from parsedResult: QueryQRCodeStatus.ParsedResult,
        dismiss shouldDismiss: Bool = true
    ) async throws {
        var cookie = ""
        cookie += "stuid=" + parsedResult.accountId + "; "
        cookie += "stoken=" + parsedResult.stoken + "; "
        cookie += "ltuid=" + parsedResult.accountId + "; "
        cookie += "ltoken=" + parsedResult.ltoken + "; "
        cookie += "mid=" + parsedResult.mid + "; "
        try await extraCookieProcess(cookie: &cookie)
        self.cookie = cookie
        if shouldDismiss {
            presentationMode.wrappedValue.dismiss()
        }
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
                .background(RoundedRectangle(cornerRadius: 8).foregroundColor(.primary.opacity(0.05)))
        }
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    errorView()
                    if let qrCodeAndTicket = viewModel.qrCodeAndTicket, let qrImage = qrImage {
                        qrImageView(qrImage)
                        if case .manually = viewModel.scanningConfirmationStatus {
                            ProgressView()
                        } else {
                            Button("profileMgr.account.qr_code_login.check_scanned".i18nPZHelper) {
                                Task {
                                    await loginCheckScannedButtonDidPress(
                                        ticket: qrCodeAndTicket.ticket
                                    )
                                }
                            }.onAppear {
                                Task {
                                    await fireAutoCheckScanningConfirmationStatus()
                                }
                            }
                        }
                    } else {
                        ProgressView()
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
            .onDisappear {
                // 确保在视图消失时取消所有任务
                viewModel.cancelAllConfirmationTasks(resetState: true)
            }
        }
    }
}

// MARK: - GetCookieQRCodeViewModel

// Credit: Bill Haku for the fix.
@Observable
final class GetCookieQRCodeViewModel: ObservableObject, @unchecked Sendable {
    // MARK: Lifecycle

    init() {
        self.taskId = .init()
        reCreateQRCode()
    }

    deinit {
        scanningConfirmationStatus = .idle
        if let pollingTaskId = pollingTaskId {
            HoYo.cancelQRCodePollingTask(taskId: pollingTaskId)
        }
    }

    // MARK: Public

    public func reCreateQRCode() {
        taskId = .init()
        Task { @MainActor in
            do {
                self.qrCodeAndTicket = try await HoYo.generateLoginQRCode(deviceId: self.taskId)
                self.error = nil
            } catch {
                self.error = error
            }
        }
    }

    // MARK: Internal

    enum ScanningConfirmationStatus: Sendable {
        case manually(Task<Void, Never>)
        case automatically(Task<Void, Never>)
        case idle

        // MARK: Internal

        var isBusy: Bool {
            switch self {
            case .automatically, .manually: true
            case .idle: false
            }
        }
    }

    nonisolated(unsafe) static var shared: GetCookieQRCodeViewModel = .init()

    var qrCodeAndTicket: (qrCode: CGImage, ticket: String)?
    var taskId: UUID
    var scanningConfirmationStatus: ScanningConfirmationStatus = .idle
    var isNotScannedAlertShown: Bool = false
    var pollingTaskId: UUID? // 新增：跟踪注册的轮询任务ID

    var error: Error? {
        didSet {
            if error != nil {
                qrCodeAndTicket = nil
            }
        }
    }

    func cancelAllConfirmationTasks(resetState: Bool) {
        switch scanningConfirmationStatus {
        case let .automatically(task), let .manually(task):
            task.cancel()
            // 确保取消在HoYo中注册的任务
            if let pollingTaskId = pollingTaskId {
                HoYo.cancelQRCodePollingTask(taskId: pollingTaskId)
                self.pollingTaskId = nil
            }
            if resetState {
                scanningConfirmationStatus = .idle
            }
        case .idle: return
        }
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
    public func handleHoYoBackgroundSessions() -> some View {
        modifier(HoYo.HandleBackgroundSessionsModifier())
    }
}

extension View {
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
