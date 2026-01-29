// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - OfficialFeedFileHandler

@available(iOS 16.0, macCatalyst 16.0, *)
public enum OfficialFeedFileHandler {}

@available(iOS 16.0, macCatalyst 16.0, *)
extension OfficialFeedFileHandler {
    @MainActor public static let folderMonitor: FolderMonitor = .init(url: contentFolderURL)

    public static func migrateFromUserDefaults() {
        if let oldCacheData = UserDefaults.baseSuite.data(forKey: "officialFeedCache"),
           let oldCache = try? JSONDecoder().decode([OfficialFeed.FeedEvent].self, from: oldCacheData),
           !oldCache.isEmpty {
            let grouped = Dictionary(grouping: oldCache, by: { $0.game })
            for (game, events) in grouped {
                saveFeed(events, for: game, broadcastChanges: false)
            }
        }
        UserDefaults.baseSuite.removeObject(forKey: "officialFeedCache")
    }

    public static func getFeed(for game: Pizza.SupportedGame) -> [OfficialFeed.FeedEvent]? {
        let fileURL = getURL4Feed(game: game)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? data.parseAs([OfficialFeed.FeedEvent].self)
    }

    public static func getAllCachedFeeds(
        specifyGames games: any Collection<Pizza.SupportedGame> = []
    )
        -> [OfficialFeed.FeedEvent] {
        var results = [OfficialFeed.FeedEvent]()
        var hasAnyCache = false
        // `Pizza.SupportedGame` 已支援 Comparable。参见 PZBaseKit 内的相关 Extensions。
        var arrGames = Set(games).sorted()
        if arrGames.isEmpty {
            arrGames = Pizza.SupportedGame.allCases
        }
        for game in arrGames {
            if let feed = getFeed(for: game) {
                results.append(contentsOf: feed)
                hasAnyCache = true
            }
        }

        if !hasAnyCache {
            return OfficialFeed.getAllBundledFeedEvents(specifyGames: games)
        }
        return results
    }

    public static func saveFeed(
        _ events: [OfficialFeed.FeedEvent],
        for game: Pizza.SupportedGame,
        broadcastChanges: Bool = true // Kept for consistency, though unused for now
    ) {
        let fileURL = getURL4Feed(game: game)
        let encodedData = try? JSONEncoder().encode(events)
        guard let encodedData else { return }

        do {
            try encodedData.write(to: fileURL, options: .atomic)
            // If we need to broadcast changes in the future, do it here.
        } catch {
            print("[OfficialFeedFileHandler] Failed to save feed for \(game): \(error)")
        }
    }

    public static func removeFeed(for game: Pizza.SupportedGame) {
        let fileURL = getURL4Feed(game: game)
        try? FileManager.default.removeItem(at: fileURL)
        Defaults[.officialFeedMostRecentFetchDate][game.rawValue] = nil
    }

    /// We assume that this API never fails.
    private static var contentFolderURL: URL {
        let backgroundFolderURL: URL = {
            switch Pizza.isAppStoreRelease {
            case false: break
            case true:
                guard let groupContainerURL else { break }
                return groupContainerURL
                    .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                    .appendingPathComponent("CachedOfficialFeeds", isDirectory: true)
            }
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                .appendingPathComponent("CachedOfficialFeeds", isDirectory: true)
        }()

        try? FileManager.default.createDirectory(
            at: backgroundFolderURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderURL
    }

    private static func getURL4Feed(game: Pizza.SupportedGame) -> URL {
        contentFolderURL.appendingPathComponent(
            "OfficialFeed-\(game.rawValue).json", isDirectory: false
        )
    }
}
