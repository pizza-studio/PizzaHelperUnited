// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

// MARK: - GachaTypeGI

/// 卡池类型，API返回
@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public enum GachaTypeGI: GachaTypeProtocol {
    case beginnersWish
    case standardWish
    case characterEventWish1
    case weaponEventWish
    case characterEventWish2
    case chronicledWish
    case unknown(rawValue: String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        self = switch rawValue {
        case "100": .beginnersWish
        case "200": .standardWish
        case "301": .characterEventWish1
        case "302": .weaponEventWish
        case "400": .characterEventWish2
        case "500": .chronicledWish
        default: .unknown(rawValue: rawValue)
        }
    }

    // MARK: Public

    public typealias ItemType = UIGFv4.GachaItemGI

    public static let knownCases: [Self] = [
        .characterEventWish1,
        .characterEventWish2,
        .chronicledWish,
        .weaponEventWish,
        .standardWish,
        .beginnersWish,
    ]

    public var rawValue: String {
        switch self {
        case .beginnersWish: "100"
        case .standardWish: "200"
        case .characterEventWish1: "301"
        case .weaponEventWish: "302"
        case .characterEventWish2: "400"
        case .chronicledWish: "500"
        case let .unknown(rawValue): rawValue
        }
    }

    public var uigfGachaType: UIGFGachaType {
        switch self {
        case .beginnersWish: .beginnersWish
        case .standardWish: .standardWish
        case .characterEventWish1, .characterEventWish2: .characterEventWish
        case .weaponEventWish: .weaponEventWish
        case .chronicledWish: .chronicledWish
        case let .unknown(rawValue): .unknown(rawValue: rawValue)
        }
    }

    public var expressible: GachaPoolExpressible {
        uigfGachaType.expressible
    }
}

// MARK: GachaTypeGI.UIGFGachaType

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension GachaTypeGI {
    /// UIGF 卡池类型，用于区分卡池类型不同，但卡池保底计算相同的物品
    @available(iOS 17.0, *)
    @available(macCatalyst 17.0, *)
    @available(macOS 14.0, *)
    public enum UIGFGachaType: RawRepresentable, AbleToCodeSendHash {
        case beginnersWish
        case standardWish
        case characterEventWish
        case weaponEventWish
        case chronicledWish
        case unknown(rawValue: String)

        // MARK: Lifecycle

        public init(rawValue: String) {
            self = switch rawValue {
            case "100": .beginnersWish
            case "200": .standardWish
            case "301", "400": .characterEventWish
            case "302": .weaponEventWish
            case "500": .chronicledWish
            default: .unknown(rawValue: rawValue)
            }
        }

        // MARK: Public

        public var rawValue: String {
            switch self {
            case .beginnersWish: "100"
            case .standardWish: "200"
            case .characterEventWish: "301"
            case .weaponEventWish: "302"
            case .chronicledWish: "500"
            case let .unknown(rawValue): rawValue
            }
        }

        public var expressible: GachaPoolExpressible {
            switch self {
            case .beginnersWish: .giBeginnersWish
            case .standardWish: .giStandardWish
            case .characterEventWish: .giCharacterEventWish
            case .weaponEventWish: .giWeaponEventWish
            case .chronicledWish: .giChronicledWish
            case .unknown: .giUnknown
            }
        }
    }
}
