// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - GITodayMaterial

public struct GITodayMaterial: AbleToCodeSendHash, Identifiable, Equatable {
    public let id: Int
    public let isWeapon: Bool
    public let nameTag: String
    public var costedBy: [String]
}

extension GITodayMaterial {
    public var iconObj: Image { Image(nameTag, bundle: .module) }

    public var localized: String {
        "asset.dailyMaterial:\(nameTag)".i18nTodayMaterialNames
    }

    public var availableWeekDay: AvailableWeekDay? {
        .init(rawValue: id % 3) ?? nil
    }

    public enum AvailableWeekDay: Int, CaseIterable, Identifiable, AbleToCodeSendHash {
        case MonThu = 0
        case TueFri = 1
        case WedSat = 2

        // MARK: Public

        public var id: Int { rawValue }

        public static func today() -> Self? {
            var calendar = Calendar.gregorian
            let maybeServer = HoYo.Server(rawValue: Defaults[.defaultServer])
            calendar.timeZone = (maybeServer ?? .asia(.genshinImpact)).timeZone
            let isTimePast4am: Bool = Date() > calendar
                .date(bySettingHour: 4, minute: 0, second: 0, of: Date())!
            let todayWeekDayNum = calendar.dateComponents([.weekday], from: Date())
                .weekday!
            let weekdayNum = isTimePast4am ? todayWeekDayNum : (todayWeekDayNum - 1)
            return switch weekdayNum {
            case 1: nil
            case 2, 5: .MonThu
            case 3, 6: .TueFri
            case 0, 4, 7: .WedSat
            default: nil
            }
        }

        public func tomorrow() -> Self? {
            switch self {
            case .MonThu:
                return .TueFri
            case .TueFri:
                return .WedSat
            case .WedSat:
                return .none
            }
        }
    }
}

extension GITodayMaterial.AvailableWeekDay? {
    public func tomorrow() -> Self {
        switch self {
        case .MonThu:
            return .TueFri
        case .TueFri:
            return .WedSat
        case .WedSat:
            return .none
        case .none:
            return .MonThu
        }
    }

    public var localizedName: String {
        switch self {
        case .MonThu: "todayMaterialsKit.week.MR".i18nTodayMaterials
        case .TueFri: "todayMaterialsKit.week.TF".i18nTodayMaterials
        case .WedSat: "todayMaterialsKit.week.WS".i18nTodayMaterials
        case .none: "todayMaterialsKit.week.SU".i18nTodayMaterials
        }
    }
}
