@testable import WallpaperKit
import XCTest

final class WallpaperKitTests: XCTestCase {
    func testAssetMetaAccessibility() throws {
        for theCase in Wallpaper.allCases(for: .genshinImpact) {
            print(theCase)
        }
        for theCase in Wallpaper.allCases(for: .starRail) {
            print(theCase)
        }
        print("------------------")
        print(Wallpaper.defaultValue(for: .genshinImpact))
        print(Wallpaper.defaultValue(for: .starRail))
    }
}
