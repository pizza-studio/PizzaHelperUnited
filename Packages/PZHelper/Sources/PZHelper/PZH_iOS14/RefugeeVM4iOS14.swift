// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import GachaKit
import PZAccountKit
import PZBaseKit
import PZCoreDataKit4GachaEntries
import PZCoreDataKit4LocalAccounts
import SwiftData
import SwiftUI
import UniformTypeIdentifiers
import WallpaperConfigKit
import WallpaperKit

// MARK: - RefugeeVM4iOS14

@MainActor
public final class RefugeeVM4iOS14: TaskManagedVMBackported {
    // MARK: Lifecycle

    override private init() {
        super.init()
        configurePublisherObservations()
        startCountingDataEntriesTask(forced: true)
    }

    // MARK: Public

    public static let shared = RefugeeVM4iOS14()

    @Published public var gachaEntriesCount: Int = 0
    @Published public var gachaEntriesCountModern: Int = 0
    @Published public var localProfileEntriesCount: Int = 0

    // MARK: - Unified Export State (iOS 17+)

    /// 統一的匯出文檔類型，用於避免 SwiftUI 多個 fileExporter 只有最後一個生效的 bug。
    @Published public var currentExportDocumentType: ExportDocumentType?

    /// 記錄最後一次匯出的文檔類型（用於顯示對應的成功/失敗訊息）。
    @Published public var lastExportedDocumentKind: ExportDocumentKind?

    // MARK: Internal

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) var isExportDialogVisible: Binding<Bool> {
        .init(get: {
            self.currentExportDocumentType != nil
        }, set: { newValue in
            if !newValue {
                self.currentExportDocumentType = nil
            }
        })
    }

    // MARK: Private

    private static var isOS23OrNewer: Bool {
        if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) { return true }
        return false
    }

    private let debouncer: Debouncer = .init(delay: 0.5)

    private var subscribed: Bool = false

    private func configurePublisherObservations() {
        guard !subscribed else { return }
        defer { subscribed = true }
        NotificationCenter.default.addObserver(
            forName: .NSManagedObjectContextDidSaveObjectIDs,
            object: nil,
            queue: nil // 不指定队列，依赖 actor 隔离
        ) { notification in // Singleton 不需要 weak self。
            let changedEntityNames = NSManagedObjectID.parseObjectNames(
                notificationResult: notification.userInfo
            )
            guard !changedEntityNames.isEmpty else { return }
            let hasAccountMO4GI = changedEntityNames.contains("AccountConfiguration")
            let hasOldGachaLog4GI = changedEntityNames.contains("GachaItemMO")
            let hasPZProfileMO = changedEntityNames.contains("PZProfileMO")
            guard hasAccountMO4GI || hasOldGachaLog4GI || hasPZProfileMO else { return }
            Task { @MainActor in
                await self.debouncer.debounce {
                    await MainActor.run {
                        self.startCountingDataEntriesTask(forced: false)
                    }
                }
            }
        }
    }
}

extension RefugeeVM4iOS14 {
    /// 舊版系統（iOS 16.x 及更早）使用的匯出方法。
    /// 由於這些系統不支援本次新增的統一匯出功能，故保留此方法。
    public func startDocumentationPreparationTask(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: {
                var result = PZRefugeeFile()
                result.oldGachaEntries4GI = try await CDGachaMOActor.shared?.getAllGenshinDataEntriesVanilla() ?? []
                if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) {
                    result.newProfiles = ProfileManagerVM.shared.profiles
                } else {
                    result.oldProfiles4GI = try await CDAccountMOActor.shared?.allAccountDataForGenshin() ?? []
                }
                return result
            }, completionHandler: { [weak self] _ in
                // 舊版系統的匯出邏輯在此不處理，因為舊版本沒有對應的 UI 處理。
                // 但這個方法需要存在以避免編譯錯誤。
                self?.forceStopTheTask()
            }
        )
    }

    public func startCountingDataEntriesTask(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: {
                var (intGacha, intGachaModern, intProfile) = (0, 0, 0)
                intGacha = try await CDGachaMOActor.shared?.countAllDataEntries(for: .genshinImpact) ?? 0
                if #available(iOS 16.2, macCatalyst 16.2, macOS 13.0, *) {
                    intProfile = ProfileManagerVM.shared.profiles.count
                } else {
                    intProfile = try await CDAccountMOActor.shared?.countAllAccountData(for: .genshinImpact) ?? 0
                }
                if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                    intGachaModern = try await GachaActor.shared.countAllDataEntries(.init())
                }
                return (intGacha, intGachaModern, intProfile)
            }, completionHandler: { [weak self] newResult in
                guard let this = self, let newResult else { return }
                let (intGacha, intGachaModern, intProfile) = newResult
                withAnimation {
                    this.gachaEntriesCount = intGacha
                    this.gachaEntriesCountModern = intGachaModern
                    this.localProfileEntriesCount = intProfile
                }
            }
        )
    }

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
    public func prepareRefugeeExportDocument(forced: Bool) {
        fireTask(
            cancelPreviousTask: forced, givenTask: {
                var result = PZRefugeeFile()
                result.oldGachaEntries4GI = try await CDGachaMOActor.shared?.getAllGenshinDataEntriesVanilla() ?? []
                result.newProfiles = ProfileManagerVM.shared.profiles
                result.newGachaEntries = try await GachaActor.shared.fetchSendableEntries(.init())
                return result
            }, completionHandler: { [weak self] newResult in
                guard let this = self, let newResult else { return }
                withAnimation {
                    this.currentExportDocumentType = .refugee(.init(file: newResult))
                }
            }
        )
    }

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
    public func prepareProfilesExportDocument() {
        let profiles = ProfileManagerVM.shared.profiles
        guard !profiles.isEmpty else { return }
        withAnimation {
            currentExportDocumentType = .profiles(.init(profiles))
        }
    }

    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
    public func prepareWallpapersExportDocument() {
        let wallpapers = UserWallpaperFileHandler.getAllUserWallpapers()
        guard !wallpapers.isEmpty else { return }
        withAnimation {
            currentExportDocumentType = .wallpapers(.init(model: wallpapers))
        }
    }
}

// MARK: RefugeeVM4iOS14.ExportDocumentType

extension RefugeeVM4iOS14 {
    /// 統一的匯出文檔類型枚舉。
    public enum ExportDocumentType: Sendable {
        case refugee(PZRefugeeDocument)
        case profiles(PZProfilesDocument)
        case wallpapers(UserWallpaperPack)

        // MARK: Public

        public var kind: ExportDocumentKind {
            switch self {
            case .refugee: .refugee
            case .profiles: .profiles
            case .wallpapers: .wallpapers
            }
        }

        public var contentType: UTType {
            switch self {
            case .refugee: .propertyList
            case .profiles, .wallpapers: .json
            }
        }

        public var defaultFileName: String {
            switch self {
            case .refugee:
                if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) {
                    return "ThePizzaHelper_RefugeeMigrationData"
                } else {
                    return "PizzaHelper4Genshin_RefugeeMigrationData"
                }
            case let .profiles(doc):
                return doc.fileNameStem
            case let .wallpapers(doc):
                return doc.fileNameStem
            }
        }
    }

    /// 匯出文檔類型的簡化標識（不包含實際資料）。
    public enum ExportDocumentKind: Sendable {
        case refugee
        case profiles
        case wallpapers
    }
}

// MARK: - RefugeeUnifiedExportDocument

/// 統一的匯出文檔包裝，封裝多種匯出類型。
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
struct RefugeeUnifiedExportDocument: FileDocument {
    // MARK: Lifecycle

    init(configuration: ReadConfiguration) throws {
        // 此文檔僅用於匯出，不支援讀取。
        throw CocoaError(.fileReadUnsupportedScheme)
    }

    init(type: RefugeeVM4iOS14.ExportDocumentType) {
        self.documentType = type
    }

    // MARK: Internal

    static let readableContentTypes: [UTType] = [.json, .propertyList]

    let documentType: RefugeeVM4iOS14.ExportDocumentType

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        switch documentType {
        case let .refugee(doc):
            return try doc.fileWrapper(configuration: configuration)
        case let .profiles(doc):
            return try doc.fileWrapper(configuration: configuration)
        case let .wallpapers(doc):
            return try doc.fileWrapper(configuration: configuration)
        }
    }
}
