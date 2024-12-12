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
            let trailingTextStr = PZWidgets.intervalFormatter.string(
                from: TimeInterval.sinceNow(to: data.staminaFullTimeOnFinish)
            )!
            let textDisplay = if staminaStatus.isAccomplished {
                Text(verbatim: " \(staminaStatus.all) @ 100%")
            } else {
                Text(verbatim: " \(staminaStatus.finished)  \(trailingTextStr)")
            }
            // In case of iOS, only SF Symbols are allowed image objects.
            // In case of watchOS, only texts are allowed as the representation of this widget.
            #if os(watchOS)
            Text(verbatim: data.game.localizedShortName) + textDisplay
            #else
            let sfSymbol: SFSymbol = switch data.game {
            case .genshinImpact: .moonFill
            case .starRail: .line3CrossedSwirlCircleFill
            case .zenlessZone: .minusPlusAndFluidBatteryblock
            }
            Text("\(Image(systemSymbol: sfSymbol))") + textDisplay
            #endif
        case .failure:
            Text(verbatim: "…")
        }
    }
}
