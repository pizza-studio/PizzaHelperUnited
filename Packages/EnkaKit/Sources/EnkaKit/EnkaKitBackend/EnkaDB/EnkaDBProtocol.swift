// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

// MARK: - EnkaDBProtocol

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

    func getCachedProfileRAW(uid: String) -> QueriedProfile? {
        QueriedProfile.getCachedProfile(uid: uid)
    }

    @MainActor
    public func query(
        for uid: String,
        dateWhenNextRefreshable nextAvailableDate: Date? = nil
    ) async throws
        -> Self.QueriedProfile {
        let existingData = QueriedProfile.locallyCachedData[uid]
        do {
            let detailInfo = try await QueriedResult.queryProfile(uid: uid, dateWhenNextRefreshable: nextAvailableDate)
            let newMerged = detailInfo.inheritAvatars(from: existingData)
            QueriedProfile.locallyCachedData[uid] = newMerged
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
            if result == "钟离" {
                return "锺离"
            } else if result.contains("钟离") {
                return result.replacingOccurrences(of: "钟离", with: "锺离")
            }
        } else if Locale.isUILanguageTraditionalChinese {
            if result == "霧切之回光" {
                return "霧切之迴光"
            }
            if result.contains("堇") {
                return result.replacingOccurrences(of: "堇", with: "菫")
            }
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
