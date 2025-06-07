// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetCorner

@available(macOS, unavailable)
extension EmbeddedWidgets {
    // MARK: Lifecycle

    @available(macOS, unavailable)
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
                    return "\(data.maxPrimaryStamina), " + "已回满".i18nWidgets
                } else {
                    return "\(staminaIntel.finished), \(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: timeOnFinish))!)"
                }
            case .failure:
                return "pzWidgetsKit.stamina.label".i18nWidgets
            }
        }
    }
}
