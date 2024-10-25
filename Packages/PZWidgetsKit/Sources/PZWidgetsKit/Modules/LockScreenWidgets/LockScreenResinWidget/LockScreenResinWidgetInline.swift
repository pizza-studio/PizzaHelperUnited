// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetInline

struct LockScreenResinWidgetInline: View {
    let entry: any TimelineEntry
    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        switch result {
        case let .success(data):
            let staminaStaus = data.staminaIntel

            if staminaStaus.existing >= staminaStaus.max {
                Image(systemSymbol: .moonStarsFill)
            } else {
                Image(systemSymbol: .moonFill)
            }
            Text(
                "\(staminaStaus.existing)  \(PZWidgets.intervalFormatter.string(from: TimeInterval.sinceNow(to: data.staminaFullTimeOnFinish))!)"
            )
        // 似乎不能插入自定义的树脂图片，也许以后会开放
//                Image("icon.resin")
        case .failure:
            Image(systemSymbol: .moonFill)
            Text("…")
        }
    }
}
