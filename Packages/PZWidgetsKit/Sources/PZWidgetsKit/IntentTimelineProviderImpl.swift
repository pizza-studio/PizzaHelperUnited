// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import WidgetKit

// MARK: - CrossGenServiceableTimelineProvider

/// 该协定便于 iOS 16 的 Protocols 对接工作所需。
@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 9.0, *)
public protocol CrossGenServiceableTimelineProvider: Sendable {
    associatedtype Entry: TimelineEntry
    associatedtype Intent: AppIntent
    typealias Context = TimelineProviderContext
    func placeholder() -> Self.Entry
    func snapshot(for configuration: Self.Intent) async -> Entry
    func timeline(for configuration: Self.Intent) async -> Timeline<Entry>
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, visionOS 26.0, *)
extension CrossGenServiceableTimelineProvider where Self: AppIntentTimelineProvider {
    public func snapshot(for configuration: Self.Intent, in context: Self.Context) async -> Self.Entry {
        await snapshot(for: configuration)
    }

    public func timeline(for configuration: Self.Intent, in context: Self.Context) async -> Timeline<Self.Entry> {
        await timeline(for: configuration)
    }

    public func placeholder(in context: Self.Context) -> Self.Entry {
        placeholder()
    }
}
