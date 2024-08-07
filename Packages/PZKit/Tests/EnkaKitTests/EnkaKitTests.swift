// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@testable import EnkaKit
import XCTest

final class EnkaKitTests: XCTestCase {
    func testEDecodingPropertyAndElement() throws {
        let jsonStr1 = #"{"PropType": "GrassAddedRatio"}"#
        let jsonStr2 = #"{"Element": "Grass"}"#
        guard let data1 = jsonStr1.data(using: .utf8), let data2 = jsonStr2.data(using: .utf8) else {
            assertionFailure("Data Failure.")
            return
        }
        let decoded1 = try JSONDecoder().decode([String: Enka.PropertyType].self, from: data1)
        let decoded2 = try JSONDecoder().decode([String: Enka.GameElement].self, from: data2)
        XCTAssertEqual(decoded1.values.first, .dendroAddedRatio)
        XCTAssertEqual(decoded2.values.first, .dendro)
    }
}
