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
    case collabWarpFateUBWCharacter
    case collabWarpFateUBWLightCone
    case departureWarp
    case unknown(rawValue: String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        self = switch rawValue {
        case "1": .stellarWarp
        case "11": .characterEventWarp
        case "12": .lightConeEventWarp
        case "2": .departureWarp
        case "21": .collabWarpFateUBWCharacter
        case "22": .collabWarpFateUBWLightCone
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
            .collabWarpFateUBWCharacter,
            .collabWarpFateUBWLightCone,
        ].compactMap(\.self)
    }

    public var rawValue: String {
        switch self {
        case .stellarWarp: "1"
        case .characterEventWarp: "11"
        case .lightConeEventWarp: "12"
        case .departureWarp: "2"
        case .collabWarpFateUBWCharacter: "21"
        case .collabWarpFateUBWLightCone: "22"
        case let .unknown(rawValue): rawValue
        }
    }

    public var expressible: GachaPoolExpressible {
        switch self {
        case .stellarWarp: .srStellarWarp
        case .characterEventWarp: .srCharacterEventWarp
        case .lightConeEventWarp: .srLightConeEventWarp
        case .departureWarp: .srDepartureWarp
        case .collabWarpFateUBWCharacter: .srCollabWarpFateUBWCharacter
        case .collabWarpFateUBWLightCone: .srCollabWarpFateUBWLightCone
        case .unknown: .srUnknown
        }
    }

    public var isCollab: Bool {
        switch self {
        case .collabWarpFateUBWCharacter: true
        case .collabWarpFateUBWLightCone: true
        default: false
        }
    }
}
