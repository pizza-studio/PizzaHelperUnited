// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels

// MARK: - Enka.CharacterName

extension Enka {
    public enum CharacterName {
        case protagonist(Protagonist)
        case someoneElse(pid: String)

        // MARK: Public

        public var game: Enka.GameType {
            switch self {
            case let .protagonist(protagonist):
                switch protagonist {
                case .ofAether, .ofLumine: .genshinImpact
                default: .starRail
                }
            case let .someoneElse(pid): pid.count == 4 ? .starRail : .genshinImpact
            }
        }

        /// 仅用于将星穹铁道的主角的不同命途的肖像专门回退检索到相同的素材上。
        public static func convertPIDForHSRProtagonist(_ pid: String) -> String {
            guard pid.count == 4, let first = pid.first, first == "8" else { return pid }
            guard let last = pid.last?.description, var lastDigi = Int(last) else { return pid }
            guard lastDigi >= 1 else { return pid }
            lastDigi = lastDigi % 2
            if lastDigi == 0 { lastDigi += 2 }
            return String(pid.dropLast()) + lastDigi.description
        }
    }
}

// MARK: - Enka.CharacterName + RawRepresentable, Hashable, Codable, Sendable

extension Enka.CharacterName: RawRepresentable, Hashable, Codable, Sendable {
    public init(pid: Int) {
        self = Enka.CharacterName(rawValue: pid.description)
    }

    public init(pidStr: String) {
        self = Enka.CharacterName(rawValue: pidStr)
    }

    public init(rawValue: String) {
        // 原神的 charID 的数字是前八位，剩下的字串位数用来判断主角的元素属性。
        // 所以只看最多前八位。
        if let rawIntValue = Int(rawValue.prefix(8)),
           let matchedProtagonist = Protagonist(rawValue: rawIntValue) {
            self = .protagonist(matchedProtagonist)
        } else {
            self = .someoneElse(pid: rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case let .someoneElse(name): return name
        case let .protagonist(protagonist):
            switch protagonist {
            case .ofCaelus: return "8001"
            case .ofStelle: return "8002"
            case .ofAether: return "10000005"
            case .ofLumine: return "10000007"
            }
        }
    }
}

// MARK: - Enka.CharacterName + Identifiable

extension Enka.CharacterName: Identifiable {
    public var id: String { rawValue }
}

// MARK: - Enka.CharacterName + CustomStringConvertible

extension Enka.CharacterName: CustomStringConvertible {
    public var description: String {
        getDescription(officialName: false)
    }

    public var officialDescription: String {
        getDescription(officialName: true)
    }

    private func getDescription(officialName: Bool) -> String {
        switch self {
        case let .someoneElse(pid):
            switch pid.count {
            case 4: Enka.Sputnik.shared.db4HSR.getTranslationFor(id: pid, realName: !officialName)
            case 8: Enka.Sputnik.shared.db4GI.getTranslationFor(id: pid, realName: !officialName)
            default: "CharID:\(pid)"
            }
        case let .protagonist(protagonist):
            protagonist.nameTranslationDict[Enka.currentWebAPILangTag] ?? String(describing: protagonist)
        }
    }

    public func i18n(theDB: (some EnkaDBProtocol)? = nil, officialNameOnly: Bool = false) -> String {
        guard let theDB = theDB else { return getDescription(officialName: officialNameOnly) }
        switch self {
        case let .protagonist(protagonist):
            let newLangTag = Enka.convertLangTagToWebAPILangTag(oldTag: theDB.locTag)
            return protagonist.nameTranslationDict[newLangTag] ?? String(describing: protagonist)
        case let .someoneElse(pid):
            return theDB.getTranslationFor(id: pid, realName: !officialNameOnly)
        }
    }
}
