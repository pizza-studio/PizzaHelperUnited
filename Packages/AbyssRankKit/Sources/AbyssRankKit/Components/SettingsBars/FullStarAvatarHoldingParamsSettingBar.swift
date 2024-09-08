// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftUI

// MARK: - FullStarAvatarHoldingParamsSettingBar

struct FullStarAvatarHoldingParamsSettingBar: View {
    @Binding var params: FullStarAPIParameters

    @MainActor var body: some View {
        Picker(params.serverChoice.describe(), selection: $params.serverChoice.animation()) {
            Text("abyssRankKit.rank.server.filter.all", bundle: .module).tag(ServerChoice.all)
            ForEach(HoYo.Server.allCases4GI, id: \.id) { server in
                Text(server.localizedDescriptionByGame).tag(ServerChoice.server(server))
            }
        }.pickerStyle(.menu).fixedSize()
        Picker(params.season.describe(), selection: $params.season.animation()) {
            ForEach(AbyssSeason.choices(), id: \.hashValue) { season in
                Text(season.describe()).tag(season)
            }
        }.pickerStyle(.menu).fixedSize()
    }
}

// MARK: - FullStarAPIParameters

struct FullStarAPIParameters {
    var season: AbyssSeason = .now()
    var serverChoice: ServerChoice = .all

    var server: HoYo.Server? {
        switch serverChoice {
        case .all:
            return nil
        case let .server(server):
            return server
        }
    }

    func describe() -> String {
        ""
    }

    func detail() -> String {
        "\(serverChoice.describe())·\(season.describe())"
    }
}
