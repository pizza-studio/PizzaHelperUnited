// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - EnkaDBProtocol

public protocol EnkaDBProtocol {
    associatedtype This = EnkaDBProtocol
    var game: Enka.GameType { get }
    var locTable: Enka.LocTable { get set }
    var locTag: String { get }
    var isExpired: Bool { get set }
    func getNameTextMapHash(id: String) -> String?

    init(host: Enka.HostType) async throws

    @MainActor
    mutating func update(new: This)
}

extension EnkaDBProtocol {
    func getTranslationFor(id: String) -> String {
        if let realNameMap = Enka.JSONType.bundledRealNameTable[locTag],
           let matchedRealName = realNameMap[id] {
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
