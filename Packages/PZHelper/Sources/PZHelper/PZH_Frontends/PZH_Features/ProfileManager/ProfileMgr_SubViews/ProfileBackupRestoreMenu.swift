// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import UniformTypeIdentifiers

// MARK: - ProfileBackupRestoreMenu

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
struct ProfileBackupRestoreMenu<T: View>: View {
    // MARK: Lifecycle

    public init(importCompletionHandler: @escaping (Result<URL, any Error>) -> Void, extraItem: (() -> T)? = nil) {
        self.importCompletionHandler = importCompletionHandler
        self.extraItem = extraItem
    }

    // MARK: Public

    @ViewBuilder public var body: some View {
        @Bindable var vm4ProfileExchange = vm4ProfileExchange
        let msgPack = vm4ProfileExchange.fileSaveActionResultMessagePack
        Menu {
            Button {
                vm4ProfileExchange.currentExportableDocument = Result.success(
                    .init(vm4ProfileMgmt.profiles)
                )
            } label: {
                Label(
                    "profileMgr.exchange.export.menuTitle".i18nPZHelper,
                    systemSymbol: .squareAndArrowUpOnSquare
                )
            }
            .disabled(vm4ProfileMgmt.profiles.isEmpty)
            Divider()
            Button {
                vm4ProfileExchange.isImporterVisible = true
            } label: {
                Label(
                    "profileMgr.exchange.import.menuTitle".i18nPZHelper,
                    systemSymbol: .squareAndArrowDownOnSquare
                )
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
                    isPresented: $vm4ProfileExchange.isImporterVisible,
                    allowedContentTypes: [.json, .propertyList]
                ) { result in
                    importCompletionHandler(result)
                }
                .fileExporter(
                    isPresented: vm4ProfileExchange.isExporterVisible,
                    document: vm4ProfileExchange.getCurrentExportableDocument(),
                    contentType: .json,
                    defaultFilename: vm4ProfileExchange.defaultFileName
                ) { result in
                    vm4ProfileExchange.fileSaveActionResult = result
                    vm4ProfileExchange.currentExportableDocument = nil
                }
                .alert(
                    msgPack.title,
                    isPresented: vm4ProfileExchange.isExportResultAvailable,
                    actions: {
                        Button("sys.ok".i18nBaseKit) {
                            vm4ProfileExchange.fileSaveActionResult = nil
                        }
                    },
                    message: {
                        Text(verbatim: msgPack.message)
                    }
                )
        }
        .onDisappear {
            vm4ProfileExchange.currentExportableDocument = nil
        }
    }

    // MARK: Private

    @StateObject private var vm4ProfileExchange = Coordinator()
    @StateObject private var vm4ProfileMgmt: ProfileManagerVM = .shared

    private let importCompletionHandler: (Result<URL, any Error>) -> Void
    private let extraItem: (() -> T)?
}

// MARK: ProfileBackupRestoreMenu.Coordinator

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension ProfileBackupRestoreMenu {
    @Observable @MainActor
    internal final class Coordinator: ObservableObject {
        // MARK: Lifecycle

        public init() {}

        // MARK: Internal

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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
internal struct PZProfilesDocument: FileDocument {
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
