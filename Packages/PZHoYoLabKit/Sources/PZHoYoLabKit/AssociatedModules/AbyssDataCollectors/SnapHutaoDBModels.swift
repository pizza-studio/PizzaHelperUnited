// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - SnapHutao

public enum SnapHutao {
    public struct AbyssDataPack: Codable, AbyssDataPackProtocol {
        public struct SpiralAbyss: Codable, Hashable {
            public struct Damage: Codable, Hashable {
                public var avatarId: Int
                public var aalue: Int
            }

            public struct Floor: Codable, Hashable {
                public struct Level: Codable, Hashable {
                    public struct Battle: Codable, Hashable {
                        public var index: Int
                        public var avatars: [Int]
                    }

                    public var index: Int
                    public var star: Int
                    public var battles: [Battle]
                }

                public var index: Int
                public var star: Int
                public var levels: [Level]
            }

            public var scheduleId: Int
            public var totalBattleTimes: Int
            public var totalWinTimes: Int
            public var damage: Damage
            public var takeDamage: Damage
            public var floors: [Floor]
        }

        public struct Avatar: Codable, Hashable {
            public var avatarId: Int
            public var weaponId: Int
            public var reliquarySetIds: [Int]
            public var activedConstellationNumber: Int
        }

        public var uid: String
        public var identity: String
        public var spiralAbyss: SpiralAbyss?
        public var avatars: [Avatar]
        public var reservedUserName: String

        public var pizzaCalculatedSeasonInt: Int

        /// 返回结尾只有0或1的abyssSeason信息
        public func getLocalAbyssSeason() -> Int {
            if pizzaCalculatedSeasonInt % 2 == 0 {
                return (pizzaCalculatedSeasonInt / 10) * 10
            } else {
                return (pizzaCalculatedSeasonInt / 10) * 10 + 1
            }
        }
    }
}

extension SnapHutao.AbyssDataPack {
    public init(
        profile: PZProfileMO,
        abyssData: HoYo.AbyssReport4GI? = nil,
        inventoryData: HoYo.CharInventory4GI? = nil
    ) async throws {
        guard profile.game == .genshinImpact else { throw AbyssCollector.ACError.wrongGame }
        guard AbyssCollector.isCommissionPermittedByUser else {
            throw AbyssCollector.ACError.insufficientUserPermission
        }
        self.uid = profile.uid
        self.identity = "GenshinPizzaHelper"
        self.reservedUserName = ""
        var abyssData = abyssData
        if abyssData == nil {
            abyssData = try await HoYo.abyssReportData4GI(for: profile)
        }
        guard let abyssData else { throw AbyssCollector.ACError.abyssDataNotSupplied }
        guard abyssData.totalStar == 36 else { throw AbyssCollector.ACError.insufficientStars }
        var inventoryData = inventoryData
        if inventoryData == nil {
            inventoryData = try await HoYo.characterInventory4GI(for: profile)
        }
        guard let inventoryData else { throw AbyssCollector.ACError.inventoryDataNotSupplied }
        self.avatars = inventoryData.avatars.map { avatar in
            .init(
                avatarId: avatar.id,
                weaponId: avatar.weapon.id,
                reliquarySetIds: avatar.reliquaries.map(\.set.id),
                activedConstellationNumber: avatar.activedConstellationNum
            )
        }
        self.spiralAbyss = .init(data: abyssData)
        self.pizzaCalculatedSeasonInt = try AbyssCollector.createAbyssSeasonStr(startTime: abyssData.startTime)
    }
}

extension SnapHutao.AbyssDataPack.SpiralAbyss {
    public init?(data: HoYo.AbyssReport4GI) {
        guard [
            data.damageRank.first,
            data.defeatRank.first,
            data.takeDamageRank.first,
            data.energySkillRank.first,
            data.normalSkillRank.first,
        ].allSatisfy({ $0 != nil }) else { return nil }
        scheduleId = data.scheduleId
        totalBattleTimes = data.totalBattleTimes
        totalWinTimes = data.totalWinTimes
        self.damage = SnapHutao.AbyssDataPack.SpiralAbyss.Damage(
            avatarId: data.damageRank.first?.avatarID ?? -1,
            aalue: data.damageRank.first?.value ?? -1
        )
        takeDamage = SnapHutao.AbyssDataPack.SpiralAbyss.Damage(
            avatarId: data.takeDamageRank.first?.avatarID ?? -1,
            aalue: data.takeDamageRank.first?.value ?? -1
        )

        floors = []
        for myFloorData in data.floors {
            var levelData = [Floor.Level]()
            for myLevelData in myFloorData.levels {
                var battleData = [Floor.Level.Battle]()
                for myBattleData in myLevelData.battles {
                    battleData.append(Floor.Level.Battle(
                        index: myBattleData.index,
                        avatars: myBattleData.avatars.map { $0.id }
                    ))
                }
                levelData.append(Floor.Level(
                    index: myLevelData.index,
                    star: myLevelData.star,
                    battles: battleData
                ))
            }
            floors.append(Floor(
                index: myFloorData.index,
                star: myFloorData.star,
                levels: levelData
            ))
        }
        if isInsane() { return nil }
    }
}

// MARK: - SnapHutao.AbyssData Sanity Checkers.

extension SnapHutao.AbyssDataPack.SpiralAbyss.Floor.Level.Battle {
    public var isInsane: Bool { avatars.isEmpty }
}

extension SnapHutao.AbyssDataPack.SpiralAbyss.Floor.Level {
    public mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    public mutating func selfTidy() -> Int {
        battles = battles.filter { !$0.isInsane }
        return battles.count
    }
}

extension SnapHutao.AbyssDataPack.SpiralAbyss.Floor {
    public mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    public mutating func selfTidy() -> Int {
        levels = levels.compactMap { level in
            var level = level
            level.selfTidy()
            return level.isInsane() ? nil : level
        }
        return levels.count
    }
}

extension SnapHutao.AbyssDataPack.SpiralAbyss {
    public mutating func isInsane() -> Bool { selfTidy() == 0 }

    @discardableResult
    public mutating func selfTidy() -> Int {
        floors = floors.compactMap { floor in
            var floor = floor
            floor.selfTidy()
            return floor.isInsane() ? nil : floor
        }
        return floors.count
    }
}

extension SnapHutao.AbyssDataPack {
    public mutating func sanityCheck() -> Bool {
        guard var abyss = spiralAbyss else { return true }
        let sanityResult = abyss.selfTidy()
        spiralAbyss = (sanityResult == 0) ? nil : abyss
        return spiralAbyss == nil
    }
}
