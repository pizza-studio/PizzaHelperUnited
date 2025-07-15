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
        case progress
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

    public var currentProfile: PZProfileSendable? {
        didSet {
            cancelAllTasks()
            resetAllStatus()
            refresh()
        }
    }

    // 统一刷新
    public func refresh() {
        guard let profile = currentProfile else { return }
        cancelAllTasks()
        // 三个异步任务并发
        tasks["CharInventory"] = Task { await fetchCharInventory(for: profile) }
        tasks["Ledger"] = Task { await fetchLedger(for: profile) }
        tasks["BattleReport"] = Task { await fetchBattleReport(for: profile) }
    }

    // MARK: Private

    @ObservationIgnored private var refreshingStatus: Status<Void> = .standby
    @ObservationIgnored private var tasks: [String: Task<Void, Never>] = [:]
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension DetailPortalViewModel {
    private func cancelAllTasks() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }

    private func resetAllStatus() {
        taskStatus4CharInventory = .standby
        taskStatus4Ledger = .standby
        taskStatus4BattleReport = .standby
    }

    private func fetchCharInventory(for profile: PZProfileSendable) async {
        await MainActor.run {
            withAnimation {
                self.taskStatus4CharInventory = .progress
            }
        }
        do {
            let result = try await HoYo.getCharacterInventory(for: profile)
            guard let result else { throw CustomError.noResult }
            await MainActor.run {
                withAnimation {
                    self.taskStatus4CharInventory = .succeed(result)
                }
            }
        } catch {
            await MainActor.run {
                withAnimation {
                    if error is CancellationError || "\(error)" == "explicitlyCancelled" {
                        return
                    } else {
                        self.taskStatus4CharInventory = .fail(error)
                    }
                }
            }
        }
    }

    private func fetchLedger(for profile: PZProfileSendable) async {
        await MainActor.run {
            withAnimation {
                self.taskStatus4Ledger = .progress
            }
        }
        do {
            let result = try await HoYo.getLedgerData(for: profile)
            guard let result else { throw CustomError.noResult }
            await MainActor.run {
                withAnimation {
                    self.taskStatus4Ledger = .succeed(result)
                }
            }
        } catch {
            await MainActor.run {
                withAnimation {
                    if error is CancellationError || "\(error)" == "explicitlyCancelled" {
                        return
                    } else {
                        self.taskStatus4Ledger = .fail(error)
                    }
                }
            }
        }
    }

    private func fetchBattleReport(for profile: PZProfileSendable) async {
        await MainActor.run {
            withAnimation {
                self.taskStatus4BattleReport = .progress
            }
        }
        do {
            let result = try await HoYo.getBattleReportSet(for: profile)
            guard let result else { throw CustomError.noResult }
            await MainActor.run {
                withAnimation {
                    self.taskStatus4BattleReport = .succeed(result)
                }
            }
        } catch {
            await MainActor.run {
                withAnimation {
                    if error is CancellationError || "\(error)" == "explicitlyCancelled" {
                        return
                    } else {
                        self.taskStatus4BattleReport = .fail(error)
                    }
                }
            }
        }
    }

    enum CustomError: Error { case noResult }
}
