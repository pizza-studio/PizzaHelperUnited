// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct DataVisibilityGuideView: View {
    public let region: HoYo.AccountRegion

    public var body: some View {
        VStack(alignment: .leading) {
            Text("profile.accountConnectivity.insufficientDataVisibility".i18nPZHelper)
                .font(.footnote)
            switch region {
            case .hoyoLab:
                Image("DataVisibilityGuide_HoYoLAB", bundle: .module).resizable().aspectRatio(contentMode: .fit)
            case .miyoushe:
                Image("DataVisibilityGuide_Miyoushe", bundle: .module).resizable().aspectRatio(contentMode: .fit)
            }
        }
    }
}
