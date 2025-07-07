// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels
import PZBaseKit

// MARK: - Enka.CharacterName

@available(iOS 17.0, macCatalyst 17.0, *)
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

        /// Used for EnkaDB.
        public func getGenshinProtagonistSkillDepotID(element: Enka.GameElement) -> Int? {
            let trailingNumber = getGenshinProtagonistSharedSkillDepotID(element: element)
            guard let trailingNumber else { return nil }
            return switch self {
            case .protagonist(.ofLumine): trailingNumber + 700
            case .protagonist(.ofAether): trailingNumber + 500
            default: nil
            }
        }

        /// Used for Hakush.in APIs.
        public func getGenshinProtagonistSharedSkillDepotID(element: Enka.GameElement) -> Int? {
            if case let .protagonist(name) = self {
                guard [.ofLumine, .ofAether].contains(name) else { return nil }
            }
            return switch (element, self) {
            case (.anemo, .protagonist): 4
            case (.geo, .protagonist): 6
            case (.electro, .protagonist): 7
            case (.dendro, .protagonist): 8
            case (.hydro, .protagonist): 3
            case (.pyro, .protagonist): 2
            case (.cryo, .protagonist): 5 // Deducted, might need fix in the future.
            default: nil
            }
        }
    }
}

// MARK: - Enka.CharacterName + RawRepresentable, AbleToCodeSendHash

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.CharacterName: RawRepresentable, AbleToCodeSendHash {
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
        case let .someoneElse(name): name
        case let .protagonist(protagonist):
            switch protagonist {
            case .ofCaelus: "8001"
            case .ofStelle: "8002"
            case .ofAether: "10000005"
            case .ofLumine: "10000007"
            }
        }
    }
}

// MARK: - Enka.CharacterName + Identifiable

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.CharacterName: Identifiable {
    public var id: String { rawValue }
}

// MARK: - Enka.CharacterName + CustomStringConvertible

@available(iOS 17.0, macCatalyst 17.0, *)
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
