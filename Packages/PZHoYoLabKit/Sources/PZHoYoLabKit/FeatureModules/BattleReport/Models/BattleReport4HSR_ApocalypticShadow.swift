// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - Apocalyptic Shadow.

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.BattleReport4HSR {
    public struct ApocalypticShadowData: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public let starNum: Int
        public let maxFloor: String
        public let battleNum: Int
        public let hasData: Bool
        public let allFloorDetail: [ASFloorDetail]
        public let extraStarNum: Int?

        public var maxFloorNumStr: String {
            allFloorDetail.max {
                $0.floorNumStr < $1.floorNumStr
            }?.floorNumStr ?? "0"
        }

        public var allNodes: [FHNode] {
            allFloorDetail.flatMap(\.allNodes)
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case starNum = "star_num"
            case maxFloor = "max_floor"
            case battleNum = "battle_num"
            case hasData = "has_data"
            case allFloorDetail = "all_floor_detail"
            case extraStarNum = "extra_star_num"
        }
    }

    public struct ASFloorDetail: AbleToCodeSendHash {
        // MARK: Public

        public let name: String
        public let starNum: String
        public let node1: FHNode
        public let node2: FHNode
        public let node3: FHNode?
        public let mazeID: Int
        public let isTierce: Bool?
        public let extraStarNum: String?

        public var allNodes: [FHNode] {
            [node1, node2, node3].compactMap(\.self)
        }

        public var isSkipped: Bool {
            _isFast || allNodes.allSatisfy(\.avatars.isEmpty)
        }

        public var floorNumStr: String {
            mazeID.description.suffix(1).description
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case name
            case starNum = "star_num"
            case node1 = "node_1"
            case node2 = "node_2"
            case node3 = "node_3"
            case mazeID = "maze_id"
            case isTierce = "is_tierce"
            case extraStarNum = "extra_star_num"
            case _isFast = "is_fast"
        }

        // MARK: Private

        private let _isFast: Bool
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension [HoYo.BattleReport4HSR.ASFloorDetail] {
    var trimmed: Self {
        var copied = self
        while copied.last?.isSkipped ?? false {
            copied.removeLast()
        }
        return copied
    }
}
