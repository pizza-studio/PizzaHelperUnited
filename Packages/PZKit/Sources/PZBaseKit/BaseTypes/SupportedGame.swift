// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - Pizza.SupportedGame

extension Pizza {
    public enum SupportedGame: String, Sendable, Identifiable, Hashable, Codable, CaseIterable, Equatable {
        case genshinImpact = "GI"
        case starRail = "HSR"

        // MARK: Public

        public var id: String { rawValue }

        public var localizedShortName: String {
            switch self {
            case .genshinImpact: "game.genshin.shortNameEX".i18nBaseKit
            case .starRail: "game.starRail.shortNameEX".i18nBaseKit
            }
        }

        public var uidPrefix: String {
            switch self {
            case .genshinImpact: "GI"
            case .starRail: "SR"
            }
        }

        public var viseVersa: Self {
            switch self {
            case .genshinImpact: .starRail
            case .starRail: .genshinImpact
            }
        }
    }
}

// MARK: - Pizza.SupportedGame + CustomStringConvertible

extension Pizza.SupportedGame: CustomStringConvertible {
    public var description: String {
        localizedDescription
    }

    public var localizedDescription: String {
        switch self {
        case .genshinImpact: "game.genshin.i18nName".i18nBaseKit
        case .starRail: "game.starRail.i18nName".i18nBaseKit
        }
    }

    /// 带书名号的产品名。
    public var titleMarkedName: String {
        switch self {
        case .genshinImpact: "game.genshin.titleMarkedName".i18nBaseKit
        case .starRail: "game.starRail.titleMarkedName".i18nBaseKit
        }
    }
}

extension Pizza.SupportedGame? {
    public var localizedShortName: String {
        self?.localizedShortName ?? "game.all.shortNameEX".i18nBaseKit
    }
}
