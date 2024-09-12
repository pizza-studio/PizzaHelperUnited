// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

/// 卡池类型，API返回
public enum GachaTypeZZZ: RawRepresentable, Codable, Hashable, Sendable {
    case standardBanner
    case limitedBanner
    case wEngineBanner
    case bangbooBanner
    case unknown(rawValue: String)

    // MARK: Lifecycle

    public init(rawValue: String) {
        self = switch rawValue {
        case "1": .standardBanner
        case "2": .limitedBanner
        case "3": .wEngineBanner
        case "5": .bangbooBanner
        default: .unknown(rawValue: rawValue)
        }
    }

    // MARK: Public

    public var rawValue: String {
        switch self {
        case .standardBanner: "1"
        case .limitedBanner: "2"
        case .wEngineBanner: "3"
        case .bangbooBanner: "5"
        case let .unknown(rawValue): rawValue
        }
    }
}
