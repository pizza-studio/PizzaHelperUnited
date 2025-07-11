// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import SwiftUI
import WidgetKit

// MARK: - Broadcaster

@MainActor
public final class Broadcaster: ObservableObject {
    public static let shared = Broadcaster()

    @Published public private(set) var eventForUpdatingLocalEnkaAvatarCache: [String: Date] = .init()
    @Published public private(set) var eventForUpdatingLocalHoYoLABAvatarCache: UUID = .init()
    @Published public private(set) var eventForUserWallpaperDidSave: UUID = .init()
    @Published public private(set) var eventForRefreshingTodayTab: UUID = .init()
    @Published public private(set) var eventForRefreshingCurrentPage: UUID = .init()
    @Published public private(set) var eventForJustSwitchedToTodayTab: UUID = .init()
    @Published public private(set) var eventForStoppingRootTabTasks: UUID = .init()

    public func userWallpaperEntryChangesDidSave() {
        eventForUserWallpaperDidSave = .init()
    }

    public func localEnkaAvatarCacheDidUpdate(uidWithGame: String) {
        eventForUpdatingLocalEnkaAvatarCache[uidWithGame] = .init()
    }

    public func localHoYoLABAvatarCacheDidUpdate() {
        eventForUpdatingLocalHoYoLABAvatarCache = .init()
    }

    public func todayTabDidSwitchTo() {
        eventForJustSwitchedToTodayTab = .init()
    }

    public func refreshPage() {
        eventForRefreshingCurrentPage = .init()
    }

    public func refreshTodayTab() {
        eventForRefreshingTodayTab = .init()
    }

    public func stopRootTabTasks() {
        eventForStoppingRootTabTasks = .init()
    }
}

extension Broadcaster {
    public func reloadAllTimeLinesAcrossWidgets() {
        WidgetCenter.shared.reloadAllTimelines()
    }

    public func requireOSNotificationCenterAuthorization() {
        Task {
            do {
                _ = try await PZNotificationCenter.requestAuthorization()
            } catch {
                print(error)
            }
        }
    }
}
