// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - GachaItemType

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public enum GachaItemType: String, AbleToCodeSendHash, Identifiable {
    case character
    case weapon
    case unknown
    case bangboo /// ZZZ Only.

    // MARK: Public

    public var id: String { rawValue }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension GachaItemType {
    public init(itemID: String, game: Pizza.SupportedGame) {
        guard let itemIDInt = Int(itemID) else {
            self = .unknown
            return
        }
        switch game {
        case .genshinImpact:
            switch itemID.count {
            case 8: self = .character
            case 5: self = .weapon
            default: self = .unknown
            }
        case .starRail:
            switch itemID.count {
            case 4: self = .character
            case 5: self = .weapon
            default: self = .unknown
            }
        case .zenlessZone:
            switch itemID.count {
            case 4: self = .character
            case 5: switch itemIDInt {
                case 50000...: self = .bangboo
                default: self = .weapon
                }
            default: self = .unknown
            }
        }
    }

    // 僅獻給原神抽卡記錄使用。
    init(rawString4GI: String) {
        let weaponStrings: [String] = [
            "Arma", "Arme", "Senjata", "Vũ Khí",
            "Waffe", "Weapon", "Weapons", "อาวุธ",
            "武器", "무기", "Оружие",
        ]
        if weaponStrings.contains(rawString4GI) {
            self = .weapon
        } else {
            self = .character
        }
    }

    public func getTranslatedRaw(for lang: GachaLanguage = .current, game: Pizza.SupportedGame) -> String {
        let lang = lang.sanitized(by: game)
        switch game {
        case .genshinImpact:
            switch (self, lang) {
            case (.character, .langDE): return "Figur"
            case (.character, .langEN): return "Character"
            case (.character, .langES): return "Personaje"
            case (.character, .langFR): return "Personnage"
            case (.character, .langID): return "Karakter"
            case (.character, .langJP): return "キャラクター"
            case (.character, .langKR): return "캐릭터"
            case (.character, .langPT): return "Personagem"
            case (.character, .langRU): return "Персонаж"
            case (.character, .langTH): return "ตัวละคร"
            case (.character, .langVI): return "Nhân Vật"
            case (.character, .langCHS): return "角色"
            case (.character, .langCHT): return "角色"
            case (.weapon, .langDE): return "Waffe"
            case (.weapon, .langEN): return "Weapons"
            case (.weapon, .langES): return "Arma"
            case (.weapon, .langFR): return "Arme"
            case (.weapon, .langID): return "Senjata"
            case (.weapon, .langJP): return "武器"
            case (.weapon, .langKR): return "무기"
            case (.weapon, .langPT): return "Arma"
            case (.weapon, .langRU): return "Оружие"
            case (.weapon, .langTH): return "อาวุธ"
            case (.weapon, .langVI): return "Vũ Khí"
            case (.weapon, .langCHS): return "武器"
            case (.weapon, .langCHT): return "武器"
            default: return ""
            }
        case .starRail:
            switch (self, lang) {
            case (.character, .langDE): return "Figur"
            case (.character, .langEN): return "Character"
            case (.character, .langES): return "Personaje"
            case (.character, .langFR): return "Personnage"
            case (.character, .langID): return "Karakter"
            case (.character, .langJP): return "キャラクター"
            case (.character, .langKR): return "캐릭터"
            case (.character, .langPT): return "Personagem"
            case (.character, .langRU): return "Персонаж"
            case (.character, .langTH): return "ตัวละคร"
            case (.character, .langVI): return "Nhân Vật"
            case (.character, .langCHS): return "角色"
            case (.character, .langCHT): return "角色"
            case (.weapon, .langDE): return "Lichtkegel"
            case (.weapon, .langEN): return "Light Cone"
            case (.weapon, .langES): return "Cono de luz"
            case (.weapon, .langFR): return "Cône de lumière"
            case (.weapon, .langID): return "Light Cone"
            case (.weapon, .langJP): return "光円錐"
            case (.weapon, .langKR): return "광추"
            case (.weapon, .langPT): return "Cone de Luz"
            case (.weapon, .langRU): return "Световой конус"
            case (.weapon, .langTH): return "Light Cone"
            case (.weapon, .langVI): return "Nón Ánh Sáng"
            case (.weapon, .langCHS): return "光锥"
            case (.weapon, .langCHT): return "光錐"
            default: return ""
            }
        case .zenlessZone: return ""
        }
    }
}

// MARK: - TimeTag

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public struct TimeTag: Hashable, Identifiable {
    // MARK: Lifecycle

    public init?(_ timeTagStr: String, tzDelta: Int) {
        guard let time = Date(timeTagStr, tzDelta: tzDelta) else { return nil }
        let components = Calendar.gregorian.dateComponents([.day], from: time, to: Date.now)
        self.timeTagStr = timeTagStr
        self.time = time
        self.dayFromNow = components.day ?? 0
    }

    // MARK: Public

    public let timeTagStr: String
    public let time: Date
    public let dayFromNow: Int

    public var id: TimeInterval { time.timeIntervalSince1970 }
}
