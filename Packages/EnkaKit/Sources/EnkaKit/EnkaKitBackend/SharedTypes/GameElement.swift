// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Foundation
import PZBaseKit

// MARK: - Enka.GameElement

extension Enka {
    /// 元素（星穹铁道与原神共用）。
    public enum GameElement: String, CaseIterable, AbleToCodeSendHash {
        case physico
        case anemo
        case geo
        case electro
        case dendro
        case hydro
        case pyro
        case cryo
        case quanto // Quantum，量子
        case imago // Imaginary，虚数
    }
}

extension Enka.GameElement {
    public init?(rawValue: String) {
        switch rawValue {
        case "Physical", "Physico", "Unknown": self = .physico
        case "Wind": self = .anemo
        case "Rock": self = .geo
        case "Electric", "Lightning", "Thunder": self = .electro
        case "Grass": self = .dendro
        case "Water": self = .hydro
        case "Fire": self = .pyro
        case "Ice": self = .cryo
        case "Imaginary", "Imago": self = .imago
        case "Quantum", "Quanto": self = .quanto
        case "Anemo": self = .anemo
        case "Cryo": self = .cryo
        case "Dendro": self = .dendro
        case "Electro": self = .electro
        case "Geo": self = .geo
        case "Hydro": self = .hydro
        case "Pyro": self = .pyro
        default: return nil
        }
    }

    public init(rawValueGuarded: String) {
        self = Self(rawValue: rawValueGuarded) ?? .physico
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let debugDescription = "Wrong type Decodable for Enka.GameElement"
        let error = DecodingError.typeMismatch(
            Self.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: debugDescription
            )
        )
        guard let rawStr = try? container.decode(String.self) else {
            throw error
        }
        let rawMatched = Self.allCases.first(where: { $0.rawValue == rawStr })
        guard let matched = rawMatched ?? Self(rawValue: rawStr) else {
            throw error
        }
        self = matched
    }

    public var rawValueForHSR: String {
        switch self {
        case .physico: "Physical"
        case .anemo: "Wind"
        case .electro: "Thunder"
        case .imago: "Imaginary"
        case .quanto: "Quantum"
        case .pyro: "Fire"
        case .cryo: "Ice"
        case .geo: "Rock" // GI
        case .dendro: "Grass" // GI
        case .hydro: "Water" // GI
        }
    }

    public var rawValueForGI: String {
        switch self {
        case .physico: "Unknown"
        case .anemo: "Wind"
        case .electro: "Electric"
        case .imago: "Imaginary"
        case .quanto: "Quantum"
        case .pyro: "Fire"
        case .cryo: "Ice"
        case .geo: "Rock"
        case .dendro: "Grass"
        case .hydro: "Water"
        }
    }

    public var localizedName: String {
        let rawKey: String.LocalizationValue = switch self {
        case .physico: "game.elements.physico"
        case .anemo: "game.elements.anemo"
        case .geo: "game.elements.geo"
        case .electro: "game.elements.electro"
        case .dendro: "game.elements.dendro"
        case .hydro: "game.elements.hydro"
        case .pyro: "game.elements.pyro"
        case .cryo: "game.elements.cryo"
        case .quanto: "game.elements.quanto"
        case .imago: "game.elements.imago"
        }
        return String(localized: rawKey, bundle: .module)
    }

    public var tourID: Int {
        switch self {
        case .physico: 0
        case .anemo: 1
        case .geo: 2
        case .electro: 3
        case .dendro: 4
        case .hydro: 5
        case .pyro: 6
        case .cryo: 7
        case .quanto: 8
        case .imago: 9
        }
    }
}

extension Enka.GameElement {
    public var iconFileNameStem: String {
        "\(rawValue)"
    }

    public var iconAssetName: String {
        let suffix = switch self {
        case .physico: "Physico"
        case .anemo: "Anemo"
        case .electro: "Electro"
        case .imago: "Imago"
        case .quanto: "Quanto"
        case .pyro: "Pyro"
        case .cryo: "Cryo"
        case .geo: "Geo"
        case .dendro: "Dendro"
        case .hydro: "Hydro"
        }
        return "element_\(suffix)"
    }

    public var damageAddedRatioProperty: Enka.PropertyType {
        switch self {
        case .physico: .physicoAddedRatio
        case .anemo: .anemoAddedRatio
        case .electro: .electroAddedRatio
        case .imago: .imagoAddedRatio
        case .quanto: .quantoAddedRatio
        case .pyro: .pyroAddedRatio
        case .cryo: .cryoAddedRatio
        case .geo: .geoAddedRatio
        case .dendro: .dendroAddedRatio
        case .hydro: .hydroAddedRatio
        }
    }

    public static let elementConversionDict: [String: String] = [
        "Physical": "Physico",
        "Wind": "Anemo",
        "Lightning": "Electro",
        "Imaginary": "Imago",
        "Quantum": "Quanto",
        "Fire": "Pyro",
        "Ice": "Cryo",
        "Rock": "Geo",
        "Water": "Hydro",
        "Grass": "Dendro",
    ]
}

extension Enka.GameElement {
    public var themeColor: CGColor {
        switch self {
        case .physico: .init(red: 0.40, green: 0.40, blue: 0.40, alpha: 1.00)
        case .anemo: .init(red: 0.00, green: 0.52, blue: 0.56, alpha: 1.00)
        case .electro: .init(red: 0.54, green: 0.14, blue: 0.79, alpha: 1.00)
        case .imago: .init(red: 1.00, green: 1.00, blue: 0.00, alpha: 1.00)
        case .quanto: .init(red: 0.00, green: 0.13, blue: 1.00, alpha: 1.00)
        case .pyro: .init(red: 0.83, green: 0.00, blue: 0.00, alpha: 1.00)
        case .cryo: .init(red: 0.00, green: 0.38, blue: 0.63, alpha: 1.00)
        case .geo: .init(red: 1.00, green: 0.7, blue: 0.00, alpha: 1.00)
        case .dendro: .init(red: 0.25, green: 0.79, blue: 0.07, alpha: 1.00)
        case .hydro: .init(red: 0.06, green: 0.35, blue: 0.85, alpha: 1.00)
        }
    }
}
