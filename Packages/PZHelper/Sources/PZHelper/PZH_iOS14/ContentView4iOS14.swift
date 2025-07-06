// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SFSafeSymbols
import SwiftUI

public struct ContentView4iOS14: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        let msgPack = fileSaveActionResultMessagePack
        NavigationView {
            List {
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
                        Text("refugee.footer.whyServiceTerminatedForOS21", bundle: .module)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationTitle(Text("app.appName.full", bundle: .module))
            .navBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if theVM.taskState == .busy {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
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
            .onChange(of: isExportResultAvailable.wrappedValue) { _ in
                theVM.forceStopTheTask()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: Private

    @StateObject private var theVM = RefugeeVM4iOS14.shared
    @State private var fileSaveActionResult: Result<URL, any Error>?

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
                "refugee.export.succeededInSavingToFile".i18nRefugee,
                "refugee.export.fileSavedTo:".i18nRefugee + "\n\n\(url)"
            )
        case let .failure(message):
            ("refugee.export.failedInSavingToFile".i18nRefugee, "⚠︎ \(message)")
        case nil: ("", "")
        }
    }
}
