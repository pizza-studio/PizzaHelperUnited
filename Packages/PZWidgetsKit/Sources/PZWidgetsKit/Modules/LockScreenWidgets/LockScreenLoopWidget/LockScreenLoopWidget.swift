// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenLoopWidget

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
                .lockscreenContainerBackground { EmptyView() }
        }
        .configurationDisplayName("widget.intro.autoRotation")
        .description("widget.intro.autoDisplay")
        #if os(watchOS)
            .supportedFamilies([.accessoryCircular, .accessoryCorner])
        #else
            .supportedFamilies([.accessoryCircular])
        #endif
    }
}

// MARK: - LockScreenLoopWidgetView

struct LockScreenLoopWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenLoopWidgetProvider.Entry
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
                    showWeeklyBosses: showWeeklyBosses,
                    showTransformer: showTransformer,
                    resinStyle: resinStyle
                )
            default:
                EmptyView()
            }
        }
        .widgetURL(url)
    }

    var result: Result<any Note4GI, any Error> { entry.result }
    var accountName: String? { entry.accountName }
    var showWeeklyBosses: Bool { entry.showWeeklyBosses }
    var showTransformer: Bool { entry.showTransformer }
    var resinStyle: AutoRotationUsingResinWidgetStyle { entry.usingResinStyle }

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
}

// MARK: - LockScreenLoopWidgetType

enum LockScreenLoopWidgetType: CaseIterable {
    case resin
    case expedition
    case dailyTask
    case homeCoin

    // MARK: Internal

    static func autoChoose(entry: any TimelineEntry, result: Result<any Note4GI, any Error>)
        -> Self {
        switch result {
        case let .success(data):
            let homeCoinInfoScore = Double(data.homeCoinInformation.calculatedCurrentHomeCoin(referTo: entry.date)) /
                Double(data.homeCoinInformation.maxHomeCoin)
            let resinInfoScore = 1.1 * Double(data.resinInfo.calculatedCurrentResin(referTo: entry.date)) /
                Double(data.resinInfo.maxResin)
            let expeditionInfoScore = if data.expeditionInfo4GI.allCompleted { 120.0 / 160.0 } else { 0.0 }
            let dailyTaskInfoScore = if Date() > Calendar.current
                .date(bySettingHour: 20, minute: 0, second: 0, of: Date())! {
                if data.dailyTaskInformation.finishedTaskCount != data.dailyTaskInformation.totalTaskCount {
                    0.8
                } else {
                    if data.dailyTaskInformation.isExtraRewardReceived {
                        0.0
                    } else {
                        1.2
                    }
                }
            } else {
                if !data.dailyTaskInformation.isExtraRewardReceived,
                   data.dailyTaskInformation.finishedTaskCount == data.dailyTaskInformation.totalTaskCount {
                    1.2
                } else {
                    0.0
                }
            }
            if homeCoinInfoScore > 0.8, homeCoinInfoScore > resinInfoScore {
                return .homeCoin
            } else if expeditionInfoScore > resinInfoScore {
                return .expedition
            } else if dailyTaskInfoScore > resinInfoScore {
                return .dailyTask
            } else {
                return .resin
            }
        case .failure:
            return .resin
        }
    }
}
