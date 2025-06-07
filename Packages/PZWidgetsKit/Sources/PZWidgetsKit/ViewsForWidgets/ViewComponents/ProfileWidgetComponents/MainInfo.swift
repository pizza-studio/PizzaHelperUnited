// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

@available(watchOS, unavailable)
public struct MainInfo<RefreshIntent: WidgetRefreshIntentProtocol>: View {
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
            tinyGlassDisplayStyle: viewConfig.useTinyGlassDisplayStyle,
            refreshIntent: RefreshIntent(dailyNoteUIDWithGame: entry.profile?.uidWithGame)
        )
    }

    // MARK: Private

    private let entry: ProfileWidgetEntry
    private let dailyNote: any DailyNoteProtocol
    private let viewConfig: WidgetViewConfig
}
