// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import WidgetKit

// MARK: - LockScreenLoopWidgetProvider

/// This struct actually "inherits" from LockScreenWidgetProvider with extra options.
@available(iOS 16.2, *)
@available(macCatalyst, unavailable)
@available(macOS, unavailable)
struct INLockScreenLoopWidgetProvider: INThreadSafeTimelineProvider {
    // MARK: Lifecycle

    public init(
        games: Set<Pizza.SupportedGame>? = nil,
        recommendationsTag: LocalizedStringResource
    ) {
        var games = games
        if let givenGames = games, givenGames.isEmpty { games = nil }
        self.asyncTLProvider = .init(games: games, recommendationsTag: recommendationsTag)
    }

    // MARK: Public

    public typealias Entry = ProfileWidgetEntry
    public typealias Intent = SelectAccountAndShowWhichInfoIntent
    public typealias NextGenTLProvider = LockScreenLoopWidgetProvider

    public let asyncTLProvider: NextGenTLProvider

    public var games: Set<Pizza.SupportedGame> { asyncTLProvider.games }
    public var recommendationsTag: LocalizedStringResource { asyncTLProvider.recommendationsTag }

    public func recommendations() -> [IntentRecommendation<Intent>] {
        #if os(watchOS)
        return PZWidgets.getAllProfiles().compactMap { config in
            let intent = Intent()
            intent.account = INAccountIntentEntity(
                identifier: config.uuid.uuidString,
                display: config.name + "\n(\(config.uidWithGame))"
            )
            if !games.contains(config.game) { return nil }
            return .init(
                intent: intent,
                description: config.name + "\n\(config.uidWithGame)\n" + String(
                    localized: recommendationsTag
                )
            )
        }
        #else
        return []
        #endif
    }
}

// MARK: - LockScreenWidgetProvider

@available(iOS 16.2, *)
@available(macCatalyst, unavailable)
@available(macOS, unavailable)
struct INLockScreenWidgetProvider: INThreadSafeTimelineProvider {
    // MARK: Lifecycle

    public init(
        games: Set<Pizza.SupportedGame>? = nil,
        recommendationsTag: LocalizedStringResource
    ) {
        var games = games
        if let givenGames = games, givenGames.isEmpty {
            games = nil
        }
        self.asyncTLProvider = .init(games: games, recommendationsTag: recommendationsTag)
    }

    // MARK: Public

    public typealias Entry = ProfileWidgetEntry
    public typealias Intent = SelectOnlyAccountIntent
    public typealias NextGenTLProvider = LockScreenWidgetProvider

    public let asyncTLProvider: NextGenTLProvider

    public var games: Set<Pizza.SupportedGame> { asyncTLProvider.games }
    public var recommendationsTag: LocalizedStringResource { asyncTLProvider.recommendationsTag }

    public func recommendations() -> [IntentRecommendation<Intent>] {
        #if os(watchOS)
        return PZWidgets.getAllProfiles().compactMap { config in
            let intent = Intent()
            intent.account = INAccountIntentEntity(
                identifier: config.uuid.uuidString,
                display: config.name + "\n(\(config.uidWithGame))"
            )
            if !games.contains(config.game) { return nil }
            return .init(
                intent: intent,
                description: config.name + "\n\(config.uidWithGame)\n" + String(
                    localized: recommendationsTag
                )
            )
        }
        #else
        return []
        #endif
    }

    // MARK: Private

    private static var viewConfig: WidgetViewConfig { .init(noticeMessage: nil) }
}

#endif
