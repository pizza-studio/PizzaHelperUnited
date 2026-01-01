// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import PZBaseKit

// MARK: - EnkaDBProtocol

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol EnkaDBProtocol: AnyObject, Sendable {
    associatedtype QueriedResult: EKQueryResultProtocol where QueriedResult.DBType == Self
    associatedtype QueriedProfile: EKQueriedProfileProtocol where QueriedProfile.DBType == Self
    associatedtype HYLAvatarDetailType: HYQueriedAvatarProtocol where HYLAvatarDetailType.DBType == Self
    static var game: Enka.GameType { get }
    var locTable: Enka.LocTable { get set }
    var locTag: String { get }
    var isExpired: Bool { get set }

    @MainActor static var shared: Self { get }

    init(host: Enka.HostType) async throws
    init(locTag: String?) throws

    func getNameTextMapHash(id: String) -> String?
    func checkIfExpired(against givenProfile: QueriedProfile) -> Bool

    @MainActor
    func saveSelfToUserDefaults()

    @MainActor
    func update(new: Self)
}

// MARK: - Online Update & Query.

@available(iOS 17.0, macCatalyst 17.0, *)
extension EnkaDBProtocol {
    public typealias QueriedAvatar = QueriedProfile.QueriedAvatar
    public typealias SummarizedType = Enka.ProfileSummarized<Self>

    public var game: Enka.GameType { Self.game }

    /// 这个 Symbol 目前还没派上用场，回头得另议与此有关的处置方案。
    public var needsUpdate: Bool {
        let previousDate = Defaults[.lastEnkaDBDataCheckDate]
        let expired = Calendar.gregorian.date(byAdding: .hour, value: 2, to: previousDate)! < Date()
        return expired || Enka.currentLangTag != locTag
    }

    @MainActor
    @discardableResult
    public func reinit() throws -> Self {
        let newDB = try Self(locTag: Enka.currentLangTag)
        newDB.saveSelfToUserDefaults()
        update(new: newDB)
        return self
    }

    @MainActor
    @discardableResult
    public func reinitOnlyIfBundledDBIsNewer() throws -> Self {
        let bundledDB = try Self(locTag: Enka.currentLangTag)
        guard bundledDB.locTable.count > locTable.count else { return self }
        bundledDB.saveSelfToUserDefaults()
        update(new: bundledDB)
        return self
    }

    @MainActor
    @discardableResult
    public func onlineUpdate() async throws -> Self {
        let newDB = try await Self(host: Defaults[.defaultDBQueryHost])
        newDB.saveSelfToUserDefaults()
        Defaults[.lastEnkaDBDataCheckDate] = Date()
        update(new: newDB)
        return self
    }

    public func getCachedProfileRAW(uid: String) -> QueriedProfile? {
        QueriedProfile.getCachedProfile(uid: uid)
    }

    public func removeCachedProfileRAW(uid: String) {
        QueriedProfile.removeCachedProfile(uid: uid)
    }

    public func getAllCachedProfiles() -> [String: QueriedProfile] {
        QueriedProfile.getAllCachedProfiles()
    }

    @MainActor
    public func query(
        for uid: String,
        dateWhenNextRefreshable nextAvailableDate: Date? = nil
    ) async throws
        -> Self.QueriedProfile {
        let existingData = QueriedProfile.getCachedProfile(uid: uid)
        do {
            let detailInfo = try await QueriedResult.queryProfile(uid: uid, dateWhenNextRefreshable: nextAvailableDate)
            let newMerged = detailInfo.inheritAvatars(from: existingData)
            newMerged.saveToCache()
            return newMerged
        } catch {
            let msg = error.localizedDescription + "\n-------\n// \(error)"
            print(msg)
            switch error {
            case Enka.EKError.queryFailure: throw error
            default: throw Enka.EKError.queryFailure(uid: uid, game: QueriedResult.game, message: msg)
            }
        }
    }
}

// MARK: - Translation APIs.

@available(iOS 17.0, macCatalyst 17.0, *)
extension EnkaDBProtocol {
    public var locTagMismatchingTheSystem: Bool {
        Enka.currentLangTag != locTag
    }

    public func reinitIfLocMismatches() async throws {
        guard locTagMismatchingTheSystem else { return }
        try await reinit()
    }

    public func getFailableTranslationFor(id: String, realName: Bool = true) -> String? {
        var id = id
        if game == .genshinImpact {
            id = id.split(separator: "_").first?.description ?? id
        }
        // 处理雷电国崩的自订姓名。
        if realName, let matchedRealName = Enka.JSONType.bundledRealNameTable[locTag]?[id] {
            return matchedRealName
        } else if ["10000075", "3230559562"].contains(id), !Defaults[.customizedNameForWanderer].isEmpty {
            return Defaults[.customizedNameForWanderer]
        }
        // 正常处理。
        let result: String? = if let hash = getNameTextMapHash(id: id) {
            locTable[hash]
        } else {
            locTable[id]
        }
        guard Defaults[.forceCharacterWeaponNameFixed] else { return result }
        guard let result else { return nil }
        if Locale.isUILanguageSimplifiedChinese {
            return Enka.kanjiFixTableCHS[result] ?? result
        } else if Locale.isUILanguageTraditionalChinese {
            return Enka.kanjiFixTableCHT[result] ?? result
        }
        return result
    }

    func getTranslationFor(id: String, realName: Bool = true) -> String {
        let missingTranslation = "i18nMissing(id:\(id))"
        return getFailableTranslationFor(id: id, realName: realName) ?? missingTranslation
    }

    func getTranslationFor(property: Enka.PropertyType) -> String? {
        if let realNameMap = Enka.JSONType.bundledRealNameTable[locTag],
           let matchedRealName = realNameMap[property.rawValue] {
            return matchedRealName
        }
        return locTable[property.rawValue]
    }

    var additionalLocTable: [String: String] {
        Enka.JSONType.bundledExtraLangTable[locTag] ?? [:]
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    fileprivate static let kanjiFixTableCHS: [String: String] = [
        "钟离": "锺离",
        "芙宁娜": "芙黎娜", // 得分清ㄋㄌ。
        "希诺宁": "希洛宁", // 得分清ㄋㄌ。
        "艾尔海森": "阿尔海森",
    ]

    fileprivate static let kanjiFixTableCHT: [String: String] = [
        "雲堇": "雲菫",
        "風堇": "風菫",
        "霧切之回光": "霧切之迴光",
        "芙寧娜": "芙黎娜", // 得分清ㄋㄌ。
        "希諾寧": "希洛寧", // 得分清ㄋㄌ。
        "茜特菈莉": "菥特菈莉", // 「茜」在港澳台不是多音字，没有「西」音。
        "艾爾海森": "阿爾海森",
    ]
}
