@testable import WallpaperKit
import XCTest

final class WallpaperKitTests: XCTestCase {
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
