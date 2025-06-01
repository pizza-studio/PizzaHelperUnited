// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ProfileBackupRestoreMenu

struct ProfileBackupRestoreMenu<T: View>: View {
    // MARK: Lifecycle

    public init(importCompletionHandler: @escaping (Result<URL, any Error>) -> Void, extraItem: (() -> T)? = nil) {
        self.importCompletionHandler = importCompletionHandler
        self.extraItem = extraItem
    }

    // MARK: Public

    @ViewBuilder public var body: some View {
        @Bindable var theVM = theVM
        let msgPack = theVM.fileSaveActionResultMessagePack
        Menu {
            Button {
                theVM.currentExportableDocument = Result.success(.init(prepareAllExportableProfiles()))
            } label: {
                Label("profileMgr.exchange.export.menuTitle".i18nPZHelper, systemSymbol: .squareAndArrowUpOnSquare)
            }
            Divider()
            Button {
                theVM.isImporterVisible = true
            } label: {
                Label("profileMgr.exchange.import.menuTitle".i18nPZHelper, systemSymbol: .squareAndArrowDownOnSquare)
            }
            if let extraItem {
                Divider()
                extraItem()
            }
        } label: {
            Image(systemSymbol: .externaldriveFillBadgePersonCrop)
        }
        .apply { coreContent in
            coreContent
                .fileImporter(
                    isPresented: $theVM.isImporterVisible,
                    allowedContentTypes: [.json]
                ) { result in
                    importCompletionHandler(result)
                }
                .fileExporter(
                    isPresented: theVM.isExporterVisible,
                    document: theVM.getCurrentExportableDocument(),
                    contentType: .json,
                    defaultFilename: theVM.defaultFileName
                ) { result in
                    theVM.fileSaveActionResult = result
                    theVM.currentExportableDocument = nil
                }
                .alert(
                    msgPack.title,
                    isPresented: theVM.isExportResultAvailable,
                    actions: {
                        Button("sys.ok".i18nBaseKit) {
                            theVM.fileSaveActionResult = nil
                        }
                    },
                    message: {
                        Text(verbatim: msgPack.message)
                    }
                )
        }
        .onDisappear {
            theVM.currentExportableDocument = nil
        }
    }

    // MARK: Private

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]
    @StateObject private var theVM = Coordinator()

    private let importCompletionHandler: (Result<URL, any Error>) -> Void
    private let extraItem: (() -> T)?
}

extension ProfileBackupRestoreMenu {
    private func prepareAllExportableProfiles() -> [PZProfileSendable] {
        profiles.map(\.asSendable)
    }
}

// MARK: ProfileBackupRestoreMenu.Coordinator

extension ProfileBackupRestoreMenu {
    @Observable
    private final class Coordinator: TaskManagedVM {
        var fileSaveActionResult: Result<URL, any Error>?
        var currentExportableDocument: Result<PZProfilesDocument, Error>?
        var isImporterVisible: Bool = false

        var fileSaveActionResultMessagePack: (title: String, message: String) {
            switch fileSaveActionResult {
            case let .success(url):
                (
                    "profileMgr.exchange.export.succeededInSavingToFile".i18nPZHelper,
                    "profileMgr.exchange.export.fileSavedTo:".i18nPZHelper + "\n\n\(url)"
                )
            case let .failure(message):
                ("profileMgr.exchange.export.failedInSavingToFile".i18nPZHelper, "⚠︎ \(message)")
            case nil: ("", "")
            }
        }

        var isExporterVisible: Binding<Bool> {
            .init(get: {
                switch self.currentExportableDocument {
                case .success: true
                case .failure, .none: false
                }
            }, set: { result in
                if !result {
                    self.currentExportableDocument = nil
                }
            })
        }

        var isExportResultAvailable: Binding<Bool> {
            .init(get: { self.fileSaveActionResult != nil }, set: { _ in })
        }

        var defaultFileName: String? {
            switch currentExportableDocument {
            case let .success(document): document.fileNameStem
            case .failure, .none: nil
            }
        }

        func getCurrentExportableDocument() -> PZProfilesDocument? {
            switch currentExportableDocument {
            case let .success(document): document
            case .failure, .none: nil
            }
        }
    }
}

// MARK: - PZProfilesDocument

private struct PZProfilesDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        let theModel = try JSONDecoder().decode(FileType.self, from: configuration.file.regularFileContents!)
        self.model = theModel
    }

    public init(_ fileObj: FileType) {
        self.model = fileObj
    }

    // MARK: Public

    public typealias FileType = [PZProfileSendable]

    public static let readableContentTypes: [UTType] = [.json]

    public let model: [PZProfileSendable]

    public let fileNameStem: String = "PZProfiles_\(dateFormatter.string(from: Date()))"

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(model)
        return FileWrapper(regularFileWithContents: data)
    }

    // MARK: Private

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        return dateFormatter
    }()
}
