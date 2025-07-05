// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Enka {
    public enum ArtifactType: String, AbleToCodeSendHash, CaseIterable, Identifiable {
        case hsrHead = "HEAD"
        case hsrHand = "HAND"
        case hsrBody = "BODY"
        case hsrFoot = "FOOT"
        case hsrObject = "NECK" // MiHoYo's mistake, not ours.
        case hsrNeck = "OBJECT" // MiHoYo's mistake, not ours.
        case giFlower = "EQUIP_BRACER"
        case giPlume = "EQUIP_NECKLACE"
        case giSands = "EQUIP_SHOES"
        case giGoblet = "EQUIP_RING"
        case giCirclet = "EQUIP_DRESS"

        // MARK: Lifecycle

        public init?(typeID: Int, game: Enka.GameType) {
            switch (game, typeID) {
            case (.starRail, 1): self = .hsrHead
            case (.starRail, 2): self = .hsrHand
            case (.starRail, 3): self = .hsrBody
            case (.starRail, 4): self = .hsrFoot
            case (.starRail, 5): self = .hsrObject
            case (.starRail, 6): self = .hsrNeck
            case (.genshinImpact, 1): self = .giFlower
            case (.genshinImpact, 2): self = .giPlume
            case (.genshinImpact, 3): self = .giSands
            case (.genshinImpact, 4): self = .giGoblet
            case (.genshinImpact, 5): self = .giCirclet
            default: return nil
            }
        }

        // MARK: Public

        public var artifactRatingTypeIDStr: String {
            let intResult = switch self {
            case .giFlower, .hsrHead: 1
            case .giPlume, .hsrHand: 2
            case .giSands, .hsrBody: 3
            case .giGoblet, .hsrFoot: 4
            case .giCirclet, .hsrObject: 5
            case .hsrNeck: 6
            }
            return intResult.description
        }

        public var game: Enka.GameType {
            rawValue.hasPrefix("EQUIP_") ? .genshinImpact : .starRail
        }

        public var id: String { rawValue }

        public var assetSuffix: Int {
            switch self {
            case .hsrHead: 0
            case .hsrHand: 1
            case .hsrBody: 2
            case .hsrFoot: 3
            case .hsrObject: 0
            case .hsrNeck: 1
            case .giFlower: 4
            case .giPlume: 2
            case .giSands: 5
            case .giGoblet: 1
            case .giCirclet: 3
            }
        }

        public var emojiRepresentable: String {
            switch self {
            case .hsrHead: "⛑️"
            case .hsrHand: "🥊"
            case .hsrBody: "🧥"
            case .hsrFoot: "🥾"
            case .hsrObject: "🏀"
            case .hsrNeck: "📿"
            case .giFlower: "🌷"
            case .giPlume: "🪶"
            case .giSands: "⏳"
            case .giGoblet: "🍷"
            case .giCirclet: "👑"
            }
        }

        public static func allCases(game: Enka.GameType) -> [Self] {
            Self.allCases.filter { $0.game == game }
        }
    }
}
