// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: OfficialFeed.FeedEvent

@available(iOS 16.0, macCatalyst 16.0, *)
extension OfficialFeed {
    public struct FeedEvent: AbleToCodeSendHash, Identifiable, Defaults.Serializable {
        public let game: Pizza.SupportedGame
        public let id: Int
        public let title: String
        public let description: String
        public let banner: String
        public let endAt: String
        public let endAtTime: Date.IntervalDate
        public let endAtDate: Date
        public let lang: HoYo.APILang
    }

    /// This returns true even if no local cache entry is available.
    public static func getCachedEventsIfValid(for game: Pizza.SupportedGame) -> [FeedEvent]? {
        let lastFetchDate = Defaults[.officialFeedMostRecentFetchDate][game.rawValue]
        guard let lastFetchDate else { return nil }
        // dateDelta 必然大于 0。
        let dateDelta = [Date.now, lastFetchDate].map(\.timeIntervalSinceNow).reduce(0, -)
        guard dateDelta < (60 * 60 * 1) else { return nil }
        let cachedEvent = Defaults[.officialFeedCache].filter { $0.game == game }
        guard cachedEvent.first?.lang == .current else { return nil }
        return cachedEvent
    }

    public static func getAllBundledFeedEvents() -> [FeedEvent] {
        var resultStack = [FeedEvent]()
        for game in Pizza.SupportedGame.allCases {
            let rawPackage = try? game.getBundledTestOfficialFeedPackage()
            guard let rawPackage else { continue }
            resultStack.append(
                contentsOf: OfficialFeed.summarize(rawPackage, for: game, server: .asia(game))
            )
        }
        return resultStack
    }
}

@available(iOS 16.0, macCatalyst 16.0, *)
extension OfficialFeed {
    public static func getAllFeedEventsOnline(
        game givenGame: Pizza.SupportedGame? = nil,
        bypassCache: Bool = false
    ) async
        -> [FeedEvent] {
        var resultStack = [FeedEvent]()
        let games: [Pizza.SupportedGame]
        if let givenGame {
            games = [givenGame]
        } else {
            games = Pizza.SupportedGame.allCases
        }
        for game in games {
            if !bypassCache, let cachedEvent = getCachedEventsIfValid(for: game) {
                resultStack.append(contentsOf: cachedEvent)
                continue
            }
            var server = HoYo.Server(rawValue: Defaults[.defaultServer]) ?? .asia(.genshinImpact)
            switch server {
            case .celestia, .irminsul: server = .asia(game)
            default: server.changeGame(to: game)
            }
            let rawPackageResult = await game.getOfficialFeedPackageOnline(server)
            switch rawPackageResult {
            case let .success(rawPackage):
                let summarized = OfficialFeed.summarize(rawPackage, for: game, server: server)
                if !bypassCache {
                    Defaults[.officialFeedCache].removeAll { $0.game == game }
                    Defaults[.officialFeedCache].append(contentsOf: summarized)
                    Defaults[.officialFeedMostRecentFetchDate][game.rawValue] = .now
                }
                resultStack.append(contentsOf: summarized)
            case let .failure(error):
                print("[getAllFeedEventsOnline][\(game)] \(error)")
                continue
            }
        }
        return resultStack
    }

    public static func summarize(
        _ package: HoYoEventPack,
        for game: Pizza.SupportedGame,
        server: HoYo.Server
    )
        -> [FeedEvent] {
        var events: [FeedEvent] = []
        var server = server
        server.changeGame(to: game)
        let validEventTypeID = Self.validEventType(for: game)
        var contentMap = [Int: HoYoEventPack.Announcement]()
        package.content.list.forEach { rawContent in
            contentMap[rawContent.annID] = rawContent
        }
        package.content.picList?.forEach { rawContent in
            contentMap[rawContent.annID] = .init(
                annID: rawContent.annID,
                title: rawContent.title,
                subtitle: rawContent.subtitle,
                banner: rawContent.picList?.first?.img,
                content: rawContent.content,
                lang: rawContent.lang
            )
        }
        var metaStack = [HoYoEventPack.Meta]()
        metaStack.append(contentsOf: package.meta.list.flatMap(\.list))
        metaStack.append(contentsOf: package.meta.picList.flatMap(\.typeList).flatMap(\.list))
        metaStack.forEach { rawMeta in
            guard !validEventTypeID.intersection([rawMeta.type]).isEmpty else { return }
            guard let contentObj = contentMap[rawMeta.annID] else { return }
            guard var contentDescription = contentObj.content, !contentDescription.isEmpty else { return }
            Self.bleachNewsDescription(&contentDescription)
            var bannerImageLink = rawMeta.img ?? rawMeta.banner
            if bannerImageLink.isEmpty {
                bannerImageLink = contentObj.banner ?? ""
            }
            guard !bannerImageLink.isEmpty else { return }
            guard let endAtTime = Self.getRemainDays(rawMeta.endTime, server: server) else { return }
            let newModel = FeedEvent(
                game: game,
                id: rawMeta.annID,
                title: rawMeta.title.replacing(try! Regex(#"<[^>]+>"#), with: ""),
                description: contentDescription,
                banner: bannerImageLink,
                endAt: rawMeta.endTime,
                endAtTime: endAtTime.intervalDate,
                endAtDate: endAtTime.date,
                lang: contentObj.lang
            )
            events.append(newModel)
        }
        return events.sorted {
            $0.endAtDate < $1.endAtDate
        }
    }

    private static func validEventType(for game: Pizza.SupportedGame) -> Set<Int> {
        switch game {
        case .genshinImpact: [1]
        case .starRail: [3]
        case .zenlessZone: [1, 3]
        }
    }

    private static func getRemainDays(
        _ endAt: String, server: HoYo.Server
    )
        -> (intervalDate: Date.IntervalDate, date: Date)? {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = server.timeZone
        let endDate = dateFormatter.date(from: endAt)
        guard let endDate else { return nil }
        let interval = endDate - Date()
        return (intervalDate: interval, date: endDate)
    }

    private static func bleachNewsDescription(_ target: inout String) {
        // Necessary decoding (e.g., Unicode escapes)
        target.replace("\\u003c", with: "<")
        target.replace("\\u003e", with: ">")
        target.replace("\\\"", with: "\"")
        target.replace("\\u0026lt;", with: "<")
        target.replace("\\u0026gt;", with: ">")
        target.replace("&lt;", with: "<") // Extra handling for HTML entities
        target.replace("&gt;", with: ">") // Extra handling for HTML entities

        // Bleach styles
        target.replace(try! Regex("font-size:.*?rem"), with: "font-size:unset")
        target.replace(try! Regex("color:rgba(.*?)"), with: "color:unset")
        target.replace(try! Regex("color:rgb(.*?)"), with: "color:unset")
        target.replace(try! Regex("color: rgba(.*?)"), with: "color:unset")
        target.replace(try! Regex("color: rgb(.*?)"), with: "color:unset")

        // Remove `contenteditable="false"`
        target.replace(try! Regex(#"\s*contenteditable="false""#), with: "")

        // Keep the content inside <t class="t_lc"> tags, and remove the tags
        target.replace(try! Regex(#"(?s)<t\s+class="t_lc"[^>]*?>"#), with: "")
        target.replace(try! Regex(#"</t>"#), with: "")
    }
}
