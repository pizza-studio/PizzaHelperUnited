// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@testable import GachaKit
import GachaMetaDB
import Testing

@Suite(.serialized)
struct GachaKitGMDBTests {
    @Test
    @available(iOS 17.0, macCatalyst 17.0, *)
    func testFetchingRemoteData() async throws {
        _ = try await GachaMeta.Sputnik.fetchPreCompiledData(from: .miyoushe(.genshinImpact))
        _ = try await GachaMeta.Sputnik.fetchPreCompiledData(from: .miyoushe(.starRail))
    }
}
