// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@testable import PZAccountKit
import Testing

@available(iOS 17.0, macCatalyst 17.0, *)
@Test
func testDeviceFPGenerationOnline() async throws {
    print(
        try await HoYo.getDeviceFingerPrint(
            region: .miyoushe(.genshinImpact),
            forceClean: true
        )
    )
}
