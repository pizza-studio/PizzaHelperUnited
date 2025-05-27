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
    case hsrCurr = "abyssReport_sample_hsr_fh_curr"
    case hsrPrev = "abyssReport_sample_hsr_fh_prev"

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

    func getReport4GI(isPrev: Bool = false) throws -> HoYo.AbyssReport4GI {
        try rawData.parseAs(HoYo.AbyssReport4GI.self)
    }

    func getReport4HSR(isPrev: Bool = false) throws -> HoYo.AbyssReport4HSR {
        let fhData = try rawData.parseAs(HoYo.AbyssReport4HSR.ForgottenHallData.self)
        let result = HoYo.AbyssReport4HSR(
            forgottenHall: fhData
        )
        return result
    }
}

#endif
