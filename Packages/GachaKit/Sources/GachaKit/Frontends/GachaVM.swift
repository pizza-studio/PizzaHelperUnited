// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Observation
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - GachaVM

@Observable
public class GachaVM: @unchecked Sendable {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public enum State: String, Sendable, Hashable, Identifiable {
        case busy
        case standBy

        // MARK: Public

        public var id: String { rawValue }
    }

    public static let shared = GachaVM()

    public var allAvailableGPIDs: [GachaProfileID] = []
    public var task: Task<Void, Never>?
    public var cachedEntries: [GachaEntryExpressible] = []
    public var currentPoolType: GachaPoolExpressible?

    public var taskState: State = .standBy

    public var errorMsg: String?

    public var currentGachaProfile: PZGachaProfileMO? {
        didSet {
            currentPoolType = Self.defaultPoolType(for: currentGachaProfile?.game)
            updateCachedEntries()
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
    public func handleError(_ error: Error) {
        withAnimation {
            errorMsg = "\(error)"
        }
        GachaActor.sharedBg.modelExecutor.modelContext.rollback()
        task?.cancel()
    }

    public func updateCachedEntries() {
        guard let currentGachaProfile else {
            withAnimation {
                cachedEntries.removeAll()
            }
            return
        }
        task?.cancel()
        withAnimation {
            taskState = .busy
            errorMsg = nil
        }
        task = Task {
            do {
                let descriptor = FetchDescriptor<PZGachaEntryMO>(
                    predicate: PZGachaEntryMO.predicate(
                        owner: currentGachaProfile,
                        rarityLevel: nil
                    ),
                    sortBy: [SortDescriptor(\PZGachaEntryMO.id, order: .reverse)]
                )
                var existedIDs = Set<String>() // 用来去除重复内容。
                var result = [GachaEntryExpressible]()
                let context = GachaActor.sharedBg.modelExecutor.modelContext
                let count = try context.fetchCount(descriptor)
                if count > 0 {
                    try context.enumerate(descriptor) { rawEntry in
                        let expressible = rawEntry.expressible
                        if existedIDs.contains(expressible.id) {
                            context.delete(rawEntry)
                        } else {
                            existedIDs.insert(expressible.id)
                            result.append(expressible)
                        }
                    }
                    if context.hasChanges {
                        try context.save()
                    }
                }
                Task { @MainActor in
                    withAnimation {
                        cachedEntries = result
                        taskState = .standBy
                        errorMsg = nil
                        // 此处不需要检查 currentGachaProfile 是否为 nil。
                    }
                }
            } catch {
                handleError(error)
            }
        }
    }
}
