// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

// MARK: - HoYo.LedgerData4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo {
    public struct LedgerData4HSR: Ledger {
        // MARK: Public

        public typealias ViewType = LedgerView4HSR

        public struct MonthData: AbleToCodeSendHash {
            // MARK: Public

            public struct LedgerDataGroup: AbleToCodeSendHash {
                // MARK: Public

                public var percent: Int
                public var num: Double
                public var actionName: String
                public var action: String

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case percent
                    case num
                    case actionName = "action_name"
                    case action
                }
            }

            public var currentStellarJades: Int
            public var currentPasses: Int
            public var prevStellarJade: Int
            public var prevPasses: Int
            public var groupBy: [LedgerDataGroup]
            public var stellarJadeRate: Int
            public var passesRate: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case currentStellarJades = "current_hcoin"
                case currentPasses = "current_rails_pass"
                case prevStellarJade = "last_hcoin"
                case prevPasses = "last_rails_pass"
                case groupBy = "group_by"
                case stellarJadeRate = "hcoin_rate"
                case passesRate = "rails_rate"
            }
        }

        public struct DayData: AbleToCodeSendHash {
            // MARK: Public

            public var currentStellarJades: Int
            public var currentPasses: Int
            public var prevStellarJade: Int
            public var prevPasses: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case currentStellarJades = "current_hcoin"
                case currentPasses = "current_rails_pass"
                case prevStellarJade = "last_hcoin"
                case prevPasses = "last_rails_pass"
            }
        }

        public var uid: String
        public var monthData: MonthData
        public var dataMonth: String
        public var region: String
        public var optionalMonth: [String]
        public var month: String
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
            case accountID = "account_id"
            case dayData = "day_data"
        }
    }
}

// MARK: - HoYo.LedgerData4HSR.Action

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.LedgerData4HSR {
    public enum Action: String, CaseIterable {
        case byOther = "other"
        case byAdventure = "adventure_reward"
        case byUniverse = "space_reward"
        case byDailyTraining = "daily_reward"
        case byAbyss = "abyss_reward"
        case byMail = "mail_reward"
        case byEvent = "event_reward"

        // MARK: Public

        public var localized: String {
            "hylKit.ledger4HSR.action.name.\(String(describing: self))".i18nHYLKit
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.LedgerData4HSR.MonthData.LedgerDataGroup {
    public var actionTyped: HoYo.LedgerData4HSR.Action {
        .init(rawValue: action) ?? .byOther
    }
}
