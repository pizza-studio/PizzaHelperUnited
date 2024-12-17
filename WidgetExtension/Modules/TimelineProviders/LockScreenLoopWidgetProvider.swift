// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftData
import WidgetKit

// MARK: - AccountAndShowWhichInfoIntentEntry

struct AccountAndShowWhichInfoIntentEntry: TimelineEntry {
    let date: Date
    let timestampOnCreation: Date = .now
    let result: Result<any DailyNoteProtocol, any Error>
    var accountName: String?

    var showEchoOfWar: Bool = true
    var showTrounceBlossom: Bool = true
    var showTransformer: Bool = true

    let accountUUIDString: String?

    var usingResinStyle: AutoRotationUsingResinWidgetStyleAppEnum

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

// MARK: - LockScreenLoopWidgetProvider

/// This struct actually "inherits" from LockScreenWidgetProvider with extra options.
@available(macOS, unavailable)
struct LockScreenLoopWidgetProvider: AppIntentTimelineProvider {
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

    typealias Entry = AccountAndShowWhichInfoIntentEntry
    typealias Intent = SelectAccountAndShowWhichInfoIntent

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
            result: .success(GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil,
            usingResinStyle: .byDefault
        )
    }

    func snapshot(
        for configuration: Intent,
        in context: Context
    ) async
        -> Entry {
        let data = Pizza.SupportedGame(intentConfig: configuration)?.exampleDailyNoteData
        return Entry(
            date: Date(),
            result: .success(data ?? GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil,
            usingResinStyle: .byDefault
        )
    }

    func timeline(
        for configuration: Intent,
        in context: Context
    ) async
        -> Timeline<Entry> {
        var refreshTime = PZWidgets.getRefreshDate()
        let entries: [Entry] = await getEntries(configuration: configuration, refreshTime: &refreshTime)
        return Timeline(
            entries: entries,
            policy: .after(refreshTime)
        )
    }

    // MARK: Private

    private func getEntries(configuration: Intent, refreshTime: inout Date) async -> [Entry] {
        let findProfileResult = findProfile(for: configuration)
        switch findProfileResult {
        case let .success(profile):
            let dailyNoteResult = await fetchDailyNote(for: profile)
            switch dailyNoteResult {
            case .success:
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
                            accountName: profile.name,
                            showEchoOfWar: configuration.showEchoOfWar,
                            showTrounceBlossom: configuration.showTrounceBlossom,
                            showTransformer: configuration.showTransformer,
                            accountUUIDString: profile.uuid.uuidString,
                            usingResinStyle: configuration.usingResinStyle
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
                        accountName: profile.name,
                        showEchoOfWar: configuration.showEchoOfWar,
                        showTrounceBlossom: configuration.showTrounceBlossom,
                        showTransformer: configuration.showTransformer,
                        accountUUIDString: profile.uuid.uuidString,
                        usingResinStyle: configuration.usingResinStyle
                    ),
                ]
            }
        case let .failure(exception):
            return [
                Entry(
                    date: Date(),
                    result: .failure(exception),
                    accountName: nil,
                    showEchoOfWar: configuration.showEchoOfWar,
                    showTrounceBlossom: configuration.showTrounceBlossom,
                    showTransformer: configuration.showTransformer,
                    accountUUIDString: nil,
                    usingResinStyle: configuration.usingResinStyle
                ),
            ]
        }
    }

    private func fetchDailyNote(for profile: PZProfileSendable) async -> Result<DailyNoteProtocol, Error> {
        await Task(priority: .background) {
            try await profile.getDailyNote()
        }.result
    }

    private func findProfile(for configuration: Intent) -> Result<PZProfileSendable, WidgetError> {
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
