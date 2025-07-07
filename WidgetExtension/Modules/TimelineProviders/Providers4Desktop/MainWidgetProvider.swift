// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import CoreGraphics
import Defaults
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import PZWidgetsKit
import WidgetKit

// MARK: - MainWidgetProvider

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
struct MainWidgetProvider: AppIntentTimelineProvider {
    // MARK: Internal

    typealias Entry = ProfileWidgetEntry
    typealias Intent = SelectAccountIntent

    func recommendations() -> [AppIntentRecommendation<Intent>] { [] }

    func placeholder(in context: Context) -> Entry {
        let sampleData = Pizza.SupportedGame.genshinImpact.exampleDailyNoteData
        let assetMap = sampleData.getExpeditionAssetMapImmediately()
        return Entry(
            date: Date(),
            result: .success(Pizza.SupportedGame.genshinImpact.exampleDailyNoteData),
            viewConfig: .defaultConfig,
            profile: .getDummyInstance(for: .genshinImpact),
            pilotAssetMap: assetMap,
            events: Defaults[.officialFeedCache].filter { $0.game == .genshinImpact }
        )
    }

    func snapshot(
        for configuration: Intent,
        in context: Context
    ) async
        -> Entry {
        let eventResults = Defaults[.officialFeedCache].filter { $0.game == .genshinImpact }
        let game = Pizza.SupportedGame(intentConfig: configuration) ?? .genshinImpact
        let sampleData = game.exampleDailyNoteData
        let assetMap = await Task(priority: .userInitiated) {
            await sampleData.getExpeditionAssetMap()
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
        let findProfileResult = findProfile(for: configuration)
        switch findProfileResult {
        case let .success(profile):
            let dailyNoteResult = await fetchDailyNote(for: profile)
            let eventResults = await OfficialFeed.getAllFeedEventsOnline(game: profile.game)
            switch dailyNoteResult {
            case let .success(dailyNoteData):
                let assetMap = await Task(priority: .userInitiated) {
                    await dailyNoteData.getExpeditionAssetMap()
                }.value
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: profile.game)
                let entries: [Entry] = [
                    Entry(
                        date: refreshTime,
                        result: dailyNoteResult,
                        viewConfig: .init(configuration, nil),
                        profile: profile,
                        pilotAssetMap: assetMap,
                        events: eventResults
                    ),
                ]
                return entries
            case let .failure(error):
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: nil)
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

    private static func fetchDailyNote(for profile: PZProfileSendable) async -> Result<any DailyNoteProtocol, Error> {
        await Task(priority: .userInitiated) {
            try await profile.getDailyNote(cached: true)
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
}

#endif
