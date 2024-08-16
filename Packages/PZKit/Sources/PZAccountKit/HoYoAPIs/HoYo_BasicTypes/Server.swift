// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - HoYo.Server

extension HoYo {
    /// 统一披萨助手引擎不再将 Server 作为要在本地帐号里面记入的资料。
    /// 该类型专门用来从 UID 倒推伺服器、或用于米哈游伺服器的 JSON 解码。
    public enum Server {
        case celestia(Pizza.SupportedGame)
        case irminsul(Pizza.SupportedGame)
        case unitedStates(Pizza.SupportedGame)
        case europe(Pizza.SupportedGame)
        case asia(Pizza.SupportedGame)
        case hkMacauTaiwan(Pizza.SupportedGame)

        // MARK: Lifecycle

        public init?(uid: String?, game: Pizza.SupportedGame?) {
            guard var theUID = uid, let theGame = game else { return nil }
            while theUID.count > 9 {
                theUID = theUID.dropFirst().description
            }
            guard let initial = theUID.first, let initialInt = Int(initial.description) else { return nil }
            switch initialInt {
            case 1 ... 4: self = .celestia(theGame)
            case 5: self = .irminsul(theGame)
            case 6: self = .unitedStates(theGame)
            case 7: self = .europe(theGame)
            case 8: self = .asia(theGame)
            case 9: self = .hkMacauTaiwan(theGame)
            default: return nil
            }
        }

        // MARK: Public

        public var region: HoYo.AccountRegion {
            switch self {
            case let .celestia(supportedGame): return .miyoushe(supportedGame)
            case let .irminsul(supportedGame): return .miyoushe(supportedGame)
            case let .unitedStates(supportedGame): return .hoyoLab(supportedGame)
            case let .europe(supportedGame): return .hoyoLab(supportedGame)
            case let .asia(supportedGame): return .hoyoLab(supportedGame)
            case let .hkMacauTaiwan(supportedGame): return .hoyoLab(supportedGame)
            }
        }

        public var game: Pizza.SupportedGame {
            switch self {
            case let .celestia(supportedGame): supportedGame
            case let .irminsul(supportedGame): supportedGame
            case let .unitedStates(supportedGame): supportedGame
            case let .europe(supportedGame): supportedGame
            case let .asia(supportedGame): supportedGame
            case let .hkMacauTaiwan(supportedGame): supportedGame
            }
        }
    }
}

// MARK: - HoYo.Server + CaseIterable

extension HoYo.Server: CaseIterable {
    public static let allCases: [Self] = allCases4GI + allCases4HSR

    public static var allCases4GI: [Self] = [
        .celestia(.genshinImpact),
        .irminsul(.genshinImpact),
        .unitedStates(.genshinImpact),
        .europe(.genshinImpact),
        .asia(.genshinImpact),
        .hkMacauTaiwan(.genshinImpact),
    ]

    public static var allCases4HSR: [Self] = [
        .celestia(.starRail),
        .irminsul(.starRail),
        .unitedStates(.starRail),
        .europe(.starRail),
        .asia(.starRail),
        .hkMacauTaiwan(.starRail),
    ]
}

// MARK: - HoYo.Server + RawRepresentable, Codable, Identifiable

extension HoYo.Server: RawRepresentable, Codable, Identifiable {
    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "cn_gf01": self = .celestia(.genshinImpact)
        case "cn_qd01": self = .irminsul(.genshinImpact)
        case "os_asia": self = .asia(.genshinImpact)
        case "os_euro": self = .europe(.genshinImpact)
        case "os_usa": self = .unitedStates(.genshinImpact)
        case "os_cht": self = .hkMacauTaiwan(.genshinImpact)
        case "prod_gf_cn": self = .celestia(.starRail)
        case "prod_qd_cn": self = .irminsul(.starRail)
        case "prod_official_asia": self = .asia(.starRail)
        case "prod_official_eur": self = .europe(.starRail)
        case "prod_official_usa": self = .unitedStates(.starRail)
        case "prod_official_cht": self = .hkMacauTaiwan(.starRail)
        default: return nil
        }
    }

    public var id: String { rawValue }

    public var rawValue: String {
        switch self {
        case let .celestia(supportedGame):
            switch supportedGame {
            case .genshinImpact: "cn_gf01"
            case .starRail: "prod_gf_cn"
            }
        case let .irminsul(supportedGame):
            switch supportedGame {
            case .genshinImpact: "cn_qd01"
            case .starRail: "prod_qd_cn"
            }
        case let .unitedStates(supportedGame):
            switch supportedGame {
            case .genshinImpact: "os_usa"
            case .starRail: "prod_official_usa"
            }
        case let .europe(supportedGame):
            switch supportedGame {
            case .genshinImpact: "os_euro"
            case .starRail: "prod_official_eur"
            }
        case let .asia(supportedGame):
            switch supportedGame {
            case .genshinImpact: "os_asia"
            case .starRail: "prod_official_asia"
            }
        case let .hkMacauTaiwan(supportedGame):
            switch supportedGame {
            case .genshinImpact: "os_cht"
            case .starRail: "prod_official_cht"
            }
        }
    }

    public typealias RawValue = String
}

// MARK: - HoYo.Server + CustomStringConvertible

extension HoYo.Server: CustomStringConvertible {
    public var description: String {
        localizedDescription
    }

    public var localizedDescription: String {
        localizedStringKey.i18nAK
    }

    public var localizedDescriptionByGame: String {
        localizedStringKeyByGame.i18nAK
    }

    public var literalNameRawValue: String {
        switch self {
        case .celestia: "celestia"
        case .irminsul: "irminsul"
        case .unitedStates: "unitedStates"
        case .europe: "europe"
        case .asia: "asia"
        case .hkMacauTaiwan: "hkMacauTaiwan"
        }
    }

    private var localizedStringKey: String {
        "server.location.\(literalNameRawValue)" // + ".\(game.rawValue)"
    }

    private var localizedStringKeyByGame: String {
        switch region {
        case .hoyoLab:
            "server.location.\(literalNameRawValue)"
        case .miyoushe:
            "server.location.\(literalNameRawValue).\(game.rawValue)"
        }
    }
}
