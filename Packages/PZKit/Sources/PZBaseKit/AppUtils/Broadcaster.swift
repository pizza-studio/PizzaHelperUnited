// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Combine
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
        Task { @MainActor in
            eventForUserWallpaperDidSave = .init()
        }
    }

    public func localEnkaAvatarCacheDidUpdate(uidWithGame: String) {
        Task { @MainActor in
            eventForUpdatingLocalEnkaAvatarCache[uidWithGame] = .init()
        }
    }

    public func localHoYoLABAvatarCacheDidUpdate() {
        Task { @MainActor in
            eventForUpdatingLocalHoYoLABAvatarCache = .init()
        }
    }

    public func todayTabDidSwitchTo() {
        Task { @MainActor in
            eventForJustSwitchedToTodayTab = .init()
        }
    }

    public func refreshPage() {
        Task { @MainActor in
            eventForRefreshingCurrentPage = .init()
        }
    }

    public func refreshTodayTab() {
        Task { @MainActor in
            eventForRefreshingTodayTab = .init()
        }
    }

    public func stopRootTabTasks() {
        Task { @MainActor in
            eventForStoppingRootTabTasks = .init()
        }
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
