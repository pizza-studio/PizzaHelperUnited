// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

// MARK: - HoYo.LedgerData4GI

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo {
    public struct LedgerData4GI: Ledger {
        // MARK: Public

        public typealias ViewType = LedgerView4GI

        public struct MonthData: AbleToCodeSendHash {
            // MARK: Public

            public struct LedgerDataGroup: AbleToCodeSendHash {
                // MARK: Public

                public var percent: Int
                public var num: Double
                public var actionID: Int
                public var action: String

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case percent
                    case num
                    case actionID = "action_id"
                    case action
                }
            }

            public var currentPrimogems: Int
            /// 国际服没有
            public var currentPrimogemsLevel: Int?
            public var lastMora: Int
            /// 国服使用
            public var primogemsRate: Int?
            /// 国际服使用
            public var primogemRate: Int?
            public var moraRate: Int
            public var groupBy: [LedgerDataGroup]
            public var lastPrimogems: Int
            public var currentMora: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case currentPrimogems = "current_primogems"
                case currentPrimogemsLevel = "current_primogems_level"
                case lastMora = "last_mora"
                case primogemsRate = "primogems_rate"
                case primogemRate = "primogem_rate"
                case moraRate = "mora_rate"
                case groupBy = "group_by"
                case lastPrimogems = "last_primogems"
                case currentMora = "current_mora"
            }
        }

        public struct DayData: AbleToCodeSendHash {
            // MARK: Public

            public var currentMora: Int
            /// 国际服没有
            public var lastPrimogems: Int?
            /// 国际服没有
            public var lastMora: Int?
            public var currentPrimogems: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case currentMora = "current_mora"
                case lastPrimogems = "last_primogems"
                case lastMora = "last_mora"
                case currentPrimogems = "current_primogems"
            }
        }

        public var uid: Int
        public var monthData: MonthData
        public var dataMonth: Int
        public var region: String
        public var optionalMonth: [Int]
        public var month: Int
        public var nickname: String
        public var lantern: Bool?
        public var dayData: DayData
        /// 国际服没有
        public var date: String?
        /// 国际服没有
        public var dataLastMonth: Int?
        /// 国际服没有
        public var accountID: Int?
        /// 国际服没有

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case uid
            case monthData = "month_data"
            case dataMonth = "data_month"
            case date
            case dataLastMonth = "data_last_month"
            case region
            case optionalMonth = "optional_month"
            case month
            case nickname
            case accountID = "account_id"
            case lantern
            case dayData = "day_data"
        }
    }
}

// MARK: - HoYo.LedgerData4GI.Action

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.LedgerData4GI {
    public enum Action: Int, CaseIterable {
        case byOther = 0
        case byAdventure = 1
        case byTask = 2
        case byActivity = 3
        case byAbyss = 4
        case byMail = 5
        case byEvent = 6

        // MARK: Public

        public var localized: String {
            "hylKit.ledger4GI.action.name.\(String(describing: self))".i18nHYLKit
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.LedgerData4GI.MonthData.LedgerDataGroup {
    public var actionTyped: HoYo.LedgerData4GI.Action {
        .init(rawValue: actionID) ?? .byOther
    }
}
