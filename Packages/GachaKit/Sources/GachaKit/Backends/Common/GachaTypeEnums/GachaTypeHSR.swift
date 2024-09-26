// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

/// 卡池类型，API返回
public enum GachaTypeHSR: GachaTypeProtocol {
    case stellarWarp
    case characterEventWarp
    case lightConeEventWarp
    case departureWarp
    case unknown(rawValue: String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        self = switch rawValue {
        case "1": .stellarWarp
        case "11": .characterEventWarp
        case "12": .lightConeEventWarp
        case "2": .departureWarp
        default: .unknown(rawValue: rawValue)
        }
    }

    // MARK: Public

    public typealias ItemType = UIGFv4.GachaItemHSR

    public static let knownCases: [Self] = [
        .characterEventWarp,
        .lightConeEventWarp,
        .stellarWarp,
        .departureWarp,
    ]

    public var rawValue: String {
        switch self {
        case .stellarWarp: "1"
        case .characterEventWarp: "11"
        case .lightConeEventWarp: "12"
        case .departureWarp: "2"
        case let .unknown(rawValue): rawValue
        }
    }

    public var expressible: GachaPoolExpressible {
        switch self {
        case .stellarWarp: .srStellarWarp
        case .characterEventWarp: .srCharacterEventWarp
        case .lightConeEventWarp: .srLightConeEventWarp
        case .departureWarp: .srDepartureWarp
        case .unknown: .srUnknown
        }
    }
}
