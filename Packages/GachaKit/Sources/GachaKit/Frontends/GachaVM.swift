// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import CoreXLSX
import EnkaKit
import GachaMetaDB
import Observation
import PZAccountKit
import PZBaseKit
import PZCoreDataKit4GachaEntries
import SwiftData
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - GachaVM

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
public final class GachaVM: TaskManagedVM {
    // MARK: Lifecycle

    override public init() {
        super.init()
        super.assignableErrorHandlingTask = { _ in
            Task {
                await GachaActor.shared.asyncRollback()
            }
        }
        // 監聽 app 前後台狀態，避免 inactive 期間因 SwiftData 通知產生 pending UI update
        // 導致回到前景時系統 flush 觸發 watchdog kill（尤其 iPhone SE2 等低 RAM 機種）。
        #if canImport(UIKit)
        let willResignActiveNotification = UIApplication.willResignActiveNotification
        let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
        #elseif canImport(AppKit)
        let willResignActiveNotification = NSApplication.willResignActiveNotification
        let didBecomeActiveNotification = NSApplication.didBecomeActiveNotification
        #endif
        NotificationCenter.default.addObserver(
            forName: willResignActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.isAppActive = false
            }
        }
        NotificationCenter.default.addObserver(
            forName: didBecomeActiveNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.isAppActive = true
                // 若 inactive 期間有 SwiftData 變更被標記 dirty，此時一次性處理。
                let needsBackendRefresh = pendingBackendChangesDirty
                let needsGPIDRefresh = pendingGPIDChanges
                self.pendingBackendChangesDirty = false
                self.pendingGPIDChanges = false
                if needsBackendRefresh {
                    self.backendChangesAvailable = true
                }
                if needsGPIDRefresh {
                    scheduleGPIDRefresh()
                }
            }
        }
        fireTask(
            cancelPreviousTask: false,
            givenTask: {
                await self.updateAllCachedGPIDs()
                self.configurePublisherObservations()
                try? await Enka.Sputnik.shared.db4HSR.reinitIfLocMismatches()
                try? await Enka.Sputnik.shared.db4GI.reinitIfLocMismatches()
            }
        )
    }

    // MARK: Public

    public static let shared = GachaVM()

    @ObservationIgnored public var isDoingBatchInsertionAction = false
    /// 由 NotificationCenter 自動維護，反映 UIApplication 是否處於 active 狀態。
    @ObservationIgnored public var isAppActive = true
    public var backendChangesAvailable = false
    public var hasInheritableGachaEntries: Bool = false
    public private(set) var mappedEntriesByPools: [GachaPoolExpressible: [GachaEntryExpressible]] = [:]
    public private(set) var currentPentaStars: [GachaEntryExpressible] = []
    public var currentExportableDocument: Result<GachaDocument, Error>?
    public var currentSceneStep4Import: GachaImportSections.SceneStep = .chooseFormat
    public var showSucceededAlertToast = false
    public var nameIDMap: [String: String] = GachaVM.getLatestNameIDMap()

    public var allGPIDs: [GachaProfileID] = [] {
        didSet {
            if let currentGPIDNonNull = currentGPID, !allGPIDs.contains(currentGPIDNonNull) {
                currentGPID = nil
            }
        }
    }

    public var currentGPID: GachaProfileID? {
        didSet {
            currentPoolType = Self.defaultPoolType(for: currentGPID?.game)
            updateMappedEntriesByPools()
        }
    }

    public var currentPoolType: GachaPoolExpressible? {
        didSet {
            updateCurrentPentaStars()
        }
    }

    public func updateAllCachedGPIDs() async {
        guard isAppActive else {
            pendingBackendChangesDirty = true
            pendingGPIDChanges = true
            return
        }
        let fetchedGPIDs = await GachaActor.shared.fetchAllGPIDs()
        guard isAppActive else {
            pendingBackendChangesDirty = true
            pendingGPIDChanges = true
            return
        }
        allGPIDs = fetchedGPIDs
        updateNameIDMap()
    }

    // MARK: Private

    /// Inactive 期間的 SwiftData 變更不會立即處理，而是標記 dirty；
    /// 等 app 回到 active 時再一次性處理，避免在 scene transition 期間
    /// 觸發系統的 dispatchImmediately 導致低 RAM 機種 watchdog kill。
    @ObservationIgnored private var pendingBackendChangesDirty = false
    @ObservationIgnored private var pendingGPIDChanges = false

    private let debouncer: Debouncer = .init(delay: 0.5)

    private var subscribed: Bool = false

    private static func defaultPoolType(for game: Pizza.SupportedGame?) -> GachaPoolExpressible? {
        switch game {
        case .genshinImpact: .giCharacterEventWish
        case .starRail: .srCharacterEventWarp
        case .zenlessZone: .zzExclusiveChannel
        case .none: nil
        }
    }

    private func refreshGPIDsAfterBackendMutation(
        postUpdate: (@MainActor () -> Void)? = nil
    ) {
        Task {
            await self.updateAllCachedGPIDs()
            if let postUpdate {
                await MainActor.run {
                    postUpdate()
                }
            }
        }
    }

    private func scheduleGPIDRefresh() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            await debouncer.debounce {
                await self.updateAllCachedGPIDs()
            }
        }
    }

    private func configurePublisherObservations() {
        guard !subscribed else { return }
        defer { subscribed = true }
        switch OS.isOS25OrNewer {
        case false:
            // OS24 (iOS 17, macOS 14) 无法时刻抓到 ModelContext.didSave，
            // 所以只能抓 NSManagedObjectContextDidSaveObjectIDs。
            NotificationCenter.default.addObserver(
                forName: .NSManagedObjectContextDidSaveObjectIDs,
                object: nil,
                queue: nil // 不指定队列，依赖 actor 隔离
            ) { notification in // Singleton 不需要 weak self。
                let changedEntityNames = NSManagedObjectID.parseObjectNames(
                    notificationResult: notification.userInfo
                )
                guard !changedEntityNames.isEmpty else { return }
                let changesInvolveGPID = changedEntityNames.contains("PZGachaProfileMO")
                let changesInvolveGachaEntry = changedEntityNames.contains("PZGachaEntryMO")
                guard changesInvolveGachaEntry else { return }
                Task { @MainActor in
                    guard !self.isDoingBatchInsertionAction else { return }
                    self.didObserveChangesFromSwiftData(changesInvolveGPID: changesInvolveGPID)
                }
            }
        case true:
            NotificationCenter.default.addObserver(
                forName: ModelContext.didSave,
                object: nil,
                queue: nil // 不指定队列，依赖 actor 隔离
            ) { notification in // Singleton 不需要 weak self。
                let changedEntityNames = PersistentIdentifier.parseObjectNames(
                    notificationResult: notification.userInfo
                )
                guard !changedEntityNames.isEmpty else { return }
                let changesInvolveGPID = changedEntityNames.contains("PZGachaProfileMO")
                let changesInvolveGachaEntry = changedEntityNames.contains("PZGachaEntryMO")
                guard changesInvolveGachaEntry else { return }
                Task { @MainActor in
                    guard !self.isDoingBatchInsertionAction else { return }
                    self.didObserveChangesFromSwiftData(changesInvolveGPID: changesInvolveGPID)
                }
            }
        }
    }

    private func didObserveChangesFromSwiftData(changesInvolveGPID: Bool) {
        guard isAppActive else {
            // Inactive 期間不直接改動 @Observable 屬性，僅標記 dirty。
            // 等 app 回到 active 時由 didBecomeActiveNotification 統一處理。
            pendingBackendChangesDirty = true
            if changesInvolveGPID { pendingGPIDChanges = true }
            return
        }
        if !backendChangesAvailable {
            backendChangesAvailable = true
        }
        if changesInvolveGPID {
            scheduleGPIDRefresh()
        }
    }
}

// MARK: - Tasks and Error Handlers.

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaVM {
    public func updateGMDB(for games: [Pizza.SupportedGame?]? = nil, immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                var games = (games ?? []).compactMap { $0 }
                if games.isEmpty {
                    games = Pizza.SupportedGame.allCases
                }
                for game in games {
                    try await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: game)
                }
            }
        )
    }

    public func deleteAllEntriesOfGPID(_ gpid: GachaProfileID, immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                let assertion = BackgroundTaskAsserter(name: UUID().uuidString)
                do {
                    if await !assertion.state.isReleased {
                        return try await GachaActor.shared.deleteAllEntriesOfGPID(gpid)
                    }
                    await assertion.release()
                } catch {
                    await assertion.release()
                    throw error
                }
                return nil
            },
            completionHandler: { _ in
                self.refreshGPIDsAfterBackendMutation {
                    self.showSucceededAlertToast = true
                }
            }
        )
    }

    public func rebuildGachaUIDList(immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                let assertion = BackgroundTaskAsserter(name: UUID().uuidString)
                do {
                    if await !assertion.state.isReleased {
                        return try await GachaActor.shared.refreshAllProfiles()
                    }
                    await assertion.release()
                } catch {
                    await assertion.release()
                    throw error
                }
                return nil
            },
            completionHandler: { _ in
                self.refreshGPIDsAfterBackendMutation {
                    if self.currentGPID == nil {
                        self.resetDefaultProfile()
                    }
                    self.backendChangesAvailable = false
                    self.showSucceededAlertToast = true
                }
            }
        )
    }

    /// This method is not supposed to have animation.
    public func checkWhetherInheritableDataExists(immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                await CDGachaMOActor.shared?.confirmWhetherHavingData() ?? false
            },
            completionHandler: {
                if let retrieved = $0 {
                    self.hasInheritableGachaEntries = retrieved
                }
            }
        )
    }

    public func migrateOldGachasIntoProfiles(immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                let assertion = BackgroundTaskAsserter(name: UUID().uuidString)
                do {
                    if await !assertion.state.isReleased {
                        return try await GachaActor.shared.migrateOldGachasIntoProfiles()
                    }
                    await assertion.release()
                } catch {
                    await assertion.release()
                    throw error
                }
                return nil
            },
            completionHandler: { _ in
                self.refreshGPIDsAfterBackendMutation {
                    if self.currentGPID == nil {
                        self.resetDefaultProfile()
                    }
                    self.showSucceededAlertToast = true
                }
            }
        )
    }

    public func updateCurrentPentaStars(immediately: Bool = true) {
        fireTask(
            prerequisite: (currentGPID != nil, {
                self.currentPentaStars.removeAll()
            }),
            cancelPreviousTask: immediately,
            givenTask: { self.getCurrentPentaStars() },
            completionHandler: {
                if let retrieved = $0 {
                    self.currentPentaStars = retrieved
                }
            }
        )
    }

    public func updateMappedEntriesByPools(immediately: Bool = true) {
        fireTask(
            prerequisite: (currentGPID != nil, {
                self.mappedEntriesByPools.removeAll()
                self.currentPentaStars.removeAll()
            }),
            cancelPreviousTask: immediately,
            givenTask: {
                if let currentGPID = self.currentGPID {
                    let descriptor = FetchDescriptor<PZGachaEntryMO>(
                        predicate: PZGachaEntryMO.predicate(
                            owner: currentGPID,
                            rarityLevel: nil
                        ),
                        sortBy: [SortDescriptor(\PZGachaEntryMO.id, order: .reverse)]
                    )
                    let fetchedEntries = try await GachaActor.shared.fetchExpressibleEntries(descriptor)
                    let mappedEntries = fetchedEntries.mappedByPools
                    let pentaStars = self.getCurrentPentaStars(from: mappedEntries)
                    return (mappedEntries, pentaStars)
                } else {
                    // 不会发生，因为上文有过一个 null check 了。
                    return nil
                }
            },
            completionHandler: { pack in
                if let pack {
                    self.mappedEntriesByPools = pack.0
                    self.currentPentaStars = pack.1
                }
            }
        )
    }

    public func prepareGachaDocumentForExport(
        packaging pkgMethod: GachaExchange.ExportPackageMethod,
        format: GachaExchange.ExportableFormat,
        lang: GachaLanguage = Locale.gachaLangauge,
        immediately: Bool = true
    ) {
        fireTask(
            prerequisite: nil,
            cancelPreviousTask: immediately,
            givenTask: {
                let packagedDocument: GachaDocument = switch pkgMethod {
                case let .singleOwner(gpid):
                    try await GachaActor.shared.prepareGachaDocument(for: gpid, format: format, lang: lang)
                case let .specifiedOwners(owners):
                    try await GachaActor.shared.prepareUIGFv4Document(for: owners, lang: lang)
                case .allOwners:
                    try await GachaActor.shared.prepareUIGFv4Document(for: nil, lang: lang)
                }
                return Result.success(packagedDocument)
            },
            completionHandler: { newDocument in
                self.currentExportableDocument = newDocument
            },
            errorHandler: { error in
                withAnimation {
                    if case .databaseExpired = error as? GachaMeta.GMDBError {
                        self.currentError = error
                    } else {
                        self.currentExportableDocument = Result.failure(error)
                    }
                }
                self.task?.cancel()
            }
        )
    }

    public func prepareGachaDocumentForImport(
        _ url: URL,
        format: GachaExchange.ImportableFormat,
        immediately: Bool = true
    ) {
        fireImportTask(
            prerequisite: (
                url.startAccessingSecurityScopedResource(), {
                    self.currentError = GachaKit.FileExchangeException.accessFailureComDlg32
                }
            ),
            cancelPreviousTask: immediately,
            givenTask: {
                defer {
                    url.stopAccessingSecurityScopedResource()
                }
                return try await Self.decodeImportableContent(fromFileURL: url, format: format)
            }
        )
    }

    /// 供除错用途：直接以手边的原始资料（例如剪贴板文字）建立导入用文件。
    public func prepareGachaDocumentForImport(
        _ data: Data,
        format: GachaExchange.ImportableFormat,
        immediately: Bool = true
    ) {
        fireImportTask(
            cancelPreviousTask: immediately,
            givenTask: {
                try await Self.decodeImportableContent(fromRawData: data, format: format)
            }
        )
    }

    /// 供除错用途：读取剪贴板上的文字、视作导入用文件。
    /// 注意：模拟器内的 `UIPasteboard.general.string` 取不到资料，此入口仅适用于真机与 macOS。
    public func prepareGachaDocumentForImportFromClipboard(
        format: GachaExchange.ImportableFormat
    ) {
        #if os(macOS) || os(iOS) || targetEnvironment(macCatalyst)
        let clipboardText = Clipboard.currentString
        #else
        let clipboardText = ""
        #endif
        guard let data = clipboardText.data(using: .utf8), !data.isEmpty else {
            withAnimation {
                self.currentError = GachaKit.FileExchangeException.otherError(
                    DebugImportException.clipboardHasNoText
                )
            }
            return
        }
        prepareGachaDocumentForImport(data, format: format)
    }

    /// 供除错用途：读取使用者指定的 URL。支援本机档案路径、`file://` URL、以及远端 http(s) URL。
    /// Xcode 27 的模拟器无法将外来 JSON 放进文件系统，但可以直接经由 URL 取得资料。
    public func prepareGachaDocumentForImportFromURL(
        _ urlString: String,
        format: GachaExchange.ImportableFormat
    ) {
        guard let url = Self.resolvedImportURL(fromRawString: urlString) else {
            withAnimation {
                self.currentError = GachaKit.FileExchangeException.otherError(
                    DebugImportException.invalidURL
                )
            }
            return
        }
        fireImportTask(
            cancelPreviousTask: true,
            givenTask: {
                // 使用者直接输入的档案路径没有 security scope，故不经过 startAccessingSecurityScopedResource，
                // 但仍沿用同一套档案解码管线，以便支援 XLSX 与胡桃难民档案。
                if url.isFileURL {
                    return try await Self.decodeImportableContent(fromFileURL: url, format: format)
                }
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse,
                   !(200 ..< 300).contains(httpResponse.statusCode) {
                    throw GachaKit.FileExchangeException.otherError(
                        DebugImportException.badServerResponse(status: httpResponse.statusCode)
                    )
                }
                return try await Self.decodeImportableContent(fromRawData: data, format: format)
            }
        )
    }

    /// 将使用者输入的字符串转成可读取的 URL。没有 scheme 时视作本机档案路径。
    private static func resolvedImportURL(fromRawString rawString: String) -> URL? {
        let trimmed = rawString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), let scheme = url.scheme, !scheme.isEmpty {
            return url
        }
        return URL(fileURLWithPath: (trimmed as NSString).expandingTildeInPath)
    }

    private func fireImportTask(
        prerequisite: (condition: Bool, notMetHandler: (() -> Void)?)? = nil,
        cancelPreviousTask: Bool,
        givenTask: @escaping @MainActor @Sendable () async throws -> UIGFv4?
    ) {
        fireTask(
            prerequisite: prerequisite,
            cancelPreviousTask: cancelPreviousTask,
            givenTask: givenTask,
            completionHandler: { fetchedFile in
                if let fetchedFile {
                    self.currentSceneStep4Import = .chooseProfiles(fetchedFile)
                }
            },
            errorHandler: { error in
                withAnimation {
                    if error is GachaKit.FileExchangeException {
                        self.currentSceneStep4Import = .error(error)
                    } else {
                        self.currentSceneStep4Import = .error(
                            GachaKit.FileExchangeException.otherError(error)
                        )
                    }
                }
                self.task?.cancel()
            }
        )
    }

    // MARK: Private

    /// 由档案 URL 解析出可导入的 UIGFv4 文件。
    private static func decodeImportableContent(
        fromFileURL url: URL,
        format: GachaExchange.ImportableFormat
    ) async throws
        -> UIGFv4 {
        switch format {
        case .asGIGFExcel:
            guard let file = XLSXFile(filepath: url.relativePath) else {
                throw GachaKit.FileExchangeException.fileNotExist
            }
            do {
                return sanitizedForImport(try await GachaActor.shared.upgradeToUIGFv4(xlsx: file))
            } catch {
                throw GachaKit.FileExchangeException.otherError(error)
            }
        case .asUIGFv4:
            let data: Data = try Data(contentsOf: url)
            // 胡桃难民档案是 SQLite 资料库，只能直接读取档案本身。
            if isSQLiteDatabase(data) {
                return try await decodeHutaoRefugeeFile(at: url)
            }
            return try await decodeImportableContent(fromRawData: data, format: format)
        case .asGIGFJson, .asSRGFv1:
            let data: Data = try Data(contentsOf: url)
            return try await decodeImportableContent(fromRawData: data, format: format)
        }
    }

    /// 由手边的原始资料解析出可导入的 UIGFv4 文件。
    private static func decodeImportableContent(
        fromRawData data: Data,
        format: GachaExchange.ImportableFormat
    ) async throws
        -> UIGFv4 {
        let decoder = JSONDecoder()
        var decoded: UIGFv4
        switch format {
        case .asGIGFExcel:
            // Excel (XLSX) 档案无法经由剪贴板之类的手边资料传递。
            throw GachaKit.FileExchangeException.otherError(
                DebugImportException.unsupportedFormat
            )
        case .asUIGFv4:
            decoded = try await decodeUIGFv4(from: data)
        case .asSRGFv1:
            do {
                decoded = try await GachaActor.shared
                    .upgradeToUIGFv4(srgf: decoder.decode(SRGFv1.self, from: data))
            } catch {
                throw GachaKit.FileExchangeException.decodingError(error)
            }
        case .asGIGFJson:
            do {
                decoded = try await GachaActor.shared
                    .upgradeToUIGFv4(gigf: decoder.decode(GIGF.self, from: data))
            } catch {
                throw GachaKit.FileExchangeException.decodingError(error)
            }
        }
        return sanitizedForImport(decoded)
    }

    /// UIGF v4 的解读流程：优先尝试旧版披萨难民档案（PLIST），否则按 JSON 处理。
    private static func decodeUIGFv4(from data: Data) async throws -> UIGFv4 {
        var isRefugee = false
        do {
            let refugeeData = try PropertyListDecoder().decode(
                PZRefugeeFile.self, from: data
            )
            isRefugee = true
            return try await upgradeRefugeeFileToUIGFv4(refugeeData)
        } catch let refugeeError {
            PZLog.error("\(refugeeError)")
            if isRefugee {
                throw GachaKit.FileExchangeException.otherError(refugeeError)
            }
            // 该资料不是旧版难民档案，继续按 JSON 处理。
        }
        do {
            return try JSONDecoder().decode(UIGFv4.self, from: data)
        } catch {
            throw GachaKit.FileExchangeException.decodingError(error)
        }
    }

    /// 旧版披萨难民档案（PLIST）的格式升级。
    private static func upgradeRefugeeFileToUIGFv4(_ refugeeData: PZRefugeeFile) async throws -> UIGFv4 {
        var genshinDataRAW = refugeeData.oldGachaEntries4GI

        var localGMDBAlreadyReset = false
        var redoTask = true
        taskRedo: while redoTask {
            // Fix Genshin ItemIDs.
            genshinDataRAW.fixItemIDs()
            if genshinDataRAW.mightHaveNonCHSLanguageTag {
                try genshinDataRAW.updateLanguage(.langCHS)
            }
            for idx in 0 ..< genshinDataRAW.count {
                let currentObj = genshinDataRAW[idx]
                guard Int(currentObj.itemId) == nil else { continue }
                // 读取难民档案时出现 GMDB 匹配错误的可能性非常小，因为旧版披萨的 GMDB 太旧、恐无法获取记录。
                // 但这里仍旧按照例行步骤处理，以防万一。
                if !localGMDBAlreadyReset {
                    GachaMeta.Sputnik.resetLocalGachaMetaDB(for: .genshinImpact)
                    localGMDBAlreadyReset = true
                    continue taskRedo
                } else {
                    redoTask = false
                    Task { @MainActor in
                        try? await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                    }
                    throw GachaMeta.GMDBError.databaseExpired(game: .genshinImpact)
                }
            }
            redoTask = false
        }

        let newUIGFEntries4Genshin = genshinDataRAW.map(\.asPZGachaEntrySendable)
        var fetchedFile = try UIGFv4(
            info: .init(),
            entries: newUIGFEntries4Genshin + refugeeData.newGachaEntries,
            lang: .langCHS
        )
        fetchedFile.info = .init(
            exportApp: "PizzaHelper4Genshin",
            exportAppVersion: "v4",
            exportTimestamp: "N/A",
            version: "N/A",
            previousFormat: "[PLIST] OldPizzaRefugeeData"
        )
        return fetchedFile
    }

    /// 胡桃难民档案是 SQLite 资料库，只能直接读取档案本身。
    private static func decodeHutaoRefugeeFile(at url: URL) async throws -> UIGFv4 {
        do {
            let hutaoFile = try HutaoRefugeeFile.fromDatabase(url: url)
            return sanitizedForImport(try await hutaoFile.toUIGFv4())
        } catch {
            PZLog.error("\(error)")
            throw GachaKit.FileExchangeException.otherError(error)
        }
    }

    /// 以 SQLite 的魔术数字（magic number）判断资料是否为 SQLite 资料库。
    private static func isSQLiteDatabase(_ data: Data) -> Bool {
        guard data.count >= 16 else { return false }
        let sqliteHeader = "SQLite format 3\0"
        let headerData = data.prefix(16)
        guard let headerString = String(data: headerData, encoding: .utf8) else { return false }
        return headerString.hasPrefix(sqliteHeader)
    }

    /// 导入前统一清理资料。
    private static func sanitizedForImport(_ document: UIGFv4) -> UIGFv4 {
        var result = document
        result.zzzProfiles = nil // TODO: 等绝区零的支持实作完毕之后，移除这一行。
        return result
    }

    // MARK: - DebugImportException

    /// 仅供除错用的导入错误。
    private enum DebugImportException: Error, CustomStringConvertible {
        case clipboardHasNoText
        case unsupportedFormat
        case invalidURL
        case badServerResponse(status: Int)

        // MARK: Internal

        var description: String {
            switch self {
            case .clipboardHasNoText:
                "The clipboard does not contain any text data. // 剪贴板上没有可用的文字内容。"
            case .unsupportedFormat:
                "XLSX files cannot be read from the clipboard. // Excel (XLSX) 档案无法经由剪贴板读取。"
            case .invalidURL:
                "The given URL is invalid. // 输入的 URL 无效。"
            case let .badServerResponse(status):
                "The server responded with HTTP status code \(status). // 服务器回传的 HTTP 状态码为 \(status)。"
            }
        }
    }

    public func importUIGFv4(
        _ source: UIGFv4,
        specifiedGPIDs: Set<GachaProfileID>? = nil,
        overrideDuplicatedEntries: Bool = false,
        immediately: Bool = true
    ) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                let assertion = BackgroundTaskAsserter(name: UUID().uuidString)
                do {
                    if await !assertion.state.isReleased {
                        return try await GachaActor.shared.importUIGFv4(
                            source,
                            specifiedGPIDs: specifiedGPIDs,
                            overrideDuplicatedEntries: overrideDuplicatedEntries
                        )
                    }
                    await assertion.release()
                } catch {
                    await assertion.release()
                    throw error
                }
                return nil
            },
            completionHandler: { resultMap in
                self.refreshGPIDsAfterBackendMutation {
                    if let resultMap {
                        self.currentSceneStep4Import = .importSucceeded(resultMap)
                    }
                    self.showSucceededAlertToast = true
                }
            },
            errorHandler: { error in
                withAnimation {
                    if error is GachaKit.FileExchangeException {
                        self.currentSceneStep4Import = .error(error)
                    } else {
                        self.currentSceneStep4Import = .error(
                            GachaKit.FileExchangeException.uigfEntryInsertionError(error)
                        )
                    }
                }
                self.task?.cancel()
            }
        )
    }
}

// MARK: - Profile Switchers and other tools.

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaVM {
    public var currentGPIDTitle: String? {
        guard let pfID = currentGPID else { return nil }
        return nameIDMap[pfID.uidWithGame] ?? nil
    }

    public var allPZProfiles: [PZProfileSendable] {
        let profileSets = Set<PZProfileSendable>(Defaults[.pzProfiles].values)
        return profileSets.sorted { $0.priority < $1.priority }
    }

    public var hasGPID: Binding<Bool> {
        .init(get: {
            !self.allGPIDs.isEmpty
        }, set: { _ in

        })
    }

    public static func getLatestNameIDMap() -> [String: String] {
        var nameMap = [String: String]()
        Defaults[.pzProfiles].values.forEach { pzProfile in
            if nameMap[pzProfile.uidWithGame] == nil {
                nameMap[pzProfile.uidWithGame] = pzProfile.name
            }
        }
        Enka.Sputnik.shared.db4GI.getAllCachedProfiles().forEach { uid, enkaProfile in
            let pfID = GachaProfileID(uid: uid, game: .genshinImpact)
            guard nameMap[pfID.uidWithGame] == nil else { return }
            nameMap[pfID.uidWithGame] = enkaProfile.nickname
        }
        Enka.Sputnik.shared.db4HSR.getAllCachedProfiles().forEach { uid, enkaProfile in
            let pfID = GachaProfileID(uid: uid, game: .starRail)
            guard nameMap[pfID.uidWithGame] == nil else { return }
            nameMap[pfID.uidWithGame] = enkaProfile.nickname
        }
        return nameMap
    }

    public func updateNameIDMap() {
        nameIDMap = Self.getLatestNameIDMap()
    }

    private func getCurrentPentaStars(
        from mappedEntries: [GachaPoolExpressible: [GachaEntryExpressible]]? = nil
    )
        -> [GachaEntryExpressible] {
        let mappedEntries = mappedEntries ?? mappedEntriesByPools
        guard let currentPoolType else {
            return mappedEntries.values.reduce([], +).filter { entry in
                entry.rarity == .rank5
            }
        }
        return mappedEntries[currentPoolType]?.filter { entry in
            entry.rarity == .rank5
        } ?? []
    }

    public func resetDefaultProfile() {
        let sortedGPIDs = allGPIDs
        guard !sortedGPIDs.isEmpty else { return }
        guard let matched = allPZProfiles.first else {
            currentGPID = sortedGPIDs.first
            return
        }
        let firstExistingProfile = sortedGPIDs.first {
            $0.uid == matched.uid && $0.game == matched.game
        }
        guard let firstExistingProfile else {
            currentGPID = sortedGPIDs.first
            return
        }
        currentGPID = firstExistingProfile
    }
}
