// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - PZCoreDataKit.CDStoredGame

extension PZCoreDataKit {
    public enum CDStoredGame: String, Sendable, Identifiable, Hashable, Codable, CaseIterable, Equatable {
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

// MARK: - PZCoreDataKit.CDStoredGame + Comparable

extension PZCoreDataKit.CDStoredGame: Comparable {
    public static func < (lhs: PZCoreDataKit.CDStoredGame, rhs: PZCoreDataKit.CDStoredGame) -> Bool {
        lhs.caseIndex < rhs.caseIndex
    }

    public var caseIndex: Int {
        Self.allCases.enumerated().first(where: { $0.element == self })?.offset ?? 0
    }
}

// MARK: - CDStoredGameAssignable

public protocol CDStoredGameAssignable {
    static var cdStoredGame: PZCoreDataKit.CDStoredGame { get }
}

extension CDStoredGameAssignable {
    public var cdStoredGame: PZCoreDataKit.CDStoredGame { Self.cdStoredGame }
}
