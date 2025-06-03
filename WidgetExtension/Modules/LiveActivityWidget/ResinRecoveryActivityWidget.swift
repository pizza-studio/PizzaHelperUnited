// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
import ActivityKit
import AppIntents
import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit
import WidgetKit

struct ResinTimerRefreshIntent: AppIntent {
    // MARK: Public

    public static var isDiscoverable: Bool { false }

    // MARK: Internal

    static let title: LocalizedStringResource = "pzWidgetsKit.WidgetRefreshIntent.Refresh"

    func perform() async throws -> some IntentResult {
        let activities = StaminaLiveActivityController.shared.currentActivities
        let accounts = PZWidgets.getAllProfiles()
        for activity in activities {
            let account = accounts.first(where: { account in
                account.uuid == activity.attributes.profileUUID
            })
            guard let account else { continue }
            let result = try await account.getDailyNote()
            StaminaLiveActivityController.shared.updateResinRecoveryTimerActivity(for: account, data: result)
        }
        return .result()
    }
}

struct ResinTimerRerenderIntent: AppIntent {
    // MARK: Public

    public static var isDiscoverable: Bool { false }

    // MARK: Internal

    static let title: LocalizedStringResource = "pzWidgetsKit.WidgetRefreshIntent.Refresh"

    func perform() async throws -> some IntentResult {
        Task {
            let activities = StaminaLiveActivityController.shared.currentActivities
            for activity in activities {
                await activity.update(activity.content)
            }
        }
        return .result()
    }
}

struct ResinRecoveryActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(
            for: LiveActivityAttributes
                .self
        ) { context in
            ResinRecoveryActivityWidgetLockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemSymbol: .personFill)
                        Text(context.attributes.profileName)
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
                        Text("app.title.short".i18nBaseKit)
                            .foregroundColor(Color("textColor.appIconLike", bundle: .main))
                            .font(.caption2)
                    }
                    .padding(.trailing)
                }
                .contentMargins(.leading, 15)
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        if Date() < context.state.next20PrimaryStaminaRecoveryTime {
                            HStack {
                                context.state.game.primaryStaminaAssetIcon
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 40)
                                VStack(alignment: .leading) {
                                    Text(
                                        "pzWidgetsKit.next20Stamina:\(context.state.next20PrimaryStamina)",
                                        bundle: .main
                                    )
                                    .font(.caption2)
                                    Text(
                                        timerInterval: Date() ... context.state
                                            .next20PrimaryStaminaRecoveryTime,
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
                        if Date() < context.state.primaryStaminaRecoveryTime {
                            HStack {
                                Color.clear.frame(width: 40, height: 40, alignment: .center)
                                    .overlay {
                                        Image(systemSymbol: .evChargerArrowtriangleRight)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 24)
                                    }
                                VStack(alignment: .leading) {
                                    Text("pzWidgetsKit.nextMaxStamina", bundle: .main)
                                        .font(.caption2)

                                    Text(
                                        timerInterval: Date() ... context.state
                                            .primaryStaminaRecoveryTime,
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
                context.state.game.primaryStaminaAssetIcon.resizable().scaledToFit()
            } compactTrailing: {
                if Date() < context.state
                    .next20PrimaryStaminaRecoveryTime {
                    Text(
                        timerInterval: Date() ... context.state
                            .next20PrimaryStaminaRecoveryTime,
                        countsDown: true,
                        showsHours: false
                    )
                    .monospacedDigit()
                    .multilineTextAlignment(.center)
                    .frame(width: 60)
                    .foregroundColor(Color("textColor2", bundle: .main))
                }
            } minimal: {
                context.state.game.primaryStaminaAssetIcon.resizable().scaledToFit()
            }
        }
    }
}

struct ResinRecoveryActivityWidgetLockScreenView: View {
    // MARK: Internal

    @State var context: ActivityViewContext<LiveActivityAttributes>

    var backgroundIDs: [String] {
        backgrounds4LiveActivity.map(\.assetName4LiveActivity)
    }

    var useNoBackground: Bool { context.state.background == .noBackground }

    var body: some View {
        let mainContent = contentView
        #if !os(watchOS)
            .background {
                if let userWallpaperOverride, context.state.background != .noBackground {
                    userWallpaperOverride
                        .resizable()
                        .scaledToFill()
                    Color.black
                        .opacity(0.3)
                } else {
                    Group {
                        let randomCardBg: Image = (
                            Wallpaper.allCases(
                                for: context.state.game
                            ).randomElement() ?? .defaultValue()
                        )
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
                                backgroundIDs.contains(wallpaper.assetName4LiveActivity)
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
                    .scaleEffect(1.01) // HSR 的名片有光边。
                }
            }
        #endif
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .activityBackgroundTint(.clear)
        Button(intent: ResinTimerRerenderIntent()) {
            mainContent
        }
        .buttonStyle(.plain)
        .ignoresSafeArea()
    }

    @ViewBuilder var contentView: some View {
        HStack {
            Grid(verticalSpacing: 7) {
                GridRow {
                    context.state.game.primaryStaminaAssetIcon
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 38)
                    VStack(alignment: .leading) {
                        Text("pzWidgetsKit.currentStamina", bundle: .main)
                            .font(.caption2)
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            Text(verbatim: "\(context.state.currentPrimaryStamina)")
                                .font(.system(.title2, design: .rounded))
                            Text(verbatim: " / \(context.state.maxPrimaryStamina)")
                                .font(.caption)
                        }
                    }
                    .gridColumnAlignment(.leading)
                }
                if Date() < context.state.primaryStaminaRecoveryTime {
                    GridRow {
                        Color.clear.frame(width: 38, height: 38, alignment: .center)
                            .overlay {
                                Image(systemSymbol: .evChargerArrowtriangleRight)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 22)
                                    .padding(.leading, 6)
                            }
                        VStack(alignment: .leading) {
                            Text("pzWidgetsKit.nextMaxStamina", bundle: .main)
                                .font(.caption2)
                            Text(
                                timerInterval: Date() ... context.state
                                    .primaryStaminaRecoveryTime,
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
                        context.state.game.expeditionAssetIcon
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
                Button(intent: ResinTimerRefreshIntent()) {
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(context.attributes.profileName)
                        Image(systemSymbol: .arrowTriangle2CirclepathCircle)
                    }
                }
                .buttonStyle(.plain)
                .font(.footnote)
            }
        }
        .shadow(radius: useNoBackground ? 0 : 0.8)
        .foregroundColor(useNoBackground ? .primary : Color("textColor3", bundle: .main))
        .padding()
    }

    // MARK: Private

    @Default(.backgrounds4LiveActivity) private var backgrounds4LiveActivity: Set<Wallpaper>
    @Default(.userWallpapers4LiveActivity) private var userWallpaperIDs4LiveActivity: Set<String>

    private var userWallpapers4LiveActivity: Set<UserWallpaper> {
        .init(defaultsValueIDs: userWallpaperIDs4LiveActivity)
    }

    private var userWallpaperOverride: Image? {
        let cgImage = userWallpapers4LiveActivity.randomElement()?.imageHorizontal
        guard let cgImage else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

#endif
