// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SwiftData

// MARK: - GachaActor

@ModelActor
public actor GachaActor {
    public init(unitTests: Bool = false) {
        modelContainer = unitTests ? Self.makeContainer4UnitTests() : Self.makeContainer()
        modelExecutor = DefaultSerialModelExecutor(
            modelContext: .init(modelContainer)
        )
    }

    // MARK: Private
}

extension GachaActor {
    public static let shared = GachaActor()

    public static func makeContainer4UnitTests() -> ModelContainer {
        do {
            return try ModelContainer(
                for:
                PZGachaEntryMO.self,
                PZGachaProfileMO.self,
                configurations:
                ModelConfiguration(
                    "PZGachaKitDB",
                    schema: Self.makeSchema(),
                    isStoredInMemoryOnly: true,
                    groupContainer: .none,
                    cloudKitDatabase: .none
                )
            )
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error)")
        }
    }

    public static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(
                for: PZGachaEntryMO.self,
                PZGachaProfileMO.self,
                configurations: Self.modelConfig
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}

// MARK: - Schemes and Configs.

extension GachaActor {
    public static func makeSchema() -> Schema {
        Schema([PZGachaEntryMO.self, PZGachaProfileMO.self])
    }

    public static var modelConfig: ModelConfiguration {
        if Pizza.isAppStoreRelease {
            return ModelConfiguration(
                "PZGachaKitDB",
                schema: Self.makeSchema(),
                isStoredInMemoryOnly: false,
                groupContainer: .identifier(appGroupID),
                cloudKitDatabase: .private(iCloudContainerName)
            )
        } else {
            return ModelConfiguration(
                "PZGachaKitDB",
                schema: Self.makeSchema(),
                isStoredInMemoryOnly: false,
                groupContainer: .none,
                cloudKitDatabase: .private(iCloudContainerName)
            )
        }
    }
}

// MARK: - CDGachaMO Related Static Methods.

extension GachaActor {
    public func migrateOldGachasIntoProfiles() throws {
        let oldData = try CDGachaMOSputnik.shared.allCDGachaMOAsPZGachaEntryMO()
        try batchInsert(
            oldData,
            overrideDuplicatedEntries: false,
            refreshGachaProfiles: true
        )
    }

    public func deleteAllEntriesOfGPID(_ gpid: GachaProfileID) throws {
        try modelContext.transaction {
            let uid = gpid.uid
            let gameStr = gpid.game.rawValue
            try modelContext.delete(
                model: PZGachaEntryMO.self,
                where: #Predicate { matchedEntryMO in
                    matchedEntryMO.uid == uid && matchedEntryMO.game == gameStr
                }
            )
            try modelContext.delete(
                model: PZGachaProfileMO.self,
                where: #Predicate { matchedEntryMO in
                    matchedEntryMO.uid == uid && matchedEntryMO.gameRAW == gameStr
                }
            )
        }
        Task { @MainActor in
            GachaVM.shared.remoteChangesAvailable = false
        }
    }

    @discardableResult
    public func batchInsert(
        _ sources: [PZGachaEntrySendable],
        overrideDuplicatedEntries: Bool = false,
        refreshGachaProfiles: Bool = false
    ) throws
        -> Int {
        var insertedEntriesCount = 0
        try modelContext.transaction {
            var existingIDsDescriptor = FetchDescriptor<PZGachaEntryMO>()
            existingIDsDescriptor.propertiesToFetch = [\.id]
            var allExistingEntryIDs: Set<String> = .init(
                try modelContext.fetch(existingIDsDescriptor).map(\.id)
            )
            if overrideDuplicatedEntries, !allExistingEntryIDs.isEmpty {
                let allNewEntryIDs: Set<String> = .init(sources.map(\.id))
                let entryIDsToRemove = allExistingEntryIDs.intersection(allNewEntryIDs)
                // 注意：空集合在 intersection 其他集合时，结果恐不为空。
                if !entryIDsToRemove.isEmpty {
                    try modelContext.delete(
                        model: PZGachaEntryMO.self,
                        where: #Predicate { matchedEntryMO in
                            entryIDsToRemove.contains(matchedEntryMO.id)
                        }
                    )
                }
                allExistingEntryIDs.subtract(entryIDsToRemove)
            }
            var profiles: Set<GachaProfileID> = .init()
            sources.forEach { theEntry in
                if overrideDuplicatedEntries || !allExistingEntryIDs.contains(theEntry.id) {
                    modelContext.insert(theEntry.asMO)
                    insertedEntriesCount += 1
                }
                let profile = GachaProfileID(uid: theEntry.uid, game: theEntry.gameTyped)
                if !profiles.contains(profile) {
                    profiles.insert(profile)
                }
            }
        }
        Task { @MainActor in
            GachaVM.shared.remoteChangesAvailable = false
        }
        // try lazyRefreshProfiles(newProfiles: profiles)
        if refreshGachaProfiles {
            try refreshAllProfiles()
        }
        return insertedEntriesCount
    }

    public func lazyRefreshProfiles(newProfiles: Set<GachaProfileID>? = nil) throws {
        try modelContext.transaction {
            let existingProfiles = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
            var profiles = newProfiles ?? .init()
            existingProfiles.forEach {
                profiles.insert($0.asSendable)
                modelContext.delete($0)
            }
            let arrProfiles = profiles.sorted { $0.uidWithGame < $1.uidWithGame }
            arrProfiles.forEach { modelContext.insert($0.asMO) }
        }
        Task { @MainActor in
            GachaVM.shared.remoteChangesAvailable = false
        }
    }

    @discardableResult
    public func refreshAllProfiles() throws -> [GachaProfileID] {
        var newProfiles = Set<GachaProfileID>()
        try modelContext.transaction {
            let oldProfileMOs = try modelContext.fetch(FetchDescriptor<PZGachaProfileMO>())
            newProfiles = Set(oldProfileMOs.map(\.asSendable))
            var entryFetchDescriptor = FetchDescriptor<PZGachaEntryMO>()
            entryFetchDescriptor.propertiesToFetch = [\.uid, \.game]
            let filteredEntries = try modelContext.fetch(entryFetchDescriptor)
            filteredEntries.forEach { currentGachaEntry in
                let alreadyExisted = newProfiles.first { $0.uidWithGame == currentGachaEntry.uidWithGame }
                guard alreadyExisted == nil else { return }
                let newProfile = GachaProfileID(uid: currentGachaEntry.uid, game: currentGachaEntry.gameTyped)
                newProfiles.insert(newProfile)
            }
            oldProfileMOs.forEach {
                modelContext.delete($0)
            }
            newProfiles.forEach {
                modelContext.insert($0.asMO)
            }
        }
        return newProfiles.sorted { $0.uidWithGame < $1.uidWithGame }
    }
}

// MARK: - CRUD APIs for GachaVM.

extension GachaActor {
    public func fetchAllGPIDs() -> [GachaProfileID] {
        let resultRAW = try? modelContext.fetch(
            FetchDescriptor<PZGachaProfileMO>()
        ).map(\.asSendable)
        let result = resultRAW?.sorted {
            $0.uidWithGame < $1.uidWithGame
        }
        return (result ?? []).reduce(into: [GachaProfileID]()) {
            if !$0.contains($1) { $0.append($1) }
        }
    }

    public func fetchExpressibleEntries(
        _ descriptor: FetchDescriptor<PZGachaEntryMO>
    ) throws
        -> [GachaEntryExpressible] {
        var existedIDs = Set<String>() // 用来去除重复内容。
        var fetchedEntries = [GachaEntryExpressible]()
        try modelContext.transaction {
            let count = try modelContext.fetchCount(descriptor)
            if count > 0 {
                try modelContext.enumerate(descriptor) { rawEntry in
                    /// 补遗：检查日期时间格式错误者，发现了就纠正。
                    try rawEntry.fixTimeFieldIfNecessary(context: modelContext)
                    let expressible = rawEntry.expressible
                    if existedIDs.contains(expressible.id) {
                        modelContext.delete(rawEntry)
                    } else {
                        existedIDs.insert(expressible.id)
                        fetchedEntries.append(expressible)
                    }
                }
                if modelContext.hasChanges {
                    Task { @MainActor in
                        GachaVM.shared.remoteChangesAvailable = false
                    }
                }
            }
        }
        return fetchedEntries
    }
}

// MARK: - CRUD APIs for GachaFetchVM.

extension GachaActor {
    /// 自本地 SwiftData 抽卡资料库移除指定 UID 与流水号的所有记录。
    /// - Parameters:
    ///   - game: 游戏。
    ///   - uid: 给定的当前游戏的 UID。
    ///   - id: 流水号。
    private func removeEntry(game: Pizza.SupportedGame, uid: String, id: String) throws {
        let gameStr = game.rawValue
        try modelContext.delete(
            model: PZGachaEntryMO.self,
            where: #Predicate {
                $0.id == id && $0.uid == uid && $0.game == gameStr
            },
            includeSubclasses: false
        )
    }

    /// 将给定的抽卡物品记录插入至本地 SwiftData 抽卡资料库。
    /// - Parameter gachaItem: 给定的抽卡物品记录（Sendable）。
    public func insertRawEntrySansCommission(
        _ gachaItem: PZGachaEntrySendable,
        forceOverride isForceOverrideModeEnabled: Bool
    ) throws {
        let game = gachaItem.gameTyped
        if !isForceOverrideModeEnabled {
            guard !checkIDAndUIDExists(game: game, uid: gachaItem.uid, id: gachaItem.id)
            else { return }
        } else {
            try removeEntry(game: game, uid: gachaItem.uid, id: gachaItem.id)
        }
        modelContext.insert(gachaItem.asMO)
        if !checkGPIDExists(game: game, uid: gachaItem.uid) {
            let gpid = GachaProfileID(uid: gachaItem.uid, game: game)
            modelContext.insert(gpid.asMO)
        }
    }

    /// 自本地 SwiftData 抽卡资料库检查给定的 UID 与流水号是否已经有对应的本地记录。
    /// - Parameters:
    ///   - game: 游戏。
    ///   - uid: 给定的当前游戏的 UID。
    ///   - id: 流水号。
    /// - Returns: 检查结果。
    private func checkIDAndUIDExists(
        game: Pizza.SupportedGame,
        uid: String,
        id: String
    )
        -> Bool {
        let gameStr = game.rawValue
        var request = FetchDescriptor<PZGachaEntryMO>(
            predicate: #Predicate {
                $0.id == id && $0.uid == uid && $0.game == gameStr
            }
        )
        request.propertiesToFetch = [\.id, \.uid, \.game]
        do {
            let gachaItemMOCount = try modelContext.fetchCount(request)
            return gachaItemMOCount > 0
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return true
        }
    }

    /// 检查本地 SwiftData 抽卡资料库，确认是否有对应的 GPID（抽卡人）在库。
    /// - Parameters:
    ///   - game: 游戏。
    ///   - uid: 给定的当前游戏的 UID。
    /// - Returns: 检查结果。
    private func checkGPIDExists(game: Pizza.SupportedGame, uid: String) -> Bool {
        let gameStr = game.rawValue
        let request = FetchDescriptor<PZGachaProfileMO>(
            predicate: #Predicate {
                $0.uid == uid && $0.gameRAW == gameStr
            }
        )
        do {
            let gpidMOCount = try modelContext.fetchCount(request)
            return gpidMOCount > 0
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return true
        }
    }
}

// MARK: - APIs for bleaching tasks.

extension GachaActor {
    /// - Remark: UID must be non-null. Otherwise this API is no-op.
    public func bleach(
        against validTransactionIDMap: [String: [String]],
        uid: String?,
        game: Pizza.SupportedGame
    ) async
        -> Int {
        var bleachCounter = 0
        guard let uid else { return bleachCounter }
        let tzDelta = GachaKit.getServerTimeZoneDelta(uid: uid, game: game)
        var allTimeTags: [TimeTag] = validTransactionIDMap.keys.compactMap {
            TimeTag($0, tzDelta: tzDelta)
        }.sorted { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 }
        /// 处理前先排查：
        /// 如果 allTimeTags 最旧的日期记录已经在库的话，就不处理这个最旧的日期记录，免得误伤已经在资料库内的更旧的抽卡记录。
        /// 这样处理的原因是：十连抽的时间戳都是雷同的。
        /// 理论上这样的漏网之鱼应该极为罕见，因为每个版本结束运营之后的抽卡记录都会固定。
        guard let oldestTimeTag = allTimeTags.first else { return bleachCounter }
        do {
            let allExistingTimeTagsInDB = try getAllExistingTimeTagsInDB(game: game, uid: uid, tzDelta: tzDelta)
            if allExistingTimeTagsInDB.map(\.time).contains(oldestTimeTag.time) {
                allTimeTags.removeFirst()
            }
            guard !allTimeTags.isEmpty else { return bleachCounter }
            // 开始处理。
            try modelContext.transaction {
                for timeTag in allTimeTags {
                    guard let validTransactionIDs = validTransactionIDMap[timeTag.timeTagStr] else { continue }
                    try bleachTrashItemsByTimeTagSansCommission(
                        game: game,
                        uid: uid,
                        timeTag: timeTag,
                        validTransactionIDs: validTransactionIDs,
                        bleachCounter: &bleachCounter
                    )
                }
            }
        } catch {
            print("ERROR BLEACHING CONTENTS. \(error.localizedDescription)")
        }
        Task { @MainActor in
            GachaVM.shared.remoteChangesAvailable = false
        }
        return bleachCounter
    }

    private func getAllExistingTimeTagsInDB(
        game: Pizza.SupportedGame,
        uid: String,
        tzDelta: Int
    ) throws
        -> [TimeTag] {
        let gameStr = game.rawValue
        let thisUID = uid
        var request = FetchDescriptor<PZGachaEntryMO>(
            predicate: #Predicate {
                $0.uid == thisUID && $0.game == gameStr
            }
        )
        request.propertiesToFetch = [\.time, \.uid, \.game]
        let fetched = try modelContext.fetch(request)
        var timeTags = fetched.compactMap {
            TimeTag($0.time, tzDelta: tzDelta)
        }
        timeTags = Array(Set(timeTags)) // Deduplicate.
        timeTags.sort { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 }
        return timeTags
    }

    /// 自本地 SwiftData 抽卡资料库移除由伺服器端此前错误生成的垃圾资料。
    /// - Warning: 该函式不对 SwiftData 做出任何 commit changes 的操作。
    /// - Parameters:
    ///   - game: 游戏。
    ///   - uid: UID。
    ///   - timeTag: 时间戳。
    ///   - validTransactionIDs: 该时间戳对应的所有合理的流水号（阵列）。
    ///   - bleachCounter: 统计到底清理了多少笔垃圾资料。
    private func bleachTrashItemsByTimeTagSansCommission(
        game: Pizza.SupportedGame,
        uid: String,
        timeTag: TimeTag,
        validTransactionIDs: [String],
        bleachCounter: inout Int
    ) throws {
        guard !validTransactionIDs.isEmpty else { return }
        let gameStr = game.rawValue
        let timeTagStr = timeTag.timeTagStr
        let thisUID = uid
        var request = FetchDescriptor<PZGachaEntryMO>(
            predicate: #Predicate {
                $0.time == timeTagStr && $0.uid == thisUID && $0.game == gameStr
            }
        )
        request.propertiesToFetch = [\.id, \.uid, \.game, \.time]
        let matchedItems = try modelContext.fetch(request)
        matchedItems.forEach { currentItem in
            if !validTransactionIDs.contains(currentItem.id) {
                modelContext.delete(currentItem)
                bleachCounter += 1
            }
        }
        // 无须在此保存。之后会有统一的保存步骤。
    }
}
