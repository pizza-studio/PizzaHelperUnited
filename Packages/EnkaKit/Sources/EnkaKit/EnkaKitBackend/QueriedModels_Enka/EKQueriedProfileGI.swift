// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import EnkaDBModels
import PZBaseKit

// MARK: - Enka.QueriedProfileGI

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    public struct QueriedProfileGI: AbleToCodeSendHash, EKQueriedProfileProtocol {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.nickname = try container.decode(String.self, forKey: .nickname)
            self.level = try container.decodeIfPresent(Int.self, forKey: .level) ?? 0
            self.signature = try container.decodeIfPresent(String.self, forKey: .signature) ?? ""
            self.worldLevel = try container.decodeIfPresent(Int.self, forKey: .worldLevel) ?? 0
            self.nameCardId = try container.decode(Int.self, forKey: .nameCardId)
            self.finishAchievementNum = try container.decode(Int.self, forKey: .finishAchievementNum)
            self.towerFloorIndex = try container.decodeIfPresent(Int.self, forKey: .towerFloorIndex)
            self.towerLevelIndex = try container.decodeIfPresent(Int.self, forKey: .towerLevelIndex)
            self.showAvatarInfoList = try container.decodeIfPresent(
                [ShowAvatarInfoRAW].self,
                forKey: .showAvatarInfoList
            )
            self.showNameCardIdList = try container.decodeIfPresent([Int].self, forKey: .showNameCardIdList)
            self.profilePicture = try container.decode(ProfilePictureRAW.self, forKey: .profilePicture)
            self.avatarDetailList = try container.decodeIfPresent([QueriedAvatar].self, forKey: .avatarDetailList) ?? []
            self.uid = (try? container.decode(String.self, forKey: .uid))
                ?? "UID not included in the retrieved JSON."
        }

        // MARK: Public

        public typealias DBType = Enka.EnkaDB4GI

        public struct ShowAvatarInfoRAW: AbleToCodeSendHash {
            /// 角色ID
            public var avatarId: Int
            /// 角色等级
            public var level: Int
            /// 角色皮肤编号
            public var costumeId: Int?
        }

        public struct ProfilePictureRAW: AbleToCodeSendHash {
            // MARK: Lifecycle

            public init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: Enka.QueriedProfileGI.ProfilePictureRAW.CodingKeys.self)
                let theID = try container.decodeIfPresent(Int.self, forKey: .id)
                self.avatarId = try container.decodeIfPresent(Int.self, forKey: .avatarId)
                self.costumeId = try container.decodeIfPresent(Int.self, forKey: .costumeId)
                if theID == nil {
                    // 针对自原神 4.1 版发行开始起没改过肖像的玩家账号实施兼容处理。
                    let candidate1: Int? = Enka.costumeReverseQueryTable[costumeId ?? -114_514]
                    let candidate2: Int? = Enka.costumeReverseQueryTable[avatarId ?? -114_514]
                    self.id = candidate1 ?? candidate2 ?? 1
                } else {
                    self.id = theID
                }
            }

            // MARK: Public

            /// 在 ProfilePictureExcelConfigData.json 当中的检索用 ID。
            /// Ref: https://twitter.com/EnkaNetwork/status/1708819830693077325
            public let id: Int?
            /// 旧 API，不要删，否则自 4.1 版发行开始起没改过肖像的玩家会受到影响。
            public var avatarId: Int?
            /// 旧 API，不要删，否则自 4.1 版发行开始起没改过肖像的玩家会受到影响。
            public var costumeId: Int?
        }

        /// UID
        public var uid: String
        /// 名称
        public var nickname: String
        /// 等级
        public var level: Int
        /// 签名
        public var signature: String
        /// 世界等级
        public var worldLevel: Int
        /// 资料名片ID
        public var nameCardId: Int
        /// 已解锁成就数
        public var finishAchievementNum: Int
        /// 本期深境螺旋层数
        public var towerFloorIndex: Int?
        /// 本期深境螺旋间数
        public var towerLevelIndex: Int?
        /// 正在展示角色资讯列表（ID与等级）
        public var showAvatarInfoList: [ShowAvatarInfoRAW]?
        /// 正在展示名片ID的列表
        public var showNameCardIdList: [Int]?
        /// 玩家头像编号，需要据此在 ProfilePictureExcelConfigData.json 单独查询。
        public var profilePicture: ProfilePictureRAW

        public var avatarDetailList: [QueriedAvatar]

        public var headIcon: Int {
            profilePicture.id ?? 1
        }
    }
}

// MARK: - Enka.QueriedProfileGI.QueriedAvatar

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.QueriedProfileGI {
    public struct QueriedAvatar: AbleToCodeSendHash, EKQueriedRawAvatarProtocol {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.avatarId = try container.decode(Int.self, forKey: .avatarId)
            self.talentIdList = try container.decodeIfPresent([Int].self, forKey: .talentIdList)
            self.propMap = try container.decode(PropMapRAW.self, forKey: .propMap)
            self.skillDepotId = try container.decode(Int.self, forKey: .skillDepotId)
            self.inherentProudSkillList = try container.decode([Int].self, forKey: .inherentProudSkillList)
            self.skillLevelMap = try container.decode([String: Int].self, forKey: .skillLevelMap)
            self.equipList = try container.decode([EquipListItemRAW].self, forKey: .equipList)
            self.fetterInfo = try container.decode(FetterInfoRAW.self, forKey: .fetterInfo)
            self.costumeId = try container.decodeIfPresent(Int.self, forKey: .costumeId)
            self.proudSkillExtraLevelMap = try container.decodeIfPresent(
                [String: Int].self, forKey: .proudSkillExtraLevelMap
            )
            let tempMap = try container.decode([Enka.PropertyType: Double].self, forKey: .fightPropMap)
            var newMap = [Enka.PropertyType: Double]()
            tempMap.forEach { key, value in
                guard key != .unknownType else { return }
                newMap[key] = value
            }
            self.fightPropMap = newMap
        }

        // MARK: Public

        public typealias DBType = Enka.EnkaDB4GI

        public struct PropMapRAW: AbleToCodeSendHash {
            // MARK: Public

            public struct ExpRAW: AbleToCodeSendHash {
                public var type: Int // 不是词条。
                public var ival: String
            }

            public struct LevelStageRAW: AbleToCodeSendHash {
                public var type: Int // 不是词条。
                public var ival: String
                public var val: String?
            }

            public struct LevelRAW: AbleToCodeSendHash {
                public var type: Int // 不是词条。
                public var ival: String
                public var val: String
            }

            public var exp: ExpRAW
            /// 等级突破
            public var levelStage: LevelStageRAW
            /// 等级
            public var level: LevelRAW

            // MARK: Private

            private enum CodingKeys: String, CodingKey {
                case exp = "1001"
                case levelStage = "1002"
                case level = "4001"
            }
        }

        /// 装备列表的一项，包括武器和圣遗物
        public struct EquipListItemRAW: AbleToCodeSendHash {
            /// 圣遗物
            public struct Reliquary: AbleToCodeSendHash {
                /// 圣遗物等级
                public var level: Int
                /// 圣遗物主属性ID
                public var mainPropId: Int
                /// 圣遗物副属性ID的列表
                public var appendPropIdList: [Int]?
            }

            public struct WeaponRAW: AbleToCodeSendHash {
                /// 武器等级
                public var level: Int
                /// 武器突破等级
                public var promoteLevel: Int?
                /// 武器精炼等级（0-4）
                public var affixMap: [String: Int]?
            }

            public struct PreCalculatedFlat: AbleToCodeSendHash {
                public struct ReliquaryMainstat: AbleToCodeSendHash {
                    public var mainPropId: Enka.PropertyType
                    public var statValue: Double
                }

                public struct ReliquarySubstat: AbleToCodeSendHash {
                    public var appendPropId: Enka.PropertyType
                    public var statValue: Double
                }

                public struct WeaponStat: AbleToCodeSendHash {
                    public var appendPropId: Enka.PropertyType
                    public var statValue: Double
                }

                /// 装备名的哈希值
                public var nameTextMapHash: String
                /// 圣遗物套装名称的哈希值
                public var setNameTextMapHash: String?
                /// 装备稀有度
                public var rankLevel: Int
                /// 圣遗物主词条
                public var reliquaryMainstat: ReliquaryMainstat?
                /// 圣遗物副词条列表
                public var reliquarySubstats: [ReliquarySubstat]?
                /// 武器属性列表：包括基础攻击力和副属性
                public var weaponStats: [WeaponStat]?
                /// 装备类别：武器、圣遗物
                public var itemType: String
                /// 装备名称图标
                public var icon: String
                /// 圣遗物类型：花/羽毛/沙漏/杯子/头
                public var equipType: String?
            }

            /// 物品的ID，武器和圣遗物共用
            public var itemId: Int
            /// 圣遗物
            public var reliquary: Reliquary?
            /// 武器
            public var weapon: WeaponRAW?
            public var flat: PreCalculatedFlat // 由 Enka 事先计算好的面板参数。
        }

        public struct FetterInfoRAW: AbleToCodeSendHash {
            public var expLevel: Int
        }

        /// 角色ID
        public var avatarId: Int
        /// 命之座ID列表
        public let talentIdList: [Int]?
        /// 角色属性
        public var propMap: PropMapRAW
        /// 角色战斗属性
        public var fightPropMap: [Enka.PropertyType: Double]
        /// 角色天赋技能组ID
        public var skillDepotId: Int
        /// 所有固定天赋ID的列表
        public var inherentProudSkillList: [Int]
        /// 天赋等级的字典，skillLevelMap.skillLevel: [天赋ID(String) : 等级(Int)]
        public var skillLevelMap: [String: Int]
        /// 装备列表，包括武器和圣遗物
        public var equipList: [EquipListItemRAW]
        /// 角色好感等级，fetterInfo.expLevel
        public var fetterInfo: FetterInfoRAW
        /// 角色时装编号（nullable）
        public var costumeId: Int?
        /// 命之座带来的额外技能等级加成
        public var proudSkillExtraLevelMap: [String: Int]?

        /// Identifiable. Optimized for Protagonists.
        public var id: String {
            let textAvatarID = avatarId.description
            var isProtagonist: Bool = Protagonist(rawValue: avatarId) != nil
            isProtagonist = isProtagonist && textAvatarID.count == 8 // 仅限原神角色。
            return isProtagonist ? "\(avatarId)-\(skillDepotId)" : textAvatarID
        }
    }
}
