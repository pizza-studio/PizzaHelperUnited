// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit
import WidgetKit

@available(iOS 17.0, macCatalyst 17.0, *)
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
    @Environment(\.self) private var environmentValues: EnvironmentValues

    @DynamicIslandExpandedContentBuilder private var expandedContent: DynamicIslandExpandedContent<some View> {
        DynamicIslandExpandedRegion(.leading) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Image(systemSymbol: .personFill)
                Text(context.attributes.profileName)
            }
            .foregroundTint(PZWidgetsSPM.Colors.TextColor.appIconLike.suiColor)
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
                Text(Pizza.appTitleLocalizedShort)
                    .foregroundTint(PZWidgetsSPM.Colors.TextColor.appIconLike.suiColor)
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
            .foregroundTint(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
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
                    .foregroundTint(
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
                    .foregroundTint(
                        PZWidgetsSPM.Colors.TextColor.originResin.suiColor
                    )
                    .gridColumnAlignment(.trailing)
                Image(systemSymbol: .checkmarkCircle)
                    .resizable()
                    .scaledToFit()
                    .foregroundTint(.green)
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
                            bundle: .currentSPM
                        )
                        .font(.caption2)
                        Text(
                            timerInterval: Date() ... context.state
                                .next20PrimaryStaminaRecoveryTime,
                            countsDown: true
                        )
                        .multilineTextAlignment(.leading)
                        .font(.system(.title2, design: .rounded))
                        .foregroundTint(
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
                        Text("pzWidgetsKit.nextMaxStamina", bundle: .currentSPM)
                            .font(.caption2)

                        Text(
                            timerInterval: Date() ... context.state
                                .primaryStaminaRecoveryTime,
                            countsDown: true
                        )
                        .multilineTextAlignment(.leading)
                        .font(.system(.title2, design: .rounded))
                        .foregroundTint(
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

    /// 瀏海右側的緊湊倒數。格式恆為 `MM:SS`（由 `Text(timerInterval:)` 逐秒自動刷新），
    /// 寬度不足時改用 SF Pro 的 Compressed 字寬收窄，而不是把格式改寫成 `12m` 之類的縮寫。
    @ViewBuilder private var compactTrailingContent: some View {
        let nextRecoveryTime = context.state.next20PrimaryStaminaRecoveryTime
        if Date() < nextRecoveryTime {
            compactTrailingCountdownText(until: nextRecoveryTime)
                .foregroundTint(PZWidgetsSPM.Colors.TextColor.activityBlueText.suiColor)
        } else {
            Image(systemSymbol: .checkmarkCircle)
                .foregroundTint(.green)
                .frame(width: 20)
        }
    }

    @ViewBuilder private var minimalContent: some View {
        context.state.game.primaryStaminaAssetIcon.resizable().scaledToFit()
    }

    /// 系統在「限縮寬度」下渲染緊湊版 Live Activity 時（例如 iPhone 18 Pro 同時有
    /// 2 個以上 Live Activity、橫向、iPhone Duo），那是渲染期的裁切、SwiftUI 量不到，
    /// 只能靠 iOS 27 起提供的 `isDynamicIslandLimitedInWidth` 得知，直接走壓縮字寬；
    /// 其餘情況交給 `ViewThatFits`，用實際提案寬度決定要不要壓縮。
    @ViewBuilder
    private func compactTrailingCountdownText(until date: Date) -> some View {
        if #available(iOS 27.0, *), environmentValues.isDynamicIslandLimitedInWidth {
            compactTrailingTimerText(until: date, compressed: true)
        } else {
            ViewThatFits(in: .horizontal) {
                compactTrailingTimerText(until: date, compressed: false)
                compactTrailingTimerText(until: date, compressed: true)
            }
        }
    }

    /// `compressed: false` 時沿用 60pt 的既有預留寬度，該寬度同時是 `ViewThatFits` 的門檻。
    /// 壓縮後實測（17pt，SF Pro）：`23:46` 46pt → 30pt、`160:23` 53pt → 36pt，比 `12m` 的 32pt 還窄。
    /// 注意：這裡不可加上 `design: .rounded` —— SF Rounded 沒有壓縮變體，`fontWidth` 會失效。
    @ViewBuilder
    private func compactTrailingTimerText(until date: Date, compressed: Bool) -> some View {
        let timer = Text(timerInterval: Date() ... date, countsDown: true, showsHours: false)
            .monospacedDigit()
        if compressed {
            timer
                .fontWidth(.compressed)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
        } else {
            timer
                .multilineTextAlignment(.center)
                .frame(width: 60)
        }
    }
}

#endif
