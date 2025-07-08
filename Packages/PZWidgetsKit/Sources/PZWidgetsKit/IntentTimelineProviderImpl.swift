// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Intents
import WidgetKit

// MARK: - AppIntentUpgradable

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 9.0, *)
public protocol AppIntentUpgradable {
    associatedtype AppIntent: AppIntents.AppIntent
    var asAppIntent: AppIntent { get }
}

// MARK: - INThreadSafeTimelineProvider

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 9.0, *)
public protocol INThreadSafeTimelineProvider: IntentTimelineProvider, Sendable where Intent: AppIntentUpgradable,
    Entry: TimelineEntry & Sendable {
    typealias AppIntent = Intent.AppIntent
    typealias Context = TimelineProviderContext
    associatedtype NextGenTLProvider: CrossGenServiceableTimelineProvider where NextGenTLProvider.Intent == AppIntent,
        NextGenTLProvider.Entry == Self.Entry
    var asyncTLProvider: NextGenTLProvider { get }
}

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, watchOS 9.0, *)
extension INThreadSafeTimelineProvider {
    public func getSnapshot(
        for configuration: Intent,
        in context: Context,
        completion: @escaping @Sendable (Entry) -> Void
    ) {
        let newIntent = configuration.asAppIntent
        Task(priority: .userInitiated) {
            let completed = await self.asyncTLProvider.snapshot(for: newIntent)
            completion(completed)
        }
    }

    public func getTimeline(
        for configuration: Intent,
        in context: Context,
        completion: @escaping @Sendable (Timeline<Entry>) -> Void
    ) {
        let newIntent = configuration.asAppIntent
        Task(priority: .userInitiated) {
            let completed = await self.asyncTLProvider.timeline(for: newIntent)
            completion(completed)
        }
    }

    public func placeholder(in context: Context) -> Entry {
        asyncTLProvider.placeholder()
    }
}

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
