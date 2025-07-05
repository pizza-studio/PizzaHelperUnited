// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct MainInfo: View {
        // MARK: Lifecycle

        public init(
            entry: ProfileWidgetEntry,
            dailyNote: any DailyNoteProtocol,
            viewConfig: WidgetViewConfig
        ) {
            self.entry = entry
            self.dailyNote = dailyNote
            self.viewConfig = viewConfig
        }

        // MARK: Public

        public var body: some View {
            ProfileAndMainStaminaView(
                profile: entry.profile,
                dailyNote: dailyNote,
                tinyGlassDisplayStyle: viewConfig.useTinyGlassDisplayStyle
            )
        }

        // MARK: Private

        private let entry: ProfileWidgetEntry
        private let dailyNote: any DailyNoteProtocol
        private let viewConfig: WidgetViewConfig
    }
}

#endif
