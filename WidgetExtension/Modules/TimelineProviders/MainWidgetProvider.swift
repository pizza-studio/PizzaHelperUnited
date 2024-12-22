// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import SwiftUI
import WidgetKit

// MARK: - MainWidgetEntry

@available(watchOS, unavailable)
struct MainWidgetEntry: TimelineEntry {
    // MARK: Lifecycle

    init(
        date: Date,
        result: Result<any DailyNoteProtocol, any Error>,
        viewConfig: WidgetViewConfiguration,
        profile: PZProfileSendable?,
        pilotAssetMap: [URL: Image]? = nil,
        events: [EventModel]
    ) {
        self.date = date
        self.result = result
        self.viewConfig = viewConfig
        self.profile = profile
        self.events = events
        self.pilotAssetMap = pilotAssetMap ?? [:]
    }

    // MARK: Internal

    let date: Date
    let timestampOnCreation: Date = .now
    let result: Result<any DailyNoteProtocol, any Error>
    let viewConfig: WidgetViewConfiguration
    let profile: PZProfileSendable?
    let events: [EventModel]
    let pilotAssetMap: [URL: Image]

    var relevance: TimelineEntryRelevance? {
        switch result {
        case let .success(data):
            if data.staminaFullTimeOnFinish >= .now {
                return .init(score: 10)
            }
            let stamina = data.staminaIntel
            return .init(
                score: 10 * Float(stamina.finished) / Float(stamina.all)
            )
        case .failure:
            return .init(score: 0)
        }
    }
}

// MARK: - MainWidgetProvider

@available(watchOS, unavailable)
struct MainWidgetProvider: AppIntentTimelineProvider {
    // MARK: Internal

    typealias Entry = MainWidgetEntry
    typealias Intent = SelectAccountIntent

    func recommendations() -> [AppIntentRecommendation<Intent>] { [] }

    func placeholder(in context: Context) -> Entry {
        let sampleData = Pizza.SupportedGame.genshinImpact.exampleDailyNoteData
        let assetMap = Self.getExpeditionAssetMap(from: sampleData)
        return Entry(
            date: Date(),
            result: .success(Pizza.SupportedGame.genshinImpact.exampleDailyNoteData),
            viewConfig: .defaultConfig,
            profile: .getDummyInstance(for: .genshinImpact),
            pilotAssetMap: assetMap,
            events: []
        )
    }

    func snapshot(
        for configuration: Intent,
        in context: Context
    ) async
        -> Entry {
        let eventResults = await OfficialFeed.getAllFeedEventsOnline().filter {
            $0.game == .genshinImpact
        }
        let game = Pizza.SupportedGame(intentConfig: configuration) ?? .genshinImpact
        let sampleData = game.exampleDailyNoteData
        let assetMap = await Task(priority: .userInitiated) {
            Self.getExpeditionAssetMap(from: sampleData)
        }.value
        return Entry(
            date: Date(),
            result: .success(
                (Pizza.SupportedGame(intentConfig: configuration) ?? .genshinImpact).exampleDailyNoteData
            ),
            viewConfig: .defaultConfig,
            profile: .getDummyInstance(for: .genshinImpact),
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
            var refreshTime = PZWidgets.getRefreshDate()
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
        let findProfileResult = findProfile(for: configuration)
        switch findProfileResult {
        case let .success(profile):
            let dailyNoteResult = await fetchDailyNote(for: profile)
            let eventResults = await OfficialFeed.getAllFeedEventsOnline().filter {
                $0.game == profile.game
            }
            switch dailyNoteResult {
            case let .success(dailyNoteData):
                let assetMap = await Task(priority: .userInitiated) {
                    Self.getExpeditionAssetMap(from: dailyNoteData)
                }.value
                refreshTime = PZWidgets.getRefreshDate() // fetchDailyNote 的过程本身就会消耗时间，需要统计。
                var tlEntryDate = Date.now

                func boostDate() {
                    tlEntryDate = tlEntryDate.addingTimeInterval(profile.game.eachStaminaRecoveryTime)
                }

                var entries: [Entry] = []
                while refreshTime > tlEntryDate {
                    entries.append(
                        Entry(
                            date: tlEntryDate,
                            result: dailyNoteResult,
                            viewConfig: .init(configuration, nil),
                            profile: profile,
                            pilotAssetMap: assetMap,
                            events: eventResults
                        )
                    )
                    boostDate()
                }
                return entries
            case let .failure(error):
                refreshTime = PZWidgets.getRefreshDate(isError: true) // fetchDailyNote 的过程本身就会消耗时间，需要统计。
                return [
                    Entry(
                        date: Date(),
                        result: .failure(error),
                        viewConfig: .init(configuration, nil),
                        profile: profile,
                        events: eventResults
                    ),
                ]
            }
        case let .failure(exception):
            return [
                Entry(
                    date: Date(),
                    result: .failure(exception),
                    viewConfig: .init(configuration, nil),
                    profile: nil,
                    events: []
                ),
            ]
        }
    }

    private static func fetchDailyNote(for profile: PZProfileSendable) async -> Result<DailyNoteProtocol, Error> {
        await Task(priority: .userInitiated) {
            try await profile.getDailyNote()
        }.result
    }

    private static func findProfile(for configuration: Intent) -> Result<PZProfileSendable, WidgetError> {
        let allProfiles = PZWidgets.getAllProfiles()
        guard let firstProfile = allProfiles.first else {
            print("Config is empty")
            return .failure(.noProfileFound)
        }
        guard let intent = configuration.accountIntent else {
            print("no account intent got")
            guard allProfiles.count == 1 else {
                print("Need to choose account")
                return .failure(.profileSelectionNeeded)
            }
            return .success(firstProfile)
        }
        let selectedAccountUUID = intent.id
        print("// [SELECTED WIDGET PROFILE] ", selectedAccountUUID, configuration)
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

    private static func getExpeditionAssetMap(from dailyNote: any DailyNoteProtocol) -> [URL: Image]? {
        guard dailyNote.hasExpeditions else { return nil }
        let expeditions = dailyNote.expeditionTasks
        guard !expeditions.isEmpty else { return nil }
        var assetMap = [URL: Image]()
        if dailyNote.hasExpeditions {
            dailyNote.expeditionTasks.forEach {
                let urls = [$0.iconURL, $0.iconURL4Copilot].compactMap { $0 }
                urls.forEach { url in
                    if let cgImage = CGImage.instantiate(url: url) {
                        assetMap[url] = Image(decorative: cgImage, scale: 1.0)
                    }
                }
            }
        }
        return assetMap
    }
}
