// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
// @_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI

@available(macOS, unavailable)
struct LockScreenDailyTaskWidgetCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        VStack(spacing: 0) {
            Image("icon.dailyTask", bundle: .main)
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
                switch data {
                case let data as any Note4GI:
                    Text(verbatim: "\(data.dailyTaskInfo.finishedTaskCount) / \(data.dailyTaskInfo.totalTaskCount)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                case let data as WidgetNote4HSR:
                    Text(verbatim: "\(data.dailyTrainingInfo.currentScore) / \(data.dailyTrainingInfo.maxScore)")
                        .font(.system(.body, design: .rounded).weight(.medium))
                default:
                    Image(systemSymbol: .ellipsis)
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
