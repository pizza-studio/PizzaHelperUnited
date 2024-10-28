// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import MultiPicker
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

public struct GachaExportSections: View {
    // MARK: Public

    public var body: some View {
        Section {
            makeFormatPicker()
            VStack {
                Picker("gachaKit.gachaLanguage".i18nGachaKit, selection: $documentLanguage) {
                    ForEach(GachaLanguage.allCasesSorted) { enumeratedLang in
                        Text(verbatim: enumeratedLang.localized).tag(enumeratedLang)
                    }
                }.frame(maxWidth: .infinity)
                Text("gachaKit.gachaLanguage.languageSupported.explanation".i18nGachaKit)
                    .font(.footnote).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            if case let .databaseExpired(game) = theVM.currentError as? GachaMeta.GMDBError {
                GachaEntryExpiredRow(alwaysVisible: true, games: [game])
            } else if theVM.taskState != .busy {
                switch theVM.currentExportableDocument {
                case let .failure(error):
                    Text(verbatim: "\(error)")
                        .font(.caption2)
                case .none, .success:
                    Button {
                        theVM.prepareGachaDocumentForExport(
                            packaging: packageMethod,
                            format: exportFormat,
                            lang: documentLanguage
                        )
                    } label: {
                        Text("gachaKit.exchange.export.clickHereToExport".i18nGachaKit)
                            .fontWeight(.bold)
                            .fontWidth(.condensed)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                            }
                    }
                }
            } else {
                InfiniteProgressBar().id(UUID())
            }
        } header: {
            HStack {
                Text("gachaKit.exchange.export.currentExportOption".i18nGachaKit)
                Spacer()
                Text(packageMethod.localizedName)
            }
            .textCase(.none)
        } footer: {
            VStack(alignment: .leading, spacing: 11) {
                Text("gachaKit.uigf.affLink.[UIGF](https://uigf.org/)", bundle: .module)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("gachaKit.export.share.warnings.doNotShareToPublicCollectors", bundle: .module)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.multilineTextAlignment(.leading)
        }
        .apply { exporterButton in
            hookAlertAndComDlg32(target: exporterButton)
        }
        .onChange(of: specifiedProfiles, initial: true) {
            packageMethod = .init(
                owners: Array(
                    specifiedProfiles.sorted {
                        $0.uidWithGame < $1.uidWithGame
                    }
                )
            )
        }
        .onChange(of: packageMethod) { _, newValue in
            switch newValue {
            case .singleOwner where specifiedProfiles.first?.game == .starRail: break
            default: exportFormat = .asUIGFv4
            }
        }

        Section {
            // Do NOT animate this. Animating this doesn't make any sense.
            MultiPicker("".description, selection: $specifiedProfiles) {
                let nameIDMap = theVM.nameIDMap
                let sortedGPIDs = theVM.allGPIDs.wrappedValue
                ForEach(sortedGPIDs) { gpid in
                    GachaExchangeView.drawGPID(
                        gpid,
                        nameIDMap: nameIDMap,
                        isChosen: specifiedProfiles.contains(gpid)
                    ).mpTag(gpid)
                }
            }
            .labelsHidden()
        } header: {
            Text("gachaKit.exchange.chooseProfiles.export.prompt".i18nGachaKit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .textCase(.none)
        }
        .mpPickerStyle(.inline)
        .selectionIndicatorPosition(.trailing)
    }

    // MARK: Internal

    @ViewBuilder
    func makeFormatPicker() -> some View {
        let formatsToEnumerate: [GachaExchange.ExportableFormat] = switch packageMethod {
        case let .singleOwner(gpid): packageMethod.supportedExportableFormats(by: gpid.game)
        default:
            if theVM.allGPIDs.wrappedValue.count == 1,
               specifiedProfiles.randomElement()?.game == .starRail {
                packageMethod.supportedExportableFormats(by: .starRail)
            } else {
                [.asUIGFv4]
            }
        }
        LabeledContent {
            Picker("gachaKit.exchange.fileFormat".i18nGachaKit, selection: $exportFormat) {
                ForEach(formatsToEnumerate) { enumeratedFormat in
                    Text(verbatim: enumeratedFormat.name).tag(enumeratedFormat)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .fixedSize()
            .disabled(formatsToEnumerate.count == 1)
        } label: {
            Text("gachaKit.exchange.fileFormat".i18nGachaKit)
        }
    }

    // MARK: Fileprivate

    @Environment(GachaVM.self) fileprivate var theVM
    @State fileprivate var packageMethod: GachaExchange.ExportPackageMethod = .allOwners
    @State fileprivate var specifiedProfiles: Set<GachaProfileID> = []
    @State fileprivate var exportFormat: GachaExchange.ExportableFormat = .asUIGFv4
    @State fileprivate var documentLanguage: GachaLanguage = .current
    @State fileprivate var fileSaveActionResult: Result<URL, any Error>?

    var isComDlg32Visible: Binding<Bool> {
        .init(get: {
            switch theVM.currentExportableDocument {
            case .success: true
            case .failure, .none: false
            }
        }, set: { result in
            if !result {
                theVM.currentExportableDocument = nil
            }
        })
    }

    var defaultFileName: String? {
        switch theVM.currentExportableDocument {
        case let .success(document): document.fileNameStem
        case .failure, .none: nil
        }
    }

    var currentExportableDocument: GachaDocument? {
        switch theVM.currentExportableDocument {
        case let .success(document): document
        case .failure, .none: nil
        }
    }

    var isExportResultAvailable: Binding<Bool> {
        .init(get: { fileSaveActionResult != nil }, set: { _ in })
    }

    var fileSaveActionResultMessagePack: (title: String, message: String) {
        switch fileSaveActionResult {
        case let .success(url):
            (
                "gachaKit.exchange.export.succeededInSavingToFile".i18nGachaKit,
                "gachaKit.exchange.export.fileSavedTo:".i18nGachaKit + "\n\n\(url)"
            )
        case let .failure(message):
            ("gachaKit.exchange.export.failedInSavingToFile".i18nGachaKit, "⚠︎ \(message)")
        case nil: ("", "")
        }
    }

    @ViewBuilder
    func hookAlertAndComDlg32(target: some View) -> some View {
        let msgPack = fileSaveActionResultMessagePack
        target
            .fileExporter(
                isPresented: isComDlg32Visible,
                document: currentExportableDocument,
                contentType: .json,
                defaultFilename: defaultFileName
            ) { result in
                fileSaveActionResult = result
                theVM.currentExportableDocument = nil
            }
            .alert(
                msgPack.title,
                isPresented: isExportResultAvailable,
                actions: {
                    Button("sys.ok".i18nBaseKit) {
                        fileSaveActionResult = nil
                    }
                },
                message: {
                    Text(verbatim: msgPack.message)
                }
            )
            .onChange(of: isExportResultAvailable) {
                theVM.forceStopTheTask()
            }
    }
}
