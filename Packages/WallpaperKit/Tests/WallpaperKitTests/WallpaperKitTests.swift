@testable import WallpaperKit
import XCTest

final class WallpaperKitTests: XCTestCase {
    func testAssetMetaAccessibility() throws {
        for theCase in Wallpaper.allCases(for: .genshinImpact) {
            print("\(theCase) " + theCase.localizedRealName)
        }
        for theCase in Wallpaper.allCases(for: .starRail) {
            print("\(theCase) " + theCase.localizedRealName)
        }
        print("------------------")
        print(Wallpaper.defaultValue(for: .genshinImpact))
        print(Wallpaper.defaultValue(for: .genshinImpact).localizedName)
        print(Wallpaper.defaultValue(for: .starRail))
        print(Wallpaper.defaultValue(for: .starRail).localizedName)
    }
}
