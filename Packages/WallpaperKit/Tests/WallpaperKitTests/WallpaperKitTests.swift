// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import Testing
@testable import WallpaperKit

struct WallpaperKitTests {
    @Test
    func testAssetMetaAccessibility() throws {
        for theCase in BundledWallpaper.allCases(for: .genshinImpact) {
            PZLog.info("\(theCase) " + theCase.localizedRealName)
        }
        for theCase in BundledWallpaper.allCases(for: .starRail) {
            PZLog.info("\(theCase) " + theCase.localizedRealName)
        }
        PZLog.info("------------------")
        PZLog.info(BundledWallpaper.defaultValue(for: .genshinImpact))
        PZLog.info(BundledWallpaper.defaultValue(for: .genshinImpact).localizedName)
        PZLog.info(BundledWallpaper.defaultValue(for: .starRail))
        PZLog.info(BundledWallpaper.defaultValue(for: .starRail).localizedName)
    }
}
