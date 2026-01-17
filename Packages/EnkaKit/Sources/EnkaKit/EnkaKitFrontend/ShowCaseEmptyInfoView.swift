// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
public struct ShowCaseEmptyInfoView: View {
    public let game: Enka.GameType

    public var body: some View {
        VStack(alignment: .leading) {
            Text("enka.showCase.emptyShowCase.description".i18nEnka)
                .font(.footnote)
            switch game {
            case .genshinImpact:
                Image("showCaseToggle-GI", bundle: .currentSPM).resizable().aspectRatio(contentMode: .fit)
            case .starRail:
                Image("showCaseToggle-HSR", bundle: .currentSPM).resizable().aspectRatio(contentMode: .fit)
            case .zenlessZone:
                EmptyView() // 临时设定。
            }
        }
    }
}
