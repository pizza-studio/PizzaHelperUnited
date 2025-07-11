// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - GachaTypeHSR

/// 卡池类型，API返回
@available(iOS 17.0, macCatalyst 17.0, *)
public enum GachaTypeHSR: GachaTypeProtocol {
    case stellarWarp
    case characterEventWarp
    case lightConeEventWarp
    case collabWarpFateUBW21
    case collabWarpFateUBW22
    case collabWarpFateUBW23
    case collabWarpFateUBW24
    case departureWarp
    case unknown(rawValue: String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        self = switch rawValue {
        case "1": .stellarWarp
        case "11": .characterEventWarp
        case "12": .lightConeEventWarp
        case "2": .departureWarp
        case "21": .collabWarpFateUBW21
        case "22": .collabWarpFateUBW22
        case "23": .collabWarpFateUBW23
        case "24": .collabWarpFateUBW24
        default: .unknown(rawValue: rawValue)
        }
    }

    // MARK: Public

    public typealias ItemType = UIGFv4.GachaItemHSR

    public static var knownCases: [Self] {
        [
            .characterEventWarp,
            .lightConeEventWarp,
            .stellarWarp,
            .departureWarp,
            .collabWarpFateUBW21,
            .collabWarpFateUBW22,
            .collabWarpFateUBW23,
            .collabWarpFateUBW24,
        ].compactMap(\.self)
    }

    public var rawValue: String {
        switch self {
        case .stellarWarp: "1"
        case .characterEventWarp: "11"
        case .lightConeEventWarp: "12"
        case .departureWarp: "2"
        case .collabWarpFateUBW21: "21"
        case .collabWarpFateUBW22: "22"
        case .collabWarpFateUBW23: "23"
        case .collabWarpFateUBW24: "24"
        case let .unknown(rawValue): rawValue
        }
    }

    public var expressible: GachaPoolExpressible {
        switch self {
        case .stellarWarp: .srStellarWarp
        case .characterEventWarp: .srCharacterEventWarp
        case .lightConeEventWarp: .srLightConeEventWarp
        case .departureWarp: .srDepartureWarp
        case .collabWarpFateUBW21: .srCollabWarpFateUBW21
        case .collabWarpFateUBW22: .srCollabWarpFateUBW22
        case .collabWarpFateUBW23: .srCollabWarpFateUBW23
        case .collabWarpFateUBW24: .srCollabWarpFateUBW24
        case .unknown: .srUnknown
        }
    }

    public var isCollab: Bool {
        switch self {
        case .collabWarpFateUBW21: true
        case .collabWarpFateUBW22: true
        case .collabWarpFateUBW23: true
        case .collabWarpFateUBW24: true
        default: false
        }
    }
}
