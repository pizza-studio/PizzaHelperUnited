// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import SwiftUI
import WidgetKit

// MARK: - Broadcaster

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable @MainActor
public final class Broadcaster {
    public static let shared = Broadcaster()

    public private(set) var eventForUpdatingLocalEnkaAvatarCache: [String: Date] = .init()
    public private(set) var eventForUpdatingLocalHoYoLABAvatarCache: UUID = .init()
    public private(set) var eventForUserWallpaperDidSave: UUID = .init()
    public private(set) var eventForRefreshingTodayTab: UUID = .init()
    public private(set) var eventForRefreshingCurrentPage: UUID = .init()
    public private(set) var eventForJustSwitchedToTodayTab: UUID = .init()
    public private(set) var eventForStoppingRootTabTasks: UUID = .init()

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

@available(iOS 17.0, macCatalyst 17.0, *)
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
