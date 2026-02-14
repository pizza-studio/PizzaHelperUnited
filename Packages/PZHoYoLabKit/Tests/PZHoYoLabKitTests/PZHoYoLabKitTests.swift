@testable import PZHoYoLabKit
import Testing

@Suite(.serialized)
struct PZHoYoLabKitTests {
    @Test
    func testBundledDataDecoding() throws {
        _ = try BattleReportTestAssets.getReport4HSR()
    }
}
