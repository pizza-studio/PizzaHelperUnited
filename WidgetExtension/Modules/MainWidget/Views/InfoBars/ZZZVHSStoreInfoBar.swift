// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ZZZVHSStoreInfoBar

@available(watchOS, unavailable)
struct ZZZVHSStoreInfoBar: View {
    // MARK: Lifecycle

    public init(data: Note4ZZZ) {
        self.state = data.vhsStoreState
    }

    // MARK: Internal

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Pizza.SupportedGame.zenlessZone.zzzVHSStoreAssetIcon
                .resizable()
                .scaledToFit()
                .frame(width: 25)
                .shadow(color: .white, radius: 1)
                .legibilityShadow(isText: false)
            ringImage
                .frame(maxWidth: 13, maxHeight: 13)
                .foregroundColor(Color("textColor3", bundle: .main))
                .legibilityShadow()
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Group {
                    Text(statusText)
                }
                .foregroundColor(Color("textColor3", bundle: .main))
                .lineLimit(1)
                .font(.system(.caption, design: .rounded))
                .minimumScaleFactor(0.2)
            }
            .legibilityShadow(isText: false)
        }
    }

    // MARK: Private

    private let state: Note4ZZZ.VHSState

    private var statusText: String {
        let key: String.LocalizationValue = switch state.isInOperation {
        case true: "pzWidgetsKit.infoBlock.zzzVHSStoreInOperationState.on"
        case false: "pzWidgetsKit.infoBlock.zzzVHSStoreInOperationState.off"
        }
        return String(localized: key, bundle: .main)
    }

    @ViewBuilder private var ringImage: some View {
        Image(systemSymbol: .recordingtape)
            .overlayImageWithRingProgressBar(1.0)
    }
}
