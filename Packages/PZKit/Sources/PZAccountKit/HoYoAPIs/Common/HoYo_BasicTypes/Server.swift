// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - HoYo.Server

extension HoYo {
    /// 统一披萨助手引擎不再将 Server 作为要在本地账号里面记入的资料。
    /// 该类型专门用来从 UID 倒推伺服器、或用于米哈游伺服器的 JSON 解码。
    public enum Server: Sendable, Equatable {
        case celestia(Pizza.SupportedGame)
        case irminsul(Pizza.SupportedGame)
        case unitedStates(Pizza.SupportedGame)
        case europe(Pizza.SupportedGame)
        case asia(Pizza.SupportedGame)
        case hkMacauTaiwan(Pizza.SupportedGame)

        // MARK: Lifecycle

        public init?(uid: String?, game: Pizza.SupportedGame?) {
            guard var theUID = uid, let theGame = game else { return nil }
            guard let initial = theUID.first, let initialInt = Int(initial.description) else { return nil }
            switch theGame {
            case .genshinImpact, .starRail:
                while theUID.count > 9 {
                    theUID = theUID.dropFirst().description
                }
                switch initialInt {
                case 1 ... 4: self = .celestia(theGame)
                case 5: self = .irminsul(theGame)
                case 6: self = .unitedStates(theGame)
                case 7: self = .europe(theGame)
                case 8: self = .asia(theGame)
                case 9: self = .hkMacauTaiwan(theGame)
                default: return nil
                }
            case .zenlessZone:
                guard theUID.count >= 10 else {
                    self = .celestia(.zenlessZone)
                    return
                }
                guard let initial = Int(theUID.prefix(2).suffix(1)),
                      let initialInt = Int(initial.description) else { return nil }
                switch initialInt {
                case 0 ... 2: self = .unitedStates(theGame)
                case 3 ... 4: self = .asia(theGame)
                case 5 ... 6: self = .europe(theGame)
                case 7...: self = .hkMacauTaiwan(theGame)
                default: return nil
                }
            }
        }

        // MARK: Public

        public var timeZoneDelta: Int {
            switch self {
            case .celestia: 8
            case .irminsul: 8
            case .unitedStates: -5
            case .europe: 1
            case .asia: 8
            case .hkMacauTaiwan: 8
            }
        }

        public var timeZone: TimeZone {
            .init(secondsFromGMT: timeZoneDelta * 3600) ?? .current
        }

        public var region: HoYo.AccountRegion {
            switch self {
            case let .celestia(supportedGame): .miyoushe(supportedGame)
            case let .irminsul(supportedGame): .miyoushe(supportedGame)
            case let .unitedStates(supportedGame): .hoyoLab(supportedGame)
            case let .europe(supportedGame): .hoyoLab(supportedGame)
            case let .asia(supportedGame): .hoyoLab(supportedGame)
            case let .hkMacauTaiwan(supportedGame): .hoyoLab(supportedGame)
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

        public func withGame(_ game: Pizza.SupportedGame) -> Self {
            var result = self
            result.changeGame(to: game)
            return result
        }

        public mutating func changeGame(to game: Pizza.SupportedGame) {
            self = switch self {
            case .celestia: .celestia(game)
            case .irminsul: game != .zenlessZone ? .irminsul(game) : .celestia(.zenlessZone)
            case .unitedStates: .unitedStates(game)
            case .europe: .europe(game)
            case .asia: .asia(game)
            case .hkMacauTaiwan: .hkMacauTaiwan(game)
            }
        }
    }
}

// MARK: - HoYo.Server + CaseIterable

extension HoYo.Server: CaseIterable {
    public static let allCases: [Self] = allCases4GI + allCases4HSR

    public static let allCases4GI: [Self] = [
        .celestia(.genshinImpact),
        .irminsul(.genshinImpact),
        .unitedStates(.genshinImpact),
        .europe(.genshinImpact),
        .asia(.genshinImpact),
        .hkMacauTaiwan(.genshinImpact),
    ]

    public static let allCases4HSR: [Self] = [
        .celestia(.starRail),
        .irminsul(.starRail),
        .unitedStates(.starRail),
        .europe(.starRail),
        .asia(.starRail),
        .hkMacauTaiwan(.starRail),
    ]

    public static let allCases4ZZZ: [Self] = [
        .celestia(.zenlessZone),
        .unitedStates(.zenlessZone),
        .europe(.zenlessZone),
        .asia(.zenlessZone),
        .hkMacauTaiwan(.zenlessZone),
    ]
}

// MARK: - HoYo.Server + RawRepresentable, Codable, Identifiable, Hashable

extension HoYo.Server: RawRepresentable, Codable, Identifiable, Hashable {
    /// 注意：该建构子无法区分绝区零的国服与星穹铁道的天空岛（星穹列车）伺服器。
    /// 初期化之后必须使用 .withGame() -> Self 来补充修正游戏类型。
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
        // case "prod_gf_cn": self = .celestia(.zenlessZone)
        case "prod_gf_jp": self = .asia(.zenlessZone)
        case "prod_gf_eu": self = .europe(.zenlessZone)
        case "prod_gf_us": self = .unitedStates(.zenlessZone)
        case "prod_gf_sg": self = .hkMacauTaiwan(.zenlessZone) // 绝区零新加坡服当作港澳台服处理。
        default: return nil
        }
    }

    public var id: String { "\(game.rawValue)-\(rawValue)" }

    public var rawValue: String {
        switch (self, game) {
        case (.celestia, .genshinImpact): "cn_gf01"
        case (.irminsul, .genshinImpact): "cn_qd01"
        case (.unitedStates, .genshinImpact): "os_usa"
        case (.europe, .genshinImpact): "os_euro"
        case (.asia, .genshinImpact): "os_asia"
        case (.hkMacauTaiwan, .genshinImpact): "os_cht"
        case (.celestia, .starRail): "prod_gf_cn"
        case (.irminsul, .starRail): "prod_qd_cn"
        case (.unitedStates, .starRail): "prod_official_usa"
        case (.europe, .starRail): "prod_official_eur"
        case (.asia, .starRail): "prod_official_asia"
        case (.hkMacauTaiwan, .starRail): "prod_official_cht"
        case (.celestia, .zenlessZone): "prod_gf_cn"
        case (.irminsul, .zenlessZone): "prod_gf_cn"
        case (.unitedStates, .zenlessZone): "prod_gf_us"
        case (.europe, .zenlessZone): "prod_gf_eu"
        case (.asia, .zenlessZone): "prod_gf_jp"
        case (.hkMacauTaiwan, .zenlessZone): "prod_gf_sg" // 绝区零新加坡服当作港澳台服处理。
        }
    }

    public typealias RawValue = String
}

// MARK: - HoYo.Server + CustomStringConvertible

@available(iOS 15.0, macCatalyst 15.0, *)
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

    public var localizedDescriptionByGameAndRegion: String {
        "\(localizedDescriptionByGame) (\(region.localizedDescription))"
    }
}

extension HoYo.Server {
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
