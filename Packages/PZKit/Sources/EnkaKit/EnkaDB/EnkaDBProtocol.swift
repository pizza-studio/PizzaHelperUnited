// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation

// MARK: - EnkaDBProtocol

public protocol EnkaDBProtocol {
    associatedtype QueriedProfile = EKQueriedProfileProtocol

    var game: Enka.GameType { get }
    var locTable: Enka.LocTable { get set }
    var locTag: String { get }
    var isExpired: Bool { get set }

    init(host: Enka.HostType) async throws

    func getNameTextMapHash(id: String) -> String?
    func checkIfExpired(against givenProfile: QueriedProfile) -> Bool

    @MainActor
    func saveSelfToUserDefaults()

    @MainActor
    mutating func update(new: Self)
}

// MARK: - Online Update.

extension EnkaDBProtocol {
    var needsUpdate: Bool {
        let previousDate = Defaults[.lastEnkaDBDataCheckDate]
        let expired = Calendar.current.date(byAdding: .hour, value: 2, to: previousDate)! < Date()
        return expired || Enka.currentLangTag != locTag
    }

    @MainActor
    @discardableResult
    mutating func onlineUpdate(forced: Bool = false) async throws -> Self {
        let newDB = try await Self(host: Defaults[.defaultDBQueryHost])
        newDB.saveSelfToUserDefaults()
        Defaults[.lastEnkaDBDataCheckDate] = Date()
        update(new: newDB)
        return self
    }
}

// MARK: - Translation APIs.

extension EnkaDBProtocol {
    func getTranslationFor(id: String, realName: Bool = true) -> String {
        if realName, let matchedRealName = Enka.JSONType.bundledRealNameTable[locTag]?[id] {
            return matchedRealName
        }
        let missingTranslation = "i18nMissing(id:\(id))"
        if let hash = getNameTextMapHash(id: id) {
            return locTable[hash] ?? missingTranslation
        } else {
            return locTable[id] ?? missingTranslation
        }
    }

    func getTranslationFor(property: Enka.PropertyType) -> String? {
        if let realNameMap = Enka.JSONType.bundledRealNameTable[locTag],
           let matchedRealName = realNameMap[property.rawValue] {
            return matchedRealName
        }
        return locTable[property.rawValue]
    }
}
