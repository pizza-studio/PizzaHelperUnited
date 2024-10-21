// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI

struct LockScreenLoopWidgetTransformerCircular: View {
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: FetchResult

    var body: some View {
        switch widgetRenderingMode {
        case .accented:
            VStack(spacing: 0) {
                Image("icon.transformer")
                    .resizable()
                    .scaledToFit()
                switch result {
                case let .success(data):
                    Text(
                        "\(data.transformerInfo.recoveryTime.describeIntervalShort(finishedTextPlaceholder: "infoBlock.transformerAvailable"))"
                    )
                    .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
            .widgetAccentable()
        case .fullColor:
            VStack(spacing: 0) {
                Image("icon.transformer")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("iconColor.transformer"))
                switch result {
                case let .success(data):
                    Text(
                        "\(data.transformerInfo.recoveryTime.describeIntervalShort(finishedTextPlaceholder: "infoBlock.transformerAvailable"))"
                    )
                    .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
        default:
            VStack(spacing: 0) {
                Image("icon.transformer")
                    .resizable()
                    .scaledToFit()
                switch result {
                case let .success(data):
                    Text(
                        "\(data.transformerInfo.recoveryTime.describeIntervalShort(finishedTextPlaceholder: "infoBlock.transformerAvailable"))"
                    )
                    .font(.system(.body, design: .rounded).weight(.medium))
                case .failure:
                    Image(systemSymbol: .ellipsis)
                }
            }
            #if os(watchOS)
            .padding(.vertical, 2)
            .padding(.top, 1)
            #else
            .padding(.vertical, 2)
            #endif
        }
    }
}
