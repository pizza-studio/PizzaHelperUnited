// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaKit
import GachaMetaDB
import Observation
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - GachaVM

@Observable
public final class GachaVM: TaskManagedViewModel {
    // MARK: Lifecycle

    @MainActor
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        super.assignableErrorHandlingTask = { _ in
            GachaActor.shared.modelExecutor.modelContext.rollback()
        }
    }

    // MARK: Public

    @MainActor public var modelContext: ModelContext
    @MainActor public var hasInheritableGachaEntries: Bool = false
    @MainActor public private(set) var mappedEntriesByPools: [GachaPoolExpressible: [GachaEntryExpressible]] = [:]
    @MainActor public private(set) var currentPentaStars: [GachaEntryExpressible] = []
    @MainActor public var currentExportableDocument: GachaDocument?

    @MainActor public var currentGPID: GachaProfileID? {
        didSet {
            currentPoolType = Self.defaultPoolType(for: currentGPID?.game)
            updateMappedEntriesByPools()
        }
    }

    @MainActor public var currentPoolType: GachaPoolExpressible? {
        didSet {
            updateCurrentPentaStars()
        }
    }

    // MARK: Fileprivate

    fileprivate static func defaultPoolType(for game: Pizza.SupportedGame?) -> GachaPoolExpressible? {
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
    @MainActor
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

    @MainActor
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
            }
        )
    }

    /// This method is not supposed to have animation.
    @MainActor
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

    @MainActor
    public func migrateOldGachasIntoProfiles(immediately: Bool = true) {
        fireTask(
            cancelPreviousTask: immediately,
            givenTask: { try await GachaActor.migrateOldGachasIntoProfiles() },
            completionHandler: { _ in
                if self.currentGPID == nil {
                    self.resetDefaultProfile()
                }
            }
        )
    }

    @MainActor
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

    @MainActor
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
            completionHandler: { mappedEntries, pentaStars in
                self.mappedEntriesByPools = mappedEntries
                self.currentPentaStars = pentaStars
            }
        )
    }

    @MainActor
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
                return packagedDocument
            },
            completionHandler: {
                self.currentExportableDocument = $0
            }
        )
    }
}

// MARK: - Profile Switchers and other tools.

extension GachaVM {
    @MainActor public var currentGPIDTitle: String? {
        guard let pfID = currentGPID else { return nil }
        return nameIDMap[pfID.uidWithGame] ?? nil
    }

    @MainActor public var nameIDMap: [String: String] {
        var nameMap = [String: String]()
        try? modelContext.enumerate(FetchDescriptor<PZProfileMO>(), batchSize: 1) { pzProfile in
            if nameMap[pzProfile.uidWithGame] == nil { nameMap[pzProfile.uidWithGame] = pzProfile.name }
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

    @MainActor public var allPZProfiles: [PZProfileMO] {
        let result = try? modelContext.fetch(FetchDescriptor<PZProfileMO>())
        return result?.sorted { $0.priority < $1.priority } ?? []
    }

    @MainActor public var allGPIDs: [GachaProfileID] {
        let context = GachaActor.shared.modelContainer.mainContext
        let result = try? context.fetch(FetchDescriptor<PZGachaProfileMO>()).map(\.asSendable)
        return result?.sorted { $0.uidWithGame < $1.uidWithGame } ?? []
    }

    @MainActor
    fileprivate func getCurrentPentaStars(
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

    @MainActor
    public func resetDefaultProfile() {
        let sortedGPIDs = allGPIDs
        guard !sortedGPIDs.isEmpty else { return }
        if let matched = allPZProfiles.first {
            let firstExistingProfile = sortedGPIDs.first {
                $0.uid == matched.uid && $0.game == matched.game
            }
            guard let firstExistingProfile else { return }
            currentGPID = firstExistingProfile
        } else {
            currentGPID = sortedGPIDs.first
        }
    }
}
