// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - GachaTypeGI

/// 卡池类型，API返回
public enum GachaTypeGI: RawRepresentable, Codable, Hashable, Sendable {
    case beginnersWish
    case standardWish
    case characterEvent1
    case weaponEvent
    case characterEvent2
    case chronicledWish
    case unknown(rawValue: String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        self = switch rawValue {
        case "100": .beginnersWish
        case "200": .standardWish
        case "301": .characterEvent1
        case "302": .weaponEvent
        case "400": .characterEvent2
        case "500": .chronicledWish
        default: .unknown(rawValue: rawValue)
        }
    }

    // MARK: Public

    public var rawValue: String {
        switch self {
        case .beginnersWish: "100"
        case .standardWish: "200"
        case .characterEvent1: "301"
        case .weaponEvent: "302"
        case .characterEvent2: "400"
        case .chronicledWish: "500"
        case let .unknown(rawValue): rawValue
        }
    }

    public var uigfGachaType: UIGFGachaType {
        switch self {
        case .beginnersWish: .beginnersWish
        case .standardWish: .standardWish
        case .characterEvent1, .characterEvent2: .characterEvent
        case .weaponEvent: .weaponEvent
        case .chronicledWish: .chronicledWish
        case let .unknown(rawValue): .unknown(rawValue: rawValue)
        }
    }
}

// MARK: GachaTypeGI.UIGFGachaType

extension GachaTypeGI {
    /// UIGF 卡池类型，用于区分卡池类型不同，但卡池保底计算相同的物品
    public enum UIGFGachaType: RawRepresentable, Codable, Hashable, Sendable {
        case beginnersWish
        case standardWish
        case characterEvent
        case weaponEvent
        case chronicledWish
        case unknown(rawValue: String)

        // MARK: Lifecycle

        public init(rawValue: String) {
            self = switch rawValue {
            case "100": .beginnersWish
            case "200": .standardWish
            case "301", "400": .characterEvent
            case "302": .weaponEvent
            case "500": .chronicledWish
            default: .unknown(rawValue: rawValue)
            }
        }

        // MARK: Public

        public var rawValue: String {
            switch self {
            case .beginnersWish: "100"
            case .standardWish: "200"
            case .characterEvent: "301"
            case .weaponEvent: "302"
            case .chronicledWish: "500"
            case let .unknown(rawValue): rawValue
            }
        }
    }
}
