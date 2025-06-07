// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit
import PZWidgetsKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - MainInfo

@available(watchOS, unavailable)
struct MainInfo: View {
    let entry: MainWidgetProvider.Entry
    let dailyNote: any DailyNoteProtocol
    let viewConfig: Config4DesktopProfileWidgets
    let accountName: String?

    var body: some View {
        ProfileAndMainStaminaView(
            profile: entry.profile,
            dailyNote: dailyNote,
            tinyGlassDisplayStyle: viewConfig.useTinyGlassDisplayStyle,
            refreshIntent: WidgetRefreshIntent(dailyNoteUIDWithGame: entry.profile?.uidWithGame)
        )
    }
}
