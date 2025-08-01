// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(macOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenLoopWidgetCircular

@available(iOS 16.2, macCatalyst 16.2, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct LockScreenLoopWidgetCircular: View {
        // MARK: Lifecycle

        public init(
            entry: any TimelineEntry,
            result: Result<any DailyNoteProtocol, any Error>,
            resinStyle: PZWidgetsSPM.StaminaContentRevolverStyle
        ) {
            self.entry = entry
            self.result = result
            self.resinStyle = resinStyle
        }

        // MARK: Public

        public let entry: any TimelineEntry

        public var body: some View {
            switch LockScreenLoopWidgetType.autoChoose(entry: entry, result: result) {
            case .resin:
                switch resinStyle {
                case .byDefault:
                    AlternativeLockScreenResinWidgetCircular(entry: entry, result: result)
                case .timer:
                    LockScreenResinTimerWidgetCircular(entry: entry, result: result)
                case .time:
                    LockScreenResinFullTimeWidgetCircular(entry: entry, result: result)
                case .roundMeter:
                    LockScreenResinWidgetCircular(entry: entry, result: result)
                }
            case .dailyTask:
                LockScreenDailyTaskWidgetCircular(result: result)
            case .expedition:
                LockScreenExpeditionWidgetCircular(result: result)
            case .homeCoin:
                LockScreenHomeCoinWidgetCircular(entry: entry, result: result)
            }
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let result: Result<any DailyNoteProtocol, any Error>
        private let resinStyle: PZWidgetsSPM.StaminaContentRevolverStyle
    }
}

#endif
