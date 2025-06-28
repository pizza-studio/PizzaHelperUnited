// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import Observation
import PZAccountKit
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

// MARK: - DetailPortalViewModel

// 注：这个 Class 不负责管理 Enka 展柜的 Raw Profile。

@Observable @MainActor
public final class DetailPortalViewModel: ObservableObject {
    // MARK: Lifecycle

    public init() {
        let pzProfiles: [PZProfileSendable] = Defaults[.pzProfiles].map(\.value)
            .sorted { $0.priority < $1.priority }
            .filter { $0.game != .zenlessZone } // 临时设定。
        self.currentProfile = pzProfiles.first
        refresh()
        Task {
            for await newMap in Defaults.updates(.pzProfiles) {
                let pzProfilesNow: [PZProfileSendable] = newMap.map(\.value)
                    .sorted { $0.priority < $1.priority }
                    .filter { $0.game != .zenlessZone } // 临时设定。
                let allUIDWithGames = pzProfilesNow.map(\.uidWithGame)
                if let currentProfile = self.currentProfile, !allUIDWithGames.contains(currentProfile.uidWithGame) {
                    self.currentProfile = pzProfilesNow.first
                }
            }
        }
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

    public static let shared = DetailPortalViewModel()

    public var taskStatus4CharInventory: Status<any CharacterInventory> = .standby
    public var taskStatus4Ledger: Status<any Ledger> = .standby
    public var taskStatus4BattleReport: Status<any BattleReportSet> = .standby
    @ObservationIgnored public var refreshingStatus: Status<Void> = .standby

    public var currentProfile: PZProfileSendable? {
        didSet {
            if case let .progress(task) = refreshingStatus { task.cancel() }
            refreshingStatus = .standby
            refresh()
        }
    }

    public func refresh() {
        guard case .standby = refreshingStatus else { return }
        let task = Task {
            await self.fetchCharacterInventoryList()
            await self.fetchLedgerData()
            await self.fetchBattleReportSet()
            refreshingStatus = .standby
        }
        refreshingStatus = .progress(task)
    }
}

extension DetailPortalViewModel {
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

    func fetchLedgerData() async {
        if case let .progress(task) = taskStatus4Ledger { task.cancel() }
        let task = Task {
            do {
                guard let profile = self.currentProfile,
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

    func fetchBattleReportSet() async {
        if case let .progress(task) = taskStatus4BattleReport { task.cancel() }
        let task = Task {
            do {
                guard let profile = self.currentProfile,
                      let queryResult = try await HoYo.getBattleReportSet(for: profile)
                else { return }
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4BattleReport = .succeed(queryResult)
                    }
                }
            } catch {
                Task.detached { @MainActor in
                    withAnimation {
                        self.taskStatus4BattleReport = .fail(error)
                    }
                }
            }
        }
        Task.detached { @MainActor in
            withAnimation {
                self.taskStatus4BattleReport = .progress(task)
            }
        }
    }
}
