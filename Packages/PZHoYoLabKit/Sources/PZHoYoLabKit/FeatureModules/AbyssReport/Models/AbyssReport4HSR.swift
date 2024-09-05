// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - HoYo.AbyssReport4HSR

extension HoYo {
    public struct AbyssReport4HSR: AbyssReport {
        // MARK: Public

        public typealias ViewType = AbyssReportView4HSR

        public let scheduleID: Int
        public let beginTime: FHDateComponents?
        public let endTime: FHDateComponents?
        public let starNum: Int
        public let maxFloor: String
        public let battleNum: Int
        public let hasData: Bool
        public let maxFloorDetail: FHFloorDetail?
        public let allFloorDetail: [FHFloorDetail]
        public let maxFloorID: Int
        public let groups: [FHMeta]?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case scheduleID = "schedule_id"
            case beginTime = "begin_time"
            case endTime = "end_time"
            case starNum = "star_num"
            case maxFloor = "max_floor"
            case battleNum = "battle_num"
            case hasData = "has_data"
            case maxFloorDetail = "max_floor_detail"
            case allFloorDetail = "all_floor_detail"
            case maxFloorID = "max_floor_id"
            case groups
        }

        var name: String? {
            groups?.first(where: { $0.scheduleID == scheduleID })?.name
        }
    }
}

extension HoYo.AbyssReport4HSR {
    public struct FHAvatar: Codable, Hashable, Sendable {
        // MARK: Public

        public let id: Int
        public let level: Int
        public let icon: String
        public let rarity: Int
        public let element: String
        public let eidolon: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case id, level, icon, rarity, element
            case eidolon = "rank"
        }
    }

    public struct FHFloorDetail: Codable, Hashable, Sendable {
        // MARK: Public

        public let name: String
        public let roundNum: Int
        public let starNum: Int
        public let node1: FHNode
        public let node2: FHNode
        public let isChaos: Bool
        public let mazeID: Int

        public var isFast: Bool {
            _isFast || (node1.avatars.isEmpty && node2.avatars.isEmpty)
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case name
            case roundNum = "round_num"
            case starNum = "star_num"
            case node1 = "node_1"
            case node2 = "node_2"
            case isChaos = "is_chaos"
            case mazeID = "maze_id"
            case _isFast = "is_fast"
        }

        // MARK: Private

        private let _isFast: Bool
    }

    public struct FHMeta: Codable, Hashable, Sendable {
        // MARK: Public

        public let scheduleID: Int
        public let beginTime: FHDateComponents
        public let endTime: FHDateComponents
        public let status: String
        public let name: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case scheduleID = "schedule_id"
            case beginTime = "begin_time"
            case endTime = "end_time"
            case status
            case name = "name_mi18n"
        }
    }

    public struct FHNode: Codable, Hashable, Sendable {
        // MARK: Public

        public let challengeTime: FHDateComponents
        public let avatars: [FHAvatar]

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case challengeTime = "challenge_time"
            case avatars
        }
    }

    public struct FHDateComponents: Codable, Hashable, Sendable {
        public let year: Int
        public let month: Int
        public let day: Int
        public let hour: Int
        public let minute: Int

        public func asDate(timeZoneDelta: Int) -> Date? {
            let calendar = Calendar(identifier: .gregorian)
            let components = DateComponents(
                calendar: calendar,
                timeZone: TimeZone(secondsFromGMT: timeZoneDelta * 3600),
                year: year,
                month: month,
                day: day,
                hour: hour,
                minute: minute
            )
            return calendar.date(from: components)
        }
    }
}
