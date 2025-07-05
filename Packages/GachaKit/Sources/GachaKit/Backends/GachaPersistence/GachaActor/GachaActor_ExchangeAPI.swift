// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreXLSX
import Foundation
import GachaMetaDB
import PZBaseKit
import SwiftData

// MARK: - UIGF & SRGF Exporter APIs.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GachaActor {
    public func prepareUIGFv4(
        for owners: [GachaProfileID]? = nil,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> UIGFv4 {
        var entries = [PZGachaEntrySendable]()
        var descriptor = FetchDescriptor<PZGachaEntryMO>()
        if let owners, !owners.isEmpty {
            try owners.forEach { pfID in
                let theUID = pfID.uid
                let theGame = pfID.game.rawValue
                descriptor.predicate = #Predicate { currentEntry in
                    currentEntry.game == theGame && currentEntry.uid == theUID
                }
                try modelContext.enumerate(descriptor) { entry in
                    try entry.fixTimeFieldIfNecessary(context: modelContext)
                    entries.append(entry.asSendable)
                }
            }
        } else {
            try modelContext.enumerate(descriptor) { entry in
                entries.append(entry.asSendable)
            }
        }
        return try UIGFv4(info: .init(), entries: entries, lang: lang)
    }

    public func prepareSRGFv1(
        for owner: GachaProfileID,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> SRGFv1 {
        var entries = [PZGachaEntrySendable]()
        var descriptor = FetchDescriptor<PZGachaEntryMO>()
        let theUID = owner.uid
        let theGame = owner.game.rawValue
        descriptor.predicate = #Predicate { currentEntry in
            currentEntry.game == theGame && currentEntry.uid == theUID
        }
        try modelContext.enumerate(descriptor) { entry in
            try entry.fixTimeFieldIfNecessary(context: modelContext)
            entries.append(entry.asSendable)
        }
        let uigfProfiles = try (
            entries as [any PZGachaEntryProtocol]
        ).extractProfiles(UIGFv4.GachaItemHSR.self, lang: lang) ?? []
        let srgfEntries = uigfProfiles.map(\.list).reduce([], +).map(\.asSRGFv1Item)
        return .init(info: .init(uid: owner.uid, lang: lang), list: srgfEntries)
    }

    public func prepareUIGFv4Document(
        for owners: [GachaProfileID]? = nil,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> GachaDocument {
        .init(theUIGFv4: try prepareUIGFv4(for: owners, lang: lang))
    }

    public func prepareSRGFv1Document(
        for owner: GachaProfileID,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> GachaDocument {
        .init(theSRGFv1: try prepareSRGFv1(for: owner, lang: lang))
    }

    public func prepareGachaDocument(
        for owner: GachaProfileID,
        format: GachaExchange.ExportableFormat,
        lang: GachaLanguage = Locale.gachaLangauge
    ) throws
        -> GachaDocument {
        switch format {
        case .asUIGFv4: .init(theUIGFv4: try prepareUIGFv4(for: [owner], lang: lang))
        case .asSRGFv1: .init(theSRGFv1: try prepareSRGFv1(for: owner, lang: lang))
        }
    }
}

// MARK: - UIGF & SRGF & GIGF Importer APIs.

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GachaActor {
    /// UIGFv4 抽卡记录导入专用函式，直接处理整个档案。
    @discardableResult
    public func importUIGFv4(
        _ source: UIGFv4,
        specifiedGPIDs: Set<GachaProfileID>? = nil,
        overrideDuplicatedEntries: Bool = false
    ) throws
        -> [GachaProfileID: Int] {
        var counterMap = [GachaProfileID: Int]()
        let langAlreadyEnforced = source.info.previousFormat.contains("XLSX")
        var specifiedGPIDs = specifiedGPIDs
        if specifiedGPIDs?.isEmpty ?? false {
            specifiedGPIDs = nil
        }
        if let profiles = source.giProfiles {
            try profiles.forEach { profile in
                let gpid = profile.gachaProfileID
                guard specifiedGPIDs?.contains(gpid) ?? true else { return }
                counterMap[gpid] = try importUIGFv4Profile(
                    profile,
                    overrideDuplicatedEntries: overrideDuplicatedEntries,
                    languageAlreadyEnforced: langAlreadyEnforced
                )
            }
        }
        if let profiles = source.hsrProfiles {
            try profiles.forEach { profile in
                let gpid = profile.gachaProfileID
                guard specifiedGPIDs?.contains(gpid) ?? true else { return }
                counterMap[gpid] = try importUIGFv4Profile(
                    profile,
                    overrideDuplicatedEntries: overrideDuplicatedEntries
                )
            }
        }
        if let profiles = source.zzzProfiles {
            try profiles.forEach { profile in
                let gpid = profile.gachaProfileID
                guard specifiedGPIDs?.contains(gpid) ?? true else { return }
                counterMap[gpid] = try importUIGFv4Profile(
                    profile,
                    overrideDuplicatedEntries: overrideDuplicatedEntries
                )
            }
        }
        try refreshAllProfiles()
        return counterMap
    }

    /// UIGFv4 抽卡记录导入专用函式（以 Profile 为单位）。
    /// 时差需要专门处理，一律转换为伺服器时间。
    ///
    /// GIGF 格式的抽卡记录会在升级为 UIGFv4 的过程中自动将语言转为简体中文，
    /// 所以 languageAlreadyEnforced 填 true 略过语言处理。
    @discardableResult
    public func importUIGFv4Profile<T: UIGFGachaItemProtocol>(
        _ source: UIGFv4.Profile<T>,
        overrideDuplicatedEntries: Bool = false,
        languageAlreadyEnforced: Bool = false
    ) throws
        -> Int {
        let uid = source.uid
        let game = T.game
        let importedTimeZoneDelta = source.timezone
        let serverTimeZoneDelta = GachaKit.getServerTimeZoneDelta(uid: uid, game: game)
        let needsTimeFix: Bool = importedTimeZoneDelta != serverTimeZoneDelta
        let dateFormatter4Import = DateFormatter.forUIGFEntry(timeZoneDelta: importedTimeZoneDelta)
        let dateFormatter4Server = DateFormatter.forUIGFEntry(timeZoneDelta: serverTimeZoneDelta)
        // --------------
        func fixTime(_ timeStr: inout String) throws {
            guard needsTimeFix else { return }
            try Date.shiftUIGFTimeStampTimeZone(
                formatterOld: dateFormatter4Import,
                formatterNew: dateFormatter4Server,
                against: &timeStr
            )
        }
        // --------------
        var list = source.list
        // 原神的抽卡记录在披萨系列 App 内部必须以简体中文存储物品名称，以便在万一时恢复 ItemID。
        if game == .genshinImpact, !languageAlreadyEnforced { try list.updateLanguage(.langCHS) }
        let sendableEntries = try list.map { uigfEntry in
            var uigfEntry = uigfEntry
            try fixTime(&uigfEntry.time)
            return uigfEntry.asPZGachaEntrySendable(uid: uid)
        }
        return try batchInsert(sendableEntries, overrideDuplicatedEntries: overrideDuplicatedEntries)
    }

    /// 星穹铁道抽卡记录的格式升級专用函式。所有 Entry 都会转换为 UIGFv4 Entry 再导入资料库。
    /// SRGFv1 的格式升级不需要处理额外的事项，所以对 GachaMetaDB 没有要求。
    /// 时差需要专门处理，一律转换为伺服器时间。
    @discardableResult
    public func upgradeToUIGFv4(srgf source: SRGFv1) throws -> UIGFv4 {
        // 星穹铁道的抽卡记录不需要将语言强制转为简体中文，所以 languageAlreadyEnforced 填 true 略过语言处理。
        let newProfile = source.upgradeToUIGFv4Profile()
        let info = UIGFv4.Info(
            exportApp: source.info.exportApp ?? "N/A",
            exportAppVersion: source.info.exportAppVersion ?? "N/A",
            exportTimestamp: source.info.exportTimestamp?.description ?? "N/A",
            previousFormat: "SRGF \(source.info.srgfVersion)"
        )
        return .init(info: info, hsrProfiles: [newProfile])
    }

    /// 原神 GIGF 格式（JSON）的格式升級专用函式。所有 Entry 都会转换为 UIGFv4 Entry 再导入资料库。
    /// GIGF (Genshin Impact Gacha-Exchangeable Format) 代指 UIGF v3.0 及之前的旧版格式，只能给原神用。
    @discardableResult
    public func upgradeToUIGFv4(gigf source: GIGF) throws -> UIGFv4 {
        let newProfile = source.upgradeToUIGFv4Profile()
        let info = UIGFv4.Info(
            exportApp: source.info.exportApp ?? "N/A",
            exportAppVersion: source.info.exportAppVersion ?? "N/A",
            exportTimestamp: source.info.exportTimestamp?.description ?? "N/A",
            previousFormat: "GIGF \(source.info.uigfVersion ?? "v2.2-v3.0 (JSON)")"
        )
        return .init(info: info, giProfiles: [newProfile])
    }

    /// 原神 GIGF 格式（Excel XLSX）导入专用函式。
    /// GIGF (Genshin Impact Gacha-Exchangeable Format) 代指 UIGF v3.0 及之前的旧版格式，只能给原神用。
    /// XLSX 的格式版本最高为 UIGF v2.2、且没有时区资讯。
    /// 有些 App (例：提瓦特小助手) 会在导出这个格式时乱改时区。
    /// 敝 App 没有处理非整数时区的 GIGF 档案的能力。
    public func upgradeToUIGFv4(xlsx source: XLSXFile) throws -> UIGFv4 {
        let profiles = try source.parseItems().giProfiles
        let info = UIGFv4.Info(
            exportApp: "N/A",
            exportAppVersion: "N/A",
            exportTimestamp: "N/A",
            previousFormat: "GIGF v2.0-v2.2 (XLSX)"
        )
        return .init(info: info, giProfiles: profiles)
    }
}
