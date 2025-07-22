// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
import ActivityKit
import AppIntents
import Defaults
import Foundation
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit
import WidgetKit

@available(iOS 16.2, macCatalyst 16.2, *)
struct StaminaTimerRefreshIntent: AppIntent {
    // MARK: Public

    public static var isDiscoverable: Bool { false }

    // MARK: Internal

    static let title: LocalizedStringResource = "pzWidgetsKit.WidgetRefreshIntent.Refresh"

    func perform() async throws -> some IntentResult {
        let activities = StaminaLiveActivityController.shared.currentActivities
        let profiles = PZWidgets.getAllProfiles()
        for activity in activities {
            let profile = profiles.first(where: { profile in
                profile.uuid == activity.attributes.profileUUID
            })
            guard let profile else { continue }
            let result = try await profile.getDailyNote()
            StaminaLiveActivityController.shared.updateResinRecoveryTimerActivity(
                for: profile, data: result
            )
        }
        return .result()
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
struct StaminaTimerRerenderIntent: AppIntent {
    // MARK: Public

    public static var isDiscoverable: Bool { false }

    // MARK: Internal

    static let title: LocalizedStringResource = "pzWidgetsKit.WidgetRefreshIntent.Refresh"

    func perform() async throws -> some IntentResult {
        Task {
            let activities = StaminaLiveActivityController.shared.currentActivities
            for activity in activities {
                await activity.update(activity.content)
            }
        }
        return .result()
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
struct StaminaTimerSharedActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: LiveActivityAttributes.self
        ) { context in
            StaminaTimerLiveActivityWidgetView<StaminaTimerRerenderIntent, StaminaTimerRefreshIntent>(
                context: context
            )
        } dynamicIsland: { context in
            StaminaTimerDynamicIslandWidgetView(context: context).dynamicIsland
        }
    }
}

#endif
