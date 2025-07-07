// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - Pure Fiction.

@available(iOS 17.0, macCatalyst 17.0, *)
extension HoYo.BattleReport4HSR {
    public struct PureFictionData: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public let starNum: Int
        public let maxFloor: String
        public let battleNum: Int
        public let hasData: Bool
        public let allFloorDetail: [PFFloorDetail]

        public var maxFloorNumStr: String {
            allFloorDetail.max {
                $0.floorNumStr < $1.floorNumStr
            }?.floorNumStr ?? "0"
        }

        public var allNodes: [FHNode] {
            allFloorDetail.compactMap {
                [$0.node1, $0.node2]
            }.reduce([], +)
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

    public struct PFFloorDetail: AbleToCodeSendHash {
        // MARK: Public

        public let name: String
        public let starNum: Int
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

@available(iOS 17.0, macCatalyst 17.0, *)
extension [HoYo.BattleReport4HSR.PFFloorDetail] {
    var trimmed: Self {
        var copied = self
        while copied.last?.isSkipped ?? false {
            copied.removeLast()
        }
        return copied
    }
}
