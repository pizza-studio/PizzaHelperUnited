// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetCorner

@available(iOS 17.0, macCatalyst 17.0, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    // MARK: Lifecycle

    public struct LockScreenResinWidgetCorner: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public var body: some View {
            Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG
                .resizable()
                .scaledToFit()
                .padding(3)
                .widgetLabel(text)
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let entry: any TimelineEntry
        private let result: Result<any DailyNoteProtocol, any Error>

        private var text: String {
            switch result {
            case let .success(data):
                let staminaIntel = data.staminaIntel
                let timeOnFinish = data.staminaFullTimeOnFinish
                if staminaIntel.isAccomplished {
                    return "\(data.maxPrimaryStamina), " +
                        String(
                            localized: String
                                .LocalizationValue(
                                    stringLiteral: "pzWidgetsKit.infoBlock.staminaFullyFilledDescription.tiny"
                                ),
                            bundle: .module
                        )
                } else {
                    return "\(staminaIntel.finished), \(PZWidgetsSPM.intervalFormatter.string(from: TimeInterval.sinceNow(to: timeOnFinish))!)"
                }
            case .failure:
                return String(
                    localized: String.LocalizationValue(stringLiteral: "pzWidgetsKit.stamina.label"),
                    bundle: .module
                )
            }
        }
    }
}

#endif
