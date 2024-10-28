// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit)
import ActivityKit
import AppIntents
@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit
import WidgetKit

struct ResinRecoveryActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: ResinRecoveryAttributes
                .self
        ) { context in
            ResinRecoveryActivityWidgetLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemSymbol: .personFill)
                        Text(context.attributes.accountName)
                    }
                    .foregroundColor(Color("textColor.appIconLike", bundle: .main))
                    .font(.caption2)
                    .padding(.leading)
                }
                .contentMargins(.trailing, 15)
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(alignment: .center, spacing: 4) {
                        Image("AppIcon")
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .frame(width: 15)
                        Text("app.title.full".i18nBaseKit)
                            .foregroundColor(Color("textColor.appIconLike", bundle: .main))
                            .font(.caption2)
                    }
                    .padding(.trailing)
                }
                .contentMargins(.leading, 15)
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if Date() < context.state.next20ResinRecoveryTime {
                            HStack {
                                AccountKit.imageAsset(resinImageAssetName(context))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 40)
                                VStack(alignment: .leading) {
                                    Text(
                                        "pzWidgetsKit.next20Stamina:\(context.state.next20ResinCount)",
                                        bundle: .main
                                    )
                                    .font(.caption2)
                                    Text(
                                        timerInterval: Date() ... context.state
                                            .next20ResinRecoveryTime,
                                        countsDown: true
                                    )
                                    .multilineTextAlignment(.leading)
                                    .font(.system(.title2, design: .rounded))
                                    .foregroundColor(
                                        Color("textColor.originResin", bundle: .main)
                                    )
                                }
                                .gridColumnAlignment(.leading)
                                .frame(width: 100)
                            }
                        }
                        Spacer()
                        if Date() < context.state.resinRecoveryTime {
                            HStack {
                                AccountKit.imageAsset("gi_note_resin_condensed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 40)
                                VStack(alignment: .leading) {
                                    Text("pzWidgetsKit.nextMaxStamina", bundle: .main)
                                        .font(.caption2)

                                    Text(
                                        timerInterval: Date() ... context.state
                                            .resinRecoveryTime,
                                        countsDown: true
                                    )
                                    .multilineTextAlignment(.leading)
                                    .font(.system(.title2, design: .rounded))
                                    .foregroundColor(
                                        Color("textColor.originResin", bundle: .main)
                                    )
                                }
                                .gridColumnAlignment(.leading)
                                .frame(width: 100)
                            }
                        }
                    }
                    .foregroundColor(Color("textColor3", bundle: .main))
                }
            } compactLeading: {
                AccountKit.imageAsset(resinImageAssetName(context)).resizable().scaledToFit()
            } compactTrailing: {
                if Date() < context.state
                    .next20ResinRecoveryTime {
                    Text(
                        timerInterval: Date() ... context.state
                            .next20ResinRecoveryTime,
                        countsDown: true,
                        showsHours: false
                    )
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .foregroundColor(Color("textColor2", bundle: .main))
                }
            } minimal: {
                AccountKit.imageAsset(resinImageAssetName(context)).resizable().scaledToFit()
            }
        }
    }

    func resinImageAssetName(_ context: ActivityViewContext<ResinRecoveryAttributes>) -> String {
        switch context.state.game {
        case .genshinImpact: "gi_note_resin"
        case .starRail: "hsr_note_trailblazePower"
        case .zenlessZone: "zzz_note_battery"
        }
    }
}

struct ResinRecoveryActivityWidgetLockScreenView: View {
    @State var context: ActivityViewContext<ResinRecoveryAttributes>

    @Default(.resinRecoveryLiveActivityBackgroundOptions) var resinRecoveryLiveActivityBackgroundOptions: [String]

    var useNoBackground: Bool { context.state.background == .noBackground }

    var resinImageAssetName: String {
        switch context.state.game {
        case .genshinImpact: "gi_note_resin"
        case .starRail: "hsr_note_trailblazePower"
        case .zenlessZone: "zzz_note_battery"
        }
    }

    var body: some View {
        let mainContent = contentView
        #if !os(watchOS)
            .background {
                let randomCardBg: Image = (Wallpaper.allCases.randomElement() ?? .defaultValue(for: nil))
                    .image4LiveActivity
                switch context.state.background {
                case .random:
                    randomCardBg
                        .resizable()
                        .scaledToFill()
                    Color.black
                        .opacity(0.3)
                case .customize:
                    let chosenCardBackgrounds = Wallpaper.allCases.filter { wallpaper in
                        resinRecoveryLiveActivityBackgroundOptions.contains(wallpaper.assetName4LiveActivity)
                    }
                    (chosenCardBackgrounds.randomElement()?.image4LiveActivity ?? randomCardBg)
                        .resizable()
                        .scaledToFill()
                    Color.black
                        .opacity(0.3)
                case .noBackground:
                    EmptyView()
                }
            }
        #endif
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .activityBackgroundTint(.clear)
        if #available(iOS 17, *) {
            Button(intent: ResinTimerRerenderIntent()) {
                mainContent
            }
            .buttonStyle(.plain)
            .ignoresSafeArea()
        } else {
            mainContent
        }
    }

    @ViewBuilder var contentView: some View {
        HStack {
            Grid(verticalSpacing: 7) {
                if #available(iOS 17, *) {
                    GridRow {
                        AccountKit.imageAsset(resinImageAssetName)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 38)
                        VStack(alignment: .leading) {
                            Text("pzWidgetsKit.currentStamina", bundle: .main)
                                .font(.caption2)
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                Text(verbatim: "\(context.state.currentResin)")
                                    .font(.system(.title2, design: .rounded))
                                Text(verbatim: " / \(context.state.maxResin)")
                                    .font(.caption)
                            }
                        }
                        .gridColumnAlignment(.leading)
                    }
                } else {
                    if context.state.showNext20Resin,
                       Date() < context.state.next20ResinRecoveryTime {
                        GridRow {
                            AccountKit.imageAsset(resinImageAssetName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 38)
                            VStack(alignment: .leading) {
                                Text("pzWidgetsKit.next20Stamina:\(context.state.next20ResinCount)", bundle: .main)
                                    .font(.caption2)
                                Text(
                                    timerInterval: Date() ... context.state
                                        .next20ResinRecoveryTime,
                                    countsDown: true
                                )
                                .multilineTextAlignment(.leading)
                                .font(.system(.title2, design: .rounded))
                            }
                            .gridColumnAlignment(.leading)
                        }
                    }
                }
                if context.state.game == .genshinImpact, Date() < context.state.resinRecoveryTime {
                    GridRow {
                        AccountKit.imageAsset("gi_note_resin_condensed")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 35)
                        VStack(alignment: .leading) {
                            Text("pzWidgetsKit.nextMaxStamina", bundle: .main)
                                .font(.caption2)
                            Text(
                                timerInterval: Date() ... context.state
                                    .resinRecoveryTime,
                                countsDown: true
                            )
                            .multilineTextAlignment(.leading)
                            .font(.system(.title2, design: .rounded))
                        }
                        .gridColumnAlignment(.leading)
                        //                    .frame(width: 140)
                    }
                }
                if context.state.showExpedition, let time = context.state.expeditionAllCompleteTime, Date() < time {
                    GridRow {
                        AccountKit.imageAsset("gi_note_expedition")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 29)
                        VStack(alignment: .leading) {
                            Text("pzWidgetsKit.expedition.timeToAllCompletion", bundle: .main)
                                .font(.caption2)
                            Text(
                                timerInterval: Date() ... time,
                                countsDown: true
                            )
                            .multilineTextAlignment(.leading)
                            .font(.system(.title2, design: .rounded))
                        }
                        .gridColumnAlignment(.leading)
//                        .frame(width: 140)
                    }
                }
            }
            Spacer()
            VStack {
                Spacer()
                if #available(iOS 17, *) {
                    Button(intent: ResinTimerRefreshIntent()) {
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            Text(context.attributes.accountName)
                            Image(systemSymbol: .arrowTriangle2CirclepathCircle)
                        }
                    }
                    .buttonStyle(.plain)
                    .font(.footnote)
                } else {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemSymbol: .personFill)
                        Text(context.attributes.accountName)
                    }
                    .font(.footnote)
                    .padding(.top, 3)
                    .padding(.leading, 3)
                }
            }
        }
        .shadow(radius: useNoBackground ? 0 : 0.8)
        .foregroundColor(useNoBackground ? .primary : Color("textColor3", bundle: .main))
        .padding()
    }
}

struct ResinTimerRefreshIntent: AppIntent {
    static let title: LocalizedStringResource = "pzWidgetsKit.Refresh"

    func perform() async throws -> some IntentResult {
        let activities = ResinRecoveryActivityController.shared.currentActivities
        let accounts = PZProfileActor.getSendableProfiles()
        for activity in activities {
            let account = accounts.first(where: { account in
                account.uuid == activity.attributes.accountUUID
            })
            guard let account else { continue }
            let result = try await account.getDailyNote()
            ResinRecoveryActivityController.shared.updateResinRecoveryTimerActivity(for: account, data: result)
        }
        return .result()
    }
}

// MARK: - ResinTimerRerenderIntent

struct ResinTimerRerenderIntent: AppIntent {
    static let title: LocalizedStringResource = "pzWidgetsKit.Refresh"

    func perform() async throws -> some IntentResult {
        Task {
            let activities = ResinRecoveryActivityController.shared.currentActivities
            for activity in activities {
                await activity.update(activity.content)
            }
        }
        return .result()
    }
}

#endif

// MARK: - ResinTimerRefreshIntent
