// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - SRGFv1

// Ref: https://uigf.org/zh/standards/srgf.html

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
public struct SRGFv1: AbleToCodeSendHash {
    // MARK: Lifecycle

    public init(info: Info, list: [DataEntry]) {
        self.info = info
        self.list = list
    }

    // MARK: Public

    public var info: Info
    public var list: [DataEntry]
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1 {
    private static func makeDecodingError(_ key: CodingKey) -> Error {
        let keyName = key.description
        var msg = "\(keyName) value is invalid or empty. "
        msg += "// \(keyName) 不得是空值或不可用值。 "
        msg += "// \(keyName) は必ず有効な値しか処理できません。"
        return DecodingError.dataCorrupted(.init(codingPath: [key], debugDescription: msg))
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1 {
    // MARK: - Info

    public struct Info: AbleToCodeSendHash {
        // MARK: Lifecycle

        public init(
            uid: String,
            srgfVersion: String,
            lang: GachaLanguage,
            regionTimeZone: Int,
            exportTimestamp: Int? = nil,
            exportApp: String? = nil,
            exportAppVersion: String? = nil
        ) {
            self.uid = uid
            self.srgfVersion = srgfVersion
            self.lang = lang
            self.regionTimeZone = regionTimeZone
            self.exportTimestamp = exportTimestamp
            self.exportApp = exportApp
            self.exportAppVersion = exportAppVersion
        }

        // MARK: Public

        public var uid, srgfVersion: String
        public var lang: GachaLanguage
        public var regionTimeZone: Int
        public var exportTimestamp: Int?
        public var exportApp, exportAppVersion: String?

        // MARK: Internal

        @available(iOS 17.0, *)
        @available(macCatalyst 17.0, *)
        @available(macOS 14.0, *)
        enum CodingKeys: String, CodingKey {
            case uid, lang
            case regionTimeZone = "region_time_zone"
            case exportTimestamp = "export_timestamp"
            case exportApp = "export_app"
            case exportAppVersion = "export_app_version"
            case srgfVersion = "srgf_version"
        }
    }

    // MARK: - List

    public struct DataEntry: AbleToCodeSendHash, Identifiable {
        // MARK: Lifecycle

        public init(
            gachaID: String,
            itemID: String,
            time: String,
            id: String,
            gachaType: GachaType,
            name: String? = nil,
            rankType: String? = nil,
            count: String? = nil,
            itemType: String? = nil
        ) {
            self.gachaID = gachaID
            self.itemID = itemID
            self.time = time
            self.id = id
            self.gachaType = gachaType
            self.name = name
            self.rankType = rankType
            self.count = count
            self.itemType = itemType
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            var error: Error?

            self.count = try container.decodeIfPresent(String.self, forKey: .count)
            if Int(count ?? "1") == nil { error = SRGFv1.makeDecodingError(CodingKeys.count) }

            self.gachaType = try container.decode(GachaType.self, forKey: .gachaType)

            self.id = try container.decode(String.self, forKey: .id)
            if Int(id) == nil { error = SRGFv1.makeDecodingError(CodingKeys.id) }

            self.itemID = try container.decode(String.self, forKey: .itemID)
            if !itemID.isInt { error = SRGFv1.makeDecodingError(CodingKeys.itemID) }

            self.itemType = try container.decodeIfPresent(String.self, forKey: .itemType)
            if itemType?.isEmpty ?? false { error = SRGFv1.makeDecodingError(CodingKeys.itemType) }

            self.gachaID = try container.decode(String.self, forKey: .gachaID)
            if Int(gachaID) == nil { error = SRGFv1.makeDecodingError(CodingKeys.gachaID) }

            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            if name?.isEmpty ?? false { error = SRGFv1.makeDecodingError(CodingKeys.name) }

            self.rankType = try container.decodeIfPresent(String.self, forKey: .rankType)
            if Int(rankType ?? "3") == nil { error = SRGFv1.makeDecodingError(CodingKeys.rankType) }

            self.time = try container.decode(String.self, forKey: .time)
            if DateFormatter.forUIGFEntry(timeZoneDelta: 0).date(from: time) == nil {
                error = SRGFv1.makeDecodingError(CodingKeys.time)
            }

            if let error = error { throw error }
        }

        // MARK: Public

        public typealias GachaType = GachaTypeHSR

        public var gachaID, itemID, time, id: String
        public var gachaType: GachaType
        public var name, rankType, count: String?
        public var itemType: String?

        // MARK: Internal

        @available(iOS 17.0, *)
        @available(macCatalyst 17.0, *)
        @available(macOS 14.0, *)
        enum CodingKeys: String, CodingKey {
            case gachaID = "gacha_id"
            case gachaType = "gacha_type"
            case itemID = "item_id"
            case count, time, name
            case itemType = "item_type"
            case rankType = "rank_type"
            case id
        }
    }
}

// MARK: - Extensions.

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1 {
    public var defaultFileNameStem: String {
        let dateFormatter = DateFormatter.forUIGFFileName
        return "SRGF_\(info.uid)_\(dateFormatter.string(from: info.maybeDateExported ?? Date()))"
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1.Info {
    public init(uid: String, lang: GachaLanguage) {
        self.uid = uid
        self.lang = lang
        self.srgfVersion = "v1.0"
        self.regionTimeZone = GachaKit.getServerTimeZoneDelta(uid: uid, game: .starRail)
        self.exportTimestamp = Int(Date.now.timeIntervalSince1970)
        self.exportApp = "UnitedPizzaHelper"
        let shortVer = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        self.exportAppVersion = shortVer ?? "1.14.514"
    }

    public var maybeDateExported: Date? {
        guard let exportTimestamp = exportTimestamp else { return nil }
        return .init(timeIntervalSince1970: Double(exportTimestamp))
    }
}

// MARK: - Translating SRGF Entry to UIGF Entry.

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4.GachaItemHSR {
    public init(fromSRGFEntry source: SRGFv1.DataEntry) {
        self = .init(
            count: source.count,
            gachaID: source.gachaID,
            gachaType: source.gachaType,
            id: source.id,
            itemID: source.itemID,
            itemType: source.itemType,
            name: source.name,
            rankType: source.rankType,
            time: source.time
        )
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1.DataEntry {
    public var asUIGFv4: UIGFv4.GachaItemHSR {
        .init(fromSRGFEntry: self)
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1 {
    public func upgradeToUIGFv4Profile() -> UIGFv4.ProfileHSR {
        .init(
            lang: info.lang,
            list: list.map(\.asUIGFv4),
            timezone: info.regionTimeZone,
            uid: info.uid
        )
    }
}

// MARK: - Translating UIGF(HSR) Entries to SRGF Entries.

/// 因为 UIGFv4 到 SRGFv1 的转换过程是无损转换，所以统一披萨引擎不再支持直接的 SRGFv1 导出。
/// 对 SRGFv1 导出的导出流程定为：先生成 UIGFv4.ProfileHSR 再转换成 SRGFv1。

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1.DataEntry {
    public init(fromUIGFv4 source: UIGFv4.GachaItemHSR) {
        self = .init(
            gachaID: source.gachaID,
            itemID: source.itemID,
            time: source.time,
            id: source.id,
            gachaType: source.gachaType,
            name: source.name,
            rankType: source.rankType,
            count: source.count,
            itemType: source.itemType
        )
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4.GachaItemHSR {
    public var asSRGFv1Item: SRGFv1.DataEntry {
        .init(fromUIGFv4: self)
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1.Info {
    public init(fromUIGFv4 source: UIGFv4.ProfileHSR) {
        self = .init(uid: source.uid, lang: source.lang ?? Locale.gachaLangauge)
        self.regionTimeZone = source.timezone
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension SRGFv1 {
    public init(fromUIGFv4 source: UIGFv4.ProfileHSR) {
        self = .init(
            info: .init(fromUIGFv4: source),
            list: source.list.map(\.asSRGFv1Item)
        )
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4.ProfileHSR {
    public var asSRGFv1: SRGFv1 {
        .init(fromUIGFv4: self)
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension UIGFv4 {
    public func extractSRGFv1() -> [SRGFv1]? {
        guard let uigfProfiles = hsrProfiles, !uigfProfiles.isEmpty else { return nil }
        return uigfProfiles.map(\.asSRGFv1)
    }
}
