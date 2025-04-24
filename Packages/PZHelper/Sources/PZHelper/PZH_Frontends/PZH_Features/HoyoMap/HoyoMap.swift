// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import SwiftUI

// MARK: - HoYoMapMenuLinkSection

struct HoYoMapMenuLinkSection: View {
    // MARK: Public

    public static let navTitle = "tools.hoyoMap.navTitle".i18nPZHelper

    // MARK: Internal

    var body: some View {
        Section {
            Menu {
                drawRegionLine(.miyoushe(.genshinImpact))
                drawRegionLine(.miyoushe(.starRail))
                Divider()
                drawRegionLine(.hoyoLab(.genshinImpact))
                drawRegionLine(.hoyoLab(.starRail))
            } label: {
                Text(verbatim: Self.navTitle)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } footer: {
            Text("tools.hoyoMap.sectionDescription", bundle: .module)
        }
    }

    @ViewBuilder
    func drawRegionLine(_ region: HoYo.AccountRegion) -> some View {
        if let described = describeRegion(region), let url = region.hoyoMapURL {
            Link(described, destination: url)
        }
    }

    // MARK: Private

    private func describeRegion(_ region: HoYo.AccountRegion) -> String? {
        "\(region.localizedDescription) - \(region.game.localizedDescription)"
    }
}

extension HoYo.AccountRegion {
    fileprivate var hoyoMapURL: URL? {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact):
            "https://act.hoyolab.com/ys/app/interactive-map/index.html".asURL
        case (.miyoushe, .genshinImpact):
            "https://webstatic.mihoyo.com/ys/app/interactive-map/index.html".asURL
        case (.hoyoLab, .starRail):
            "https://act.hoyolab.com/sr/app/interactive-map/index.html".asURL
        case (.miyoushe, .starRail):
            "https://webstatic.mihoyo.com/sr/app/interactive-map/index.html".asURL
        case (.hoyoLab, .zenlessZone):
            "https://act.hoyolab.com/zzz/app/interactive-map/index.html".asURL // 乱填的。
        case (.miyoushe, .zenlessZone):
            "https://webstatic.mihoyo.com/zzz/app/interactive-map/index.html".asURL // 乱填的。
        }
    }
}
