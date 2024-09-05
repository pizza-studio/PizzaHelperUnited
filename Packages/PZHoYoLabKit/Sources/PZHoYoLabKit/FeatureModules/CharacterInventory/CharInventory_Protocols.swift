// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftUI

// MARK: - CharacterInventory

public protocol CharacterInventory: Codable, Hashable, Sendable, DecodableFromMiHoYoAPIJSONResult {
    associatedtype AvatarType: HYAvatar
    associatedtype ViewType: CharacterInventoryView where Self == ViewType.InventoryData
    var avatars: [AvatarType] { get }
}

extension CharacterInventory {
    @MainActor @ViewBuilder
    public func asView(isMiyousheUID: Bool) -> some View {
        ViewType(data: self, isMiyousheUID: isMiyousheUID)
    }
}

// MARK: - HYAvatar

public protocol HYAvatar: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: Int { get }
    var rarity: Int { get }
    var icon: String { get }
}

extension HYAvatar {
    public var firstCostumeID: Int? {
        guard let this = self as? HoYo.CharInventory4GI.HYAvatar4GI else { return nil }
        return this.costumes.first?.id
    }
}

// MARK: - CharacterInventoryView

@MainActor
public protocol CharacterInventoryView: View {
    associatedtype InventoryData: CharacterInventory where Self == InventoryData.ViewType
    init(data: InventoryData, isMiyousheUID: Bool)
    var data: InventoryData { get }
}

extension CharacterInventoryView {
    var characterStats: LocalizedStringKey {
        let a = data.avatars.count
        let b = data.avatars.filter { $0.rarity == 5 }.count
        let c = data.avatars.filter { $0.rarity == 4 }.count
        return "hylKit.inventoryView.characters.count.character:\(a, specifier: "%lld")\(b, specifier: "%lld")\(c, specifier: "%lld")"
    }

    var goldStats: LocalizedStringKey {
        let d = goldNum(data: data).allGold
        let e = goldNum(data: data).charGold
        let f = goldNum(data: data).weaponGold
        return "hylKit.inventoryView.characters.count.golds:\(d, specifier: "%lld")\(e, specifier: "%lld")\(f, specifier: "%lld")"
    }

    func filterAvatars(type: InventoryViewFilterType) -> [InventoryData.AvatarType] {
        switch type {
        case .all: return data.avatars
        case .star4: return data.avatars.filter { $0.rarity == 4 }
        case .star5: return data.avatars.filter { $0.rarity == 5 }
        }
    }

    func goldNum(data: InventoryData)
        -> GoldNum {
        var charGold = 0
        var weaponGold = 0
        for avatar in data.avatars {
            if avatar.id.description.prefix(1) == "8" {
                continue
            }
            if avatar.id == 10000005 || avatar.id == 10000007 {
                continue
            }
            if avatar.rarity == 5 {
                charGold += 1
                if let avatar = avatar as? HoYo.CharInventory4GI.AvatarType {
                    charGold += avatar.activedConstellationNum
                } else if let avatar = avatar as? HoYo.CharInventory4HSR.AvatarType {
                    charGold += avatar.rank
                }
            }

            if let avatar = avatar as? HoYo.CharInventory4GI.AvatarType {
                weaponGold += avatar.weapon.affixLevel
            } else if let avatar = avatar as? HoYo.CharInventory4HSR.AvatarType {
                if let equip = avatar.equip, equip.rarity == 5 {
                    weaponGold += equip.rank
                }
            }
        }
        return .init(
            allGold: charGold + weaponGold,
            charGold: charGold,
            weaponGold: weaponGold
        )
    }
}

// MARK: - GoldNum

struct GoldNum {
    let allGold, charGold, weaponGold: Int
}

// MARK: - InventoryViewFilterType

enum InventoryViewFilterType: String, CaseIterable {
    case all = "hylKit.inventoryView.characters.filter.all"
    case star5 = "hylKit.inventoryView.characters.filter.5star"
    case star4 = "hylKit.inventoryView.characters.filter.4star"
}
