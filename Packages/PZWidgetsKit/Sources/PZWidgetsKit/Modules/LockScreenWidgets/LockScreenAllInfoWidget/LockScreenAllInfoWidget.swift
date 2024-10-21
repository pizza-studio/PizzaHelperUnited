// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenAllInfoWidgetProvider

struct LockScreenAllInfoWidgetProvider: TimelineProvider {
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
        let refreshMinute =
            Int(Defaults[.lockscreenWidgetRefreshFrequencyInMinute])
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

        guard configs.contains(where: { $0.uuid == selectedAccountUUID }) else {
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

        // 正常情况

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
                            accountName: config.name,
                            accountUUIDString: config.uuid?.uuidString
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

// MARK: - LockScreenAllInfoWidget

struct LockScreenAllInfoWidget: Widget {
    let kind: String = "LockScreenAllInfoWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenAllInfoWidgetProvider(
                recommendationsTag: "watch.info.dailyCommission"
            )
        ) { entry in
            LockScreenAllInfoWidgetView(entry: entry)
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("widget.intro.generalInfo")
        .description("widget.intro.generalInfo.detail")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - LockScreenAllInfoWidgetView

struct LockScreenAllInfoWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    @Environment(\.widgetRenderingMode) var widgetRenderingMode
    let entry: LockScreenAllInfoWidgetProvider.Entry

    var result: Result<any Note4GI, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.accountUUIDString
                ),
            ]
            return components.url!
        }()

        switch result {
        case .success:
            return nil
        case .failure:
            return errorURL
        }
    }

    var body: some View {
        Group {
            switch widgetRenderingMode {
            case .fullColor:
                switch result {
                case let .success(data):
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                                .foregroundColor(Color("iconColor.resin"))
                            Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                                .foregroundColor(
                                    Color("iconColor.expedition")
                                )
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.expeditionInfo4GI.ongoingExpeditionCount)"
                                )
                                Text(
                                    " / \(data.expeditionInfo4GI.maxExpeditionsCount)"
                                )
                                .font(.caption)
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                                .foregroundColor(
                                    Color("iconColor.homeCoin")
                                )
                            Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin(referTo: entry.date))")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .foregroundColor(
                                    Color("iconColor.dailyTask")
                                )
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.dailyTaskInformation.finishedTaskCount)"
                                )
                                Text(
                                    " / \(data.dailyTaskInformation.totalTaskCount)"
                                )
                                .font(.caption)
                            }
                        }
                        if let data = data as? GeneralNote4GI {
                            GridRow(alignment: .lastTextBaseline) {
                                Text("\(Image("icon.transformer"))")
                                    .foregroundColor(
                                        Color("iconColor.transformer")
                                    )
                                    .widgetAccentable()
                                let day = Calendar.current.dateComponents(
                                    [.day],
                                    from: Date(),
                                    to: data.transformerInformation.recoveryTime
                                ).day!
                                Text("\(day)天")
                                Spacer()
                                Text("\(Image("icon.weeklyBosses"))")
                                    .widgetAccentable()
                                    .foregroundColor(
                                        Color("iconColor.weeklyBosses")
                                    )
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    Text(
                                        "\(data.weeklyBossesInformation.remainResinDiscount)"
                                    )
                                    Text(
                                        " / \(data.weeklyBossesInformation.totalResinDiscount)"
                                    )
                                    .font(.caption)
                                }
                                Spacer()
                            }
                        }
                    }
                case .failure:
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                            Text("\(Image(systemSymbol: .ellipsis))")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.transformer"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.weeklyBosses"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(.gray)
                }

            default:
                switch result {
                case let .success(data):
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                            Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.expeditionInfo4GI.ongoingExpeditionCount)"
                                )
                                Text(
                                    " / \(data.expeditionInfo4GI.maxExpeditionsCount)"
                                )
                                .font(.caption)
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                            Text("\(data.homeCoinInformation.calculatedCurrentHomeCoin(referTo: entry.date))")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(
                                    "\(data.dailyTaskInformation.finishedTaskCount)"
                                )
                                Text(
                                    " / \(data.dailyTaskInformation.totalTaskCount)"
                                )
                                .font(.caption)
                            }
                        }
                        if let data = data as? GeneralNote4GI {
                            GridRow(alignment: .lastTextBaseline) {
                                Text("\(Image("icon.transformer"))")
                                    .widgetAccentable()
                                let day = Calendar.current.dateComponents(
                                    [.day],
                                    from: Date(),
                                    to: data.transformerInformation.recoveryTime
                                ).day!
                                Text("\(day)天")
                                Spacer()
                                Text("\(Image("icon.weeklyBosses"))")
                                    .widgetAccentable()
                                HStack(
                                    alignment: .lastTextBaseline,
                                    spacing: 0
                                ) {
                                    Text(
                                        "\(data.weeklyBossesInformation.remainResinDiscount)"
                                    )
                                    Text(
                                        " / \(data.weeklyBossesInformation.totalResinDiscount)"
                                    )
                                    .font(.caption)
                                }
                                Spacer()
                            }
                        }
                    }
                case .failure:
                    Grid(
                        alignment: .leadingFirstTextBaseline,
                        horizontalSpacing: 3,
                        verticalSpacing: 2
                    ) {
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.resin"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.expedition"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.homeCoin"))")
                                .widgetAccentable()
                            Text("\(Image(systemSymbol: .ellipsis))")
                            Spacer()
                            Text("\(Image("icon.dailyTask"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            Text("\(Image("icon.transformer"))")
                                .widgetAccentable()
                            Text(Image(systemSymbol: .ellipsis))
                            Spacer()
                            Text("\(Image("icon.weeklyBosses"))")
                                .widgetAccentable()
                            HStack(
                                alignment: .lastTextBaseline,
                                spacing: 0
                            ) {
                                Text(Image(systemSymbol: .ellipsis))
                            }
                            Spacer()
                        }
                    }
                    .foregroundColor(.gray)
                }
            }
        }
        .widgetURL(url)
    }
}
