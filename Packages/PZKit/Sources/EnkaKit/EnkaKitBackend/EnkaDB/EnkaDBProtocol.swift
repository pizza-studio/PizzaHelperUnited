// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

// MARK: - EnkaDBProtocol

public protocol EnkaDBProtocol {
    associatedtype QueriedResult: EKQueryResultProtocol
    static var game: Enka.GameType { get }
    var locTable: Enka.LocTable { get set }
    var locTag: String { get }
    var isExpired: Bool { get set }

    @MainActor static var shared: Self { get }

    init(host: Enka.HostType) async throws
    init(locTag: String?)

    func getNameTextMapHash(id: String) -> String?
    func checkIfExpired(against givenProfile: QueriedProfile) -> Bool

    @MainActor
    func saveSelfToUserDefaults()

    @MainActor
    mutating func update(new: Self)
}

// MARK: - Online Update & Query.

extension EnkaDBProtocol {
    public init(locTag: String? = nil) {
        self.init(locTag: locTag)
    }

    public typealias QueriedProfile = QueriedResult.QueriedProfileType
    public var game: Enka.GameType { Self.game }
    public var needsUpdate: Bool {
        let previousDate = Defaults[.lastEnkaDBDataCheckDate]
        let expired = Calendar.current.date(byAdding: .hour, value: 2, to: previousDate)! < Date()
        return expired || Enka.currentLangTag != locTag
    }

    @MainActor
    @discardableResult
    mutating public func onlineUpdate(forced: Bool = false) async throws -> Self {
        let newDB = try await Self(host: Defaults[.defaultDBQueryHost])
        newDB.saveSelfToUserDefaults()
        Defaults[.lastEnkaDBDataCheckDate] = Date()
        update(new: newDB)
        return self
    }

    public func query(
        for uid: String,
        dateWhenNextRefreshable nextAvailableDate: Date? = nil
    ) async throws
        -> Self.QueriedProfile {
        let existingData = QueriedProfile.locallyCachedData[uid]
        do {
            let newData = try await Enka.Sputnik.fetchEnkaQueryResultRAW(
                uid, type: QueriedResult.self, dateWhenNextRefreshable: nextAvailableDate
            )
            guard let detailInfo = newData.detailInfo else {
                let errMsgCore = newData.message ?? "No Error Message is Given."
                throw Enka.EKError.queryFailure(uid: uid, game: QueriedResult.game, message: errMsgCore)
            }
            let newMerged = detailInfo.inheritAvatars(from: existingData)
            QueriedProfile.locallyCachedData[uid] = newMerged
            return newMerged
        } catch {
            let msg = error.localizedDescription
            print(msg)
            throw Enka.EKError.queryFailure(uid: uid, game: QueriedResult.game, message: msg)
        }
    }
}

// MARK: - Translation APIs.

extension EnkaDBProtocol {
    func getTranslationFor(id: String, realName: Bool = true) -> String {
        if realName, let matchedRealName = Enka.JSONType.bundledRealNameTable[locTag]?[id] {
            return matchedRealName
        } else if ["10000075", "3230559562"].contains(id), !Defaults[.customizedNameForWanderer].isEmpty {
            return Defaults[.customizedNameForWanderer]
        }
        let missingTranslation = "i18nMissing(id:\(id))"
        if let hash = getNameTextMapHash(id: id) {
            return locTable[hash] ?? missingTranslation
        } else {
            return locTable[id] ?? missingTranslation
        }
    }

    func getFailableTranslationFor(id: String, realName: Bool = true) -> String? {
        if realName, let matchedRealName = Enka.JSONType.bundledRealNameTable[locTag]?[id] {
            return matchedRealName
        }
        if let hash = getNameTextMapHash(id: id) {
            return locTable[hash]
        } else {
            return locTable[id]
        }
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
