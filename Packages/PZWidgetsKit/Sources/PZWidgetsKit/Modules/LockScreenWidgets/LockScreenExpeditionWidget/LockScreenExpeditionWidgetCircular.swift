// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI

struct LockScreenExpeditionWidgetCircular: View {
    // MARK: Internal

    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        VStack(spacing: 0) {
            Image("icon.expedition")
                .resizable()
                .scaledToFit()
            switch result {
            case let .success(data):
                drawExpeditionCompletionStatus(for: data)?
                    .font(.system(.body, design: .rounded).weight(.medium))
            case .failure:
                Image(systemSymbol: .ellipsis)
            }
        }
        .widgetAccentable(widgetRenderingMode == .accented)
        #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
        #else
            .padding(.vertical, 2)
        #endif
    }

    // MARK: Private

    @MainActor
    private func drawExpeditionCompletionStatus(for data: any DailyNoteProtocol) -> Text? {
        /// ZZZ Has no expedition intels available through API yet.
        switch data {
        case let data as any Note4GI:
            let numerator = data.expeditionProgressCounts.ongoing
            let denominator = data.expeditionProgressCounts.all
            let result = "\(numerator) / \(denominator)"
            return Text(verbatim: result)
        case let data as Note4HSR:
            let numerator = data.expeditionProgressCounts.ongoing
            let denominator = data.expeditionProgressCounts.all
            let result = "\(numerator) / \(denominator)"
            return Text(verbatim: result)
        default:
            return nil
        }
    }
}
