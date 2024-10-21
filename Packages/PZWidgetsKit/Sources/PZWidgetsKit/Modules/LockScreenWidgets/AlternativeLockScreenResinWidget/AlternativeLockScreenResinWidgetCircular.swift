// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

struct AlternativeLockScreenResinWidgetCircular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any Note4GI, any Error>

    var body: some View {
        switch widgetRenderingMode {
        case .accented:
            VStack(spacing: 0) {
                Image("icon.resin")
                    .resizable()
                    .scaledToFit()
                switch result {
                case let .success(data):
                    Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .minimumScaleFactor(0.1)
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
                LinearGradient(
                    colors: [
                        .init("iconColor.resin.dark"),
                        .init("iconColor.resin.middle"),
                        .init("iconColor.resin.light"),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .mask(
                    Image("icon.resin")
                        .resizable()
                        .scaledToFit()
                )
                switch result {
                case let .success(data):
                    Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .minimumScaleFactor(0.1)
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
                Image("icon.resin")
                    .resizable()
                    .scaledToFit()
                switch result {
                case let .success(data):
                    Text("\(data.resinInfo.calculatedCurrentResin(referTo: entry.date))")
                        .font(.system(.body, design: .rounded).weight(.medium))
                        .minimumScaleFactor(0.1)
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
