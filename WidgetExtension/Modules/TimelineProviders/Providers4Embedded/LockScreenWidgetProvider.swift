// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftData
import WidgetKit

// MARK: - AccountOnlyEntry

struct AccountOnlyEntry: TimelineEntry {
    let date: Date
    let timestampOnCreation: Date = .now
    let result: Result<any DailyNoteProtocol, any Error>
    let profile: PZProfileSendable?

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

// MARK: - LockScreenWidgetProvider

@available(macOS, unavailable)
struct LockScreenWidgetProvider: AppIntentTimelineProvider {
    // MARK: Lifecycle

    public init(
        games: Set<Pizza.SupportedGame>? = nil,
        recommendationsTag: LocalizedStringResource
    ) {
        var games = games
        if let givenGames = games, givenGames.isEmpty {
            games = nil
        }
        self.games = games ?? .init(Pizza.SupportedGame.allCases)
        self.recommendationsTag = recommendationsTag
    }

    // MARK: Internal

    typealias Entry = AccountOnlyEntry
    typealias Intent = SelectOnlyAccountIntent

    let games: Set<Pizza.SupportedGame>
    // 填入在手表上显示的Widget配置内容，例如："的原粹树脂"
    let recommendationsTag: LocalizedStringResource

    #if os(watchOS)
    let modelContext = ModelContext(PZProfileActor.shared.modelContainer)
    #endif

    func recommendations() -> [AppIntentRecommendation<Intent>] {
        #if os(watchOS)
        let configs = (try? modelContext.fetch(FetchDescriptor<PZProfileMO>()).map(\.asSendable)) ?? []
        return configs.compactMap { config in
            let intent = Intent()
            intent.account = .init(
                id: config.uuid.uuidString,
                displayString: config.name + "\n(\(config.uidWithGame))"
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

    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            result: .success(Pizza.SupportedGame.genshinImpact.exampleDailyNoteData),
            profile: .getDummyInstance(for: .genshinImpact)
        )
    }

    func snapshot(
        for configuration: Intent,
        in context: Context
    ) async
        -> Entry {
        Entry(
            date: Date(),
            result: .success(
                (Pizza.SupportedGame(intentConfig: configuration) ?? .genshinImpact).exampleDailyNoteData
            ),
            profile: .getDummyInstance(for: .genshinImpact)
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
            switch dailyNoteResult {
            case .success:
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: profile.game)
                let entries: [Entry] = [
                    Entry(
                        date: refreshTime,
                        result: dailyNoteResult,
                        profile: profile
                    ),
                ]
                return entries
            case let .failure(error):
                refreshTime = PZWidgets.getRefreshDateByGameStamina(game: nil)
                return [
                    Entry(
                        date: Date(),
                        result: .failure(error),
                        profile: profile
                    ),
                ]
            }
        case let .failure(exception):
            return [
                Entry(
                    date: Date(),
                    result: .failure(exception),
                    profile: nil
                ),
            ]
        }
    }

    private static func fetchDailyNote(for profile: PZProfileSendable) async -> Result<DailyNoteProtocol, Error> {
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
        guard let intent = configuration.account else {
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
