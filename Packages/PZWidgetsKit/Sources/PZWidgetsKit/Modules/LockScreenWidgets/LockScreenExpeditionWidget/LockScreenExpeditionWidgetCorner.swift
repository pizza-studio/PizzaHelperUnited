// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI

// MARK: - LockScreenExpeditionWidgetCorner

struct LockScreenExpeditionWidgetCorner: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

    var text: String {
        switch result {
        case let .success(data):
            let timeDescription: String = {
                if data.expeditionInfo4GI.allCompleted {
                    return "widget.status.done".i18nWidgets
                } else {
                    if let expeditionInformation = data.expeditionInfo4GI as? GeneralNote4GI
                        .ExpeditionInfo4GI {
                        return formatter.string(from: expeditionInformation.expeditions.map(\.finishTime).max()!)
                    } else {
                        return ""
                    }
                }
            }()
            return "\(data.expeditionInfo4GI.ongoingExpeditionCount)/\(data.expeditionInfo4GI.maxExpeditionsCount) \(timeDescription)"
        case .failure:
            return "app.dailynote.card.expedition.label".i18nWidgets
        }
    }

    var body: some View {
        Image("icon.expedition")
            .resizable()
            .scaledToFit()
            .padding(3.5)
            .widgetLabel(text)
    }
}

private let formatter: DateFormatter = {
    let fmt = DateFormatter()
    fmt.doesRelativeDateFormatting = true
    fmt.dateStyle = .short
    fmt.timeStyle = .short
    return fmt
}()
