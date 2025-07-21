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

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
public final class DetailPortalViewModel {
    // MARK: Lifecycle

    public init() {
        refresh()
        Task {
            for await newMap in Defaults.updates(.pzProfiles) {
                let pzProfilesNow: [PZProfileSendable] = newMap.map(\.value)
                    .sorted { $0.priority < $1.priority }
                    .filter { $0.game != .zenlessZone } // 临时设定。
                let allUIDWithGames = pzProfilesNow.map(\.uidWithGame)
                if let currentProfile = self.currentProfile {
                    if !allUIDWithGames.contains(currentProfile.uidWithGame) {
                        self.currentProfile = pzProfilesNow.first
                    } else if let currentProfileUpdated = newMap[currentProfile.uuid.uuidString] {
                        self.currentProfile?.inherit(from: currentProfileUpdated)
                    }
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

        mutating func cancelAndStandBy() {
            if case let .progress(task) = self { task.cancel() }
            self = .standby
        }

        mutating func goProgress(task: Task<Void, Never>) {
            self = .progress(task)
        }

        mutating func accept(_ succeededObj: T) {
            self = .succeed(succeededObj)
        }

        mutating func accept(_ error: Error) {
            if error is CancellationError || "\(error)" == "explicitlyCancelled" {
                return
            }
            self = .fail(error)
        }
    }

    public static let shared = DetailPortalViewModel()

    public var taskStatus4CharInventory: Status<any CharacterInventory> = .standby
    public var taskStatus4Ledger: Status<any Ledger> = .standby
    public var taskStatus4BattleReport: Status<any BattleReportSet> = .standby
    @ObservationIgnored public var refreshingStatus: Status<Void> = .standby

    public var currentProfile: PZProfileSendable? = {
        let pzProfiles: [PZProfileSendable] = Defaults[.pzProfiles].map(\.value)
            .sorted { $0.priority < $1.priority }
            .filter { $0.game != .zenlessZone } // 临时设定。
        return pzProfiles.first
    }() {
        didSet {
            if oldValue != currentProfile, currentProfile != nil {
                if case let .progress(task) = refreshingStatus { task.cancel() }
                refreshingStatus = .standby
                refresh()
            }
        }
    }

    public func refresh() {
        guard case .standby = refreshingStatus else { return }
        withAnimation {
            taskStatus4CharInventory.cancelAndStandBy()
            taskStatus4Ledger.cancelAndStandBy()
            taskStatus4BattleReport.cancelAndStandBy()
        }
        let task = Task {
            // 此处的 `HoYo.waitFor300ms()` 是必需的，否则伺服器会喷 TOO MANY REQUESTS。
            await self.fetchCharacterInventoryList()
            await HoYo.waitFor300ms()
            await self.fetchLedgerData()
            await HoYo.waitFor300ms()
            await self.fetchBattleReportSet()
            refreshingStatus = .standby
        }
        refreshingStatus = .progress(task)
    }

    // MARK: Private

    private func animateOnMain<T>(
        resultType: T.Type = T.self,
        body action: @MainActor () throws -> T
    ) async rethrows
        -> T where T: Sendable {
        try withAnimation {
            try action()
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension DetailPortalViewModel {
    enum DPVError: Error { case noResult }
    private func update<T: Sendable>(_ status: Status<T>, _ task: () async throws -> T?) async -> Status<T> {
        var status = status
        do {
            let retrieved = try await task()
            guard let retrieved else { throw DPVError.noResult }
            await animateOnMain { status.accept(retrieved) }
        } catch {
            await animateOnMain { status.accept(error) }
        }
        return status
    }

    func fetchCharacterInventoryList() async {
        guard let profile = currentProfile else { return }
        if case let .progress(task) = taskStatus4CharInventory { task.cancel() }
        let newTask = await update(taskStatus4CharInventory) {
            try await HoYo.getCharacterInventory(for: profile)
        }
        await animateOnMain {
            taskStatus4CharInventory = newTask
        }
    }

    func fetchLedgerData() async {
        guard let profile = currentProfile else { return }
        if case let .progress(task) = taskStatus4Ledger { task.cancel() }
        let newTask = await update(taskStatus4Ledger) {
            try await HoYo.getLedgerData(for: profile)
        }
        await animateOnMain {
            taskStatus4Ledger = newTask
        }
    }

    func fetchBattleReportSet() async {
        guard let profile = currentProfile else { return }
        if case let .progress(task) = taskStatus4BattleReport { task.cancel() }
        let newTask = await update(taskStatus4BattleReport) {
            try await HoYo.getBattleReportSet(for: profile)
        }
        await animateOnMain {
            taskStatus4BattleReport = newTask
        }
    }
}
