// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
@testable import PZHoYoLabKit
import Testing

@Suite(.serialized)
struct PZHoYoLabKitTests {
    // MARK: Internal

    @Test
    func testBundledDataDecoding() throws {
        for isPrev in [false, true] {
            _ = try BattleReportTestAssets.getReport4GI(isPrev: isPrev)
            _ = try BattleReportTestAssets.getReport4HSR(isPrev: isPrev)
        }
        // 逐一驗證每個測試素材都能單獨解碼。
        _ = try decode(HoYo.BattleReport4GI.SpiralAbyssData.self, from: .giSACurr)
        _ = try decode(HoYo.BattleReport4GI.SpiralAbyssData.self, from: .giSAPrev)
        _ = try decode(HoYo.BattleReport4GI.StygianOnslaughtQueryResult.self, from: .giSOCurr)
        _ = try decode(HoYo.BattleReport4HSR.ForgottenHallData.self, from: .hsrFHCurr)
        _ = try decode(HoYo.BattleReport4HSR.ForgottenHallData.self, from: .hsrFHPrev)
        _ = try decode(HoYo.BattleReport4HSR.ApocalypticShadowData.self, from: .hsrASCurr)
        _ = try decode(HoYo.BattleReport4HSR.ApocalypticShadowData.self, from: .hsrASPrev)
        _ = try decode(HoYo.BattleReport4HSR.PureFictionData.self, from: .hsrPFCurr)
        _ = try decode(HoYo.BattleReport4HSR.PureFictionData.self, from: .hsrPFPrev)
    }

    /// 鐵道戰報的 `node_1` / `node_2` 都可能為 null；同一層樓也可能有多筆嘗試紀錄
    /// （例如幽境危戰的「星啟模式」與「常規模式」共用同一個 `maze_id`）。
    @Test
    func testHSRFloorDetailNullNodesAndBestAttempts() throws {
        let data4AS = try decode(HoYo.BattleReport4HSR.ApocalypticShadowData.self, from: .hsrASCurr)
        // 原始資料必須涵蓋「node_2 為 null」與「同層樓重複」這兩種狀況。
        #expect(data4AS.allFloorDetail.contains { $0.node2 == nil })
        let duplicatedMazeIDs = Dictionary(grouping: data4AS.allFloorDetail, by: \.mazeID)
            .filter { $0.value.count > 1 }
        #expect(!duplicatedMazeIDs.isEmpty)

        let bestAttempts = data4AS.allFloorDetail.bestAttemptsPerFloor
        // 每層樓只剩一筆，且都是該層樓星數最高的那次嘗試。
        #expect(bestAttempts.count == Set(bestAttempts.map(\.mazeID)).count)
        for floor in bestAttempts {
            let attempts = data4AS.allFloorDetail.filter { $0.mazeID == floor.mazeID }
            #expect(floor.starNumInt == attempts.map(\.starNumInt).max())
            // 同星數時取時間最新的那次。
            let tiedBestStar = attempts.filter { $0.starNumInt == floor.starNumInt }
            #expect(floor.latestChallengeDate == tiedBestStar.compactMap(\.latestChallengeDate).max())
        }
        // 樓層順序沿用原始資料的順序。
        var expectedOrder: [Int] = []
        for floor in data4AS.allFloorDetail where !expectedOrder.contains(floor.mazeID) {
            expectedOrder.append(floor.mazeID)
        }
        #expect(bestAttempts.map(\.mazeID) == expectedOrder)

        // 這批資料裡重複的那層樓，較低星的是「星啟模式」，應被淘汰。
        let surviving = try #require(bestAttempts.first { duplicatedMazeIDs.keys.contains($0.mazeID) })
        #expect(surviving.isTierce == false)
        #expect(surviving.starNumInt == 3)

        // 榜尾被跳過的樓層仍應被 trimmed 剔除。
        let trimmed = bestAttempts.trimmed
        #expect(trimmed.count <= bestAttempts.count)
        #expect(trimmed.last?.isSkipped == false)

        // 忘卻之庭的樓層本來就不重複，去重不應改變筆數。
        let data4FH = try decode(HoYo.BattleReport4HSR.ForgottenHallData.self, from: .hsrFHCurr)
        #expect(data4FH.allFloorDetail.bestAttemptsPerFloor.count == data4FH.allFloorDetail.count)

        // 虛構敘事同樣有「星啟模式 vs 常規模式」共用 `maze_id` 的狀況。
        let data4PF = try decode(HoYo.BattleReport4HSR.PureFictionData.self, from: .hsrPFCurr)
        #expect(!Dictionary(grouping: data4PF.allFloorDetail, by: \.mazeID).filter { $0.value.count > 1 }.isEmpty)
        let pfBestAttempts = data4PF.allFloorDetail.bestAttemptsPerFloor
        #expect(pfBestAttempts.count < data4PF.allFloorDetail.count)
        #expect(pfBestAttempts.count == Set(pfBestAttempts.map(\.mazeID)).count)
        for floor in pfBestAttempts {
            let attempts = data4PF.allFloorDetail.filter { $0.mazeID == floor.mazeID }
            #expect(floor.starNumInt == attempts.map(\.starNumInt).max())
        }
    }

    /// 战报原始 JSON 必须在尝试解码之前先落地到硬碟，供解码失败时排障。
    @Test
    func testRawBattleReportDumping() throws {
        let sampleData = BattleReportTestAssets.hsrFHCurr.rawData
        let savedURL = try #require(
            BattleReportFileHandler.saveRawReportData(
                sampleData,
                game: .starRail,
                reportType: "unitTest",
                seasonScope: .current
            )
        )
        defer { try? FileManager.default.removeItem(at: savedURL) }
        let writtenData = try Data(contentsOf: savedURL)
        #expect(writtenData == sampleData)

        // 同一（游戏 × 战报种类 × 赛季范围）组合重复写入时覆写既有档案，不新增拷贝。
        let overwritingData = Data("{}".utf8)
        let URL4Overwrite = try #require(
            BattleReportFileHandler.saveRawReportData(
                overwritingData,
                game: .starRail,
                reportType: "unitTest",
                seasonScope: .current
            )
        )
        #expect(URL4Overwrite == savedURL)
        #expect(try Data(contentsOf: URL4Overwrite) == overwritingData)
    }

    // MARK: Private

    private func decode<T: Decodable>(_ type: T.Type, from asset: BattleReportTestAssets) throws -> T {
        try JSONDecoder().decode(T.self, from: asset.rawData)
    }
}
