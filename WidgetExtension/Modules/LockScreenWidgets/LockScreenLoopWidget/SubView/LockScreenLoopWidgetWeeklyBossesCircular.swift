// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

@available(macOS, unavailable)
struct LockScreenLoopWidgetWeeklyBossesCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
        VStack(spacing: 0) {
            Image("icon.weeklyBosses", bundle: .main)
                .resizable()
                .scaledToFit()
                .apply { imageView in
                    if widgetRenderingMode == .fullColor {
                        imageView
                            .foregroundColor(Color("iconColor.weeklyBosses", bundle: .main))
                    } else {
                        imageView
                    }
                }
            switch result {
            case let .success(data):
                switch data {
                case let data as GeneralNote4GI:
                    Text(verbatim: data.weeklyBossesInfo.textDescription)
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
