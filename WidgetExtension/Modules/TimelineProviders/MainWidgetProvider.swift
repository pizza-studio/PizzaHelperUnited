// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - ResinEntry

@available(watchOS, unavailable)
struct ResinEntry: TimelineEntry {
    let date: Date
    let timestampOnCreation: Date = .now
    let result: Result<any DailyNoteProtocol, any Error>
    let viewConfig: WidgetViewConfiguration
    var accountName: String?
    let accountUUIDString: String?

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

    typealias Entry = ResinEntry
    typealias Intent = SelectAccountIntent

    func recommendations() -> [AppIntentRecommendation<SelectAccountIntent>] { [] }

    func placeholder(in context: Context) -> Entry {
        Entry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
            viewConfig: .defaultConfig,
            accountName: "荧",
            accountUUIDString: ""
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
            viewConfig: .defaultConfig,
            accountName: "荧",
            accountUUIDString: ""
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
                            viewConfig: .init(configuration, nil),
                            accountName: profile.name,
                            accountUUIDString: profile.uuid.uuidString
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
                        accountName: profile.name,
                        accountUUIDString: profile.uuid.uuidString
                    ),
                ]
            }
        case let .failure(exception):
            return [
                Entry(
                    date: Date(),
                    result: .failure(exception),
                    viewConfig: .init(configuration, nil),
                    accountUUIDString: nil
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
