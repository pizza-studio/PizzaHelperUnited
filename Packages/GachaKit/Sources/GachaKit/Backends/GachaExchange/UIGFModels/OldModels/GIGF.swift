// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreData
import CoreXLSX
import Defaults
import Foundation
import GachaMetaDB
@preconcurrency import NaturalLanguage
import SwiftUI
import UniformTypeIdentifiers

// MARK: - GIGF

/// UIGFv2~v3 格式（也就是 GIGF 格式）。
///
/// 原披助手不再提供 UIGFv2~v3 格式（也就是 GIGF 格式）的导出支援，而是仅保留导入的功能。
///
/// 没写明 lang 的一律先侦测语言、且拿简体中文当垫底语言来处理。
///
/// 原披助手不图 GIGF 格式所承载的资料的完美性，GIGF 的所有内容都会被先转换成 UIGFv4 再利用。
///
/// 最终写入 App 自身的 CoreData 资料库的内容一定是简体中文，这个步骤由 UIGFv4 把关。
///
/// Ref: [UIGF](https://uigf.org/zh/standards/uigf.html)
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct GIGF: Decodable {
    // MARK: Lifecycle

    public init(info: Info, list: [GIGFGachaItem]) {
        self.info = info
        self.list = list
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.info = try container.decode(GIGF.Info.self, forKey: .info)
        self.list = try container.decode([GIGFGachaItem].self, forKey: .list)
        fixItemIDs()
        fixTimeZoneIfNil()
    }

    // MARK: Public

    public struct Info: Decodable {
        // MARK: Lifecycle

        init(
            uid: String,
            lang: GachaLanguage,
            exportTime: Date? = nil,
            exportTimestamp: Int? = nil,
            exportApp: String? = nil,
            exportAppVersion: String? = nil,
            uigfVersion: String? = nil,
            regionTimeZone: Int? = nil
        ) {
            self.uid = uid
            self.lang = lang
            self.exportTime = exportTime
            self.exportTimestamp = exportTimestamp
            self.exportApp = exportApp
            self.exportAppVersion = exportAppVersion
            self.uigfVersion = uigfVersion
            self.regionTimeZone = regionTimeZone
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uid = try container.decode(String.self, forKey: .uid)

            let dateFormatter = DateFormatter.GregorianPOSIX()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let dateString = try container.decodeIfPresent(
                String.self,
                forKey: .exportTime
            ),
                let date = dateFormatter.date(from: dateString) {
                self.exportTime = date
            } else {
                self.exportTime = nil
            }

            self.exportTimestamp = nil
            self.exportApp = try container.decodeIfPresent(
                String.self,
                forKey: .exportApp
            )
            self.exportAppVersion = try container.decodeIfPresent(
                String.self,
                forKey: .exportAppVersion
            )
            self.uigfVersion = try container.decodeIfPresent(
                String.self,
                forKey: .uigfVersion
            )
            self.regionTimeZone = try container.decodeIfPresent(
                Int.self,
                forKey: .regionTimeZone
            )

            self.lang = (try? container.decodeIfPresent(GachaLanguage.self, forKey: .lang)) ?? .langCHS
        }

        // MARK: Public

        public internal(set) var regionTimeZone: Int?

        // MARK: Internal

        @available(iOS 17.0, *)
        @available(macCatalyst 17.0, *)
        @available(macOS 14.0, *)
        enum CodingKeys: String, CodingKey {
            case uid, lang
            case exportTime = "export_time"
            case exportApp = "export_app"
            case exportAppVersion = "export_app_version"
            case uigfVersion = "uigf_version"
            case regionTimeZone = "region_time_zone"
        }

        let uid: String
        var lang: GachaLanguage
        let exportTime: Date?
        let exportTimestamp: Int?
        let exportApp: String?
        let exportAppVersion: String?
        let uigfVersion: String?
    }

    public var info: Info
    public internal(set) var list: [GIGFGachaItem]

    public var needsItemIDFix: Bool {
        !list.filter(\.itemID.isNotInt).isEmpty
    }

    // MARK: Internal

    enum CodingKeys: CodingKey {
        case info
        case list
    }
}

// MARK: - GIGFGachaItem

/// UIGFv2~v3 格式（也就是 GIGF 格式）的 GachaItem。
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct GIGFGachaItem: Decodable {
    // MARK: Lifecycle

    fileprivate init(
        gachaType: GachaTypeGI,
        itemID: String,
        count: String,
        time: String,
        name: String,
        itemType: String,
        rankType: GachaItemRankType?,
        id: String,
        uigfGachaType: GachaTypeGI.UIGFGachaType
    ) {
        self.gachaType = gachaType
        self.itemID = itemID
        self.count = count
        self.time = time
        self.name = name
        self.itemType = itemType
        self.rankType = rankType
        self.id = id
        self.uigfGachaType = uigfGachaType
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let gcTypeStr = try container.decodeIfPresent(String.self, forKey: .gachaType) {
            self.gachaType = GachaTypeGI(rawValue: gcTypeStr)
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.gachaType],
                debugDescription: "invalid gacha_type format."
            ))
        }

        self.itemID = try container.decodeIfPresent(String.self, forKey: .itemID) ?? ""
        self.count = try container
            .decodeIfPresent(String.self, forKey: .count) ?? "1"

        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let timeStr = try? container.decode(String.self, forKey: .time),
           dateFormatter.date(from: try container.decode(String.self, forKey: .time)) != nil {
            self.time = timeStr
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.time],
                debugDescription: "invalid date format: \(try container.decode(String.self, forKey: .time))"
            ))
        }

        self.name = try container.decode(String.self, forKey: .name)
        if let raw = try container.decodeIfPresent(
            String.self,
            forKey: .itemType
        ) {
            self.itemType = GachaItemType(rawString4GI: raw).getTranslatedRaw(for: .langCHS, game: .genshinImpact)
        } else {
            self.itemType = GachaItemType.weapon.getTranslatedRaw(for: .langCHS, game: .genshinImpact)
        }
        if let raw = try container.decodeIfPresent(
            String.self,
            forKey: .rankType
        ),
            let intRaw = Int(raw),
            let type = GachaItemRankType(rawValue: intRaw) {
            self.rankType = type
        } else {
            self.rankType = nil
        }

        self.id = (try? container.decodeIfPresent(String.self, forKey: .id)) ?? ""
        self.uigfGachaType = gachaType.uigfGachaType
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case gachaType = "gacha_type"
        case itemID = "item_id"
        case count
        case time
        case name
        case itemType = "item_type"
        case rankType = "rank_type"
        case id
        case uigfGachaType = "uigf_gacha_type"
    }

    var gachaType: GachaTypeGI
    var itemID: String
    var count: String
    var time: String
    var name: String
    var itemType: String
    var rankType: GachaItemRankType?
    var id: String
    var uigfGachaType: GachaTypeGI.UIGFGachaType
}

// MARK: - Time Zone Fixer

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GIGF {
    mutating func fixTimeZoneIfNil() {
        guard info.regionTimeZone == nil else { return }
        let fallbackTimeZone = Defaults[.fallbackTimeForGIGFFileImport]
        let newTimeZoneDelta = GachaKit.getServerTimeZoneDelta(uid: info.uid, game: .genshinImpact)

        let timeZoneDeltaAsSeconds: Int = {
            var timeZoneSeconds = newTimeZoneDelta * 3600
            if let fallbackTimeZone {
                timeZoneSeconds = fallbackTimeZone.secondsFromGMT()
            }
            return timeZoneSeconds
        }()

        guard newTimeZoneDelta * 3600 != fallbackTimeZone?.secondsFromGMT() else { return }

        for i in 0 ..< list.count {
            if let timeTyped: Date = DateFormatter.forUIGFEntry(
                timeZoneDeltaAsSeconds: timeZoneDeltaAsSeconds
            ).date(from: list[i].time) {
                list[i].time = timeTyped.asUIGFDate(timeZoneDelta: newTimeZoneDelta)
            }
        }
    }
}

// MARK: - Translator to UIGFv4 Profile

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GIGF {
    /// 注意：这个方法不会自动尝试修复 GIGF (UIGFv2.2 & v2.3) 的时区资讯。
    func upgradeToUIGFv4Profile() -> UIGFv4.ProfileGI {
        // MARK: Info

        var newInfo = UIGFv4.ProfileGI(
            lang: info.lang,
            list: [],
            timezone: info.regionTimeZone ?? GachaKit.getServerTimeZoneDelta(
                uid: info.uid, game: .genshinImpact
            ),
            uid: info.uid
        )

        let mainDB = GachaMeta.sharedDB.mainDB4GI
        let revDB = mainDB.generateHotReverseQueryDict(for: info.lang.rawValue) ?? [:]

        list.forEach { v2Item in
            var newItemID = v2Item.itemID
            var newName = v2Item.name
            if newItemID.isNotInt {
                if let newItemIDInt = revDB[v2Item.name] {
                    newItemID = newItemIDInt.description
                }
            }
            if newItemID.isInt {
                newName = GachaMeta.sharedDB.mainDB4GI.plainQueryForNames(
                    itemID: newItemID, langID: self.info.lang.rawValue
                ) ?? v2Item.name
            }

            var maybeRankType: String? = v2Item.rankType?.rawValue.description ?? nil
            if maybeRankType == nil, newItemID.isInt,
               let intMaybeRankType = mainDB.plainQueryForRarity(itemID: newItemID) {
                maybeRankType = intMaybeRankType.description
            }

            let v4Item = UIGFv4.GachaItemGI(
                count: v2Item.count,
                gachaID: nil,
                gachaType: v2Item.gachaType,
                id: v2Item.id,
                itemID: newItemID,
                itemType: v2Item.itemType,
                name: newName,
                rankType: maybeRankType,
                time: v2Item.time
            )
            newInfo.list.append(v4Item)
        }

        return newInfo
    }
}

// MARK: - Language Detection Feature

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GachaLanguage {
    var nlLanguage: NLLanguage {
        switch self {
        case .langTH: .thai
        case .langKR: .korean
        case .langES: .spanish
        case .langJP: .japanese
        case .langCHS: .simplifiedChinese
        case .langID: .indonesian
        case .langPT: .portuguese
        case .langDE: .german
        case .langFR: .french
        case .langCHT: .traditionalChinese
        case .langRU: .russian
        case .langEN: .english
        case .langVI: .vietnamese
        case .langIT: .italian // GI only.
        case .langTR: .turkish // GI only.
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GIGF {
    private static let recognizer = NLLanguageRecognizer()

    private static func guessLanguages(for text: String) -> [GachaLanguage] {
        recognizer.languageConstraints = GachaLanguage.allCases.compactMap { $0.nlLanguage }
        Self.recognizer.processString(text)
        return Self.recognizer.languageHypotheses(withMaximum: 114514).sorted {
            $0.value > $1.value
        }.compactMap { tag in
            GachaLanguage(langTag: tag.key.rawValue)
        }
    }

    private var lingualDataForAnalysis: String {
        var result = Set<String>()
        list.forEach { currentItem in
            result.insert(currentItem.name)
            result.insert(currentItem.itemType)
        }
        return result.joined(separator: "\n")
    }

    public var possibleLanguages: [GachaLanguage] {
        Self.guessLanguages(for: lingualDataForAnalysis)
    }

    public var mightHaveWrongLanguageTag: Bool {
        guard !list.isEmpty, let maybeLang = possibleLanguages.first else { return false }
        return maybeLang != info.lang
    }

    public mutating func fixItemIDs(with givenLanguage: GachaLanguage? = nil) {
        guard !list.isEmpty, needsItemIDFix else { return }
        var languages = [info.lang]
        if mightHaveWrongLanguageTag, !possibleLanguages.isEmpty {
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
        let listBackup = list
        languageEnumeration: while !languages.isEmpty, let language = languages.first {
            var languageMismatchDetected = false
            revDB = language.makeRevDB()
            listItemEnumeration: for listIndex in 0 ..< list.count {
                guard list[listIndex].itemID.isNotInt else { continue }
                /// 只要没查到结果，就可以认定当前的语言匹配有误。
                lazy var trie = GachaMeta.Trie(words: [String](revDB.keys))
                let oldItemName = list[listIndex].name
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
                list[listIndex].itemID = newItemID.description
            }

            /// 检测无误的话，就退出处理。
            guard languageMismatchDetected else { break languageEnumeration }
            /// 处理语言有误时的情况：将 list 还原成修改前的状态，再测试下一个语言。
            languages.removeFirst()
            if !languages.isEmpty { list = listBackup }
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GachaLanguage {
    func makeRevDB() -> [String: Int] {
        GachaMeta.sharedDB.mainDB4GI.generateHotReverseQueryDict(for: rawValue) ?? [:]
    }
}

// MARK: - GIGF XLSX Parsing

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension XLSXFile {
    enum GIGFExcelError: Error, LocalizedError {
        case errorWithMessage(msg: String)
        case rawDataMissing
        case tableDataMissing

        // MARK: Public

        public var localizedDescription: String {
            switch self {
            case let .errorWithMessage(msg): msg
            case .rawDataMissing: "app.gacha.import.fail.rawDataNotExist".i18nGachaKit
            case .tableDataMissing: "app.gacha.import.fail.dataTableMissingData".i18nGachaKit
            }
        }

        public var errorDescription: String? { localizedDescription }

        public var description: String { localizedDescription }
    }

    private struct ParsedRow {
        let lang: GachaLanguage
        let uid: String
        let item: GIGFGachaItem
    }

    func parseItems() throws -> UIGFv4 {
        let extracted = try parseRawItems()
        var giProfiles = [UIGFv4.ProfileGI]()

        GachaLanguage.allCases.forEach { langCode in
            let rows = extracted.filter { $0.lang == langCode }
            guard !rows.isEmpty else { return }
            // UID: Items
            var map = [String: [GIGFGachaItem]]()
            rows.forEach { row in
                map[row.uid, default: []].append(row.item)
            }
            map.forEach { uid, item in
                let info = GIGF.Info(
                    uid: uid,
                    lang: langCode,
                    uigfVersion: "v2.2",
                    regionTimeZone: nil
                )
                var newFile = GIGF(info: info, list: item)
                newFile.fixItemIDs()
                newFile.fixTimeZoneIfNil()
                giProfiles.append(newFile.upgradeToUIGFv4Profile())
            }
        }

        var newMap = [String: [UIGFv4.GachaItemGI]]()
        for iii in 0 ..< giProfiles.count {
            try giProfiles[iii].list.updateLanguage(.langCHS)
            newMap[giProfiles[iii].uid, default: []].append(contentsOf: giProfiles[iii].list)
        }

        let newProfiles: [UIGFv4.ProfileGI] = newMap.map { uid, list in
            .init(
                lang: .langCHS,
                list: list,
                timezone: GachaKit.getServerTimeZoneDelta(uid: uid, game: .genshinImpact),
                uid: uid
            )
        }

        return UIGFv4(info: .init(), giProfiles: newProfiles)
    }

    private func parseRawItems() throws -> [ParsedRow] {
        let file = self
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        let errRDM = GIGFExcelError.rawDataMissing
        guard let workbook = try file.parseWorkbooks().first else { throw errRDM }
        let pathsAndNames = try file.parseWorksheetPathsAndNames(workbook: workbook)
        guard let (_, path) = pathsAndNames.first(where: { $0.name == "原始数据" }) else { throw errRDM }
        guard let worksheet = try? file.parseWorksheet(at: path) else { throw errRDM }
        guard let sharedStrings = try file.parseSharedStrings() else { throw errRDM }

        let errTDM = GIGFExcelError.tableDataMissing
        guard let rawRows = worksheet.data?.rows else { throw errTDM }
        guard let firstRowCells = rawRows.first?.cells else { throw errTDM }
        let head = firstRowCells.map { $0.stringValue(sharedStrings) }
        let rows = rawRows[1...].map { $0.cells.map { $0.stringValue(sharedStrings) }}
        guard let gachaTypeIndex = head.firstIndex(where: { $0 == "gacha_type" }) else { throw errTDM }
        guard let itemTypeIndex = head.firstIndex(where: { $0 == "item_type" }) else { throw errTDM }
        guard let nameIndex = head.firstIndex(where: { $0 == "name" }) else { throw errTDM }
        guard let uidIndex = head.firstIndex(where: { $0 == "uid" }) else { throw errTDM }
        guard let idIndex = head.firstIndex(where: { $0 == "id" }) else { throw errTDM }

        let itemIdIndex = head.firstIndex(where: { $0 == "item_id" })
        let timeIndex = head.firstIndex(where: { $0 == "time" })
        let langIndex = head.firstIndex(where: { $0 == "lang" })
        let rankTypeIndex = head.firstIndex(where: { $0 == "rank_type" })
        let countIndex = head.firstIndex(where: { $0 == "count" })

        var extracted: [ParsedRow] = []

        rows.forEach { cells in
            guard let id = cells[idIndex] else { return }
            guard let uid = cells[uidIndex] else { return }
            guard let gachaTypeRAW = cells[gachaTypeIndex] else { return }
            guard let itemType = cells[itemTypeIndex] else { return }
            guard let name = cells[nameIndex] else { return }

            let gachaType = GachaTypeGI(rawValue: gachaTypeRAW)

            var itemID = ""
            if let itemIdIndex = itemIdIndex, let itemIdString = cells[itemIdIndex] {
                itemID = itemIdString
            }

            var count = "1"
            if let countIndex = countIndex, let countString = cells[countIndex] {
                count = countString
            }

            /// GIGF XLSX 格式的时间原则上得认为是伺服器时间，
            /// 不存在 JSON 那种在导出时改变时区的可能。
            var time: Date = .distantPast
            let timeZoneDelta = GachaKit.getServerTimeZoneDelta(uid: uid, game: .genshinImpact)
            if let timeIndex = timeIndex, let timeString = cells[timeIndex] {
                time = DateFormatter.forUIGFEntry(
                    timeZoneDelta: timeZoneDelta
                ).date(from: timeString) ?? .distantPast
            }

            var lang: GachaLanguage = .langCHS
            if let langIndex = langIndex, let langString = cells[langIndex],
               let langCode = GachaLanguage(rawValue: langString) {
                lang = langCode
            }

            let rankType: Int
            if let rankTypeIndex = rankTypeIndex,
               let rankTypeString = cells[rankTypeIndex],
               let rankTypeInt = Int(rankTypeString) {
                rankType = rankTypeInt
            } else {
                rankType = 3
            }

            let newItem = GIGFGachaItem(
                gachaType: gachaType,
                itemID: itemID,
                count: count,
                time: time.asUIGFDate(timeZoneDelta: timeZoneDelta),
                name: name,
                itemType: itemType,
                rankType: GachaItemRankType(rawValue: rankType) ?? .rank3,
                id: id,
                uigfGachaType: gachaType.uigfGachaType
            )

            let newRow = ParsedRow(lang: lang, uid: uid, item: newItem)
            extracted.append(newRow)
        }

        return extracted
    }
}
