// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import CoreData
import GachaMetaDB
@preconcurrency import NaturalLanguage
import PZAccountKit
import PZBaseKit
@preconcurrency import Sworm

// MARK: - CDGachaMOSputnik

/// 警告：请务必不要直接初始化这个 class。请借由 GachaActor 来使用这个 class。
public final class CDGachaMOSputnik: Sendable {
    // MARK: Lifecycle

    public init(persistence: DBPersistenceMethod, backgroundContext: Bool) throws {
        let pc4HSR = try CDGachaMO4HSR.getLoadedPersistentContainer(persistence: persistence)
        let pc4GI = try CDGachaMO4GI.getLoadedPersistentContainer(persistence: persistence)
        if backgroundContext {
            self.db4HSR = .init(managedObjectContext: pc4HSR.newBackgroundContext)
            self.db4GI = .init(managedObjectContext: pc4GI.newBackgroundContext)
        } else {
            self.db4HSR = .init { pc4HSR.viewContext }
            self.db4GI = .init { pc4GI.viewContext }
        }
    }

    // MARK: Public

    public static let shared = try! CDGachaMOSputnik(persistence: .cloud, backgroundContext: true)

    public func confirmWhetherHavingData() async -> Bool {
        ((try? await countAllCDGachaMOAsPZGachaEntryMO()) ?? 0) > 0
    }

    public func allGachaDataMO(for game: Pizza.SupportedGame, fixItemIDs: Bool = true) throws -> [CDGachaMOProtocol] {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact:
                var genshinDataRAW = try ctx.fetch(CDGachaMO4GI.all).map { try $0.decode() }
                if fixItemIDs {
                    // Fix Genshin ItemIDs.
                    genshinDataRAW.fixItemIDs()
                    if genshinDataRAW.mightHaveNonCHSLanguageTag {
                        try genshinDataRAW.updateLanguage(.langCHS)
                    }
                    for idx in 0 ..< genshinDataRAW.count {
                        let currentObj = genshinDataRAW[idx]
                        guard Int(currentObj.itemId) == nil else { continue }
                        Task { @MainActor in
                            try? await GachaMeta.Sputnik.updateLocalGachaMetaDB(for: .genshinImpact)
                        }
                        throw GachaMeta.GMDBError.databaseExpired(game: .genshinImpact)
                    }
                }
                return genshinDataRAW
            case .starRail: return try ctx.fetch(CDGachaMO4HSR.all).map { try $0.decode() }
            case .zenlessZone: return []
            }
        } ?? []
    }

    public func countAllCDGachaMO(for game: Pizza.SupportedGame) throws -> Int {
        try theDB(for: game)?.perform { ctx in
            switch game {
            case .genshinImpact: try ctx.count(of: CDGachaMO4GI.all)
            case .starRail: try ctx.count(of: CDGachaMO4HSR.all)
            case .zenlessZone: 0
            }
        } ?? 0
    }

    public func countAllCDGachaMOAsPZGachaEntryMO() async throws -> Int {
        async let countGI = countAllCDGachaMO(for: .genshinImpact)
        async let countHSR = countAllCDGachaMO(for: .starRail)
        let intGI = try await countGI
        let intHSR = try await countHSR
        return intGI + intHSR
    }

    public func allCDGachaMOAsPZGachaEntryMO() throws -> [PZGachaEntrySendable] {
        // Genshin.
        let genshinData = try allGachaDataMO(for: .genshinImpact, fixItemIDs: true).map(\.asPZGachaEntrySendable)
        // StarRail.
        let hsrData = try allGachaDataMO(for: .starRail).map(\.asPZGachaEntrySendable)
        let dataSet: [PZGachaEntrySendable] = [genshinData, hsrData].compactMap { $0 }.reduce([], +)
        return dataSet
    }

    // MARK: Internal

    func theDB(for game: Pizza.SupportedGame) -> PersistentContainer? {
        switch game {
        case .genshinImpact: db4GI
        case .starRail: db4HSR
        case .zenlessZone: nil
        }
    }

    // MARK: Private

    private let db4GI: PersistentContainer
    private let db4HSR: PersistentContainer
}

// MARK: - Language parser (duplicated from GIGF with modifications)

extension [CDGachaMO4GI] {
    fileprivate static let recognizer = NLLanguageRecognizer()

    fileprivate static func guessLanguages(for text: String) -> [GachaLanguage] {
        recognizer.languageConstraints = GachaLanguage.allCases.compactMap { $0.nlLanguage }
        Self.recognizer.processString(text)
        return Self.recognizer.languageHypotheses(withMaximum: 114514).sorted {
            $0.value > $1.value
        }.compactMap { tag in
            GachaLanguage(langTag: tag.key.rawValue)
        }
    }

    fileprivate var lingualDataForAnalysis: String {
        var result = Set<String>()
        forEach { currentItem in
            result.insert(currentItem.name)
            result.insert(currentItem.itemType)
        }
        return result.joined(separator: "\n")
    }

    public var possibleLanguages: [GachaLanguage] {
        Self.guessLanguages(for: lingualDataForAnalysis)
    }

    public var mightHaveNonCHSLanguageTag: Bool {
        possibleLanguages != [.langCHS]
    }

    public mutating func fixItemIDs(with givenLanguage: GachaLanguage? = nil) {
        let needsItemIDFix = !filter(\.itemId.isNotInt).isEmpty
        guard !isEmpty, needsItemIDFix else { return }
        var languages: [HoYo.APILang] = [.langCHS]
        if mightHaveNonCHSLanguageTag, !possibleLanguages.isEmpty {
            languages = possibleLanguages
        }
        if let givenLanguage {
            languages.removeAll { $0 == givenLanguage }
            languages.insert(givenLanguage, at: 0)
        }

        if !languages.contains(.langCHS) {
            languages.append(.langCHS) // 垫底语言。
        }

        var revDB = [String: Int]()
        var revDBDeducted = [String: Int]() // 复用表。
        let listBackup = self
        languageEnumeration: while !languages.isEmpty, let language = languages.first {
            var languageMismatchDetected = false
            revDB = language.makeRevDB() // Just in case.
            listItemEnumeration: for listIndex in 0 ..< count {
                guard self[listIndex].itemId.isNotInt else { continue }
                /// 只要没查到结果，就可以认定当前的语言匹配有误。
                lazy var trie = GachaMeta.Trie(words: [String](revDB.keys))
                let oldItemName = self[listIndex].name
                let newItemID: Int?
                matchText: if !revDB.keys.contains(oldItemName), !revDBDeducted.keys.contains(oldItemName) {
                    /// 只允许有最多一个错别字。
                    let matched = trie.findSimilarWords(against: oldItemName, maxDistance: 1)
                    /// 如果有多个匹配结果的话，现阶段不处理。回头实作一个画面让用户确认。
                    guard matched.count == 1 else { newItemID = nil; break matchText }
                    guard let newItemName = matched.first else { newItemID = nil; break matchText }
                    /// 文字数量得相等。（Swift 的 String.count 是语言学上的字符长度，这与 Cpp 不同。）
                    guard newItemName.count == oldItemName.count else { newItemID = nil; break matchText }
                    /// 如果只有一个匹配结果的话，那应该就是正确结果。
                    revDBDeducted[oldItemName] = revDB[newItemName] // 将该结果留着复用。
                    newItemID = revDB[newItemName]
                } else {
                    newItemID = revDB[oldItemName] ?? revDBDeducted[oldItemName]
                }
                guard let newItemID else {
                    languageMismatchDetected = true
                    break listItemEnumeration
                }
                self[listIndex].itemId = newItemID.description
            }

            /// 检测无误的话，就退出处理。
            guard languageMismatchDetected else { break languageEnumeration }
            /// 处理语言有误时的情况：将 list 还原成修改前的状态，再测试下一个语言。
            languages.removeFirst()
            if !languages.isEmpty { self = listBackup }
        }
    }

    /// 将当前 CDGachaMO4GI 的物品分类与名称转换成给定的语言。
    /// - Parameter lang: 给定的语言。
    mutating func updateLanguage(_ lang: GachaLanguage) throws {
        var newItemContainer = Self()
        // 君子协定：这里要求 UIGFGachaItem 的 itemID 必须是有效值，否则会出现灾难性的后果。
        try forEach { currentItem in
            guard currentItem.itemId.isInt else {
                throw GachaMeta.GMDBError.itemIDInvalid(
                    name: currentItem.name, game: currentItem.game, uid: currentItem.uid
                )
            }
            let lang = lang.sanitized(by: currentItem.game)
            let theDB: [String: GachaItemMetadata] = switch currentItem.game {
            case .genshinImpact: GachaMeta.sharedDB.mainDB4GI
            case .starRail: GachaMeta.sharedDB.mainDB4HSR
            case .zenlessZone: [:] // 目前暂时不处理绝区零。
            }
            var newItem = currentItem
            let itemTypeRaw: GachaItemType = .init(itemID: newItem.itemId, game: currentItem.game)
            newItem.itemType = itemTypeRaw.getTranslatedRaw(for: lang, game: currentItem.game)
            if let newName = theDB.plainQueryForNames(itemID: newItem.itemId, langID: lang.rawValue) {
                newItem.name = newName
            } else {
                throw GachaMeta.GMDBError.databaseExpired(game: currentItem.game)
            }
            newItemContainer.append(newItem)
        }
        self = newItemContainer
    }
}
