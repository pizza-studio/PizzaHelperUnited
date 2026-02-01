// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - GachaFetchVM

/// The view model displaying current fetch gacha status.
@Observable @MainActor
@available(iOS 17.0, macCatalyst 17.0, *)
public class GachaFetchVM<GachaType: GachaTypeProtocol> {
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
        // 在抓取过程中保持萤幕常亮，避免因萤幕自动锁定而中断抓取。
        // Keep screen awake during fetching to prevent interruption from auto-lock.
        Self.setScreenIdleTimerDisabled(true)
        task = Task { [weak self] in
            // 确保在任务结束时（无论成功、取消或失败）恢复萤幕正常锁定设置。
            // Ensure screen idle timer is re-enabled when task ends (success, cancel, or failure).
            defer { Self.setScreenIdleTimerDisabled(false) }
            guard let self else { return }
            var uid: String?
            var validTransactionIDMap: [String: [String]] = [:]
            do {
                let assertion = BackgroundTaskAsserter(name: UUID().uuidString)
                do {
                    if await !assertion.state.isReleased {
                        GachaVM.shared.isDoingBatchInsertionAction = true
                        defer {
                            GachaVM.shared.isDoingBatchInsertionAction = false
                        }
                        for try await (gachaType, result) in client {
                            setGot(page: Int(result.page) ?? 0, gachaType: gachaType)
                            var transactionCounter = 0
                            // 每隔一个小保底，就存盘一次。
                            func saveDataPer16PagesOfTransactions() async throws {
                                transactionCounter += 1
                                if transactionCounter >= 16 {
                                    try await GachaActor.shared.asyncSave()
                                    transactionCounter = 0
                                    try await Task.sleep(for: .seconds(1))
                                }
                            }
                            for item in result.listConverted {
                                if uid == nil { uid = item.uid }
                                withAnimation {
                                    self.updateCachedItems(item)
                                    self.updateGachaDateCounts(item)
                                }
                                if isBleachingModeEnabled {
                                    validTransactionIDMap[item.time, default: []].append(item.id)
                                }
                                try await GachaActor.shared.insertRawEntrySansCommission(
                                    item, forceOverride: isForceOverrideModeEnabled
                                )
                                withAnimation {
                                    self.savedTypeFetchedCount[.init(rawValue: item.gachaType)]! += 1
                                }
                                try await Task.sleep(for: .seconds(0.5 / 20.0))
                            }
                            try await saveDataPer16PagesOfTransactions()
                        }
                        try await GachaActor.shared.asyncSave()
                        try await Task.sleep(for: .seconds(1))
                        if isBleachingModeEnabled {
                            bleachCounter += await GachaActor.shared.bleach(
                                against: validTransactionIDMap, uid: uid, game: GachaType.game
                            ) // This will do asyncSave at the end of its transaction block.
                            try await Task.sleep(for: .seconds(1))
                        }
                        GachaVM.shared.isDoingBatchInsertionAction = false
                        await GachaVM.shared.updateAllCachedGPIDs()
                        setFinished()
                    }
                    await assertion.release()
                } catch {
                    await assertion.release()
                    throw error
                }
            } catch {
                if error is CancellationError {
                    // 被取消时，最新的时间戳资料可能不完整，因此排除以防误删。
                    // On cancellation, the newest timestamp's data may be incomplete,
                    // so we exclude it to prevent accidental deletion.
                    bleachCounter += await GachaActor.shared.bleach(
                        against: validTransactionIDMap, uid: uid, game: GachaType.game,
                        excludeNewestTimeTag: true
                    )
                    setFinished()
                } else {
                    switch error {
                    case let error as GachaError:
                        switch error {
                        case let .fetchDataError(page, _, gachaType, error):
                            setFailFetching(page: page, gachaType: .init(rawValue: gachaType), error: error)
                        }
                    case let error as URLError where error.code == .cancelled:
                        // 同上，被取消时排除最新时间戳以防误删。
                        // Same as above, exclude newest timestamp on cancellation.
                        bleachCounter += await GachaActor.shared.bleach(
                            against: validTransactionIDMap, uid: uid, game: GachaType.game,
                            excludeNewestTimeTag: true
                        )
                        setFinished()
                    default:
                        break
                        // since `next` is typed throwing it is unreachable here
                    }
                }
            }
        }
    }

    /// 设置萤幕是否保持常亮。
    /// Set whether the screen should stay awake.
    /// - Parameter disabled: If true, the screen will not auto-lock. If false, normal auto-lock behavior resumes.
    private static func setScreenIdleTimerDisabled(_ disabled: Bool) {
        #if canImport(UIKit) && !os(watchOS)
        Task { @MainActor in
            UIApplication.shared.isIdleTimerDisabled = disabled
        }
        #endif
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
}
