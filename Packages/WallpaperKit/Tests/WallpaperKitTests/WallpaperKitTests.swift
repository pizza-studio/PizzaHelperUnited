@testable import WallpaperKit
import XCTest

final class WallpaperKitTests: XCTestCase {
    func testAssetMetaAccessibility() throws {
        XCTAssert(!Wallpaper.allCases4HSR.isEmpty)
    }
}
