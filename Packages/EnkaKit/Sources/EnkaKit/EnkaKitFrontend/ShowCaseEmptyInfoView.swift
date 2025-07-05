// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct ShowCaseEmptyInfoView: View {
    public let game: Enka.GameType

    public var body: some View {
        VStack(alignment: .leading) {
            Text("enka.showCase.emptyShowCase.description".i18nEnka)
                .font(.footnote)
            switch game {
            case .genshinImpact:
                Image("showCaseToggle-GI", bundle: .module).resizable().aspectRatio(contentMode: .fit)
            case .starRail:
                Image("showCaseToggle-HSR", bundle: .module).resizable().aspectRatio(contentMode: .fit)
            case .zenlessZone:
                EmptyView() // 临时设定。
            }
        }
    }
}
