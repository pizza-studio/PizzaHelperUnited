// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - PZCoreDataKit.StoredGame

extension PZCoreDataKit {
    public enum StoredGame: String, Sendable, Identifiable, Hashable, Codable, CaseIterable, Equatable {
        case genshinImpact = "GI"
        case starRail = "HSR"

        // MARK: Lifecycle

        public init?(uidPrefix: String) {
            let matched = Self.allCases.first { $0.uidPrefix == uidPrefix }
            guard let matched else { return nil }
            self = matched
        }

        // MARK: Public

        public var id: String { rawValue }

        public var uidPrefix: String {
            switch self {
            case .genshinImpact: "GI"
            case .starRail: "SR"
            }
        }

        public var titleFullInEnglish: String {
            switch self {
            case .genshinImpact: "Genshin Impact"
            case .starRail: "Star Rail"
            }
        }

        public var nextIteration: Self {
            switch self {
            case .genshinImpact: .starRail
            case .starRail: .genshinImpact
            }
        }

        // 生成带有游戏标识码的 UID。
        public func with(uid: String) -> String {
            "\(uidPrefix)-\(uid)"
        }
    }
}

// MARK: - PZCoreDataKit.StoredGame + Comparable

extension PZCoreDataKit.StoredGame: Comparable {
    public static func < (lhs: PZCoreDataKit.StoredGame, rhs: PZCoreDataKit.StoredGame) -> Bool {
        lhs.caseIndex < rhs.caseIndex
    }

    public var caseIndex: Int {
        Self.allCases.enumerated().first(where: { $0.element == self })?.offset ?? 0
    }
}

// MARK: - CDStoredGameAssignable

public protocol CDStoredGameAssignable {
    static var storedGame: PZCoreDataKit.StoredGame { get }
}

extension CDStoredGameAssignable {
    public var storedGame: PZCoreDataKit.StoredGame { Self.storedGame }
}
