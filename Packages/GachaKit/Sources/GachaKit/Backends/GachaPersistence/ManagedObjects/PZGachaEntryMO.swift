// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftData

// MARK: - PZGachaEntryProtocol

public protocol PZGachaEntryProtocol {
    var game: String { get set }
    var uid: String { get set }
    var gachaType: String { get set }
    var itemID: String { get set }
    var count: String { get set }
    var time: String { get set }
    var name: String { get set }
    var lang: String { get set }
    var itemType: String { get set }
    var rankType: String { get set }
    var id: String { get set }
    var gachaID: String { get set }
}

extension PZGachaEntryProtocol {
    public var gameTyped: Pizza.SupportedGame {
        .init(rawValue: game) ?? .genshinImpact
    }
}

extension PZGachaEntryProtocol {
    public var uidWithGame: String {
        "\(gameTyped.uidPrefix)-\(uid)"
    }
}

// MARK: - PZGachaEntryMO

@Model
public final class PZGachaEntryMO: Codable, PZGachaEntryProtocol {
    // MARK: Lifecycle

    public init(handler: ((PZGachaEntryMO) -> Void)? = nil) {
        handler?(self)
    }

    public init(
        game: Pizza.SupportedGame,
        uid: String,
        gachaType: String,
        itemID: String,
        count: String,
        time: String,
        name: String,
        lang: String,
        itemType: String,
        rankType: String,
        id: String,
        gachaID: String
    ) {
        self.game = game.rawValue
        self.uid = uid
        self.gachaType = gachaType
        self.itemID = itemID
        self.count = count
        self.time = time
        self.name = name
        self.lang = lang
        self.itemType = itemType
        self.rankType = rankType
        self.id = id
        self.gachaID = gachaID
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.game = try container.decode(String.self, forKey: .game)
        self.uid = try container.decode(String.self, forKey: .uid)
        self.gachaType = try container.decode(String.self, forKey: .gachaType)
        self.itemID = try container.decode(String.self, forKey: .itemID)
        self.count = try container.decode(String.self, forKey: .count)
        self.time = try container.decode(String.self, forKey: .time)
        self.name = try container.decode(String.self, forKey: .name)
        self.lang = try container.decode(String.self, forKey: .lang)
        self.itemType = try container.decode(String.self, forKey: .itemType)
        self.rankType = try container.decode(String.self, forKey: .rankType)
        self.id = try container.decode(String.self, forKey: .id)
        self.gachaID = try container.decode(String.self, forKey: .gachaID)
    }

    // MARK: Public

    public var game: String = "GI"
    public var uid: String = "000000000"
    public var gachaType: String = "5"
    public var itemID: String = UUID().uuidString
    public var count: String = "1"
    public var time: String = "2000-01-01 00:00:00"
    public var name: String = "YJSNPI"
    public var lang: String = "zh-cn"
    public var itemType: String = "武器"
    public var rankType: String = "3"
    public var id: String = PZGachaEntryMO.makeEntryID()
    public var gachaID: String = "0"

    final public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: PZGachaEntryMO.CodingKeys.self)
        try container.encode(game, forKey: .game)
        try container.encode(uid, forKey: .uid)
        try container.encode(gachaType, forKey: .gachaType)
        try container.encode(itemID, forKey: .itemID)
        try container.encode(count, forKey: .count)
        try container.encode(time, forKey: .time)
        try container.encode(name, forKey: .name)
        try container.encode(lang, forKey: .lang)
        try container.encode(itemType, forKey: .itemType)
        try container.encode(rankType, forKey: .rankType)
        try container.encode(id, forKey: .id)
        try container.encode(gachaID, forKey: .gachaID)
    }

    // MARK: Private

    private enum CodingKeys: CodingKey {
        case game
        case uid
        case gachaType
        case itemID
        case count
        case time
        case name
        case lang
        case itemType
        case rankType
        case id
        case gachaID
    }

    private static func makeEntryID() -> String {
        var stringStack = "9"
        while stringStack.count < 19 {
            stringStack.append(Int.random(in: 0 ... 9).description)
        }
        return stringStack
    }
}

// MARK: - Predicates.

extension PZGachaEntryMO {
    public static func predicate(
        owner gachaProfile: PZGachaProfileMO?,
        rarityLevel: GachaItemRankType? = GachaItemRankType.rank5
    )
        -> Predicate<PZGachaEntryMO> {
        guard let gachaProfile else { return #Predicate<PZGachaEntryMO> { _ in false } }
        let matchedGame = gachaProfile.game.rawValue
        let matchedUID = gachaProfile.uid
        let matchedRankType = rarityLevel?.rawValue.description
        if let matchedRankType {
            return #Predicate<PZGachaEntryMO> { entry in
                entry.uid == matchedUID
                    && entry.game == matchedGame
                    && entry.rankType == matchedRankType
            }
        } else {
            return #Predicate<PZGachaEntryMO> { entry in
                entry.uid == matchedUID
                    && entry.game == matchedGame
            }
        }
    }
}
