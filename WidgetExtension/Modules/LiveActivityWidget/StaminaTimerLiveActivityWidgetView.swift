// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst)
import Defaults
import Foundation
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit
import WidgetKit

struct StaminaTimerLiveActivityWidgetView: View {
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
        Button(intent: StaminaTimerRerenderIntent()) {
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
                Button(intent: StaminaTimerRefreshIntent()) {
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
