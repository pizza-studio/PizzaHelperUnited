// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

/// 卡池类型，API返回
public enum GachaTypeHSR: RawRepresentable, Codable, Hashable, Sendable {
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

    public var rawValue: String {
        switch self {
        case .stellarWarp: "1"
        case .characterEventWarp: "11"
        case .lightConeEventWarp: "12"
        case .departureWarp: "2"
        case let .unknown(rawValue): rawValue
        }
    }
}
