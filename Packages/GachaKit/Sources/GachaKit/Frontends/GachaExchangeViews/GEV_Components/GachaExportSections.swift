// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import MultiPicker
import SFSafeSymbols
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

public struct GachaExportSections: View {
    // MARK: Public

    @MainActor public var body: some View {
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
                VStack {
                    Button {
                        theVM.updateGMDB(for: [game])
                    } label: {
                        Text("gachaKit.export.clickHereToUpdateGMDB".i18nGachaKit)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(8)
                            .background {
                                RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                            }
                            .foregroundStyle(.red)
                    }
                    Text("gachaKit.export.gmdbExpired.explanation".i18nGachaKit)
                        .font(.footnote).foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else if theVM.taskState != .busy {
                Button {
                    theVM.prepareGachaDocumentForExport(
                        packaging: packageMethod,
                        format: exportFormat,
                        lang: documentLanguage
                    )
                } label: {
                    Text("gachaKit.export.clickHereToExport".i18nGachaKit)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                        }
                }
                .apply { exporterButton in
                    hookAlertAndComDlg32(target: exporterButton)
                }
            } else {
                ProgressView()
            }
        } header: {
            HStack {
                Text("gachaKit.export.currentExportOption".i18nGachaKit)
                Spacer()
                Text(packageMethod.localizedName)
            }
            .textCase(.none)
        } footer: {
            Text("gachaKit.uigf.affLink.[UIGF](https://uigf.org/)", bundle: .module)
        }
        .onChange(of: specifiedOwners, initial: true) {
            packageMethod = .init(
                owners: Array(
                    specifiedOwners.sorted {
                        $0.uidWithGame < $1.uidWithGame
                    }
                )
            )
        }
        .onChange(of: packageMethod) { _, newValue in
            switch newValue {
            case .singleOwner where specifiedOwners.first?.game == .starRail: break
            default: exportFormat = .asUIGFv4
            }
        }

        Section {
            // Do NOT animate this. Animating this doesn't make any sense.
            MultiPicker("".description, selection: $specifiedOwners) {
                let nameIDMap = theVM.nameIDMap
                let sortedGPIDs = sortedGPIDs
                ForEach(sortedGPIDs) { gpid in
                    drawGPID(gpid, nameIDMap: nameIDMap, isChosen: specifiedOwners.contains(gpid))
                        .mpTag(gpid)
                }
            }
            .labelsHidden()
        } header: {
            Text("gachaKit.export.chooseOwners.prompt".i18nGachaKit)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .mpPickerStyle(.inline)
        .selectionIndicatorPosition(.trailing)
    }

    // MARK: Internal

    @MainActor @ViewBuilder
    func drawGPID(_ gpid: GachaProfileID, nameIDMap: [String: String], isChosen: Bool) -> some View {
        HStack {
            gpid.photoView.frame(width: 35, height: 35)
            HStack {
                Group {
                    if let name = nameIDMap[gpid.uidWithGame] {
                        VStack(alignment: .leading) {
                            Text(name)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(gpid.uidWithGame)
                                .font(.caption2)
                                .fontDesign(.monospaced)
                                .opacity(0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        Text(gpid.uidWithGame)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .foregroundStyle(isChosen ? Color.accentColor : .primary)
                Spacer()
            }
        }.padding(.vertical, 4)
    }

    @MainActor @ViewBuilder
    func makeFormatPicker() -> some View {
        let formatsToEnumerate: [GachaExchange.ExportableFormat] = switch packageMethod {
        case let .singleOwner(gpid): packageMethod.supportedExportableFormats(by: gpid.game)
        default:
            if pzGachaProfileIDs.count == 1, specifiedOwners.randomElement()?.game == .starRail {
                packageMethod.supportedExportableFormats(by: .starRail)
            } else {
                [.asUIGFv4]
            }
        }
        LabeledContent {
            Picker("gachaKit.exchange.currentFileFormat".i18nGachaKit, selection: $exportFormat) {
                ForEach(formatsToEnumerate) { enumeratedFormat in
                    Text(verbatim: enumeratedFormat.name).tag(enumeratedFormat)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .fixedSize()
            .disabled(formatsToEnumerate.count == 1)
        } label: {
            Text("gachaKit.exchange.currentFileFormat".i18nGachaKit)
        }
    }

    // MARK: Fileprivate

    @Query fileprivate var pzGachaProfileIDs: [PZGachaProfileMO]
    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM
    @State fileprivate var packageMethod: GachaExchange.ExportPackageMethod = .allOwners
    @State fileprivate var specifiedOwners: Set<GachaProfileID> = []
    @State fileprivate var exportFormat: GachaExchange.ExportableFormat = .asUIGFv4
    @State fileprivate var documentLanguage: GachaLanguage = .current
    @State fileprivate var fileSaveActionResult: Result<URL, any Error>?

    fileprivate var sortedGPIDs: [GachaProfileID] {
        pzGachaProfileIDs.map(\.asSendable).sorted { $0.uidWithGame < $1.uidWithGame }
    }

    var isComDlg32Visible: Binding<Bool> {
        .init(get: { theVM.currentExportableDocument != nil }, set: { _ in })
    }

    var isExportResultAvailable: Binding<Bool> {
        .init(get: { fileSaveActionResult != nil }, set: { _ in })
    }

    var fileSaveActionResultMessagePack: (title: String, message: String) {
        return switch fileSaveActionResult {
        case let .success(url):
            (
                "gachaKit.export.succeededInSavingToFile".i18nGachaKit,
                "gachaKit.export.fileSavedTo:".i18nGachaKit + "\n\n\(url)"
            )
        case let .failure(message):
            ("gachaKit.export.failedInSavingToFile".i18nGachaKit, "⚠︎ \(message)")
        case nil: ("", "")
        }
    }

    @MainActor @ViewBuilder
    func hookAlertAndComDlg32(target: some View) -> some View {
        let msgPack = fileSaveActionResultMessagePack
        target
            .fileExporter(
                isPresented: isComDlg32Visible,
                document: theVM.currentExportableDocument,
                contentType: .json,
                defaultFilename: theVM.currentExportableDocument?.fileNameStem
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
    }
}
