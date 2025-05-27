// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if DEBUG
import Foundation
import PZAccountKit
import PZBaseKit

enum AbyssReportTestAssets: String {
    case giCurr = "abyssReport_sample_gi_curr"
    case giPrev = "abyssReport_sample_gi_prev"
    case hsrFHCurr = "abyssReport_sample_hsr_fh_curr"
    case hsrFHPrev = "abyssReport_sample_hsr_fh_prev"
    case hsrASCurr = "abyssReport_sample_hsr_as_curr"
    case hsrASPrev = "abyssReport_sample_hsr_as_prev"
    case hsrPFCurr = "abyssReport_sample_hsr_pf_curr"
    case hsrPFPrev = "abyssReport_sample_hsr_pf_prev"

    // MARK: Internal

    static let testAssetFolderPath: String = {
        let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
            separator: "/"
        ).dropFirst()
        return packageRootPath + "/Tests/PZHoYoLabKitTests/TestAssets/"
    }()

    var rawData: Data {
        let exampleURL = Bundle.module.url(forResource: rawValue, withExtension: "json")!
        return try! Data(contentsOf: exampleURL)
    }

    static func getReport4HSR(isPrev: Bool = false) throws -> HoYo.AbyssReport4HSR {
        var step = 0
        do {
            let dataForgottenHall = try hsrFHCurr.rawData.parseAs(HoYo.AbyssReport4HSR.ForgottenHallData.self)
            step += 1
            let dataPureFiction = try hsrPFCurr.rawData.parseAs(HoYo.AbyssReport4HSR.PureFictionData.self)
            step += 1
            let dataApocalypticShadow = try hsrASCurr.rawData.parseAs(HoYo.AbyssReport4HSR.ApocalypticShadowData.self)
            step += 1
            let result = HoYo.AbyssReport4HSR(
                forgottenHall: dataForgottenHall,
                pureFiction: dataPureFiction,
                apocalypticShadow: dataApocalypticShadow
            )
            return result
        } catch {
            throw error
        }
    }

    func getReport4GI(isPrev: Bool = false) throws -> HoYo.AbyssReport4GI {
        try rawData.parseAs(HoYo.AbyssReport4GI.self)
    }
}

#endif
