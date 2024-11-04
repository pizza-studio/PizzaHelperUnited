// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

struct ListOf3rdPartyComponentsView: View {
    static let navTitle: String = {
        let key: String.LocalizationValue = "aboutKit.3rdParty.navTitle"
        return .init(localized: key, bundle: .module)
    }()

    var body: some View {
        VStack(alignment: .leading) {
            Text("aboutKit.3rdParty.headline", bundle: .module)
                .font(.footnote)
            Divider()
            VStack(alignment: .leading, spacing: 12) {
                Text(verbatim: """
                SWORM - Prisma AI
                https://github.com/prisma-ai/Sworm
                """).textSelection(.enabled)
                Text(verbatim: """
                CoreXLSX - CoreOffice
                https://github.com/CoreOffice/CoreXLSX
                """).textSelection(.enabled)
                Text(verbatim: """
                Multipicker - James Pamplona
                https://github.com/toastersocks/MultiPicker
                """).textSelection(.enabled)
                Text(verbatim: """
                AlertToast - elai950
                https://github.com/elai950/AlertToast
                """).textSelection(.enabled)
                Text(verbatim: """
                Swift Pie Chart - Nazar Ilamanov
                https://github.com/ilamanov/SwiftPieChart
                """).textSelection(.enabled)
                Text(verbatim: """
                SFSafeSymbols
                https://github.com/SFSafeSymbols/SFSafeSymbols
                """).textSelection(.enabled)
                Text(verbatim: """
                Defaults - Sindre Sorhus
                https://github.com/sindresorhus/Defaults
                """).textSelection(.enabled)
                Text(verbatim: """
                Enka ShowCase API - Enka Network
                https://enka.network/?hsr
                """).textSelection(.enabled)
                Text(verbatim: """
                MiHoMo Origin API Mirror for Star Rail - MiHoMo
                https://github.com/Mar-7th/March7th-Docs
                """).textSelection(.enabled)
                Text(verbatim: """
                MicroGG ShowCase API for Genshin Impact - MicroGG
                https://microgg.cn
                """).textSelection(.enabled)
                Text(verbatim: """
                StarRailScore - Mobyw @ Mar-7th
                https://github.com/Mar-7th/StarRailScore
                """).textSelection(.enabled)
                Text(verbatim: """
                Genshin Artifact Rating System (database model only) - Alice Workshop
                https://github.com/Kamihimmel/artifactrating
                """).textSelection(.enabled)
            }
            .font(.caption)
            .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            Group {
                Text(verbatim: "Game Account Data API - 米游社 (CN) / HoYoLAB (OS)")
            }
            .font(.caption)
            Spacer()
        }
        .padding()
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.large)
    }
}
