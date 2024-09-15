// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import Foundation
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - GachaItemExpressible

/// 专用于 PZGachaEntry 的前端表述框架。
public struct GachaItemExpressible: Identifiable, Equatable, Sendable {
    // MARK: Public

    public let id: String
    public let uid: String
    public let game: Pizza.SupportedGame
    public let pool: GachaPoolExpressible
    public let itemID: String
    public let count: String
    public let time: Date
    public let gachaID: String

    // MARK: Fileprivate

    fileprivate let name: String
    fileprivate let rankType: GachaItemRankType
}

extension GachaItemExpressible {
    public init(rawEntry: PZGachaEntryProtocol) {
        self.id = rawEntry.id
        self.uid = rawEntry.uid
        self.game = rawEntry.game
        self.pool = .init(rawEntry.gachaType, game: rawEntry.game) // 从 GachaType 解读。
        self.itemID = rawEntry.itemID // 这里假设原神的 itemID 已被修复。
        self.count = rawEntry.count
        self.name = rawEntry.name
        // self.itemType = .init(rawString4GI: rawEntry.itemType) // 改用 ItemID 推断。
        self.rankType = .init(rawValueStr: rawEntry.rankType, game: rawEntry.game) ?? .rank3
        self.gachaID = rawEntry.gachaID
        let tzDelta = GachaKit.getServerTimeZoneDelta(uid: rawEntry.uid, game: rawEntry.game)
        self.time = .init(rawEntry.time, tzDelta: tzDelta) ?? .distantPast
    }
}

extension GachaItemExpressible {
    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }

    /// Is Lose5050 (i.e. Surinuked).
    /// Surinuke 此处作动词使用，意思是「歪了」。
    public var isSurinuked: Bool {
        guard rankType == .rank5, pool.isSurinukable else { return true }
        switch game {
        case .starRail:
            return switch itemID {
            case "1003": true // Nanashibito: Himeko
            case "1004": true // Nanashibito: Welt
            case "1101": true // Belobog: Bronya
            case "1104": true // Belobog: Gepard
            case "1107": true // Belobog: Clara
            case "1209": true // Luofu: Yanqing
            case "1211": true // Luofu: Bailu
            case "23000": true // 银河铁道之夜 (Himeko)
            case "23002": true // 无可取代的东西 (Clara)
            case "23003": true // 但战鬥还未结束 (Bronya)
            case "23004": true // 以世界之名 (Welt)
            case "23005": true // 制胜的瞬间 (Gepard)
            case "23012": true // 如泥酣眠 (Yanqing)
            case "23013": true // 时节不居 (Bailu)
            default: false
            }
        case .genshinImpact:
            return switch itemID {
            case "15502": true // 阿莫斯之弓
            case "15501": true // 天空之翼
            case "14502": true // 四风原典
            case "14501": true // 天空之卷
            case "13505": true // 和璞鸢
            case "13502": true // 天空之脊
            case "12502": true // 狼的末路
            case "12501": true // 天空之傲
            case "11501": true // 风鹰剑
            case "11502": true // 天空之刃
            case "10000016": true // Diluc
            case "10000003": true // Jean
            case "10000035": true // Qiqi
            case "10000041": true // Mona
            case "10000042": // Keqing
                checkSurinukeByTime(
                    from: .init(year: 2021, month: 2, day: 17),
                    to: .init(year: 2021, month: 3, day: 2)
                )
            case "10000069": // Tighnari
                checkSurinukeByTime(
                    from: .init(year: 2022, month: 8, day: 24),
                    to: .init(year: 2022, month: 9, day: 9)
                )
            case "10000079": // Dehya
                checkSurinukeByTime(
                    from: .init(year: 2023, month: 3, day: 1),
                    to: .init(year: 2023, month: 3, day: 21)
                )
            default: false
            }
        case .zenlessZone: return false // 暂不实作。
        }
    }

    /// 处理一开始是限定五星、后来变成常驻五星的角色。
    private func checkSurinukeByTime(from startDate: DateComponents, to endDate: DateComponents) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let dateStarted = calendar.date(from: startDate)!
        let dateEnded = calendar.date(from: endDate)!
        guard dateStarted <= dateEnded else { return false } // 不这样处理的话，会 runtime error。
        return !(dateStarted ... dateEnded).contains(time)
    }
}

extension GachaItemExpressible {
    public var itemType: GachaItemType { GachaItemType(itemID: itemID, game: game) }

    /// 建议在实际使用时以该变数取代用作垫底值的 rankType。
    public var rarity: GachaItemRankType {
        var rarityInt: Int?
        switch game {
        case .genshinImpact: rarityInt = GachaMeta.sharedDB.mainDB4GI.plainQueryForRarity(itemID: itemID)
        case .starRail: rarityInt = GachaMeta.sharedDB.mainDB4HSR.plainQueryForRarity(itemID: itemID)
        case .zenlessZone: rarityInt = nil // 警告：绝区零的 rankType 需要 +1 才能用。
        }
        return switch rarityInt {
        case 3: .rank3
        case 4: .rank4
        case 5: .rank5
        default: rankType
        }
    }

    public func nameLocalized(for lang: GachaLanguage = .current, realName: Bool = true) -> String {
        switch game {
        case .genshinImpact:
            var result: String?
            if lang == .current {
                result = Enka.Sputnik.shared.db4GI.getFailableTranslationFor(id: itemID, realName: realName)
            } else {
                result = nil
            }
            return result ?? GachaMeta.sharedDB.mainDB4GI.plainQueryForNames(
                itemID: itemID,
                langID: lang.rawValue
            )
                ?? name
        case .starRail:
            var result: String?
            if lang == .current {
                result = Enka.Sputnik.shared.db4HSR.getFailableTranslationFor(id: itemID, realName: realName)
            } else {
                result = nil
            }
            return result ?? GachaMeta.sharedDB.mainDB4HSR
                .plainQueryForNames(itemID: itemID, langID: lang.rawValue) ?? name
        case .zenlessZone: return name // 暂不处理。
        }
    }

    // 如果是大图表的话，建议尺寸是 40；否则是 30。
    @MainActor @ViewBuilder
    public func icon(_ size: CGFloat = 30) -> some View {
        Group {
            switch (game, itemType) {
            case (_, .unknown): AnonymousIconView(size, cutType: .circleClipped)
            case (.zenlessZone, .bangboo): AnonymousIconView(size, cutType: .circleClipped).colorMultiply(.red)
            case (_, .character): CharacterIconView(charID: itemID, size: size, circleClipped: true, clipToHead: true)
            case (.genshinImpact, .weapon): Enka.queryImageAssetSUI(for: "gi_weapon_\(itemID)")
            case (.starRail, .weapon): Enka.queryImageAssetSUI(for: "hsr_light_cone_\(itemID)")
            default: AnonymousIconView(size, cutType: .circleClipped).colorMultiply(.gray)
            }
        }.background {
            rankType.backgroundGradient
        }.clipShape(.circle)
    }
}
