// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.
// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Defaults
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import WidgetKit

// MARK: - DualProfileWidgetEntry

@available(watchOS, unavailable)
struct DualProfileWidgetEntry: TimelineEntry {
    // MARK: Lifecycle

    init(
        date: Date,
        resultSlot1: Result<any DailyNoteProtocol, any Error>,
        resultSlot2: Result<any DailyNoteProtocol, any Error>,
        viewConfig: WidgetViewConfiguration,
        profileSlot1: PZProfileSendable?,
        profileSlot2: PZProfileSendable?,
        pilotAssetMap: [URL: SendableImagePtr]? = nil,
        events: [EventModel]
    ) {
        self.date = date
        self.resultSlot1 = resultSlot1
        self.resultSlot2 = resultSlot2
        self.viewConfig = viewConfig
        self.profileSlot1 = profileSlot1
        self.profileSlot2 = profileSlot2
        self.events = events
        self.pilotAssetMap = pilotAssetMap ?? [:]
    }

    // MARK: Internal

    let date: Date
    let timestampOnCreation: Date = .now
    let resultSlot1: Result<any DailyNoteProtocol, any Error>
    let resultSlot2: Result<any DailyNoteProtocol, any Error>
    let viewConfig: WidgetViewConfiguration
    let profileSlot1: PZProfileSendable?
    let profileSlot2: PZProfileSendable?
    let events: [EventModel]
    let pilotAssetMap: [URL: SendableImagePtr]

    var relevance: TimelineEntryRelevance? {
        .init(score: Swift.max(countRelevance(resultSlot1), countRelevance(resultSlot2)))
    }

    func countRelevance(_ result: Result<any DailyNoteProtocol, any Error>) -> Float {
        switch result {
        case let .success(data):
            if data.staminaFullTimeOnFinish >= .now {
                return 10
            }
            let stamina = data.staminaIntel
            return 10 * Float(stamina.finished) / Float(stamina.all)
        case .failure:
            return 0
        }
    }
}

// MARK: - DualProfileWidgetProvider

@available(watchOS, unavailable)
struct DualProfileWidgetProvider: AppIntentTimelineProvider {
    // MARK: Internal

    typealias Entry = DualProfileWidgetEntry
    typealias Intent = SelectDualProfileIntent

    func recommendations() -> [AppIntentRecommendation<Intent>] { [] }

    func placeholder(in context: Context) -> Entry {
        let sampleData1 = Pizza.SupportedGame.genshinImpact.exampleDailyNoteData
        let sampleData2 = Pizza.SupportedGame.starRail.exampleDailyNoteData
        let assetMap = Self.prepareAssetMapImmediately([sampleData1, sampleData2])
        return Entry(
            date: Date(),
            resultSlot1: .success(sampleData1),
            resultSlot2: .success(sampleData2),
            viewConfig: .defaultConfig,
            profileSlot1: .getDummyInstance(for: .genshinImpact),
            profileSlot2: .getDummyInstance(for: .starRail),
            pilotAssetMap: assetMap,
            events: Defaults[.officialFeedCache].filter { $0.game != .zenlessZone }
        )
    }

    func snapshot(
        for configuration: Intent,
        in context: Context
    ) async
        -> Entry {
        let eventResults = Defaults[.officialFeedCache].filter { $0.game != .zenlessZone }
        let games = Pizza.SupportedGame.initFromDualProfileConfig(intent: configuration)
        var game1 = games.slot1 ?? .genshinImpact
        var game2 = games.slot2 ?? .starRail
        if game1 == game2 {
            game1 = .genshinImpact
            game2 = .starRail
        }
        let sampleData1 = game1.exampleDailyNoteData
        let sampleData2 = game2.exampleDailyNoteData
        let assetMap = await Self.prepareAssetMap([sampleData1, sampleData2])
        return Entry(
            date: Date(),
            resultSlot1: .success(sampleData1),
            resultSlot2: .success(sampleData2),
            viewConfig: .defaultConfig,
            profileSlot1: .getDummyInstance(for: .genshinImpact),
            profileSlot2: .getDummyInstance(for: .starRail),
            pilotAssetMap: assetMap,
            events: eventResults
        )
    }

    func timeline(
        for configuration: Intent,
        in context: Context
    ) async
        -> Timeline<Entry> {
        let result: (entries: [Entry], refreshTime: Date) = await Task(priority: .userInitiated) {
            var refreshTime = PZWidgets.getRefreshDateByGameStamina(game: nil)
            let entries = await Self.getEntries(configuration: configuration, refreshTime: &refreshTime)
            return (entries, refreshTime)
        }.value
        return Timeline(
            entries: result.entries,
            policy: .after(result.refreshTime)
        )
    }

    // MARK: Private

    private static func getEntries(configuration: Intent, refreshTime: inout Date) async -> [Entry] {
        let viewConfig = WidgetViewConfiguration(configuration, nil)
        let intentEntity1 = configuration.profileSlot1
        let intentEntity2 = configuration.profileSlot2

        let findProfileResult1 = findProfile(for: intentEntity1)
        let findProfileResult2 = findProfile(for: intentEntity2)

        var eventResults = [OfficialFeed.FeedEvent]()
        var pilotAssetMap: [URL: SendableImagePtr]?

        switch (findProfileResult1, findProfileResult2) {
        case let (.success(profile1), .success(profile2)):
            if profile1.game != profile2.game {
                let eventResults1 = await OfficialFeed.getAllFeedEventsOnline(game: profile1.game)
                let eventResults2 = await OfficialFeed.getAllFeedEventsOnline(game: profile2.game)
                eventResults = eventResults1 + eventResults2
            } else {
                eventResults = await OfficialFeed.getAllFeedEventsOnline(game: profile1.game)
            }
            refreshTime = PZWidgets.getRefreshDateByGameStamina(game: nil)
            let dailyNoteResult1 = await fetchDailyNote(for: profile1)
            let dailyNoteResult2 = await fetchDailyNote(for: profile2)
            var dailyNotes = [any DailyNoteProtocol]()
            if case let .success(dailyNote1) = dailyNoteResult1 {
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: profile1.game)
                dailyNotes.append(dailyNote1)
            }
            if case let .success(dailyNote2) = dailyNoteResult2 {
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: profile2.game)
                dailyNotes.append(dailyNote2)
            }
            // 当两个结果都获取到的时候，刷新时间取两款游戏的最大公约数。
            if dailyNotes.count == 2 {
                refreshTime = PZWidgets.getSharedRefreshDateFor(game1: profile1.game, game2: profile2.game)
            }
            pilotAssetMap = await Self.prepareAssetMap(dailyNotes)
            return [
                Entry(
                    date: Date(),
                    resultSlot1: dailyNoteResult1,
                    resultSlot2: dailyNoteResult2,
                    viewConfig: viewConfig,
                    profileSlot1: profile1,
                    profileSlot2: profile2,
                    pilotAssetMap: pilotAssetMap,
                    events: eventResults
                ),
            ]
        case let (.success(profile1), .failure(error2)):
            eventResults = await OfficialFeed.getAllFeedEventsOnline(game: profile1.game)
            let dailyNoteResult = await fetchDailyNote(for: profile1)
            refreshTime = PZWidgets.getRefreshDateByGameStamina(game: nil)
            let dailyNoteResult1 = await fetchDailyNote(for: profile1)
            if case let .success(dailyNote1) = dailyNoteResult1 {
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: profile1.game)
                pilotAssetMap = await Self.prepareAssetMap([dailyNote1])
            }
            return [
                Entry(
                    date: Date(),
                    resultSlot1: dailyNoteResult,
                    resultSlot2: .failure(error2),
                    viewConfig: viewConfig,
                    profileSlot1: profile1,
                    profileSlot2: nil,
                    pilotAssetMap: pilotAssetMap,
                    events: eventResults
                ),
            ]

        case let (.failure(error1), .success(profile2)):
            eventResults = await OfficialFeed.getAllFeedEventsOnline(game: profile2.game)
            let dailyNoteResult = await fetchDailyNote(for: profile2)
            refreshTime = PZWidgets.getRefreshDateByGameStamina(game: nil)
            let dailyNoteResult2 = await fetchDailyNote(for: profile2)
            if case let .success(dailyNote2) = dailyNoteResult2 {
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: profile2.game)
                pilotAssetMap = await Self.prepareAssetMap([dailyNote2])
            }
            return [
                Entry(
                    date: Date(),
                    resultSlot1: .failure(error1),
                    resultSlot2: dailyNoteResult,
                    viewConfig: viewConfig,
                    profileSlot1: nil,
                    profileSlot2: profile2,
                    pilotAssetMap: pilotAssetMap,
                    events: eventResults
                ),
            ]
        case let (.failure(error1), .failure(error2)):
            return [
                Entry(
                    date: Date(),
                    resultSlot1: .failure(error1),
                    resultSlot2: .failure(error2),
                    viewConfig: viewConfig,
                    profileSlot1: nil,
                    profileSlot2: nil,
                    pilotAssetMap: pilotAssetMap,
                    events: eventResults
                ),
            ]
        }
    }

    private static func fetchDailyNote(for profile: PZProfileSendable) async -> Result<DailyNoteProtocol, Error> {
        await Task(priority: .userInitiated) {
            try await profile.getDailyNote(cached: true)
        }.result
    }

    private static func findProfile(for entity: AccountIntentAppEntity?) -> Result<PZProfileSendable, WidgetError> {
        let allProfiles = PZWidgets.getAllProfiles()
        guard let firstProfile = allProfiles.first else {
            print("Config is empty")
            return .failure(.noProfileFound)
        }
        guard let intent = entity else {
            print("no account intent got")
            guard allProfiles.count == 1 else {
                print("Need to choose account")
                return .failure(.profileSelectionNeeded)
            }
            return .success(firstProfile)
        }
        let selectedAccountUUID = intent.id
        print("// [SELECTED WIDGET PROFILE] ", selectedAccountUUID, intent)
        let firstMatchedProfile = allProfiles.first {
            $0.uuid.uuidString == selectedAccountUUID
        }

        guard let firstMatchedProfile else {
            // 有时候删除账号，Intent没更新就会出现这样的情况
            print("Need to choose account")
            return .failure(.profileSelectionNeeded)
        }
        return .success(firstMatchedProfile)
    }

    private static func getExpeditionAssetMap(from dailyNote: any DailyNoteProtocol) async -> [URL: SendableImagePtr]? {
        guard dailyNote.hasExpeditions else { return nil }
        let expeditions = dailyNote.expeditionTasks
        guard !expeditions.isEmpty else { return nil }
        var assetMap = [URL: SendableImagePtr]()
        if dailyNote.hasExpeditions {
            for task in dailyNote.expeditionTasks {
                let urls = [task.iconURL, task.iconURL4Copilot].compactMap { $0 }
                for url in urls {
                    if let image = await ImageMap.shared.assetMap[url] {
                        assetMap[url] = image
                    } else if let cgImage = CGImage.instantiate(url: url) {
                        let image = SendableImagePtr(img: .init(decorative: cgImage, scale: 1.0))
                        await ImageMap.shared.insertValue(url: url, image: image)
                        assetMap[url] = image
                    }
                }
            }
        }
        return assetMap
    }

    /// 这是给 .placeholder() 专用的函式，不会调用 ImageMap 的缓存。
    private static func getExpeditionAssetMapImmediately(from dailyNote: any DailyNoteProtocol)
        -> [URL: SendableImagePtr]? {
        guard dailyNote.hasExpeditions else { return nil }
        let expeditions = dailyNote.expeditionTasks
        guard !expeditions.isEmpty else { return nil }
        var assetMap = [URL: SendableImagePtr]()
        if dailyNote.hasExpeditions {
            for task in dailyNote.expeditionTasks {
                let urls = [task.iconURL, task.iconURL4Copilot].compactMap { $0 }
                for url in urls {
                    if let cgImage = CGImage.instantiate(url: url) {
                        let image = SendableImagePtr(img: .init(decorative: cgImage, scale: 1.0))
                        assetMap[url] = image
                    }
                }
            }
        }
        return assetMap
    }

    private static func prepareAssetMap(_ data: [any DailyNoteProtocol]) async -> [URL: SendableImagePtr]? {
        var assetMap: [URL: SendableImagePtr]? = [:]
        for currentDailyNote in data {
            let fetchedMap = await Task(priority: .userInitiated) {
                await Self.getExpeditionAssetMap(from: currentDailyNote)
            }.value
            fetchedMap?.forEach { theKey, theValue in
                assetMap?[theKey] = theValue
            }
        }
        if assetMap?.isEmpty ?? false {
            assetMap = nil
        }
        return assetMap
    }

    /// 这是给 .placeholder() 专用的函式，不会调用 ImageMap 的缓存。
    private static func prepareAssetMapImmediately(_ data: [any DailyNoteProtocol]) -> [URL: SendableImagePtr]? {
        var assetMap: [URL: SendableImagePtr]? = [:]
        for currentDailyNote in data {
            let fetchedMap = Self.getExpeditionAssetMapImmediately(from: currentDailyNote)
            fetchedMap?.forEach { theKey, theValue in
                assetMap?[theKey] = theValue
            }
        }
        if assetMap?.isEmpty ?? false {
            assetMap = nil
        }
        return assetMap
    }
}
