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
    let result: Result<any Note4GI, any Error>

    var body: some View {
        switch result {
        case let .success(data):
            if data.resinInfo.calculatedCurrentResin(referTo: entry.date) >= data.resinInfo.maxResin {
                Image(systemSymbol: .moonStarsFill)
            } else {
                Image(systemSymbol: .moonFill)
            }
            Text(
                "\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))  \(intervalFormatter.string(from: TimeInterval.sinceNow(to: data.resinInfo.resinRecoveryTime))!)"
            )
        // 似乎不能插入自定义的树脂图片，也许以后会开放
//                Image("icon.resin")
        case .failure:
            Image(systemSymbol: .moonFill)
            Text("…")
        }
    }
}

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()

private let intervalFormatter: DateComponentsFormatter = {
    let dateComponentFormatter = DateComponentsFormatter()
    dateComponentFormatter.allowedUnits = [.hour, .minute]
    dateComponentFormatter.maximumUnitCount = 2
    dateComponentFormatter.unitsStyle = .brief
    return dateComponentFormatter
}()
