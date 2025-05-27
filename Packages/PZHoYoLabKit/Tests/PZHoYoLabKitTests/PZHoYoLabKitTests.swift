@testable import PZHoYoLabKit
import XCTest

final class PZHoYoLabKitTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }

    #if DEBUG
    func testBundledDataDecoding() throws {
        _ = try AbyssReportTestAssets.getReport4HSR()
    }
    #endif
}
