// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit

/// 卡池类型，API返回
@available(iOS 17.0, macCatalyst 17.0, *)
public enum GachaTypeZZZ: GachaTypeProtocol {
    case stableChannel
    case exclusiveChannel
    case wEngineChannel
    case bangbooChannel
    case unknown(rawValue: String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        self = switch rawValue {
        case "1": .stableChannel
        case "2": .exclusiveChannel
        case "3": .wEngineChannel
        case "5": .bangbooChannel
        default: .unknown(rawValue: rawValue)
        }
    }

    // MARK: Public

    public typealias ItemType = UIGFv4.GachaItemZZZ

    public static let knownCases: [Self] = [
        .exclusiveChannel,
        .wEngineChannel,
        .bangbooChannel,
        .stableChannel,
    ]

    public var rawValue: String {
        switch self {
        case .stableChannel: "1"
        case .exclusiveChannel: "2"
        case .wEngineChannel: "3"
        case .bangbooChannel: "5"
        case let .unknown(rawValue): rawValue
        }
    }

    public var expressible: GachaPoolExpressible {
        switch self {
        case .stableChannel: .zzStableChannel
        case .exclusiveChannel: .zzExclusiveChannel
        case .wEngineChannel: .zzWEngineChannel
        case .bangbooChannel: .zzBangbooChannel
        case .unknown: .zzUnknown
        }
    }
}
