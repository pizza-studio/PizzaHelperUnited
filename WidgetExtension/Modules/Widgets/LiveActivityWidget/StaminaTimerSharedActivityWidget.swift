// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
import ActivityKit
import AppIntents
import Foundation
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WallpaperKit
import WidgetKit

// NOTE: 所有 AppIntent Conformation 都需要在 SPM 外部（也就是 Xcode Target 内）就地实作。
// 任何基于 Protocols 的抽象工作都会妨碍到 AppIntent 的实际可用性。

@available(iOS 16.2, macCatalyst 16.2, *)
public struct StaminaTimerIntent4Redraw: AppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static var title: LocalizedStringResource { "pzWidgetsKit.WidgetRefreshIntent.Refresh" }
    public static var isDiscoverable: Bool { false }

    public let getLatestRemoteNotes: Bool = false

    public func perform() async throws -> some IntentResult {
        let activities = StaminaLiveActivityController.shared.currentActivities
        let profiles = PZWidgets.getAllProfiles()
        for activity in activities {
            let profile = profiles.first(where: { profile in
                profile.uuid == activity.attributes.profileUUID
            })
            guard let profile else { continue }
            let result = try await profile.getDailyNote(cached: !getLatestRemoteNotes)
            StaminaLiveActivityController.shared.updateResinRecoveryTimerActivity(
                for: profile, data: result
            )
        }
        return .result()
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
public struct StaminaTimerIntent4Refetch: AppIntent {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static var title: LocalizedStringResource { "pzWidgetsKit.WidgetRefreshIntent.Refresh" }
    public static var isDiscoverable: Bool { false }

    public let getLatestRemoteNotes: Bool = true

    public func perform() async throws -> some IntentResult {
        let activities = StaminaLiveActivityController.shared.currentActivities
        let profiles = PZWidgets.getAllProfiles()
        for activity in activities {
            let profile = profiles.first(where: { profile in
                profile.uuid == activity.attributes.profileUUID
            })
            guard let profile else { continue }
            let result = try await profile.getDailyNote(cached: !getLatestRemoteNotes)
            StaminaLiveActivityController.shared.updateResinRecoveryTimerActivity(
                for: profile, data: result
            )
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
            StaminaTimerLiveActivityWidgetView<StaminaTimerIntent4Redraw, StaminaTimerIntent4Refetch>(
                context: context
            )
        } dynamicIsland: { context in
            StaminaTimerDynamicIslandWidgetView(context: context).dynamicIsland
        }
    }
}

#endif
