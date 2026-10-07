// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
@testable import PZHoYoLabKit
import Testing

@Suite(.serialized)
struct PZHoYoLabKitTests {
    @Test
    func testBundledDataDecoding() throws {
        _ = try BattleReportTestAssets.getReport4HSR()
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
}
