// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit

// MARK: - HoYo.AbyssReport4GI

extension HoYo {
    public struct AbyssReport4GI: AbyssReport, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public typealias ViewType = AbyssReportView4GI

        public struct CharacterRankModel: AbleToCodeSendHash {
            // MARK: Public

            /// 角色ID
            public var avatarID: Int
            /// 排名对应的值
            public var value: Int
            /// 角色头像
            public var avatarIcon: String
            /// 角色星级（4/5）
            public var rarity: Int

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case avatarID = "avatar_id"
                case value
                case avatarIcon = "avatar_icon"
                case rarity
            }
        }

        public struct Floor: AbleToCodeSendHash {
            // MARK: Public

            public struct Level: AbleToCodeSendHash {
                // MARK: Public

                public struct Battle: AbleToCodeSendHash {
                    public struct Avatar: AbleToCodeSendHash, Identifiable {
                        // MARK: Lifecycle

                        public init(id: Int, icon: String, level: Int, rarity: Int) {
                            self.id = id
                            self.icon = icon
                            self.level = level
                            self.rarity = rarity
                        }

                        // MARK: Public

                        /// 角色ID
                        public var id: Int
                        /// 角色头像
                        public var icon: String
                        /// 角色等级
                        public var level: Int
                        /// 角色星级
                        public var rarity: Int
                    }

                    /// 半间序数，1为上半，2为下半
                    public var index: Int
                    /// 出战角色
                    public var avatars: [Avatar]
                    /// 完成时间戳since1970
                    public var timestamp: String
                }

                /// 本间星数
                public var star: Int
                /// 本间满星数（3）
                public var maxStar: Int
                /// 上半间与下半间
                public var battles: [Battle]
                /// 本间序数，第几件
                public var index: Int

                // MARK: Internal

                enum CodingKeys: String, CodingKey {
                    case star
                    case maxStar = "max_star"
                    case battles
                    case index
                }
            }

            /// 是否解锁
            public var isUnlock: Bool
            /// ？
            public var settleTime: String
            /// 本层星数
            public var star: Int
            /// 各间数据
            public var levels: [Level]
            /// 满星数（=9）
            public var maxStar: Int
            /// 废弃
            public var icon: String
            /// 第几层，楼层序数（9,10,11,12）
            public var index: Int

            /// 是否满星
            public var gainAllStar: Bool {
                star == maxStar
            }

            // MARK: Internal

            enum CodingKeys: String, CodingKey {
                case isUnlock = "is_unlock"
                case settleTime = "settle_time"
                case star
                case levels
                case maxStar = "max_star"
                case icon
                case index
            }
        }

        public enum AbyssRound: String {
            case this = "1", last = "2"
        }

        /// 元素爆发排名（只有第一个）
        public var energySkillRank: [CharacterRankModel]
        /// 本期深境螺旋开始时间
        public var startTime: String
        /// 总胜利次数
        public var totalWinTimes: Int
        /// 到达最高层间数（最深抵达），eg "12-3"
        public var maxFloor: String
        /// 各楼层数据
        public var floors: [Floor]
        /// 总挑战次数
        public var totalBattleTimes: Int
        /// 最高承受伤害排名（只有最高）
        public var takeDamageRank: [CharacterRankModel]
        /// 是否解锁深境螺旋
        public var isUnlock: Bool
        /// 最多击败敌人数量排名（只有最高
        public var defeatRank: [CharacterRankModel]
        /// 本期深境螺旋结束时间
        public var endTime: String
        /// 元素战记伤害排名（只有最高）
        public var normalSkillRank: [CharacterRankModel]
        /// 元素战记伤害排名（只有最高）
        public var damageRank: [CharacterRankModel]
        /// 深境螺旋期数ID，每期+1
        public var scheduleId: Int
        /// 出站次数
        public var revealRank: [CharacterRankModel]
        public var totalStar: Int

        public var rankDataMissing: Bool {
            damageRank.count * defeatRank.count * takeDamageRank.count * normalSkillRank.count * energySkillRank
                .count == 0
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case energySkillRank = "energy_skill_rank"
            case startTime = "start_time"
            case totalWinTimes = "total_win_times"
            case maxFloor = "max_floor"
            case floors
            case totalBattleTimes = "total_battle_times"
            case takeDamageRank = "take_damage_rank"
            case isUnlock = "is_unlock"
            case defeatRank = "defeat_rank"
            case endTime = "end_time"
            case normalSkillRank = "normal_skill_rank"
            case damageRank = "damage_rank"
            case scheduleId = "schedule_id"
            case revealRank = "reveal_rank"
            case totalStar = "total_star"
        }
    }
}

extension HoYo.AbyssReport4GI {
    public var hasSufficientStarsForUpload: Bool {
        var finalFloorIndex = 0
        for floor in floors where floor.index >= 9 {
            guard floor.star == floor.maxStar else { return false }
            finalFloorIndex = Swift.max(floor.index, finalFloorIndex)
        }
        return finalFloorIndex >= 12
    }
}
