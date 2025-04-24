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
    let entry: MainWidgetProvider.Entry
    var dailyNote: any DailyNoteProtocol
    let viewConfig: WidgetViewConfiguration
    let accountName: String?

    var body: some View {
        HStack {
            Spacer()
            MainInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                accountName: accountName
            )
            Spacer()
            DetailInfo(
                entry: entry,
                dailyNote: dailyNote,
                viewConfig: viewConfig,
                spacing: 10
            )
            .fixedSize(horizontal: true, vertical: false)
            Spacer()
        }
    }
}
