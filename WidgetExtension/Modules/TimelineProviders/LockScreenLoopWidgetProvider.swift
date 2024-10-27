// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import WidgetKit

// MARK: - AccountAndShowWhichInfoIntentEntry

struct AccountAndShowWhichInfoIntentEntry: TimelineEntry {
    let date: Date
    let result: Result<any DailyNoteProtocol, any Error>
    var accountName: String?

    var showWeeklyBosses: Bool = false
    var showTransformer: Bool = false

    let accountUUIDString: String?

    var usingResinStyle: AutoRotationUsingResinWidgetStyleAppEnum
}

// MARK: - LockScreenLoopWidgetProvider

/// This struct actually "inherits" from LockScreenWidgetProvider with extra options.
@available(macOS, unavailable)
struct LockScreenLoopWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = AccountAndShowWhichInfoIntentEntry
    typealias Intent = SelectAccountAndShowWhichInfoIntent

    // 填入在手表上显示的Widget配置内容，例如："的原粹树脂"
    let recommendationsTag: LocalizedStringResource

    func recommendations() -> [AppIntentRecommendation<Intent>] {
        let configs = PZProfileActor.getSendableProfiles()
        return configs.map { config in
            let intent = Intent()
            intent.account = .init(
                id: config.uuid.uuidString,
                displayString: config.name + " (\(config.server.localizedDescriptionByGameAndRegion))"
            )
            return .init(
                intent: intent,
                description: config.name + String(localized: recommendationsTag)
            )
        }
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
        Entry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
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

        let configs = await PZProfileActor.shared.getSendableProfiles()
        let style = configuration.usingResinStyle ?? .byDefault

        func makeFallbackResult(error: WidgetError) -> Timeline<Entry> {
            let entry = Entry(
                date: currentDate,
                result: .failure(error),
                accountUUIDString: nil,
                usingResinStyle: style
            )
            return Timeline<Entry>(
                entries: [entry],
                policy: .after(refreshDate)
            )
        }

        func getTimelineEntries(
            config: PZProfileSendable
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
                        accountName: config.name,
                        showWeeklyBosses: configuration.showWeeklyBosses ?? true,
                        showTransformer: configuration.showTransformer ?? true,
                        accountUUIDString: config.uuid.uuidString,
                        usingResinStyle: style
                    )
                }
                return .init(entries: entries, policy: .after(refreshDate))
            } catch {
                let entry = Entry(
                    date: Date(),
                    result: .failure(error),
                    showWeeklyBosses: configuration.showWeeklyBosses ?? true,
                    showTransformer: configuration.showTransformer ?? true,
                    accountUUIDString: config.uuid.uuidString,
                    usingResinStyle: style
                )
                return .init(entries: [entry], policy: .after(refreshDate))
            }
        }

        guard let firstProfile = configs.first else {
            print("Config is empty")
            return makeFallbackResult(error: .noProfileFound)
        }

        guard let intent = configuration.account else {
            print("no account intent got")
            guard configs.count == 1 else {
                print("Need to choose account")
                return makeFallbackResult(error: .profileSelectionNeeded)
            }
            // 如果还未选择账号且只有一个账号，默认获取第一个
            return await getTimelineEntries(config: firstProfile)
        }

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

        return await getTimelineEntries(config: firstMatchedProfile)
    }
}
