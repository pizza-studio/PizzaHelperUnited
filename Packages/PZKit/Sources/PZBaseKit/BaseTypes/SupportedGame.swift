// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - Pizza.SupportedGame

extension Pizza {
    public enum SupportedGame: String, Sendable, Identifiable, Hashable, Codable, CaseIterable, Equatable {
        case genshinImpact = "GI"
        case starRail = "HSR"
        case zenlessZone = "ZZZ"

        // MARK: Lifecycle

        public init?(uidPrefix: String) {
            let matched = Self.allCases.first { $0.uidPrefix == uidPrefix }
            guard let matched else { return nil }
            self = matched
        }

        // MARK: Public

        public var id: String { rawValue }

        @available(iOS 15.0, macCatalyst 15.0, *) public var localizedShortName: String {
            switch self {
            case .genshinImpact: "game.genshin.shortNameEX".i18nBaseKit
            case .starRail: "game.starRail.shortNameEX".i18nBaseKit
            case .zenlessZone: "game.zenlessZone.shortNameEX".i18nBaseKit
            }
        }

        // Needed when interating with MiHoYo API.
        public var hoyoBizID: String {
            switch self {
            case .genshinImpact: "hk4e"
            case .starRail: "hkrpg"
            case .zenlessZone: "nap"
            }
        }

        public var uidPrefix: String {
            switch self {
            case .genshinImpact: "GI"
            case .starRail: "SR"
            case .zenlessZone: "ZZ"
            }
        }

        public var nextIteration: Self {
            switch self {
            case .genshinImpact: .starRail
            case .starRail: .zenlessZone
            case .zenlessZone: .genshinImpact
            }
        }

        // 生成带有游戏标识码的 UID。
        public func with(uid: String) -> String {
            "\(uidPrefix)-\(uid)"
        }
    }
}

// MARK: - Pizza.SupportedGame + CustomStringConvertible

@available(iOS 15.0, macCatalyst 15.0, *)
extension Pizza.SupportedGame: CustomStringConvertible {
    public var description: String {
        localizedDescription
    }

    public var localizedDescription: String {
        switch self {
        case .genshinImpact: "game.genshin.i18nName".i18nBaseKit
        case .starRail: "game.starRail.i18nName".i18nBaseKit
        case .zenlessZone: "game.zenlessZone.i18nName".i18nBaseKit
        }
    }

    /// Specifically used for Segmented Pickers when `localizedShortName` is too short.
    public var localizedDescriptionTrimmed: String {
        switch self {
        case .genshinImpact: "game.genshin.i18nNameTrimmed".i18nBaseKit
        case .starRail: "game.starRail.i18nNameTrimmed".i18nBaseKit
        case .zenlessZone: "game.zenlessZone.i18nNameTrimmed".i18nBaseKit
        }
    }

    /// 带书名号的产品名。
    public var titleMarkedName: String {
        switch self {
        case .genshinImpact: "game.genshin.titleMarkedName".i18nBaseKit
        case .starRail: "game.starRail.titleMarkedName".i18nBaseKit
        case .zenlessZone: "game.zenlessZone.titleMarkedName".i18nBaseKit
        }
    }
}

@available(iOS 15.0, macCatalyst 15.0, *)
extension Pizza.SupportedGame? {
    public var localizedShortName: String {
        self?.localizedShortName ?? "game.all.shortNameEX".i18nBaseKit
    }
}

// MARK: - Pizza.SupportedGame + Comparable

extension Pizza.SupportedGame: Comparable {
    public static func < (lhs: Pizza.SupportedGame, rhs: Pizza.SupportedGame) -> Bool {
        lhs.caseIndex < rhs.caseIndex
    }

    public var caseIndex: Int {
        Self.allCases.enumerated().first(where: { $0.element == self })?.offset ?? 0
    }
}
