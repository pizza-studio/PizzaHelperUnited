// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
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
                .lockscreenContainerBackground { EmptyView() }
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
    @MainActor var body: some View {
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

    var result: Result<any DailyNoteProtocol, any Error> { entry.result }
    var accountName: String? { entry.accountName }
    var showWeeklyBosses: Bool { entry.showWeeklyBosses }
    var showTransformer: Bool { entry.showTransformer }
    var resinStyle: AutoRotationUsingResinWidgetStyleAppEnum { entry.usingResinStyle }

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

@available(macOS, unavailable)
enum LockScreenLoopWidgetType: CaseIterable {
    case resin
    case expedition
    case dailyTask
    case homeCoin

    // MARK: Internal

    static func autoChoose(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>)
        -> Self {
        switch result {
        case let .success(data):
            switch data {
            case let data as any Note4GI:
                let homeCoinInfoScore = Double(data.homeCoinInfo.currentHomeCoinDynamic) /
                    Double(data.homeCoinInfo.maxHomeCoin)
                let resinInfoScore = 1.1 * Double(data.resinInfo.currentResinDynamic) /
                    Double(data.resinInfo.maxResin)
                let expeditionInfoScore = if data.expeditions.allCompleted { 120.0 / 160.0 } else { 0.0 }
                let dailyTaskInfoScore = if Date() > Calendar.current
                    .date(bySettingHour: 20, minute: 0, second: 0, of: Date())! {
                    if data.dailyTaskInfo.finishedTaskCount != data.dailyTaskInfo.totalTaskCount {
                        0.8
                    } else {
                        if data.dailyTaskInfo.isExtraRewardReceived {
                            0.0
                        } else {
                            1.2
                        }
                    }
                } else {
                    if !data.dailyTaskInfo.isExtraRewardReceived,
                       data.dailyTaskInfo.finishedTaskCount == data.dailyTaskInfo.totalTaskCount {
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
            case let data as any Note4HSR:
                let resinInfoScore = 1.1 * Double(data.staminaInfo.currentStamina) / Double(data.staminaInfo.maxStamina)
                let expeditionInfoScore = if data.assignmentInfo.allCompleted { 120.0 / 160.0 } else { 0.0 }
                let dailyTaskInfoScore: Double = {
                    guard let dailyNote = data as? WidgetNote4HSR else { return 0 }
                    let today8pmPassed: Bool = Date() > Calendar.current.date(
                        bySettingHour: 20,
                        minute: 0,
                        second: 0,
                        of: Date()
                    )!
                    if dailyNote.dailyTrainingInfo.currentScore != dailyNote.dailyTrainingInfo.maxScore {
                        return today8pmPassed ? 0.8 : 0.0
                    } else {
                        return 1.2
                    }
                }()
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
