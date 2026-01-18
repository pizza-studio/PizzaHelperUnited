// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAboutKit
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI

/// 业务逻辑：
/// iOS 16.1 为止的系统：仅允许导出资料。
/// iOS 16.2 开始的 iOS 16 系统：允许导出资料、使用小工具、体力通知、Apple Watch。
/// iOS 17+：仅允许导出资料，但该画面允许关闭。用户关闭该画面之后可继续照常使用 App，只是所有功能全部放弃维护。
public struct ContentView4iOS14: View {
    // MARK: Lifecycle

    public init() {
        self.snoozeAction = {}
    }

    public init(snoozeAction: (() -> Void)?) {
        self.snoozeAction = snoozeAction
    }

    // MARK: Public

    public var body: some View {
        if #available(iOS 16.2, *) {
            NavigationStack {
                contentsInsideNavigationContainer
            }
        } else {
            NavigationView {
                contentsInsideNavigationContainer
            }
            #if !canImport(AppKit)
            .navigationViewStyle(StackNavigationViewStyle())
            #endif
        }
    }

    // MARK: Internal

    @ViewBuilder var contentsInsideNavigationContainer: some View {
        let msgPack = fileSaveActionResultMessagePack
        List {
            if let theError = theVM.currentError {
                Section {
                    Text(verbatim: "\(theError) ||| \(theError.localizedDescription)")
                }
            }
            if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                Text("refugee.crossAppMigrationNotice.headerText", bundle: .currentSPM)
                    .font(.body)
                    .bold()
                    .foregroundStyle(.red)
            } else if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) {
                renderAvailableFeaturesAtThisPage()
            }
            Section {
                if theVM.localProfileEntriesCount > 0 {
                    HStack {
                        Text("refugee.exportableCount.profiles", bundle: .currentSPM)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(verbatim: theVM.localProfileEntriesCount.description)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    }
                }
                if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                    if theVM.gachaEntriesCountModern > 0 {
                        HStack {
                            Text("refugee.exportableCount.gachaEntries", bundle: .currentSPM)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(verbatim: theVM.gachaEntriesCountModern.description)
                                .foregroundColor(.secondary)
                                .padding(.leading)
                        }
                    }
                }
                if theVM.gachaEntriesCount > 0 {
                    HStack {
                        Text("refugee.exportableCount.gachaEntries4GI", bundle: .currentSPM)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(verbatim: theVM.gachaEntriesCount.description)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    }
                }
                if !hasData {
                    if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                        Text("refugee.noDataExportable.refugeeMigratingToLatteHelper", bundle: .currentSPM)
                            .foregroundColor(.secondary)
                    } else {
                        Text("refugee.noDataExportable.iOS16AndEarlier", bundle: .currentSPM)
                            .foregroundColor(.secondary)
                    }
                }
            } header: {
                HStack {
                    Text("refugee.exportableCount.header", bundle: .currentSPM)
                        .multilineTextAlignment(.leading)
                        .textCase(.none)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Button {
                        theVM.startCountingDataEntriesTask(forced: true)
                    } label: {
                        Image(systemSymbol: .arrowClockwiseCircle)
                    }
                    .disabled(theVM.taskState == .busy)
                }
                .frame(maxWidth: .infinity)
            } footer: {
                renderBottomFooterContents()
            }
        }
        .disableFocusable()
        .navigationTitle(navTitle)
        .navBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                if let snoozeAction {
                    Button {
                        snoozeAction()
                    } label: {
                        Text("pzHelper.refugeeSheet.dismiss", bundle: .currentSPM)
                    }
                    .disabled(theVM.taskState == .busy)
                }
            }
            ToolbarItem(placement: .primaryAction) {
                if theVM.taskState == .busy {
                    ProgressView()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    theVM.startDocumentationPreparationTask(forced: false)
                } label: {
                    Image(systemSymbol: .squareAndArrowUp)
                }
                .disabled(theVM.taskState == .busy)
            }
        }
        .fileExporter(
            isPresented: theVM.isExportDialogVisible,
            document: theVM.currentExportableDocument,
            contentType: .propertyList,
            defaultFilename: "PizzaHelper4Genshin_RefugeeMigrationData"
        ) { result in
            fileSaveActionResult = result
            theVM.currentExportableDocument = nil
        }
        .alert(isPresented: isExportResultAvailable) {
            Alert(
                title: Text(msgPack.title),
                message: Text(msgPack.message),
                dismissButton: Alert.Button.default(Text(verbatim: "✔︎")) {
                    fileSaveActionResult = nil
                    theVM.forceStopTheTask()
                }
            )
        }
        .react(to: isExportResultAvailable.wrappedValue) {
            theVM.forceStopTheTask()
        }
    }

    @available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
    @ViewBuilder
    func drawLiveActivityCallerRow() -> some View {
        LabeledContent {
            Menu {
                ForEach(pzProfilesSorted, id: \.uuid) { profile in
                    Button(profile.asTinyMenuLabelText()) {
                        theVM.fireTask(
                            givenTask: {
                                let dailyNote = try await profile.getDailyNote(cached: true)
                                try await StaminaLiveActivityController.shared.createResinRecoveryTimerActivity(
                                    for: profile,
                                    data: dailyNote
                                )
                            }
                        )
                    }
                }
            } label: {
                Text("refugee.liveActivity.tapHereToInitiate", bundle: .currentSPM)
            }
        } label: {
            Label {
                Text("refugee.liveActivity.featureLabel", bundle: .currentSPM)
            } icon: {
                Image(systemSymbol: .timerSquare)
            }
        }
    }

    @available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *)
    @ViewBuilder
    func renderAvailableFeaturesAtThisPage() -> some View {
        Section {
            NavigationLink(destination: ProfileManagerPageContent.init) {
                Label(
                    "profileMgr.manage.title".i18nPZHelper,
                    systemSymbol: .personTextRectangleFill
                )
            }
            NavigationLink(destination: NotificationSettingsPageContent.init) {
                Label(NotificationSettingsPageContent.navTitle, systemSymbol: .bellBadge)
            }
            LiveActivitySettingNavigator()
            if !pzProfilesMap.isEmpty {
                drawLiveActivityCallerRow()
            }
            AppLanguageSwitcher()
            NavigationLink(
                destination: AboutView.init,
                label: {
                    Label {
                        Text(verbatim: AboutView.navTitle)
                    } icon: {
                        AboutView.navIcon
                    }
                }
            )
        } header: {
            if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                Text("refugee.limitedServiceCategory4iOS17.header", bundle: .currentSPM)
                    .textCase(.none)
            } else {
                Text("refugee.limitedServiceCategory4iOS16.header", bundle: .currentSPM)
                    .textCase(.none)
            }
        } footer: {
            if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                Text("refugee.limitedServiceCategory4iOS17.footer", bundle: .currentSPM)
                    .textCase(.none)
            } else {
                Text("refugee.limitedServiceCategory4iOS16.footer", bundle: .currentSPM)
                    .textCase(.none)
            }
        }
        .fontWidth(.condensed)
        WatchDataPusherButton()
            .fontWidth(.condensed)
    }

    @ViewBuilder
    func renderBottomFooterContents() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("refugee.footer.exportInstructions", bundle: .currentSPM)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.accentColor)
            if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                Text("refugee.footer.whyServiceTerminatedInPublic", bundle: .currentSPM)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                let linkTitle = String(localized: "refugee.link.getTheLatteHelper", bundle: .currentSPM)
                let latteAppURLStr = Pizza.AppStoreURL.asLatteHelper.rawValue
                let rawMarkdown = "**[\(linkTitle)](\(latteAppURLStr))**"
                if let attrStr = try? AttributedString(markdown: rawMarkdown) {
                    Text(attrStr)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if let latteAppURL = URL(string: latteAppURLStr) {
                    Link(destination: latteAppURL) {
                        Text("refugee.link.getTheLatteHelper", bundle: .currentSPM)
                            .bold()
                    }
                }
            } else {
                Text("refugee.footer.whyServiceTerminatedForOS21", bundle: .currentSPM)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: Private

    @StateObject private var theVM = RefugeeVM4iOS14.shared
    @State private var fileSaveActionResult: Result<URL, any Error>?

    private let snoozeAction: (() -> Void)?

    @Default(.pzProfiles) private var pzProfilesMap: [String: PZProfileSendable]

    private var pzProfilesSorted: [PZProfileSendable] {
        Array(pzProfilesMap.values.sorted { $0.priority < $1.priority })
    }

    private var isOS23OrNewer: Bool {
        if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) { return true }
        return false
    }

    private var isExportResultAvailable: Binding<Bool> {
        .init(get: { fileSaveActionResult != nil }, set: { _ in })
    }

    private var hasData: Bool {
        theVM.localProfileEntriesCount + theVM.gachaEntriesCount + theVM.gachaEntriesCountModern > 0
    }

    private var fileSaveActionResultMessagePack: (title: String, message: String) {
        switch fileSaveActionResult {
        case let .success(url):
            (
                "refugee.export.succeededInSavingToFile".i18nPZHelper,
                "refugee.export.fileSavedTo:".i18nPZHelper + "\n\n\(url)"
            )
        case let .failure(message):
            ("refugee.export.failedInSavingToFile".i18nPZHelper, "⚠︎ \(message)")
        case nil: ("", "")
        }
    }

    private var navTitle: Text {
        if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
            Text("refugee.navTitle.noticingEndOfMaintenance", bundle: .currentSPM)
        } else {
            Text(verbatim: Pizza.appTitleLocalizedFull)
        }
    }
}
