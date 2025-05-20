// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - WatchResinDetailView

struct WatchResinDetailView: View {
    let dailyNote: any DailyNoteProtocol

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(height: 25)
                Text("watch.stamina", bundle: .module)
                    .foregroundColor(.gray)
            }
            Text(verbatim: "\(dailyNote.staminaIntel.finished)")
                .font(.system(size: 40, design: .rounded))
                .fontWeight(.medium)
            recoveryTimeText()
        }
    }

    @ViewBuilder
    func recoveryTimeText() -> some View {
        let timeOnFinish = dailyNote.staminaFullTimeOnFinish
        if timeOnFinish >= Date() {
            Text("watch.infoBlock.refilledAt:\(dateFormatter.string(from: timeOnFinish))", bundle: .module)
                .lineLimit(2)
                .foregroundColor(.gray)
                .minimumScaleFactor(0.3)
                .font(.footnote)
        } else {
            Text("watch.stamina.fullyCharged", bundle: .module)
                .foregroundColor(.gray)
                .minimumScaleFactor(0.3)
                .font(.footnote)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let fmt = DateFormatter.CurrentLocale()
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
