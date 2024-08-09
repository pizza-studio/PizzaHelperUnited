// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - Enka.GameElement

extension Enka {
    /// 元素（星穹铁道与原神共用）。
    public enum GameElement: String, CaseIterable, Hashable, Codable {
        case physico
        case anemo
        case geo
        case electro
        case dendro
        case hydro
        case pyro
        case cryo
        case posesto // Quantum，量子
        case fantastico // Imaginary，虚数
    }
}

extension Enka.GameElement {
    public init?(rawValue: String) {
        switch rawValue {
        case "Physical", "Unknown": self = .physico
        case "Wind": self = .anemo
        case "Rock": self = .geo
        case "Electric", "Lightning", "Thunder": self = .electro
        case "Grass": self = .dendro
        case "Water": self = .hydro
        case "Fire": self = .pyro
        case "Ice": self = .cryo
        case "Imaginary": self = .fantastico
        case "Quantum": self = .posesto
        default: return nil
        }
    }

    public init(rawValueGuarded: String) {
        self = Self(rawValue: rawValueGuarded) ?? .physico
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let debugDescription = "Wrong type decodable for Enka.GameElement"
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
        case .physico: return "Physical"
        case .anemo: return "Wind"
        case .electro: return "Thunder"
        case .fantastico: return "Imaginary"
        case .posesto: return "Quantum"
        case .pyro: return "Fire"
        case .cryo: return "Ice"
        case .geo: return "Rock" // GI
        case .dendro: return "Grass" // GI
        case .hydro: return "Water" // GI
        }
    }

    public var rawValueForGI: String {
        switch self {
        case .physico: return "Unknown"
        case .anemo: return "Wind"
        case .electro: return "Electric"
        case .fantastico: return "Imaginary"
        case .posesto: return "Quantum"
        case .pyro: return "Fire"
        case .cryo: return "Ice"
        case .geo: return "Rock"
        case .dendro: return "Grass"
        case .hydro: return "Water"
        }
    }
}

extension Enka.GameElement {
    public var iconFileNameStem: String {
        "\(rawValue)"
    }

    public var iconAssetName: String {
        "\(rawValue)"
    }

    public var damageAddedRatioProperty: Enka.PropertyType {
        switch self {
        case .physico: return .physicoAddedRatio
        case .anemo: return .anemoAddedRatio
        case .electro: return .electroAddedRatio
        case .fantastico: return .fantasticoAddedRatio
        case .posesto: return .posestoAddedRatio
        case .pyro: return .pyroAddedRatio
        case .cryo: return .cryoAddedRatio
        case .geo: return .geoAddedRatio
        case .dendro: return .dendroAddedRatio
        case .hydro: return .hydroAddedRatio
        }
    }

    public static let elementConversionDict: [String: String] = [
        "Physical": "Physico",
        "Wind": "Anemo",
        "Lightning": "Electro",
        "Imaginary": "Fantastico",
        "Quantum": "Posesto",
        "Fire": "Pyro",
        "Ice": "Cryo",
        "Rock": "Geo",
        "Water": "Hydro",
        "Grass": "Dendro",
    ]
}
