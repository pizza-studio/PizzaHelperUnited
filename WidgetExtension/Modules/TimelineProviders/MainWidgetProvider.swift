// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
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
                score: 10 * Float(stamina.existing) / Float(stamina.max)
            )
        case .failure:
            return .init(score: 0)
        }
    }
}

// MARK: - MainWidgetProvider

@available(watchOS, unavailable)
struct MainWidgetProvider: AppIntentTimelineProvider {
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
        Entry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
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
        let syncFrequencyInMinute = widgetRefreshByMinute
        let currentDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute,
            value: syncFrequencyInMinute,
            to: currentDate
        )!

        let configs = PZWidgets.getAllProfiles()

        var viewConfig: WidgetViewConfiguration = .defaultConfig

        func makeFallbackResult(error: WidgetError) -> Timeline<Entry> {
            let entry = Entry(
                date: currentDate,
                result: .failure(error),
                viewConfig: WidgetViewConfiguration(noticeMessage: error.description),
                accountUUIDString: nil
            )
            return Timeline<Entry>(
                entries: [entry],
                policy: .after(refreshDate)
            )
        }

        func getTimelineEntries(
            config: PZProfileSendable,
            viewConfig: WidgetViewConfiguration
        ) async
            -> Timeline<Entry> {
            do {
                let data = try await config.getDailyNote()
                let entries = (0 ... 40).map { index in
                    let timeInterval = TimeInterval(index * 8 * 60)
                    let entryDate =
                        Date(timeIntervalSinceNow: timeInterval)
                    return Entry(
                        date: entryDate,
                        result: .success(data),
                        viewConfig: viewConfig,
                        accountName: config.name,
                        accountUUIDString: config.uuid.uuidString
                    )
                }
                return .init(entries: entries, policy: .after(refreshDate))
            } catch {
                let entry = Entry(
                    date: Date(),
                    result: .failure(error),
                    viewConfig: viewConfig,
                    accountUUIDString: config.uuid.uuidString
                )
                return .init(entries: [entry], policy: .after(refreshDate))
            }
        }

        guard let firstProfile = configs.first else {
            print("Config is empty")
            return makeFallbackResult(error: .noProfileFound)
        }

        guard let intent = configuration.accountIntent else {
            print("no account intent got")
            guard configs.count == 1 else {
                print("Need to choose account")
                return makeFallbackResult(error: .profileSelectionNeeded)
            }
            viewConfig = WidgetViewConfiguration(configuration, nil)
            // 如果还未选择账号且只有一个账号，默认获取第一个
            return await getTimelineEntries(config: firstProfile, viewConfig: .init())
        }

        viewConfig = WidgetViewConfiguration(configuration, nil)
        let selectedAccountUUID = intent.id
        print("// [SELECTED WIDGET PROFILE] ", selectedAccountUUID, configuration)

        let firstMatchedProfile = configs.first {
            $0.uuid.uuidString == selectedAccountUUID
        }

        guard let firstMatchedProfile else {
            // 有时候删除账号，Intent没更新就会出现这样的情况
            print("Need to choose account")
            return makeFallbackResult(error: .profileSelectionNeeded)
        }

        return await getTimelineEntries(config: firstMatchedProfile, viewConfig: viewConfig)
    }
}
