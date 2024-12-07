// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

@available(macOS, unavailable)
struct LockScreenDailyTaskWidgetCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        VStack(spacing: 0) {
            Pizza.SupportedGame(dailyNoteResult: result).dailyTaskAssetSVG
                .resizable()
                .scaledToFit()
                .apply { imageView in
                    if widgetRenderingMode == .fullColor {
                        imageView
                            .foregroundColor(Color("iconColor.dailyTask", bundle: .main))
                    } else {
                        imageView
                    }
                }
            switch result {
            case let .success(data):
                if data.hasDailyTaskIntel {
                    let sitrep = data.dailyTaskCompletionStatus
                    Text(verbatim: "\(sitrep.finished) / \(sitrep.all)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                } else {
                    Text(verbatim: "WRONG GAME").fixedSize().fontWidth(.compressed)
                        .minimumScaleFactor(0.2)
                }
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
}
