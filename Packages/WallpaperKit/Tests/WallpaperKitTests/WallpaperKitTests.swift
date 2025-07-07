// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Testing
@testable import WallpaperKit

struct WallpaperKitTests {
    @available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
    @Test
    func testAssetMetaAccessibility() throws {
        for theCase in BundledWallpaper.allCases(for: .genshinImpact) {
            print("\(theCase) " + theCase.localizedRealName)
        }
        for theCase in BundledWallpaper.allCases(for: .starRail) {
            print("\(theCase) " + theCase.localizedRealName)
        }
        print("------------------")
        print(BundledWallpaper.defaultValue(for: .genshinImpact))
        print(BundledWallpaper.defaultValue(for: .genshinImpact).localizedName)
        print(BundledWallpaper.defaultValue(for: .starRail))
        print(BundledWallpaper.defaultValue(for: .starRail).localizedName)
    }
}
