// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import PZBaseKit

extension Pizza.SupportedGame {
    public var gachaItemType: any UIGFGachaItemProtocol.Type {
        switch self {
        case .genshinImpact: return UIGFv4.GachaItemGI.self
        case .starRail: return UIGFv4.GachaItemHSR.self
        case .zenlessZone: return UIGFv4.GachaItemZZZ.self
        }
    }
}

// MARK: - GachaTypeProtocol

public protocol GachaTypeProtocol: RawRepresentable, Codable, Hashable, Sendable {
    associatedtype ItemType: UIGFGachaItemProtocol where ItemType.PoolType == Self
    var rawValue: String { get }
}

extension GachaTypeProtocol {
    static var game: Pizza.SupportedGame { ItemType.game }
    var game: Pizza.SupportedGame { Self.game }
}

// MARK: - UIGFGachaItemProtocol

public protocol UIGFGachaItemProtocol: Codable, Hashable, Sendable {
    associatedtype PoolType: GachaTypeProtocol where PoolType.ItemType == Self
    static var game: Pizza.SupportedGame { get }

    init(
        count: String?,
        gachaID: String?,
        gachaType: PoolType,
        id: String,
        itemID: String,
        itemType: String?,
        name: String?,
        rankType: String?,
        time: String
    )

    var count: String? { get set }
    var gachaType: PoolType { get set }
    var gachaID: String { get set }
    var id: String { get set }
    var itemID: String { get set }
    var itemType: String? { get set }
    var name: String? { get set }
    var rankType: String? { get set }
    var time: String { get set }
}

extension UIGFGachaItemProtocol {
    var game: Pizza.SupportedGame { Self.game }
}

extension Array where Element: UIGFGachaItemProtocol {
    /// 将当前 UIGFGachaItem 的物品分类与名称转换成给定的语言。
    /// - Parameter lang: 给定的语言。
    mutating func updateLanguage(_ lang: GachaLanguage) throws {
        var newItemContainer = Self()
        // 君子协定：这里要求 UIGFGachaItem 的 itemID 必须是有效值，否则会出现灾难性的后果。
        try forEach { currentItem in
            guard Int(currentItem.itemID) != nil else {
                throw GachaMeta.GMDBError.itemIDInvalid(name: currentItem.name ?? "", game: currentItem.game)
            }
            let theDB: [String: GachaItemMetadata] = switch currentItem.game {
            case .genshinImpact: GachaMeta.sharedDB.mainDB4GI
            case .starRail: GachaMeta.sharedDB.mainDB4HSR
            case .zenlessZone: [:] // 目前暂时不处理绝区零。
            }
            var newItem = currentItem
            let itemTypeRaw: GachaItemType = .init(itemID: newItem.itemID, game: currentItem.game)
            newItem.itemType = itemTypeRaw.getTranslatedRaw(for: lang, game: currentItem.game)
            if let newName = theDB.plainQueryForNames(itemID: newItem.itemID, langID: lang.rawValue) {
                newItem.name = newName
            }
            newItemContainer.append(newItem)
        }
        self = newItemContainer
    }
}

// MARK: - UIGFProfileProtocol

public protocol UIGFProfileProtocol {
    associatedtype ItemType: UIGFGachaItemProtocol where ItemType.PoolType == PoolType
    associatedtype PoolType: GachaTypeProtocol
}

extension UIGFProfileProtocol {
    static var game: Pizza.SupportedGame { ItemType.game }
    var game: Pizza.SupportedGame { Self.game }
}
