// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftUI

// MARK: - UtilizationParasSettingBar

struct UtilizationParasSettingBar: View {
    var pvp: Bool = false
    @Binding var params: UtilizationAPIParameters

    var body: some View {
        Picker(params.serverChoice.describe(), selection: $params.serverChoice.animation()) {
            Text("abyssRankKit.rank.server.filter.all", bundle: .module).tag(ServerChoice.all)
            ForEach(HoYo.Server.allCases4GI, id: \.id) { server in
                Text(server.localizedDescriptionByGame).tag(ServerChoice.server(server))
            }
        }.pickerStyle(.menu)
        Spacer()
        Picker(selection: $params.floor.animation()) {
            ForEach((9 ... 12).reversed(), id: \.self) { number in
                Text("abyssRankKit.rank.floor.title:\(number)", bundle: .module).tag(number)
            }
        } label: {
            Text("abyssRankKit.rank.floor.title:\(params.floor)")
        }.pickerStyle(.menu)
        Spacer()
        Picker(params.season.describe(), selection: $params.season.animation()) {
            ForEach(AbyssSeason.choices(pvp: pvp), id: \.hashValue) { season in
                Text(season.describe()).tag(season)
            }
        }.pickerStyle(.menu)
    }
}

// MARK: - UtilizationAPIParameters

struct UtilizationAPIParameters {
    var season: AbyssSeason = .from(Date())
    var serverChoice: ServerChoice = .all

    var floor: Int = 12

    var server: HoYo.Server? {
        switch serverChoice {
        case .all:
            return nil
        case let .server(server):
            return server
        }
    }

    func describe() -> String {
        "abyssRankKit.rank.note.1".i18nAbyssRank
    }

    func detail() -> String {
        String(
            format: NSLocalizedString("abyssRankKit.collection.1:%@%@%lld", comment: "detail"),
            serverChoice.describe(),
            season.describe(),
            floor
        )
    }
}
