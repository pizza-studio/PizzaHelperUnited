// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - PZAbyssDB

public enum PZAbyssDB {
    static let homeAPISalt: String = "2f2d1f9e00719112e88d92d98165f9aa"
    static let uidSalt: String = "GenshinPizzaHelper"

    static func writeSaltedHeaders(using data: Data, to req: inout URLRequest) {
        guard let stringData = String(data: data, encoding: .utf8) else { return }
        let salt = PZAbyssDB.homeAPISalt
        let ds = (stringData.sha256 + salt).sha256
        req.setValue(ds, forHTTPHeaderField: "ds")
        req.setValue(
            String(Int.random(in: 0 ... 999999)),
            forHTTPHeaderField: "dseed"
        )
    }
}

// MARK: PZAbyssDB.AvatarHoldingDataPack

extension PZAbyssDB {
    public struct AvatarHoldingDataPack: Codable, Hashable, AbyssDataPackProtocol {
        /// 混淆后的UID的哈希值，用于标记是哪一位玩家打的深境螺旋
        public let uid: String
        /// 深境螺旋期数，格式为年月日+上/下半月，其中上半月用奇数表示，下半月后偶数表示，如"2022101"
        public var updateDate: String
        /// 玩家已解锁角色
        public let owningChars: [Int]
        /// 账号所属服务器ID
        public let serverId: String
    }
}

extension PZAbyssDB {
    /// 用于向服务器发送的深境螺旋数据
    public struct AbyssDataPack: Codable, AbyssDataPackProtocol {
        public struct SubmitDetailModel: AbleToCodeSendHash {
            /// 深境螺旋层数
            public let floor: Int
            /// 深境螺旋间数
            public let room: Int
            /// 上半间/下半间，1表示上半，2表示下半
            public let half: Int

            /// 使用了哪些角色
            public let usedChars: [Int]
        }

        public struct AbyssRankModel: AbleToCodeSendHash {
            /// 造成的最高伤害
            public let topDamageValue: Int

            /// 最高伤害的角色ID，下同
            public let topDamage: Int
            public let topTakeDamage: Int
            public let topDefeat: Int
            public let topEUsed: Int
            public let topQUsed: Int
        }

        /// 提交数据的ID
        public var submitId: String = UUID().uuidString

        /// 混淆后的UID的哈希值，用于标记是哪一位玩家打的深境螺旋
        public let uid: String

        /// 提交时间的时间戳since1970
        public var submitTime: Int = .init(Date().timeIntervalSince1970)

        /// 深境螺旋期数，格式为年月日+上/下半月，其中上半月用奇数表示，下半月后偶数表示，如"2022101"
        public var abyssSeason: Int

        /// 账号服务器ID
        public let server: String

        /// 每半间深境螺旋的数据
        public let submitDetails: [SubmitDetailModel]

        /// 深境螺旋伤害等数据的排名统计
        public let abyssRank: AbyssRankModel?

        /// 玩家已解锁角色
        public let owningChars: [Int]

        /// 战斗次数
        public let battleCount: Int

        /// 获胜次数
        public let winCount: Int

        /// 返回结尾只有0或1的abyssSeason资讯
        public func getLocalAbyssSeason() -> Int {
            if abyssSeason % 2 == 0 {
                (abyssSeason / 10) * 10
            } else {
                (abyssSeason / 10) * 10 + 1
            }
        }

        /// Just a reference for the Server side implementation.
        public func hasSufficientBattles() -> Bool {
            6 == submitDetails.filter { $0.floor == 12 }.count
        }
    }

    // MARK: - AccountSpiralAbyssDetail

    public struct AccountSpiralAbyssDetail {
        // MARK: Lifecycle

        public init(this: HoYo.AbyssReport4GI, last: HoYo.AbyssReport4GI? = nil) {
            self.this = this
            self.last = last
        }

        public init(dataSet: AbyssReportSet4GI) {
            self.this = dataSet.current
            self.last = dataSet.previous
        }

        // MARK: Public

        public enum WhichSeason {
            case this
            case last
        }

        public let this: HoYo.AbyssReport4GI
        public let last: HoYo.AbyssReport4GI?
    }
}

extension PZAbyssDB.AvatarHoldingDataPack {
    public init(
        profile: PZProfileSendable,
        travelStats: HoYo.TravelStatsData4GI? = nil
    ) async throws {
        let obfuscatedUid = "\(profile.uid)\(profile.uid.md5)\(PZAbyssDB.uidSalt)"
        self.uid = String(obfuscatedUid.md5)

        let formatter = DateFormatter.GregorianPOSIX()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Calendar(identifier: .gregorian)
        self.updateDate = formatter.string(from: Date())
        var travelStats = travelStats
        if travelStats == nil {
            travelStats = try await HoYo.getTravelStatsData4GI(for: profile)
        }
        guard let travelStats else { throw AbyssCollector.ACError.inventoryDataNotSupplied }

        self.owningChars = travelStats.avatars.map { $0.id }
        self.serverId = profile.server.rawValue
    }
}

extension PZAbyssDB.AbyssDataPack {
    public init(
        profile: PZProfileSendable,
        abyssData: HoYo.AbyssReport4GI? = nil,
        travelStats: HoYo.TravelStatsData4GI? = nil
    ) async throws {
        guard profile.game == .genshinImpact else { throw AbyssCollector.ACError.wrongGame }
        guard AbyssCollector.isCommissionPermittedByUser else {
            throw AbyssCollector.ACError.insufficientUserPermission
        }

        let obfuscatedUid = "\(profile.uid)\(profile.uid.md5)\(PZAbyssDB.uidSalt)"
        self.uid = obfuscatedUid.md5
        self.server = profile.server.rawValue
        var abyssData = abyssData
        if abyssData == nil {
            abyssData = try await HoYo.abyssReportData4GI(for: profile)
        }
        guard let abyssData else { throw AbyssCollector.ACError.abyssDataNotSupplied }
        guard abyssData.hasSufficientStarsForUpload else { throw AbyssCollector.ACError.ungainedStarsDetected }

        let component = Calendar.gregorian.dateComponents(
            [.year, .month, .day],
            from: Date(timeIntervalSince1970: Double(abyssData.startTime)!)
        )
        let abyssDataDate =
            Date(timeIntervalSince1970: Double(abyssData.startTime)!)
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyyMM"
        let abyssSeasonStr = dateFormatter.string(from: abyssDataDate)
        guard let abyssSeasonInt = Int(abyssSeasonStr) else {
            throw AbyssCollector.ACError.dateEncodingFailure
        }
        if component.day! <= 15 {
            let evenNumber = [0, 2, 4, 6, 8]
            self.abyssSeason = abyssSeasonInt * 10 + evenNumber.randomElement()!
        } else {
            let oddNumber = [1, 3, 5, 7, 9]
            self.abyssSeason = abyssSeasonInt * 10 + oddNumber.randomElement()!
        }
        var travelStats = travelStats
        if travelStats == nil {
            travelStats = try await HoYo.getTravelStatsData4GI(for: profile)
        }
        guard let travelStats else { throw AbyssCollector.ACError.inventoryDataNotSupplied }

        self.owningChars = travelStats.avatars.map { $0.id }
        self.abyssRank = .init(data: abyssData)
        self.submitDetails = .new(from: abyssData)
        self.battleCount = abyssData.totalBattleTimes
        self.winCount = abyssData.totalWinTimes
    }
}

extension PZAbyssDB.AbyssDataPack.AbyssRankModel {
    public init?(data: HoYo.AbyssReport4GI) {
        guard [
            data.damageRank.first,
            data.defeatRank.first,
            data.takeDamageRank.first,
            data.energySkillRank.first,
            data.normalSkillRank.first,
        ].allSatisfy({ $0 != nil }) else { return nil }
        topDamageValue = data.damageRank.first?.value ?? 0
        topDamage = data.damageRank.first?.avatarID ?? -1
        topDefeat = data.defeatRank.first?.avatarID ?? -1
        topTakeDamage = data.takeDamageRank.first?.avatarID ?? -1
        topQUsed = data.energySkillRank.first?.avatarID ?? 0
        topEUsed = data.normalSkillRank.first?.avatarID ?? 0
        guard [
            topDamageValue,
            topDamage,
            topDefeat,
            topTakeDamage,
        ].allSatisfy({ $0 != -1 }) else { return nil }
    }
}

extension [PZAbyssDB.AbyssDataPack.SubmitDetailModel] {
    public static func new(from abyssReport: HoYo.AbyssReport4GI)
        -> [PZAbyssDB.AbyssDataPack.SubmitDetailModel] {
        abyssReport.floors.flatMap { floor in
            floor.levels.flatMap { level in
                level.battles.compactMap { battle in
                    if floor.gainAllStar {
                        PZAbyssDB.AbyssDataPack.SubmitDetailModel(
                            floor: floor.index,
                            room: level.index,
                            half: battle.index,
                            usedChars: battle.avatars
                                .sorted(by: { $0.id < $1.id }).map { $0.id }
                        )
                    } else { nil }
                }
            }
        }
    }
}
