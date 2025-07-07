// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - ArtifactRatingOptions

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating {
    /// 圣遗物评分时的例外选项的处理，仅适用于原神。
    ///
    /// 原神很多角色可以开发出离经叛道的有效玩法。
    /// 比如说雷电将军低命座可以用影芙妲白打全自动脱手超绽放，此时元素精通是雷电将军的最有效的词条。
    /// 这类需求使得对原神的雷系角色不能只用一套固定的静态圣遗物评分模型来处理。
    public struct Rules: OptionSet, Sendable {
        // MARK: Lifecycle

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        // MARK: Public

        public static let allDisabled = Self([])
        public static let allEnabled = Self([.enabled, .considerSwirls, .considerHyperbloomElectroRoles])
        public static let enabled = Self(rawValue: 1 << 0)
        public static let considerSwirls = Self(rawValue: 1 << 1) // 如雷万葉
        public static let considerHyperbloomElectroRoles = Self(rawValue: 1 << 2) // 千精雷军

        public let rawValue: Int
    }
}
