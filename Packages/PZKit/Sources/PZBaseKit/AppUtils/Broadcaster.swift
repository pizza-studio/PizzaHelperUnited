// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Observation
import SwiftUI
import WidgetKit

// MARK: - Broadcaster

@Observable @MainActor
public final class Broadcaster: ObservableObject, Sendable {
    public static let shared = Broadcaster()

    public private(set) var eventForRefreshingCurrentPage: UUID = .init()
    public private(set) var eventForJustSwitchedToTodayTab: UUID = .init()
    public private(set) var eventForStoppingRootTabTasks: UUID = .init()
    public var splitViewVisibility: NavigationSplitViewVisibility = .all // Accessible by SPM.

    public func todayTabDidSwitchTo() {
        eventForJustSwitchedToTodayTab = .init()
    }

    public func refreshPage() {
        eventForRefreshingCurrentPage = .init()
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
