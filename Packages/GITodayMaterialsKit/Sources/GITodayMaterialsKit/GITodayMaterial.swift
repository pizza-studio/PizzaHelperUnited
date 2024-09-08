// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - GITodayMaterial

public struct GITodayMaterial: Codable, Identifiable, Equatable, Hashable {
    public let id: Int
    public let isWeapon: Bool
    public let nameTag: String
    public var costedBy: [String]
}

extension GITodayMaterial {
    public var localized: String {
        "asset.dailyMaterial:\(nameTag)".i18nTodayMaterialNames
    }

    public var availableWeekDay: AvailableWeekDay? {
        .init(rawValue: id % 3) ?? nil
    }

    public enum AvailableWeekDay: Int, CaseIterable, Identifiable, Hashable, Equatable {
        case MonThu = 0
        case TueFri = 1
        case WedSat = 2

        // MARK: Public

        public var id: Int { rawValue }
    }
}
