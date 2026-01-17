// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import Foundation
import Observation
import PZBaseKit
import SwiftUI
import UniformTypeIdentifiers
import WallpaperKit

// MARK: - UserWallpaperExchangeMenu

@available(iOS 17.0, macCatalyst 17.0, *)
struct UserWallpaperExchangeMenu<T: View>: View {
    // MARK: Lifecycle

    public init(importCompletionHandler: @escaping (Result<URL, any Error>) -> Void, extraItem: (() -> T)? = nil) {
        self.importCompletionHandler = importCompletionHandler
        self.extraItem = extraItem
    }

    // MARK: Public

    @ViewBuilder public var body: some View {
        let userWallpapers = UserWallpaperFileHandler.getAllUserWallpapers()
        @Bindable var theVM = theVM
        let msgPack = theVM.fileSaveActionResultMessagePack
        Menu {
            if let extraItem {
                extraItem()
                Divider()
            }
            Button {
                theVM.currentExportableDocument = Result.success(.init(model: userWallpapers))
            } label: {
                Label {
                    Text("userWallpaperMgr.exchange.export.menuTitle", bundle: .currentSPM)
                } icon: {
                    Image(systemSymbol: .squareAndArrowUpOnSquare)
                }
            }
            .disabled(userWallpapers.isEmpty)
            Divider()
            Button {
                theVM.isImporterVisible = true
            } label: {
                Label {
                    Text("userWallpaperMgr.exchange.import.menuTitle", bundle: .currentSPM)
                } icon: {
                    Image(systemSymbol: .squareAndArrowDownOnSquare)
                }
            }
        } label: {
            Image(systemSymbol: .filemenuAndSelection)
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
                .id(broadcaster.eventForUserWallpaperDidSave)
        }
        .onDisappear {
            theVM.currentExportableDocument = nil
        }
    }

    // MARK: Private

    @State private var theVM = Coordinator()
    @StateObject private var broadcaster = Broadcaster.shared

    private let importCompletionHandler: (Result<URL, any Error>) -> Void
    private let extraItem: (() -> T)?
}

// MARK: UserWallpaperExchangeMenu.Coordinator

@available(iOS 17.0, macCatalyst 17.0, *)
extension UserWallpaperExchangeMenu {
    @Observable
    private final class Coordinator: TaskManagedVM {
        var fileSaveActionResult: Result<URL, any Error>?
        var currentExportableDocument: Result<UserWallpaperPack, Error>?
        var isImporterVisible: Bool = false

        var fileSaveActionResultMessagePack: (title: String, message: String) {
            switch fileSaveActionResult {
            case let .success(url):
                (
                    "userWallpaperMgr.exchange.export.succeededInSavingToFile".i18nWPConfKit,
                    "userWallpaperMgr.exchange.export.fileSavedTo:".i18nWPConfKit + "\n\n\(url)"
                )
            case let .failure(message):
                ("userWallpaperMgr.exchange.export.failedInSavingToFile".i18nWPConfKit, "⚠︎ \(message)")
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

        func getCurrentExportableDocument() -> UserWallpaperPack? {
            switch currentExportableDocument {
            case let .success(document): document
            case .failure, .none: nil
            }
        }
    }
}

#endif
