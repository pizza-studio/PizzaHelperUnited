// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
@_exported import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

struct LockScreenLoopWidgetWeeklyBossesCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        VStack(spacing: 0) {
            Image("icon.weeklyBosses", bundle: .module)
                .resizable()
                .scaledToFit()
                .apply { imageView in
                    if widgetRenderingMode == .fullColor {
                        imageView
                            .foregroundColor(Color("iconColor.weeklyBosses", bundle: .module))
                    } else {
                        imageView
                    }
                }
            switch result {
            case let .success(data):
                switch data {
                case let data as GeneralNote4GI:
                    let numerator = data.weeklyBossesInfo.remainResinDiscount
                    let denominator = data.weeklyBossesInfo.totalResinDiscount
                    Text(verbatim: "\(numerator) / \(denominator)")
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
