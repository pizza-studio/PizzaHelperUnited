// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
import AppIntents
import Defaults
import Foundation
import SFSafeSymbols
import SwiftUI
import WallpaperKit
import WidgetKit

@available(iOS 16.2, macCatalyst 16.2, *)
public struct StaminaTimerLiveActivityWidgetView<
    StaminaTimerIntent4Redraw: AppIntent,
    StaminaTimerIntent4Refetch: AppIntent
>: View {
    // MARK: Lifecycle

    public init(context: ActivityViewContext<LiveActivityAttributes>) {
        self.context = context
    }

    // MARK: Public

    public var body: some View {
        let disableTextShadow = useNoBackground
        let mainContent = Group {
            if #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) {
                Button(intent: redrawIntent) {
                    contentView
                }
                .buttonStyle(.plain)
            } else {
                contentView
            }
        }
        mainContent
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        #if !os(watchOS)
            .background {
                LiveActivityWallpaperView(game: context.state.game)
                    .scaleEffect(context.state.game == .starRail ? 1.05 : 1) // HSR 的名片有光边。
            }
            .overlay(alignment: .bottomTrailing) {
                let label = HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text(context.attributes.profileName)
                    Image(systemSymbol: .arrowTriangle2CirclepathCircle)
                }
                .legibilityShadow(isText: true, enabled: !disableTextShadow)
                .font(.footnote)
                .clipShape(.rect)
                Group {
                    if #available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *) {
                        Button(intent: refetchIntent) {
                            label
                        }
                        .buttonStyle(.plain)
                    } else {
                        label
                    }
                }
                .foregroundColor(useNoBackground ? .primary : .white)
                .padding()
            }
        #endif
            .activityBackgroundTint(.clear)
            .ignoresSafeArea()
    }

    // MARK: Internal

    var useNoBackground: Bool {
        liveActivityWallpaperIDs.contains(Wallpaper.nullLiveActivityWallpaperIdentifier)
    }

    @ViewBuilder var contentView: some View {
        let disableTextShadow = useNoBackground
        Grid(verticalSpacing: 7) {
            GridRow {
                context.state.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 38)
                    .legibilityShadow(isText: false, enabled: !disableTextShadow)
                VStack(alignment: .leading) {
                    Text("pzWidgetsKit.currentStamina", bundle: .module)
                        .font(.caption2)
                    HStack(alignment: .lastTextBaseline, spacing: 0) {
                        Text(verbatim: "\(context.state.currentPrimaryStamina)")
                            .font(.system(.title2, design: .rounded))
                        Text(verbatim: " / \(context.state.maxPrimaryStamina)")
                            .font(.caption)
                    }
                }
                .gridColumnAlignment(.leading)
                .legibilityShadow(isText: true, enabled: !disableTextShadow)
            }
            if Date() < context.state.primaryStaminaRecoveryTime {
                GridRow {
                    Color.clear.frame(width: 38, height: 38, alignment: .center)
                        .overlay {
                            Image(systemSymbol: .alarmWavesLeftAndRightFill)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 22)
                                .padding(.leading, 6)
                                .legibilityShadow(isText: false, enabled: !disableTextShadow)
                        }
                    VStack(alignment: .leading) {
                        Text("pzWidgetsKit.nextMaxStamina", bundle: .module)
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
                    .legibilityShadow(isText: true, enabled: !disableTextShadow)
                }
            }
            if context.state.showExpedition, let time = context.state.expeditionAllCompleteTime, Date() < time {
                GridRow {
                    context.state.game.expeditionAssetIcon
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 29)
                        .legibilityShadow(isText: false, enabled: !disableTextShadow)
                    VStack(alignment: .leading) {
                        Text("pzWidgetsKit.expedition.timeToAllCompletion", bundle: .module)
                            .font(.caption2)
                        Text(
                            timerInterval: Date() ... time,
                            countsDown: true
                        )
                        .multilineTextAlignment(.leading)
                        .font(.system(.title2, design: .rounded))
                    }
                    .gridColumnAlignment(.leading)
                    .legibilityShadow(isText: true, enabled: !disableTextShadow)
                }
            }
        }
        .foregroundColor(useNoBackground ? .primary : .white)
        .padding()
    }

    // MARK: Private

    @State private var context: ActivityViewContext<LiveActivityAttributes>

    private let redrawIntent = StaminaTimerIntent4Redraw()
    private let refetchIntent = StaminaTimerIntent4Refetch()

    @Default(.liveActivityWallpaperIDs) private var liveActivityWallpaperIDs: Set<String>
}

#endif
