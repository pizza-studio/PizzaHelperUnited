// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAboutKit
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI

public struct ContentView4iOS14: View {
    // MARK: Lifecycle

    public init() {}

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
            if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) {
                Section {
                    NavigationLink(destination: ProfileManagerPageContent.init) {
                        Label("profileMgr.manage.title".i18nPZHelper, systemSymbol: .personTextRectangleFill)
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
                        Text("refugee.limitedServiceCategory4iOS17.header", bundle: .module)
                            .textCase(.none)
                    } else {
                        Text("refugee.limitedServiceCategory4iOS16.header", bundle: .module)
                            .textCase(.none)
                    }
                } footer: {
                    if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                        Text("refugee.limitedServiceCategory4iOS17.footer", bundle: .module)
                            .textCase(.none)
                    } else {
                        Text("refugee.limitedServiceCategory4iOS16.footer", bundle: .module)
                            .textCase(.none)
                    }
                }
                .fontWidth(.condensed)
                WatchDataPusherButton()
                    .fontWidth(.condensed)
            }
            Section {
                if theVM.localProfileEntriesCount > 0 {
                    HStack {
                        Text("refugee.exportableCount.profiles", bundle: .module)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(verbatim: theVM.localProfileEntriesCount.description)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    }
                }
                if theVM.gachaEntriesCount > 0 {
                    HStack {
                        Text("refugee.exportableCount.gachaEntries", bundle: .module)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(verbatim: theVM.gachaEntriesCount.description)
                            .foregroundColor(.secondary)
                            .padding(.leading)
                    }
                }
                if !hasData {
                    Text("refugee.noDataExportable", bundle: .module)
                        .foregroundColor(.secondary)
                }
            } header: {
                HStack {
                    Text("refugee.exportableCount.header", bundle: .module)
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
                VStack(alignment: .leading, spacing: 20) {
                    Text("refugee.footer.exportInstructions", bundle: .module)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.accentColor)
                    if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                        Text("refugee.footer.whyServiceTerminatedInPublic", bundle: .module)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("refugee.footer.whyServiceTerminatedForOS21", bundle: .module)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .disableFocusable()
        .navigationTitle(Text(verbatim: Pizza.appTitleLocalizedFull))
        .navBarTitleDisplayMode(.large)
        .toolbar {
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
                Text("refugee.liveActivity.tapHereToInitiate", bundle: .module)
            }
        } label: {
            Label {
                Text("refugee.liveActivity.featureLabel", bundle: .module)
            } icon: {
                Image(systemSymbol: .timerSquare)
            }
        }
    }

    // MARK: Private

    @StateObject private var theVM = RefugeeVM4iOS14.shared
    @State private var fileSaveActionResult: Result<URL, any Error>?

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
        theVM.localProfileEntriesCount + theVM.gachaEntriesCount > 0
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
}
