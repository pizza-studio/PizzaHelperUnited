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
public final class DetailPortalViewModel: ObservableObject {
    // MARK: Lifecycle

    @MainActor
    public init() {
        let actor = PZProfileActor.shared
        let context = actor.modelContainer.mainContext
        let pzProfiles = try? context.fetch(FetchDescriptor<PZProfileMO>())
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
            case .progress: true
            default: false
            }
        }
    }

    @MainActor public var taskStatus4CharInventory: Status<any CharacterInventory> = .standby
    @MainActor public var taskStatus4Ledger: Status<any Ledger> = .standby
    @MainActor public var taskStatus4AbyssReport: Status<any AbyssReportSet> = .standby

    @ObservationIgnored public var refreshingStatus: Status<Void> = .standby

    @MainActor public var currentProfile: PZProfileMO? {
        didSet {
            if case let .progress(task) = refreshingStatus { task.cancel() }
            refreshingStatus = .standby
            refresh()
        }
    }

    @MainActor
    public func refresh() {
        guard case .standby = refreshingStatus else { return }
        let task = Task {
            await self.fetchCharacterInventoryList()
            await self.fetchLedgerData()
            await self.fetchAbyssReportSet()
            refreshingStatus = .standby
        }
        refreshingStatus = .progress(task)
    }
}

extension DetailPortalViewModel {
    @MainActor
    func fetchCharacterInventoryList() async {
        if case let .progress(task) = taskStatus4CharInventory { task.cancel() }
        let task = Task {
            do {
                guard let profile = self.currentProfile?.asSendable,
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
        let task = Task {
            do {
                guard let profile = self.currentProfile?.asSendable,
                      let queryResult = try await HoYo.getLedgerData(for: profile)
                else { return }
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
    func fetchAbyssReportSet() async {
        if case let .progress(task) = taskStatus4AbyssReport { task.cancel() }
        let task = Task {
            do {
                guard let profile = self.currentProfile?.asSendable,
                      let queryResult = try await HoYo.getAbyssReportSet(for: profile)
                else { return }
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4AbyssReport = .succeed(queryResult)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4AbyssReport = .fail(error)
                    }
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.taskStatus4AbyssReport = .progress(task)
            }
        }
    }
}
