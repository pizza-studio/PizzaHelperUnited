// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - LockScreenResinWidgetInline

@available(macOS, unavailable)
struct LockScreenResinWidgetInline: View {
    let entry: any TimelineEntry
    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        switch result {
        case let .success(data):
            let staminaStatus = data.staminaIntel
            // Only SF Symbols are allowed image objects in this widget.
            let sfSymbol: SFSymbol = switch data.game {
            case .genshinImpact: .moonFill
            case .starRail: .line3CrossedSwirlCircleFill
            case .zenlessZone: .minusPlusAndFluidBatteryblock
            }
            let trailingTextStr = PZWidgets.intervalFormatter.string(
                from: TimeInterval.sinceNow(to: data.staminaFullTimeOnFinish)
            )!
            let textDisplay = if staminaStatus.isAccomplished {
                Text(verbatim: " \(staminaStatus.all) @ 100%")
            } else {
                Text(verbatim: " \(staminaStatus.finished)  \(trailingTextStr)")
            }
            Text("\(Image(systemSymbol: sfSymbol))") + textDisplay
        case .failure:
            Text(verbatim: "…")
        }
    }
}
