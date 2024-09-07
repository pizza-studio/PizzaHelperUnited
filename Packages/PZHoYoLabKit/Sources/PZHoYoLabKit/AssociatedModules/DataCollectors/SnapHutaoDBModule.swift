// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit

// MARK: - SnapHutao

public enum SnapHutao {
    public typealias CommissionResult = Result<
        SnapHutao.ResponseModel,
        SnapHutao.SHError
    >

    public struct ResponseModel: Codable {
        public let retcode: Int
        public let message: String
    }

    public enum SHError: Error {
        case insufficientUserPermission
        case otherError(String)
        case uploadError(String)
        case getResponseError(String)
        case respDecodingError(String)
    }

    public static var isCommissionPermittedByUser: Bool {
        Defaults[.allowAbyssDataCollection]
    }

    public static func commitAbyssRecord(
        profile: PZProfileMO,
        abyssData: HoYo.AbyssReport4GI? = nil
    ) async throws
        -> CommissionResult {
        let dataPack = try await AbyssDataPack(profile: profile, abyssData: abyssData)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try await commitAbyssRecord(data: encoder.encode(dataPack))
    }

    public static func commitAbyssRecord(
        data dataToSend: Data
    ) async throws
        -> CommissionResult {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "homa.snapgenshin.com"
        components.path = "/Record/Upload"
        guard let url = components.url else {
            throw SHError.uploadError("Remote URL Construction Failed.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = HoYo.HTTPMethod.post.rawValue
        // 设置请求头
        request.allHTTPHeaderFields = [
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
        ]
        request.setValue(
            "Pizza-Helper/5.0",
            forHTTPHeaderField: "User-Agent"
        )
        request.httpBody = dataToSend
        request.setValue(
            "\(dataToSend.count)",
            forHTTPHeaderField: "Content-Length"
        )
        do {
            let (data, responseRAW) = try await URLSession.shared.data(for: request)
            guard let response = responseRAW as? HTTPURLResponse else {
                throw SHError.getResponseError("Not a valid HTTPURLResponse.")
            }
            handleStatus: switch response.statusCode {
            case 200: break handleStatus
            default: throw SHError.getResponseError("Initial HTTP Response is not 200.")
            }
            let decoded = try JSONDecoder().decode(ResponseModel.self, from: data)
            switch decoded.retcode {
            case 0: return .success(decoded) // 完成工作，退出执行。
            default: throw SHError.getResponseError("Final Server Response is not 0.")
            }
        } catch {
            if error is DecodingError {
                return .failure(.respDecodingError("\(error)"))
            }
            if error is SHError {
                return .failure(.otherError("\(error)"))
            } // 防止俄罗斯套娃。
            return .failure(SHError.uploadError("\(error)"))
        }
    }
}

// MARK: SnapHutao.AbyssDataPack

extension SnapHutao {
    public struct AbyssDataPack: Codable {
        public struct SpiralAbyss: Codable {
            public struct Damage: Codable {
                public var avatarId: Int
                public var aalue: Int
            }

            public struct Floor: Codable {
                public struct Level: Codable {
                    public struct Battle: Codable {
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

        public struct Avatar: Codable {
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
