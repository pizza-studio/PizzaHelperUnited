// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenLoopWidget

@available(macOS, unavailable)
struct LockScreenLoopWidget: Widget {
    let kind: String = "LockScreenLoopWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectAccountAndShowWhichInfoIntent.self,
            provider: LockScreenLoopWidgetProvider(
                recommendationsTag: "watch.info.autoRotation"
            )
        ) { entry in
            LockScreenLoopWidgetView(entry: entry)
                .smartStackWidgetContainerBackground { EmptyView() }
        }
        .configurationDisplayName("pzWidgetsKit.cfgName.autoRotation".i18nWidgets)
        .description("pzWidgetsKit.cfgName.autoDisplay".i18nWidgets)
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenLoopWidgetView

@available(macOS, unavailable)
struct LockScreenLoopWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily

    let entry: LockScreenLoopWidgetProvider.Entry

    var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    var accountName: String? { entry.profile?.name }

    var resinStyle: PZWidgetsSPM.StaminaContentRevolverStyle {
        entry.viewConfig.staminaContentRevolverStyle
    }

    var url: URL? {
        let errorURL: URL = {
            var components = URLComponents()
            components.scheme = "ophelperwidget"
            components.host = "accountSetting"
            components.queryItems = [
                .init(
                    name: "accountUUIDString",
                    value: entry.profile?.uuid.uuidString
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
            switch family {
            #if os(watchOS)
            case .accessoryCorner:
                LockScreenLoopWidgetCorner(entry: entry, result: result)
            #endif
            case .accessoryCircular:
                LockScreenLoopWidgetCircular(
                    entry: entry,
                    result: result,
                    resinStyle: resinStyle
                )
            default:
                EmptyView()
            }
        }
        .widgetURL(url)
    }
}

// MARK: - LockScreenLoopWidgetType

@available(macOS, unavailable)
enum LockScreenLoopWidgetType: CaseIterable {
    case resin
    case expedition
    case dailyTask
    case homeCoin

    // MARK: Internal

    static func autoChoose(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>)
        -> Self {
        // TODO: 此处恐需在本地 API 优化之后针对绝区零全部重新调整。
        let today8pmPassed: Bool = Date() > Calendar.gregorian.date(
            bySettingHour: 20,
            minute: 0,
            second: 0,
            of: Date()
        )!
        switch result {
        case let .success(data):
            let dailyTaskInfoScore: Double = {
                guard data.hasDailyTaskIntel else { return 0 }
                guard data.allDailyTasksAccomplished ?? false else {
                    return today8pmPassed ? 1.2 : 0.8
                }
                return 0.0
            }()
            switch data {
            case let data as any Note4GI:
                let homeCoinInfoScore = Double(data.homeCoinInfo.currentHomeCoin) /
                    Double(data.homeCoinInfo.maxHomeCoin)
                let resinInfoScore = 1.1 * Double(data.resinInfo.currentResinDynamic) /
                    Double(data.resinInfo.maxResin)
                let expeditionInfoScore = if data.allExpeditionsAccomplished { 0.75 } else { 0.0 }
                if homeCoinInfoScore > 0.8, homeCoinInfoScore > resinInfoScore {
                    return .homeCoin
                } else if expeditionInfoScore > resinInfoScore {
                    return .expedition
                } else if dailyTaskInfoScore > resinInfoScore {
                    return .dailyTask
                } else {
                    return .resin
                }
            case let data as any Note4HSR:
                let resinInfoScore = 1.1 * Double(data.staminaInfo.currentStamina) / Double(data.staminaInfo.maxStamina)
                let expeditionInfoScore = if data.allExpeditionsAccomplished { 0.75 } else { 0.0 }
                if expeditionInfoScore > resinInfoScore {
                    return .expedition
                } else if dailyTaskInfoScore > resinInfoScore {
                    return .dailyTask
                } else {
                    return .resin
                }
            case _ as Note4ZZZ: return .resin
            default: return .resin
            }
        case .failure:
            return .resin
        }
    }
}
