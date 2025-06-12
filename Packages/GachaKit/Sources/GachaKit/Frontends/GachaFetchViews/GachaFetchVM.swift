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
            var uid: String?
            var validTransactionIDMap: [String: [String]] = [:]
            do {
                for try await (gachaType, result) in client {
                    setGot(page: Int(result.page) ?? 0, gachaType: gachaType)
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
                    try await GachaActor.shared.asyncSave()
                    GachaActor.remoteChangesAvailable = false
                }
                if isBleachingModeEnabled {
                    bleachCounter += await GachaActor.shared.bleach(
                        against: validTransactionIDMap, uid: uid, game: GachaType.game
                    )
                }
                setFinished()
            } catch {
                if error is CancellationError {
                    bleachCounter += await GachaActor.shared.bleach(
                        against: validTransactionIDMap, uid: uid, game: GachaType.game
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
                        bleachCounter += await GachaActor.shared.bleach(
                            against: validTransactionIDMap, uid: uid, game: GachaType.game
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
