// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SFSafeSymbols
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct GachaExportToolbarButton: View {
    // MARK: Lifecycle

    public init?(gpid: GachaProfileID?) {
        guard let gpid else { return nil }
        self.specifiedProfile = gpid
        self.packageMethod = .singleOwner(gpid)
    }

    // MARK: Public

    public var body: some View {
        let msgPack = fileSaveActionResultMessagePack
        Menu {
            Menu {
                ForEach(GachaLanguage.allCasesSorted) { enumeratedLang in
                    Button(enumeratedLang.localized) {
                        theVM.prepareGachaDocumentForExport(
                            packaging: packageMethod,
                            format: .asUIGFv4,
                            lang: enumeratedLang
                        )
                    }
                }
            } label: {
                Text(verbatim: "UIGFv4.0")
            }
            if specifiedProfile.game == .starRail {
                Menu {
                    ForEach(GachaLanguage.allCasesSorted) { enumeratedLang in
                        Button(enumeratedLang.localized) {
                            theVM.prepareGachaDocumentForExport(
                                packaging: packageMethod,
                                format: .asSRGFv1,
                                lang: enumeratedLang
                            )
                        }
                    }
                } label: {
                    Text(verbatim: "SRGFv1")
                }
            }
        } label: {
            Image(systemSymbol: .squareAndArrowUpOnSquare)
        }.apply { coreContent in
            coreContent
                .disabled(theVM.taskState == .busy)
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
                            theVM.forceStopTheTask()
                        }
                    },
                    message: {
                        Text(verbatim: msgPack.message)
                    }
                )
                .onChange(of: isExportResultAvailable.wrappedValue) {
                    theVM.forceStopTheTask()
                }
        }
        .onDisappear {
            theVM.currentExportableDocument = nil
        }
    }

    // MARK: Internal

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

    // MARK: Private

    @State private var fileSaveActionResult: Result<URL, any Error>?
    @Environment(GachaVM.self) private var theVM

    private let specifiedProfile: GachaProfileID
    private let packageMethod: GachaExchange.ExportPackageMethod
}
