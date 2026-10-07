// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if DEBUG
import Foundation
import PZAccountKit
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, *)
enum BattleReportTestAssets: String {
    case giSACurr = "battleReport_sample_gi_sa_curr"
    case giSAPrev = "battleReport_sample_gi_sa_prev"
    case giSOCurr = "battleReport_sample_gi_so_curr"
    case hsrFHCurr = "battleReport_sample_hsr_fh_curr"
    case hsrFHPrev = "battleReport_sample_hsr_fh_prev"
    case hsrASCurr = "battleReport_sample_hsr_as_curr"
    case hsrASPrev = "battleReport_sample_hsr_as_prev"
    case hsrPFCurr = "battleReport_sample_hsr_pf_curr"
    case hsrPFPrev = "battleReport_sample_hsr_pf_prev"

    // MARK: Internal

    static let testAssetFolderPath: String = {
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        return packageRootPath + "/Tests/PZHoYoLabKitTests/TestAssets/"
    }()

    var rawData: Data {
        let exampleURL = Bundle.currentSPM.url(forResource: rawValue, withExtension: "json")!
        return try! Data(contentsOf: exampleURL)
    }

    static func getReport4HSR(isPrev: Bool = false) throws -> HoYo.BattleReport4HSR {
        let dataForgottenHall = try (isPrev ? hsrFHPrev : hsrFHCurr).rawData
            .parseAs(HoYo.BattleReport4HSR.ForgottenHallData.self)
        let dataPureFiction = try (isPrev ? hsrPFPrev : hsrPFCurr).rawData
            .parseAs(HoYo.BattleReport4HSR.PureFictionData.self)
        let dataApocalypticShadow = try (isPrev ? hsrASPrev : hsrASCurr).rawData
            .parseAs(HoYo.BattleReport4HSR.ApocalypticShadowData.self)
        return HoYo.BattleReport4HSR(
            forgottenHall: dataForgottenHall,
            pureFiction: dataPureFiction,
            apocalypticShadow: dataApocalypticShadow
        )
    }

    static func getReport4GI(isPrev: Bool = false) throws -> HoYo.BattleReport4GI {
        let spiralAbyss = try (isPrev ? giSAPrev : giSACurr).rawData
            .parseAs(HoYo.BattleReport4GI.SpiralAbyssData.self)
        let onslaughtResult = try giSOCurr.rawData
            .parseAs(HoYo.BattleReport4GI.StygianOnslaughtQueryResult.self)
        var stygianOnslaught: HoYo.BattleReport4GI.StygianOnslaughtData?
        if onslaughtResult.isUnlock {
            // 幽境危戰會「同時」打包返回當前與上一個賽季的報告。
            let season = isPrev ? onslaughtResult.data.dropFirst().first : onslaughtResult.data.first
            if let season, season.single.hasData { stygianOnslaught = season }
        }
        return HoYo.BattleReport4GI(
            spiralAbyss: spiralAbyss,
            stygianOnslaught: stygianOnslaught
        )
    }
}

#endif
