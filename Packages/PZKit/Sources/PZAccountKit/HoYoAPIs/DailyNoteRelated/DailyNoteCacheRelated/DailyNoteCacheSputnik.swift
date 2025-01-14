// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

extension PZProfileSendable {
    public func clearDailyNoteCache() {
        Defaults[.cachedDailyNotes].removeValue(forKey: uidWithGame)
    }
}

extension DailyNoteProtocol {
    typealias CacheSputnik = DailyNoteCacheSputnik<Self>
}

// MARK: - DailyNoteCacheSputnik

public struct DailyNoteCacheSputnik<T: DailyNoteProtocol> {
    public static func cache(_ data: Data, uidWithGame: String) {
        guard let dataStr = String(data: data, encoding: .utf8) else { return }
        Defaults[.cachedDailyNotes][uidWithGame] = .init(rawJSONString: dataStr)
    }

    public static func getCache(uidWithGame: String) -> T? {
        guard let package = Defaults[.cachedDailyNotes][uidWithGame] else { return nil }
        let cachedTimestamp = package.timestamp
        let currentTimestamp = Date.now.timeIntervalSince1970
        guard cachedTimestamp + T.game.eachStaminaRecoveryTime > currentTimestamp else { return nil }
        guard let data = package.rawJSONString.data(using: .utf8) else { return nil }
        let decoded = try? T.decodeFromMiHoYoAPIJSONResult(
            data: data, debugTag: "DailyNoteCacheSputnik.getCache()"
        )
        return decoded
    }
}

// MARK: - CachedJSON

public struct CachedJSON: AbleToCodeSendHash, Defaults.Serializable {
    // MARK: Lifecycle

    public init(rawJSONString: String, timestamp: TimeInterval? = nil) {
        self.rawJSONString = rawJSONString
        self.timestamp = timestamp ?? Date.now.timeIntervalSince1970
    }

    // MARK: Public

    public let rawJSONString: String
    public let timestamp: TimeInterval

    public var cachedTime: Date { .init(timeIntervalSince1970: timestamp) }
}
