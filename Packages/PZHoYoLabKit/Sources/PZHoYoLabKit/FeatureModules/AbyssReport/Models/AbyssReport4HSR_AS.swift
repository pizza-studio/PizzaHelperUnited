// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - Apocalyptic Shadow.

extension HoYo.AbyssReport4HSR {
    public struct ApocalypticShadowData: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public let starNum: Int
        public let maxFloor: String
        public let battleNum: Int
        public let hasData: Bool
        public let allFloorDetail: [ASFloorDetail]

        public var maxFloorNumStr: String {
            allFloorDetail.max {
                $0.floorNumStr < $1.floorNumStr
            }?.floorNumStr ?? "0"
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case starNum = "star_num"
            case maxFloor = "max_floor"
            case battleNum = "battle_num"
            case hasData = "has_data"
            case allFloorDetail = "all_floor_detail"
        }
    }

    public struct ASFloorDetail: AbleToCodeSendHash {
        // MARK: Public

        public let name: String
        public let starNum: String
        public let node1: FHNode
        public let node2: FHNode
        public let mazeID: Int

        public var isSkipped: Bool {
            _isFast || (node1.avatars.isEmpty && node2.avatars.isEmpty)
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
            case mazeID = "maze_id"
            case _isFast = "is_fast"
        }

        // MARK: Private

        private let _isFast: Bool
    }
}
