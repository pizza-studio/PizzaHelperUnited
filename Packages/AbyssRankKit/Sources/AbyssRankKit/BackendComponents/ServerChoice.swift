// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit

// MARK: - ServerChoice

enum ServerChoice: Hashable {
    case all
    case server(HoYo.Server)

    // MARK: Internal

    func describe() -> String {
        switch self {
        case .all:
            return "abyssRankKit.rank.server.filter.all".i18nAbyssRank
        case let .server(server):
            return server.localizedDescriptionByGame
        }
    }
}
