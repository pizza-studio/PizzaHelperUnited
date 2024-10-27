// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - MainInfoWithDetail

struct MainInfoWithDetail: View {
    let entry: any TimelineEntry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    @MainActor var body: some View {
        HStack {
            Spacer()
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: accountName
            )
            .padding()
            Spacer()
            DetailInfo(entry: entry, dailyNote: dailyNote, viewConfig: viewConfig)
                .padding([.vertical])
                .containerRelativeFrame(.horizontal) { length, _ in length / 8 * 3 }
            Spacer()
        }
    }
}
