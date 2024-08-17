// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - HoYo.AccountRegion

extension HoYo {
    public enum AccountRegion {
        case hoyoLab(Pizza.SupportedGame)
        case miyoushe(Pizza.SupportedGame)

        // MARK: Lifecycle

        public init?(uid: String?, game: Pizza.SupportedGame?) {
            guard let server = HoYo.Server(uid: uid, game: game) else { return nil }
            self = server.region
        }

        // MARK: Public

        public var game: Pizza.SupportedGame {
            switch self {
            case let .hoyoLab(supportedGame): supportedGame
            case let .miyoushe(supportedGame): supportedGame
            }
        }
    }
}

// MARK: - HoYo.AccountRegion + CaseIterable

extension HoYo.AccountRegion: CaseIterable {
    public static let allCases: [Self] = allCases4GI + allCases4HSR

    public static let allCases4GI: [Self] = [
        .hoyoLab(.genshinImpact), .miyoushe(.genshinImpact),
    ]

    public static let allCases4HSR: [Self] = [
        .hoyoLab(.starRail), .miyoushe(.starRail),
    ]
}

// MARK: - HoYo.AccountRegion + RawRepresentable, Codable, Identifiable, Hashable

extension HoYo.AccountRegion: RawRepresentable, Codable, Identifiable, Hashable {
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "hkrpg_global": self = .hoyoLab(.starRail)
        case "hkrpg_cn": self = .miyoushe(.starRail)
        case "hk4e_global": self = .hoyoLab(.genshinImpact)
        case "hk4e_cn": self = .miyoushe(.genshinImpact)
        default: return nil
        }
    }

    public var id: String { rawValue }

    public var rawValue: String {
        switch self {
        case let .hoyoLab(supportedGame):
            switch supportedGame {
            case .genshinImpact: "hk4e_global"
            case .starRail: "hkrpg_global"
            }
        case let .miyoushe(supportedGame):
            switch supportedGame {
            case .genshinImpact: "hk4e_cn"
            case .starRail: "hkrpg_cn"
            }
        }
    }

    public typealias RawValue = String
}

// MARK: - HoYo.AccountRegion + CustomStringConvertible

extension HoYo.AccountRegion: CustomStringConvertible {
    public var description: String {
        localizedDescription
    }

    public var localizedDescription: String {
        localizedStringKey.i18nAK
    }

    public var literalNameRawValue: String {
        switch self {
        case .miyoushe: "miyoushe"
        case .hoyoLab: "hoyoLab"
        }
    }

    private var localizedStringKey: String {
        "accountRegion.name.\(literalNameRawValue)"
    }
}
