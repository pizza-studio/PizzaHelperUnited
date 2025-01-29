// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - GachaFetchVM

/// The view model displaying current fetch gacha status.
@Observable @MainActor
public class GachaFetchVM<GachaType: GachaTypeProtocol>: ObservableObject {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public struct GachaTypeDateCount: Hashable, Identifiable {
        // MARK: Lifecycle

        public init(
            date: Date,
            count: Int,
            countAsMergedPool: Int,
            gachaType: GachaType,
            id: String
        ) {
            self.date = date
            self.count = count
            self.countAsMergedPool = countAsMergedPool
            self.gachaType = gachaType
            self.poolType = gachaType.expressible
            self.id = id
        }

        // MARK: Public

        public let date: Date
        public var count: Int
        public var countAsMergedPool: Int // 将原神的两个平行限定卡池合并计算，仅用于图表显示。
        public let gachaType: GachaType
        public let poolType: GachaPoolExpressible
        public let id: String

        public func hash(into hasher: inout Hasher) {
            hasher.combine(date)
            hasher.combine(count)
            hasher.combine(countAsMergedPool)
            hasher.combine(gachaType)
            hasher.combine(id)
        }
    }

    public enum Status {
        case waitingForURL
        case readyToFire(start: () -> Void, reinit: () -> Void)
        case inProgress(cancel: () -> Void)
        case got(page: Int, gachaType: GachaType, newItemCount: Int, cancel: () -> Void)
        case failFetching(page: Int, gachaType: GachaType, error: Error, retry: () -> Void)
        case finished(
            typeFetchedCount: [GachaType: Int],
            dataBleachedCount: Int,
            initialize: () -> Void
        )

        // MARK: Public

        public var isBusy: Bool {
            switch self {
            case .waitingForURL: false
            case .readyToFire: false
            case .inProgress: true
            case .got: true
            case .failFetching: false
            case .finished: false
            }
        }
    }

    public var savedTypeFetchedCount: [GachaType: Int] = Dictionary(
        uniqueKeysWithValues: GachaType.knownCases
            .map { gachaType in
                (gachaType, 0)
            }
    )

    public var status: Status = .waitingForURL
    public var cachedItems: [PZGachaEntrySendable] = []
    public var gachaTypeDateCounts: [GachaTypeDateCount] = []
    public var fetchRange: GachaFetchRange = .allAvailable
    public var chosenPools: Set<GachaType> = Set(GachaType.knownCases)
    public var isForceOverrideModeEnabled = true
    public var isBleachingModeEnabled = true
    public var showSucceededAlertToast: Bool = false
    public private(set) var bleachCounter = 0

    public private(set) var client: GachaClient<GachaType>?

    public func load(urlString: String) throws {
        client = try .init(gachaURLString: urlString)
        setPending()
    }

    // MARK: Private

    private var task: Task<Void, Never>?

    private var mainContext: ModelContext {
        GachaActor.shared.modelContainer.mainContext
    }

    private func initialize() {
        client = nil
        setWaitingForURL()
        savedTypeFetchedCount = Dictionary(
            uniqueKeysWithValues: GachaType.knownCases
                .map { gachaType in
                    (gachaType, 0)
                }
        )
        task?.cancel()
        cachedItems = []
        gachaTypeDateCounts = []
        bleachCounter = 0
    }

    private func retry() {
        setPending()
        client?.reset()
        savedTypeFetchedCount = Dictionary(
            uniqueKeysWithValues: GachaType.knownCases
                .map { gachaType in
                    (gachaType, 0)
                }
        )
        task?.cancel()
        cachedItems = []
        gachaTypeDateCounts = []
    }

    private func cancel() {
        task?.cancel()
    }

    private func startFetching() {
        guard var client else { return }
        client.fetchRange = fetchRange
        client.chosenPools = chosenPools
        setInProgress()
        task = Task { [weak self] in
            guard let self else { return }
            var bleacher: GachaBleachSputnik?
            do {
                for try await (gachaType, result) in client {
                    setGot(page: Int(result.page) ?? 0, gachaType: gachaType)
                    for item in result.listConverted {
                        if bleacher == nil, isBleachingModeEnabled {
                            bleacher = .init(uid: item.uid, game: GachaType.game)
                        }
                        withAnimation {
                            self.updateCachedItems(item)
                            self.updateGachaDateCounts(item)
                        }
                        bleacher?.validTransactionIDMap[item.time, default: []].append(item.id)
                        try await insert(item)
                        try await Task.sleep(for: .seconds(0.5 / 20.0))
                    }
                    try mainContext.save()
                    GachaActor.remoteChangesAvailable = false
                }
                bleacher?.startBleachTask(counter: &bleachCounter)
                setFinished()
            } catch {
                if error is CancellationError {
                    bleacher?.startBleachTask(counter: &bleachCounter)
                    setFinished()
                } else {
                    switch error {
                    case let error as GachaError:
                        switch error {
                        case let .fetchDataError(page, _, gachaType, error):
                            setFailFetching(page: page, gachaType: .init(rawValue: gachaType), error: error)
                        }
                    case let error as URLError where error.code == .cancelled:
                        bleacher?.startBleachTask(counter: &bleachCounter)
                        setFinished()
                    default:
                        break
                        // since `next` is typed throwing it is unreachable here
                    }
                }
            }
        }
    }

    private func setFinished() {
        withAnimation {
            self.status = .finished(
                typeFetchedCount: self.savedTypeFetchedCount,
                dataBleachedCount: self.bleachCounter,
                initialize: { self.initialize() }
            )
        }
    }

    private func setFailFetching(page: Int, gachaType: GachaType, error: Error) {
        if let task, task.isCancelled {
            setFinished()
        } else {
            withAnimation {
                self.status = .failFetching(
                    page: page,
                    gachaType: gachaType,
                    error: error,
                    retry: {
                        self.initialize()
                    }
                )
            }
        }
    }

    private func setGot(page: Int, gachaType: GachaType) {
        withAnimation {
            self.status = .got(
                page: page,
                gachaType: gachaType,
                newItemCount: self.savedTypeFetchedCount.values.reduce(.zero, +),
                cancel: {
                    self.cancel()
                }
            )
        }
    }

    private func setWaitingForURL() {
        withAnimation {
            self.status = .waitingForURL
        }
    }

    private func setPending() {
        withAnimation {
            self.status = .readyToFire(start: { self.startFetching() }, reinit: { self.initialize() })
        }
    }

    private func setInProgress() {
        withAnimation {
            self.status = .inProgress(cancel: { self.cancel() })
        }
    }

    /// 将给定的抽卡物品记录插入至本地 SwiftData 抽卡资料库。
    /// - Parameter gachaItem: 给定的抽卡物品记录（Sendable）。
    private func insert(_ gachaItem: PZGachaEntrySendable) async throws {
        if !isForceOverrideModeEnabled {
            guard !checkIDAndUIDExists(uid: gachaItem.uid, id: gachaItem.id) else { return }
        } else {
            try removeEntry(uid: gachaItem.uid, id: gachaItem.id)
        }
        mainContext.insert(gachaItem.asMO)
        if !checkGPIDExists(uid: gachaItem.uid) {
            let gpid = GachaProfileID(uid: gachaItem.uid, game: GachaType.game)
            mainContext.insert(gpid.asMO)
        }
        withAnimation {
            self.savedTypeFetchedCount[.init(rawValue: gachaItem.gachaType)]! += 1
        }
    }

    /// 更新抽卡记录缓存。
    /// - Parameter item: 给定的单笔抽卡记录（Sendable）。
    private func updateCachedItems(_ item: PZGachaEntrySendable) {
        if cachedItems.count > 20 {
            _ = cachedItems.removeFirst()
        }
        cachedItems.append(item)
    }

    /// 更新「抽卡卡池类型与抽卡数量」统计阵列。
    /// - Parameter item: 给定的单笔抽卡记录（Sendable）。
    private func updateGachaDateCounts(_ item: PZGachaEntrySendable) {
        let itemExpr = item.expressible
        let dateAndPoolMatched = gachaTypeDateCounts.first {
            ($0.date == itemExpr.time) && ($0.gachaType.rawValue == item.gachaType)
        }
        if dateAndPoolMatched == nil {
            let count = GachaTypeDateCount(
                date: itemExpr.time,
                count: gachaTypeDateCounts.filter { data in
                    (data.date < itemExpr.time) && (data.gachaType == .init(rawValue: item.gachaType))
                }.map(\.count).reduce(.zero, +),
                countAsMergedPool: gachaTypeDateCounts.filter { data in
                    (data.date < itemExpr.time) && (data.poolType == itemExpr.pool)
                }.map(\.count).reduce(.zero, +),
                gachaType: .init(rawValue: item.gachaType),
                id: itemExpr.id
            )
            withAnimation {
                gachaTypeDateCounts.append(count)
            }
        }
        func predicateElementByMergedPool(_ element: GachaTypeDateCount) -> Bool {
            (element.date >= itemExpr.time) && (element.poolType == itemExpr.pool)
        }
        gachaTypeDateCounts.indicesMeeting(condition: predicateElementByMergedPool)?.forEach { index in
            // 先处理将原神的两个限定卡池合并计算时的情形，回头绘制图表时会用到。
            self.gachaTypeDateCounts[index].countAsMergedPool += 1
            // 再分开处理原神的两个限定卡池各自的情形。
            if self.gachaTypeDateCounts[index].gachaType.rawValue == item.gachaType {
                self.gachaTypeDateCounts[index].count += 1
            }
        }
    }

    /// 自本地 SwiftData 抽卡资料库检查给定的 UID 与流水号是否已经有对应的本地记录。
    /// - Parameters:
    ///   - uid: 给定的当前游戏的 UID。
    ///   - id: 流水号。
    /// - Returns: 检查结果。
    private func checkIDAndUIDExists(uid: String, id: String) -> Bool {
        let gameStr = GachaType.game.rawValue
        var request = FetchDescriptor<PZGachaEntryMO>(
            predicate: #Predicate {
                $0.id == id && $0.uid == uid && $0.game == gameStr
            }
        )
        request.propertiesToFetch = [\.id, \.uid, \.game]
        do {
            let gachaItemMOCount = try mainContext.fetchCount(request)
            return gachaItemMOCount > 0
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return true
        }
    }

    /// 自本地 SwiftData 抽卡资料库移除指定 UID 与流水号的所有记录。
    /// - Parameters:
    ///   - uid: 给定的当前游戏的 UID。
    ///   - id: 流水号。
    private func removeEntry(uid: String, id: String) throws {
        let gameStr = GachaType.game.rawValue
        try mainContext.delete(
            model: PZGachaEntryMO.self,
            where: #Predicate {
                $0.id == id && $0.uid == uid && $0.game == gameStr
            },
            includeSubclasses: false
        )
    }

    /// 检查本地 SwiftData 抽卡资料库，确认是否有对应的 GPID（抽卡人）在库。
    /// - Parameter uid: 给定的当前游戏的 UID。
    /// - Returns: 检查结果。
    private func checkGPIDExists(uid: String) -> Bool {
        let gameStr = GachaType.game.rawValue
        let request = FetchDescriptor<PZGachaProfileMO>(
            predicate: #Predicate {
                $0.uid == uid && $0.gameRAW == gameStr
            }
        )
        do {
            let gpidMOCount = try mainContext.fetchCount(request)
            return gpidMOCount > 0
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return true
        }
    }
}

// MARK: - GachaBleachSputnik

@MainActor
private class GachaBleachSputnik {
    // MARK: Lifecycle

    public init(uid: String, game: Pizza.SupportedGame) {
        self.uid = uid
        self.game = game
        self.tzDelta = GachaKit.getServerTimeZoneDelta(uid: uid, game: game)
    }

    // MARK: Public

    public var validTransactionIDMap: [String: [String]] = [:]

    public func startBleachTask(counter bleachCounter: inout Int) {
        var allTimeTags: [TimeTag] = validTransactionIDMap.keys.compactMap {
            TimeTag($0, tzDelta: tzDelta)
        }.sorted { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 }
        /// 处理前先排查：
        /// 如果 allTimeTags 最旧的日期记录已经在库的话，就不处理这个最旧的日期记录，免得误伤已经在资料库内的更旧的抽卡记录。
        /// 这样处理的原因是：十连抽的时间戳都是雷同的。
        /// 理论上这样的漏网之鱼应该极为罕见，因为每个版本结束运营之后的抽卡记录都会固定。
        guard let oldestTimeTag = allTimeTags.first else { return }
        let allExistingTimeTagsInDB = allExistingTimeTagsInDB
        if allExistingTimeTagsInDB.map(\.time).contains(oldestTimeTag.time) {
            allTimeTags.removeFirst()
        }
        guard !allTimeTags.isEmpty else { return }
        // 开始处理。
        for timeTag in allTimeTags {
            guard let validTransactionIDs = validTransactionIDMap[timeTag.timeTagStr] else { continue }
            bleachTrashItemsByTimeTag(
                timeTag: timeTag,
                validTransactionIDs: validTransactionIDs,
                bleachCounter: &bleachCounter
            )
        }
        try? mainContext.save()
        GachaActor.remoteChangesAvailable = false
    }

    // MARK: Private

    private let uid: String
    private let game: Pizza.SupportedGame
    private let tzDelta: Int

    private var mainContext: ModelContext {
        GachaActor.shared.modelContainer.mainContext
    }

    private var allExistingTimeTagsInDB: [TimeTag] {
        let gameStr = game.rawValue
        var request = FetchDescriptor<PZGachaEntryMO>(
            predicate: #Predicate {
                $0.uid == uid && $0.game == gameStr
            }
        )
        request.propertiesToFetch = [\.time, \.uid, \.game]
        do {
            let fetched = try mainContext.fetch(request)
            var timeTags = fetched.compactMap {
                TimeTag($0.time, tzDelta: tzDelta)
            }
            timeTags = Array(Set(timeTags)) // Deduplicate.
            timeTags.sort { $0.time.timeIntervalSince1970 < $1.time.timeIntervalSince1970 }
            return timeTags
        } catch {
            print("ERROR FETCHING CONFIGURATION. \(error.localizedDescription)")
            return []
        }
    }

    /// 自本地 SwiftData 抽卡资料库移除由伺服器端此前错误生成的垃圾资料。
    /// - Parameters:
    ///   - timeTag: 时间戳。
    ///   - validTransactionIDs: 该时间戳对应的所有合理的流水号（阵列）。
    ///   - bleachCounter: 统计到底清理了多少笔垃圾资料。
    private func bleachTrashItemsByTimeTag(
        timeTag: TimeTag, validTransactionIDs: [String],
        bleachCounter: inout Int
    ) {
        guard !validTransactionIDs.isEmpty else { return }
        let gameStr = game.rawValue
        let timeTagStr = timeTag.timeTagStr
        var request = FetchDescriptor<PZGachaEntryMO>(
            predicate: #Predicate {
                $0.time == timeTagStr && $0.uid == uid && $0.game == gameStr
            }
        )
        request.propertiesToFetch = [\.id, \.uid, \.game, \.time]
        do {
            let matchedItems = try mainContext.fetch(request)
            matchedItems.forEach { currentItem in
                if !validTransactionIDs.contains(currentItem.id) {
                    mainContext.delete(currentItem)
                    bleachCounter += 1
                }
            }
            // 无须在此保存。之后会有统一的保存步骤。
        } catch {
            print("ERROR BLEACHING CONTENTS. \(error.localizedDescription)")
        }
    }
}
