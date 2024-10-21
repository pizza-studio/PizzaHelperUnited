// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
import WidgetKit

// MARK: - AccountAndShowWhichInfoIntentEntry

struct AccountAndShowWhichInfoIntentEntry: TimelineEntry {
    let date: Date
    let result: Result<any Note4GI, any Error>
    var accountName: String?

    var showWeeklyBosses: Bool = false
    var showTransformer: Bool = false

    let accountUUIDString: String?

    var usingResinStyle: AutoRotationUsingResinWidgetStyle
}

// MARK: - LockScreenLoopWidgetProvider

struct LockScreenLoopWidgetProvider: TimelineProvider {
    // 填入在手表上显示的Widget配置内容，例如："的原粹树脂"
    let recommendationsTag: String

    func recommendations()
        -> [IntentRecommendation<SelectAccountAndShowWhichInfoIntent>] {
        let configs = AccountModel.shared.fetchAccountConfigs()
        return configs.map { config in
            let intent = SelectAccountAndShowWhichInfoIntent()
            intent.account = .init(
                identifier: config.uuid!.uuidString,
                display: config.name! + "(\(config.server.localized))"
            )
            intent.showTransformer = false
            intent.showWeeklyBosses = false
            return IntentRecommendation(
                intent: intent,
                description: config.name! + recommendationsTag.localized
            )
        }
    }

    func placeholder(in context: Context)
        -> AccountAndShowWhichInfoIntentEntry {
        AccountAndShowWhichInfoIntentEntry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil,
            usingResinStyle: .default_
        )
    }

    func getSnapshot(
        for configuration: SelectAccountAndShowWhichInfoIntent,
        in context: Context,
        completion: @escaping (AccountAndShowWhichInfoIntentEntry) -> Void
    ) {
        let entry = AccountAndShowWhichInfoIntentEntry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil,
            usingResinStyle: .default_
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: SelectAccountAndShowWhichInfoIntent,
        in context: Context,
        completion: @escaping (Timeline<AccountAndShowWhichInfoIntentEntry>)
            -> Void
    ) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let syncFrequencyInMinute = widgetRefreshByMinute
        var refreshDate: Date {
            Calendar.current.date(
                byAdding: .minute,
                value: syncFrequencyInMinute,
                to: currentDate
            )!
        }

        let accountConfigurationModel = AccountModel.shared
        let configs = accountConfigurationModel.fetchAccountConfigs()

        let style = configuration.usingResinStyle

        guard !configs.isEmpty else {
            let entry = AccountAndShowWhichInfoIntentEntry(
                date: currentDate,
                result: .failure(WidgetError.noAccountFound),
                accountUUIDString: nil,
                usingResinStyle: style
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            return
        }

        guard configuration.account != nil else {
            let config = configs.first!
            getTimelineEntries(config: config)
            return
        }

        let selectedAccountUUID = UUID(
            uuidString: configuration.account!
                .identifier!
        )
        print(configs.first!.uuid!, configuration)

        guard let config = configs
            .first(where: { $0.uuid == selectedAccountUUID }) else {
            // 有时候删除账号，Intent没更新就会出现这样的情况
            let entry = AccountAndShowWhichInfoIntentEntry(
                date: currentDate,
                result: .failure(WidgetError.accountSelectNeeded),
                accountUUIDString: nil,
                usingResinStyle: style
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            print("Need to choose account")
            return
        }

        getTimelineEntries(config: config)

        func getTimelineEntries(config: Account) {
            Task {
                do {
                    let data = try await config.dailyNote()
                    let entries = (0 ... 40).map { index in
                        let timeInterval = TimeInterval(index * 8 * 60)
                        let entryDate =
                            Date(timeIntervalSinceNow: timeInterval)
                        return AccountAndShowWhichInfoIntentEntry(
                            date: entryDate,
                            result: .success(data),
                            accountName: config.name,
                            showWeeklyBosses: configuration
                                .showWeeklyBosses as! Bool,
                            showTransformer: configuration
                                .showTransformer as! Bool,
                            accountUUIDString: config.safeUuid.uuidString,
                            usingResinStyle: style
                        )
                    }
                    completion(.init(entries: entries, policy: .after(refreshDate)))
                } catch {
                    let entry = AccountAndShowWhichInfoIntentEntry(
                        date: currentDate,
                        result: .failure(error),
                        accountName: config.name,
                        showWeeklyBosses: configuration
                            .showWeeklyBosses as! Bool,
                        showTransformer: configuration.showTransformer as! Bool,
                        accountUUIDString: config.safeUuid.uuidString,
                        usingResinStyle: style
                    )
                    completion(.init(entries: [entry], policy: .after(refreshDate)))
                }
            }
        }
    }
}
