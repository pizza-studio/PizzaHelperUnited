// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@testable import EnkaKit
import XCTest

final class EnkaKitTests: XCTestCase {
    func testDecodingPropertyAndElement() throws {
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

    func testEnkaDBInitUsingBundledData() throws {
        let dbGI = try Enka.EnkaDB4GI(locTag: "zh-Hant")
        let dbHSR = try Enka.EnkaDB4HSR(locTag: "zh-Hant")
        XCTAssertEqual(dbGI.locTag, "zh-tw")
        XCTAssertEqual(dbHSR.locTag, "zh-tw")
    }

    func testEnkaDBOnlineConstruction() async throws {
        let dbGI = try await Enka.EnkaDB4GI(host: .mainlandChina)
        let dbHSR = try await Enka.EnkaDB4HSR(host: .mainlandChina)
        XCTAssertEqual(dbGI.game, .genshinImpact)
        XCTAssertEqual(dbHSR.game, .starRail)
    }
}
