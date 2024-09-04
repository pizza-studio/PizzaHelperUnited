// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftData
import SwiftUI

// MARK: - DetailPortalViewModel

// 注：这个 Class 不负责管理 Enka 展柜的 Raw Profile。

@Observable
public final class DetailPortalViewModel {
    // MARK: Lifecycle

    @MainActor
    public init() {
        let pzProfiles = try? PersistenceController.shared.modelContainer
            .mainContext.fetch(FetchDescriptor<PZProfileMO>())
            .sorted { $0.priority < $1.priority }
            .filter { $0.game != .zenlessZone } // 临时设定。
        self.currentProfile = pzProfiles?.first
        refresh()
    }

    // MARK: Public

    public enum Status<T> {
        case progress(Task<Void, Never>)
        case fail(Error)
        case succeed(T)
        case standby

        // MARK: Internal

        var isBusy: Bool {
            switch self {
            case .progress: return true
            default: return false
            }
        }
    }

    public var taskStatus4CharInventory: Status<any CharacterInventory> = .standby
    public var taskStatus4Ledger: Status<HoYo.LedgerData4GI> = .standby
    public var taskStatus4TravelStats: Status<HoYo.TravelStatsData4GI> = .standby

    public var currentProfile: PZProfileMO? {
        didSet {
            refresh()
        }
    }

    public func refresh() {
        Task {
            await fetchCharacterInventoryList()
            await fetchTravelStatsData()
            await fetchLedgerData()
        }
    }

    // MARK: Private
}

extension DetailPortalViewModel {
    @MainActor
    func fetchCharacterInventoryList() async {
        if case let .progress(task) = taskStatus4CharInventory { task.cancel() }
        let task = Task {
            do {
                guard let profile = self.currentProfile,
                      let queryResult = try await HoYo.getCharacterInventory(for: profile)
                else { return }
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4CharInventory = .succeed(queryResult)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4CharInventory = .fail(error)
                    }
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.taskStatus4CharInventory = .progress(task)
            }
        }
    }

    @MainActor
    func fetchLedgerData() async {
        if case let .progress(task) = taskStatus4Ledger { task.cancel() }
        guard currentProfile?.game == .genshinImpact else {
            taskStatus4Ledger = .standby
            return
        }
        let task = Task {
            do {
                let month = Calendar.current.dateComponents([.month], from: Date()).month
                guard let month, let profile = self.currentProfile else { return }
                let queryResult = try await HoYo.getLedgerData4GI(
                    month: month,
                    uid: profile.uid,
                    server: profile.server,
                    cookie: profile.cookie
                )
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4Ledger = .succeed(queryResult)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4Ledger = .fail(error)
                    }
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.taskStatus4Ledger = .progress(task)
            }
        }
    }

    @MainActor
    func fetchTravelStatsData() async {
        if case let .progress(task) = taskStatus4TravelStats { task.cancel() }
        let task = Task {
            do {
                guard let profile = self.currentProfile else { return }
                let queryResult = try await HoYo.getTravelStatsData4GI(for: profile)
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4TravelStats = .succeed(queryResult)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4TravelStats = .fail(error)
                    }
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.taskStatus4TravelStats = .progress(task)
            }
        }
    }
}
