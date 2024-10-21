// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
import WidgetKit

// MARK: - AccountOnlyEntry

struct AccountOnlyEntry: TimelineEntry {
    typealias Result = Swift.Result<any Note4GI, any Error>

    let date: Date
    let result: Result
    var accountName: String?
    let accountUUIDString: String?
}

// MARK: - LockScreenWidgetProvider

struct LockScreenWidgetProvider: TimelineProvider {
    // 填入在手表上显示的Widget配置内容，例如："的原粹树脂"
    let recommendationsTag: String

    func recommendations() -> [IntentRecommendation<SelectOnlyAccountIntent>] {
        let configs = AccountModel.shared.fetchAccountConfigs()
        return configs.map { config in
            let intent = SelectOnlyAccountIntent()
            intent.account = .init(
                identifier: config.uuid!.uuidString,
                display: config.name! + "(\(config.server.localized))"
            )
            return IntentRecommendation(
                intent: intent,
                description: config.name! + recommendationsTag.localized
            )
        }
    }

    func placeholder(in context: Context) -> AccountOnlyEntry {
        AccountOnlyEntry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil
        )
    }

    func getSnapshot(
        for configuration: SelectOnlyAccountIntent,
        in context: Context,
        completion: @escaping (AccountOnlyEntry) -> Void
    ) {
        let entry = AccountOnlyEntry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil
        )
        completion(entry)
    }

    func getTimeline(
        for configuration: SelectOnlyAccountIntent,
        in context: Context,
        completion: @escaping (Timeline<AccountOnlyEntry>) -> Void
    ) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()

        let refreshMinute = widgetRefreshByMinute

        var refreshDate: Date {
            Calendar.current.date(
                byAdding: .minute,
                value: refreshMinute,
                to: currentDate
            )!
        }

        let accountConfigurationModel = AccountModel.shared
        let configs = accountConfigurationModel.fetchAccountConfigs()

        guard !configs.isEmpty else {
            let entry = AccountOnlyEntry(
                date: currentDate,
                result: .failure(WidgetError.noAccountFound),
                accountUUIDString: nil
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            return
        }

        guard configuration.account != nil else {
            getTimelineEntries(config: configs.first!)
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
            let entry = AccountOnlyEntry(
                date: currentDate,
                result: .failure(WidgetError.accountSelectNeeded),
                accountUUIDString: nil
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
                        return AccountOnlyEntry(
                            date: entryDate,
                            result: .success(data),
                            accountName: config.safeName,
                            accountUUIDString: config.safeUuid.uuidString
                        )
                    }
                    completion(.init(entries: entries, policy: .after(refreshDate)))
                } catch {
                    let entry = AccountOnlyEntry(
                        date: currentDate,
                        result: .failure(error),
                        accountName: config.name,
                        accountUUIDString: config.uuid?.uuidString
                    )
                    completion(.init(entries: [entry], policy: .after(refreshDate)))
                }
            }
        }
    }
}
