// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
import Defaults
import Foundation
import SFSafeSymbols
import SwiftUI
import WallpaperKit
import WidgetKit

@available(iOS 16.2, macCatalyst 16.2, *)
public struct StaminaTimerDynamicIslandWidgetView: View {
    // MARK: Lifecycle

    public init(context: ActivityViewContext<LiveActivityAttributes>) {
        self.context = context
    }

    // MARK: Public

    public var dynamicIsland: DynamicIsland {
        DynamicIsland {
            expandedContent
        } compactLeading: {
            compactLeadingContent
        } compactTrailing: {
            compactTrailingContent
        } minimal: {
            minimalContent
        }
    }

    public var body: some View {
        Text(
            verbatim: "Use `StaminaTimerDynamicIslandWidgetView().dynamicIsland` instead."
        )
    }

    // MARK: Private

    @State private var context: ActivityViewContext<LiveActivityAttributes>

    @DynamicIslandExpandedContentBuilder private var expandedContent: DynamicIslandExpandedContent<some View> {
        DynamicIslandExpandedRegion(.leading) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemSymbol: .personFill)
                Text(context.attributes.profileName)
            }
            .foregroundColor(PZWidgetsSPM.Colors.TextColor.appIconLike.suiColor)
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
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.appIconLike.suiColor)
                    .font(.caption2)
            }
            .padding(.trailing)
        }
        .contentMargins(.leading, 15)
        DynamicIslandExpandedRegion(.bottom) {
            Group {
                if Date() < context.state.primaryStaminaRecoveryTime {
                    expandedContentWhenStaminaIsNotFull
                } else {
                    expandedContentWhenStaminaIsFull
                }
            }
            .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
        }
    }

    @ViewBuilder private var expandedContentWhenStaminaIsFull: some View {
        HStack {
            HStack {
                context.state.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
                Text(verbatim: context.state.currentPrimaryStamina.description)
                    .multilineTextAlignment(.leading)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(
                        PZWidgetsSPM.Colors.TextColor.originResin.suiColor
                    )
                    .gridColumnAlignment(.leading)
            }
            .frame(height: 40)
            Spacer()
            HStack {
                Text(verbatim: "100%")
                    .multilineTextAlignment(.trailing)
                    .font(.system(.title, design: .rounded))
                    .foregroundColor(
                        PZWidgetsSPM.Colors.TextColor.originResin.suiColor
                    )
                    .gridColumnAlignment(.trailing)
                Image(systemSymbol: .checkmarkCircle)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.green)
                    .frame(height: 30)
            }
            .frame(height: 40)
        }
    }

    @ViewBuilder private var expandedContentWhenStaminaIsNotFull: some View {
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
                            bundle: .module
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
                            PZWidgetsSPM.Colors.TextColor.originResin.suiColor
                        )
                    }
                    .gridColumnAlignment(.leading)
                    .frame(width: 100)
                }
            }
            Spacer()
            if Date() < context.state.primaryStaminaRecoveryTime {
                HStack {
                    Color.clear
                        .frame(width: 40, height: 40, alignment: .center)
                        .overlay {
                            Image(systemSymbol: .alarmWavesLeftAndRightFill)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 24)
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
                        .foregroundColor(
                            PZWidgetsSPM.Colors.TextColor.originResin.suiColor
                        )
                    }
                    .gridColumnAlignment(.leading)
                    .frame(width: 100)
                }
            }
        }
    }

    @ViewBuilder private var compactLeadingContent: some View {
        context.state.game.primaryStaminaAssetIcon.resizable().scaledToFit()
    }

    @ViewBuilder private var compactTrailingContent: some View {
        let nextTS = context.state.next20PrimaryStaminaRecoveryTime.timeIntervalSince1970
        if Date().timeIntervalSince1970 < nextTS {
            Text(
                timerInterval: Date() ... context.state
                    .next20PrimaryStaminaRecoveryTime,
                countsDown: true,
                showsHours: false
            )
            .monospacedDigit()
            .multilineTextAlignment(.center)
            .frame(width: 60)
            .foregroundColor(PZWidgetsSPM.Colors.TextColor.activityBlueText.suiColor)
        } else {
            Image(systemSymbol: .checkmarkCircle)
                .foregroundColor(.green)
                .frame(width: 20)
        }
    }

    @ViewBuilder private var minimalContent: some View {
        context.state.game.primaryStaminaAssetIcon.resizable().scaledToFit()
    }
}

#endif
