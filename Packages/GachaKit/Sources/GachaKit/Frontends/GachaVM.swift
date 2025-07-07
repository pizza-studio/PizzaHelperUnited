// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import CoreXLSX
import Defaults
import EnkaKit
import GachaMetaDB
import Observation
import PZAccountKit
import PZBaseKit
import PZCoreDataKit4GachaEntries
import SwiftData
import SwiftUI

// MARK: - GachaVM

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
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

    public static var shared = GachaVM()

    @ObservationIgnored public var isDoingBatchInsertionAction = false
    public var remoteChangesAvailable = false
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
        allGPIDs = await GachaActor.shared.fetchAllGPIDs()
        updateNameIDMap()
    }

    // MARK: Private

    private var subscribed: Bool = false

    private static func defaultPoolType(for game: Pizza.SupportedGame?) -> GachaPoolExpressible? {
        switch game {
        case .genshinImpact: .giCharacterEventWish
        case .starRail: .srCharacterEventWarp
        case .zenlessZone: .zzExclusiveChannel
        case .none: nil
        }
    }

    private func configurePublisherObservations() {
        guard !subscribed else { return }
        defer { subscribed = true }
        switch OS.isOS25OrAbove {
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
                Task { @MainActor in
                    guard !changedEntityNames.isEmpty else { return }
                    let changesInvolveGPID = changedEntityNames.contains("PZGachaProfileMO")
                    let changesInvolveGachaEntry = changedEntityNames.contains("PZGachaEntryMO")
                    guard changesInvolveGPID, changesInvolveGachaEntry else { return }
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
                Task { @MainActor in
                    guard !changedEntityNames.isEmpty else { return }
                    let changesInvolveGPID = changedEntityNames.contains("PZGachaProfileMO")
                    let changesInvolveGachaEntry = changedEntityNames.contains("PZGachaEntryMO")
                    guard changesInvolveGPID, changesInvolveGachaEntry else { return }
                    guard !self.isDoingBatchInsertionAction else { return }
                    self.didObserveChangesFromSwiftData(changesInvolveGPID: changesInvolveGPID)
                }
            }
        }
    }

    nonisolated private func didObserveChangesFromSwiftData(changesInvolveGPID: Bool) {
        Task { @MainActor in
            if !self.remoteChangesAvailable {
                self.remoteChangesAvailable = true
            }
        }
        if changesInvolveGPID {
            Task {
                await self.updateAllCachedGPIDs()
            }
        }
    }
}

// MARK: - Tasks and Error Handlers.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
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
                self.showSucceededAlertToast = true
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
                if self.currentGPID == nil {
                    self.resetDefaultProfile()
                }
                self.remoteChangesAvailable = false
                self.showSucceededAlertToast = true
            }
        )
    }

    /// This method is not supposed to have animation.
    public func checkWhetherInheritableDataExists(immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                await CDGachaMOSputnik.shared.confirmWhetherHavingData()
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
                if self.currentGPID == nil {
                    self.resetDefaultProfile()
                }
                self.showSucceededAlertToast = true
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
        fireTask(
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
                var fetchedFile: UIGFv4
                let decoder = JSONDecoder()
                formatProcess: switch format {
                case .asGIGFExcel:
                    guard let file = XLSXFile(filepath: url.relativePath) else {
                        throw GachaKit.FileExchangeException.fileNotExist
                    }
                    do {
                        fetchedFile = try await GachaActor.shared.upgradeToUIGFv4(xlsx: file)
                    } catch {
                        throw GachaKit.FileExchangeException.otherError(error)
                    }
                case .asUIGFv4:
                    let data: Data = try Data(contentsOf: url)
                    var isRefugee = false
                    refugeeTask: do {
                        let refugeeData = try PropertyListDecoder().decode(
                            RefugeeFile.self, from: data
                        )
                        isRefugee = true
                        var genshinDataRAW = refugeeData.oldGachaEntries4GI
                        genshinDataRAW.fixItemIDs()
                        if genshinDataRAW.mightHaveNonCHSLanguageTag {
                            try genshinDataRAW.updateLanguage(.langCHS)
                        }
                        for idx in 0 ..< genshinDataRAW.count {
                            let currentObj = genshinDataRAW[idx]
                            guard Int(currentObj.itemId) == nil else { continue }
                            Task { @MainActor in
                                // 读取难民档案时出现 GMDB 匹配错误的可能性非常小，因为旧版披萨的 GMDB 太旧、恐无法获取记录。
                                // 但这里仍旧按照例行步骤处理，以防万一。
                                try? await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                            }
                            throw GachaMeta.GMDBError.databaseExpired(game: .genshinImpact)
                        }
                        let newUIGFEntries4Genshin = genshinDataRAW.map(\.asPZGachaEntrySendable)
                        fetchedFile = try UIGFv4(info: .init(), entries: newUIGFEntries4Genshin, lang: .langCHS)
                        fetchedFile.info = .init(
                            exportApp: "PizzaHelper4Genshin",
                            exportAppVersion: "v4",
                            exportTimestamp: "N/A",
                            version: "N/A",
                            previousFormat: "[PLIST] OldPizzaRefugeeData"
                        )
                        break formatProcess
                    } catch let refugeeError {
                        print(refugeeError)
                        if isRefugee {
                            throw GachaKit.FileExchangeException.otherError(refugeeError)
                        } else {
                            break refugeeTask
                        }
                    }
                    // 正常处理流程。
                    do {
                        fetchedFile = try decoder.decode(UIGFv4.self, from: data)
                    } catch {
                        throw GachaKit.FileExchangeException.decodingError(error)
                    }
                case .asSRGFv1:
                    let data: Data = try Data(contentsOf: url)
                    do {
                        fetchedFile = try await GachaActor.shared
                            .upgradeToUIGFv4(srgf: decoder.decode(SRGFv1.self, from: data))
                    } catch {
                        throw GachaKit.FileExchangeException.decodingError(error)
                    }
                case .asGIGFJson:
                    let data: Data = try Data(contentsOf: url)
                    do {
                        fetchedFile = try await GachaActor.shared
                            .upgradeToUIGFv4(gigf: decoder.decode(GIGF.self, from: data))
                    } catch {
                        throw GachaKit.FileExchangeException.decodingError(error)
                    }
                }
                fetchedFile.zzzProfiles = nil // TODO: 等绝区零的支持实作完毕之后，移除这一行。
                return fetchedFile
            },
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
                if let resultMap {
                    self.currentSceneStep4Import = .importSucceeded(resultMap)
                }
                self.showSucceededAlertToast = true
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
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
