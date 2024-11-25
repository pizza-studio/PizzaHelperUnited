// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - MainInfoWithDetail

@available(watchOS, unavailable)
struct MainInfoWithDetail: View {
    let entry: any TimelineEntry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        HStack {
            Spacer()
                .containerRelativeFrame(.horizontal) { length, _ in length / 10 * 1 }
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: accountName
            )
            .containerRelativeFrame(.horizontal, alignment: .leading) { length, _ in length / 10 * 4 }
            DetailInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig
            )
            .containerRelativeFrame(.horizontal, alignment: .center) { length, _ in length / 10 * 4 }
            Spacer()
                .containerRelativeFrame(.horizontal) { length, _ in length / 10 * 1 }
        }
        .containerRelativeFrame(.horizontal) { length, _ in length / 10 * 8 }
        .padding()
        .padding(.horizontal)
    }
}
