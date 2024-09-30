// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

/// The view model displaying current fetch gacha status.
@Observable @MainActor
public class GachaFetchVM<GachaType: GachaTypeProtocol> {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public struct GachaTypeDateCount: Hashable, Identifiable {
        // MARK: Lifecycle

        public init(date: Date, count: Int, gachaType: GachaType) {
            self.date = date
            self.count = count
            self.gachaType = gachaType
            self.poolType = gachaType.expressible
        }

        // MARK: Public

        public let date: Date
        public var count: Int
        public let gachaType: GachaType
        public let poolType: GachaPoolExpressible

        public var id: Int {
            hashValue
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(date)
            hasher.combine(gachaType)
        }
    }

    public enum Status {
        case waitingForURL
        case readyToFire(start: () -> Void, reinit: () -> Void)
        case inProgress(cancel: () -> Void)
        case got(page: Int, gachaType: GachaType, newItemCount: Int, cancel: () -> Void)
        case failFetching(page: Int, gachaType: GachaType, error: Error, retry: () -> Void)
        case finished(typeFetchedCount: [GachaType: Int], initialize: () -> Void)

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
    public var isForceOverrideModeEnabled = true

    public private(set) var client: GachaClient<GachaType>?

    // MARK: Internal

    func load(urlString: String) throws {
        client = try .init(gachaURLString: urlString)
        setPending()
    }

    func updateCachedItems(_ item: PZGachaEntrySendable) {
        if cachedItems.count > 20 {
            _ = cachedItems.removeFirst()
        }
        cachedItems.append(item)
    }

    func updateGachaDateCounts(_ item: PZGachaEntrySendable) {
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
                gachaType: .init(rawValue: item.gachaType)
            )
            gachaTypeDateCounts.append(count)
        }
        func predicateElement(_ element: GachaTypeDateCount) -> Bool {
            (element.date >= itemExpr.time) && (element.gachaType.rawValue == item.gachaType)
        }
        gachaTypeDateCounts.indicesMeeting(condition: predicateElement)?.forEach { index in
            self.gachaTypeDateCounts[index].count += 1
        }
    }

    func checkIDAndUIDExists(uid: String, id: String) -> Bool {
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

    func removeEntry(uid: String, id: String) throws {
        let gameStr = GachaType.game.rawValue
        try mainContext.delete(
            model: PZGachaEntryMO.self,
            where: #Predicate {
                $0.id == id && $0.uid == uid && $0.game == gameStr
            },
            includeSubclasses: false
        )
    }

    func checkGPIDExists(uid: String) -> Bool {
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

    // MARK: Private

    private var task: Task<Void, Never>?

    private var mainContext: ModelContext {
        GachaActor.shared.modelContainer.mainContext
    }

    private func setFinished() {
        withAnimation {
            self.status = .finished(typeFetchedCount: self.savedTypeFetchedCount, initialize: { self.initialize() })
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

    private func startFetching() {
        guard let client else { return }
        setInProgress()
        task = Task { [weak self] in
            guard let self else { return }
            do {
                for try await (gachaType, result) in client {
                    setGot(page: Int(result.page) ?? 0, gachaType: gachaType)
                    Task.detached { @MainActor @Sendable [weak self] in
                        guard let self else { return }
                        for item in result.listConverted {
                            Task {
                                withAnimation {
                                    self.updateCachedItems(item)
                                    self.updateGachaDateCounts(item)
                                }
                            }
                            try? await insert(item)
                            try? await Task.sleep(for: .seconds(0.5 / 20.0))
                        }
                        try? mainContext.save()
                    }
                }
                setFinished()
            } catch {
                if error is CancellationError {
                    setFinished()
                } else {
                    switch error {
                    case let error as GachaError:
                        switch error {
                        case let .fetchDataError(page, _, gachaType, error):
                            setFailFetching(page: page, gachaType: .init(rawValue: gachaType), error: error)
                        }
                    case let error as URLError where error.code == .cancelled:
                        setFinished()
                    default:
                        break
                        // since `next` is typed throwing it is unreachable here
                    }
                }
            }
        }
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
}
