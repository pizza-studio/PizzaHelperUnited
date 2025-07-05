// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@available(macOS, unavailable)
extension EmbeddedWidgets {
    public struct LockScreenLoopWidgetCorner: View {
        // MARK: Lifecycle

        public init(entry: any TimelineEntry, result: Result<any DailyNoteProtocol, any Error>) {
            self.entry = entry
            self.result = result
        }

        // MARK: Public

        public let entry: any TimelineEntry

        public var body: some View {
            switch LockScreenLoopWidgetType.autoChoose(entry: entry, result: result) {
            case .resin:
                LockScreenResinWidgetCorner(entry: entry, result: result)
            case .dailyTask:
                LockScreenDailyTaskWidgetCorner(result: result)
            case .expedition:
                LockScreenExpeditionWidgetCorner(result: result)
            case .homeCoin:
                LockScreenHomeCoinWidgetCorner(entry: entry, result: result)
            }
        }

        // MARK: Private

        @Environment(\.widgetRenderingMode) private var widgetRenderingMode

        private let result: Result<any DailyNoteProtocol, any Error>
    }
}
