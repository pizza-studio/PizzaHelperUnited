// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - MainInfo

@available(iOS 17.0, macCatalyst 17.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct ProfileAndMainStaminaView: View {
        // MARK: Lifecycle

        public init(
            profile: PZProfileSendable?,
            dailyNote: any DailyNoteProtocol,
            tinyGlassDisplayStyle: Bool = false,
            verticalSpacing4NonTinyGlassMode: CGFloat? = 0,
            useSpacer: Bool = true
        ) {
            self.profile = profile
            self.dailyNote = dailyNote
            self.tinyGlassDisplayStyle = tinyGlassDisplayStyle
            self.useSpacer = useSpacer
            self.verticalSpacing4NonTinyGlassMode = verticalSpacing4NonTinyGlassMode
        }

        // MARK: Public

        public var body: some View {
            VStack(alignment: .leading, spacing: verticalSpacing4NonTinyGlassMode) {
                if profile != nil {
                    profileNameLabel
                    if useSpacer { Spacer() }
                }

                switch tinyGlassDisplayStyle {
                case false:
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(dailyNote.staminaIntel.finished.description)
                            .font(.system(size: 50, design: .rounded))
                            .fontWeight(.medium)
                            .minimumScaleFactor(0.1)
                            .legibilityShadow()
                        dailyNote.game.primaryStaminaAssetIcon
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 30)
                            .alignmentGuide(.firstTextBaseline) { context in
                                context[.bottom] - 0.17 * context.height
                            }
                            .legibilityShadow(isText: false)
                    }
                    if useSpacer { Spacer() }
                    HStack {
                        let labelImage = Image(systemSymbol: .arrowClockwiseCircle)
                            .font(.title3)
                            .clipShape(.circle)
                            .legibilityShadow()
                        Button(intent: WidgetRefreshIntent(dailyNoteUIDWithGame: profile?.uidWithGame)) {
                            labelImage
                        }
                        .buttonStyle(.plain)
                        StaminaRecoveryTimeText(data: dailyNote)
                    }
                case true:
                    staminaLabelCompact
                }
            }
            .foregroundColor(.primary)
            .environment(\.colorScheme, .dark)
        }

        @ViewBuilder public var profileNameLabel: some View {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                switch tinyGlassDisplayStyle {
                case false:
                    Image(systemSymbol: .personFill)
                        .legibilityShadow(isText: false)
                    Text(profile?.name ?? "Anonymous")
                        .allowsTightening(true)
                        .lineLimit(1)
                        .fixedSize()
                        .minimumScaleFactor(0.5)
                        .legibilityShadow()
                        .font(.footnote)
                case true:
                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Image(systemSymbol: .personFill)
                            .legibilityShadow(isText: false)
                        Text(profile?.name ?? "Anonymous")
                            .legibilityShadow(isText: true)
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .widgetAccessibilityBackground(enabled: true)
                }
            }
        }

        @ViewBuilder public var staminaLabelCompact: some View {
            let bigLabel = HStack(spacing: 0) {
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(minHeight: 20, maxHeight: 27)
                    .legibilityShadow(isText: false)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(dailyNote.staminaIntel.finished.description)
                        .minimumScaleFactor(0.5)
                        .font(staminaFont4TinyGlassMode)
                        .legibilityShadow(isText: false)
                        .lineLimit(1)
                    StaminaRecoveryTimeText(data: dailyNote, tiny: true)
                        .lineLimit(2).lineSpacing(1)
                        .minimumScaleFactor(0.5)
                        .fontWidth(.condensed)
                }
            }
            .padding(.leading, 5)
            .padding(.trailing, 10)
            .padding(.vertical, 5)
            .widgetAccessibilityBackground(enabled: true)
            Button(intent: WidgetRefreshIntent(dailyNoteUIDWithGame: profile?.uidWithGame)) {
                bigLabel
            }
            .buttonStyle(.plain)
        }

        // MARK: Private

        @Environment(\.widgetFamily) private var widgetFamily

        private let profile: PZProfileSendable?
        private let dailyNote: any DailyNoteProtocol
        private let tinyGlassDisplayStyle: Bool
        private let verticalSpacing4NonTinyGlassMode: CGFloat?
        private let useSpacer: Bool

        private var staminaFont4TinyGlassMode: Font {
            switch widgetFamily {
            case .systemSmall:
                return .title3
            case .systemExtraLarge, .systemLarge, .systemMedium:
                return .title
            default:
                return .title
            }
        }
    }
}

#endif
