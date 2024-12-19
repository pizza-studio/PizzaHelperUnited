// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - OfficialFeed

@available(watchOS, unavailable)
public enum OfficialFeed {}

// MARK: OfficialFeed.FeedEvent

@available(watchOS, unavailable)
extension OfficialFeed {
    public struct FeedEvent: AbleToCodeSendHash, Identifiable {
        public let game: Pizza.SupportedGame
        public let id: Int
        public let title: String
        public let description: String
        public let banner: String
        public let endAt: String
        public let endAtTime: Date.IntervalDate
        public let endAtDate: Date
    }
}

@available(watchOS, unavailable)
extension OfficialFeed {
    public static func getAllFeedEventsOnline() async -> [FeedEvent] {
        var resultStack = [FeedEvent]()
        for game in Pizza.SupportedGame.allCases {
            var server = HoYo.Server(rawValue: Defaults[.defaultServer]) ?? .asia(.genshinImpact)
            server.changeGame(to: game)
            let rawPackageResult = await game.getOfficialFeedPackageOnline(server)
            switch rawPackageResult {
            case let .success(rawPackage):
                resultStack.append(
                    contentsOf: OfficialFeed.summarize(rawPackage, for: game, server: server)
                )
            case .failure: continue
            }
        }
        return resultStack
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
            if game == .starRail {
                print(game.description)
            }
            guard rawMeta.type == validEventTypeID else { return }
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
                endAtDate: endAtTime.date
            )
            events.append(newModel)
        }
        return events.sorted {
            $0.endAtDate < $1.endAtDate
        }
    }

    private static func validEventType(for game: Pizza.SupportedGame) -> Int {
        switch game {
        case .genshinImpact: 1
        case .starRail: 3
        case .zenlessZone: 4
        }
    }

    private static func getRemainDays(
        _ endAt: String, server: HoYo.Server
    )
        -> (intervalDate: Date.IntervalDate, date: Date)? {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
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

        // Remove `contenteditable="false"`
        target.replace(try! Regex(#"\s*contenteditable="false""#), with: "")

        // Keep the content inside <t class="t_lc"> tags, and remove the tags
        target.replace(try! Regex(#"(?s)<t\s+class="t_lc"[^>]*?>"#), with: "")
        target.replace(try! Regex(#"</t>"#), with: "")
    }
}
