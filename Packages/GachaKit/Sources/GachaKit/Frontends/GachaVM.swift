// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreXLSX
import Defaults
import EnkaKit
import GachaMetaDB
import Observation
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - GachaVM

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
                try? await Enka.Sputnik.shared.db4HSR.reinitIfLocMismatches()
                try? await Enka.Sputnik.shared.db4GI.reinitIfLocMismatches()
            }
        )
    }

    // MARK: Public

    public static var shared = GachaVM()

    public var remoteChangesAvailable = false
    public var hasInheritableGachaEntries: Bool = false
    public private(set) var mappedEntriesByPools: [GachaPoolExpressible: [GachaEntryExpressible]] = [:]
    public private(set) var currentPentaStars: [GachaEntryExpressible] = []
    public var currentExportableDocument: Result<GachaDocument, Error>?
    public var currentSceneStep4Import: GachaImportSections.SceneStep = .chooseFormat
    public var showSucceededAlertToast = false

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

    // MARK: Private

    private static func defaultPoolType(for game: Pizza.SupportedGame?) -> GachaPoolExpressible? {
        switch game {
        case .genshinImpact: .giCharacterEventWish
        case .starRail: .srCharacterEventWarp
        case .zenlessZone: .zzExclusiveChannel
        case .none: nil
        }
    }
}

// MARK: - Tasks and Error Handlers.

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
                try await GachaActor.shared.deleteAllEntriesOfGPID(gpid)
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
                try await GachaActor.shared.refreshAllProfiles()
            },
            completionHandler: { _ in
                if self.currentGPID == nil {
                    self.resetDefaultProfile()
                }
                self.remoteChangesAvailable = false
                GachaActor.remoteChangesAvailable = false
                self.showSucceededAlertToast = true
            }
        )
    }

    /// This method is not supposed to have animation.
    public func checkWhetherInheritableDataExists(immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: {
                await GachaActor.shared.cdGachaMOSputnik.confirmWhetherHavingData()
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
            givenTask: { try await GachaActor.shared.migrateOldGachasIntoProfiles() },
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
                    var existedIDs = Set<String>() // 用来去除重复内容。
                    var fetchedEntries = [GachaEntryExpressible]()
                    let context = GachaActor.shared.modelExecutor.modelContext
                    let count = try context.fetchCount(descriptor)
                    if count > 0 {
                        try context.enumerate(descriptor) { rawEntry in
                            /// 补遗：检查日期时间格式错误者，发现了就纠正。
                            try rawEntry.fixTimeFieldIfNecessary(context: context)
                            let expressible = rawEntry.expressible
                            if existedIDs.contains(expressible.id) {
                                context.delete(rawEntry)
                            } else {
                                existedIDs.insert(expressible.id)
                                fetchedEntries.append(expressible)
                            }
                        }
                        if context.hasChanges {
                            try context.save()
                            GachaActor.remoteChangesAvailable = false
                        }
                    }
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
                switch format {
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
                try await GachaActor.shared.importUIGFv4(
                    source,
                    specifiedGPIDs: specifiedGPIDs,
                    overrideDuplicatedEntries: overrideDuplicatedEntries
                )
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

extension GachaVM {
    public var currentGPIDTitle: String? {
        guard let pfID = currentGPID else { return nil }
        return nameIDMap[pfID.uidWithGame] ?? nil
    }

    public var nameIDMap: [String: String] {
        var nameMap = [String: String]()
        Defaults[.pzProfiles].values.forEach { pzProfile in
            if nameMap[pzProfile.uidWithGame] == nil {
                nameMap[pzProfile.uidWithGame] = pzProfile.name
            }
        }
        Defaults[.queriedEnkaProfiles4GI].forEach { uid, enkaProfile in
            let pfID = GachaProfileID(uid: uid, game: .genshinImpact)
            guard nameMap[pfID.uidWithGame] == nil else { return }
            nameMap[pfID.uidWithGame] = enkaProfile.nickname
        }
        Defaults[.queriedEnkaProfiles4HSR].forEach { uid, enkaProfile in
            let pfID = GachaProfileID(uid: uid, game: .starRail)
            guard nameMap[pfID.uidWithGame] == nil else { return }
            nameMap[pfID.uidWithGame] = enkaProfile.nickname
        }
        return nameMap
    }

    public var allPZProfiles: [PZProfileSendable] {
        let profileSets = Set<PZProfileSendable>(Defaults[.pzProfiles].values)
        return profileSets.sorted { $0.priority < $1.priority }
    }

    public var allGPIDs: Binding<[GachaProfileID]> {
        .init(get: {
            let context = GachaActor.shared.modelContainer.mainContext
            let resultRAW = try? context.fetch(FetchDescriptor<PZGachaProfileMO>()).map(\.asSendable)
            let result = resultRAW?.sorted { $0.uidWithGame < $1.uidWithGame } ?? []
            return result.reduce(into: [GachaProfileID]()) { if !$0.contains($1) { $0.append($1) } }
        }, set: { _ in

        })
    }

    public var hasGPID: Binding<Bool> {
        .init(get: {
            let context = GachaActor.shared.modelContainer.mainContext
            let result = try? context.fetchCount(FetchDescriptor<PZGachaProfileMO>())
            return result ?? 0 > 0
        }, set: { _ in

        })
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
        let sortedGPIDs = allGPIDs.wrappedValue
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
