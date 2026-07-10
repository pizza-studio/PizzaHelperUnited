// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Combine
import Foundation
import Observation
import SwiftUI
import WidgetKit

// MARK: - Broadcaster

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
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
