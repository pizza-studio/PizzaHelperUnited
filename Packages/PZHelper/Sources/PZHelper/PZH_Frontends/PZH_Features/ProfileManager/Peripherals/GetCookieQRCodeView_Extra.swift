// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension GetCookieQRCodeView {
    func extraCookieProcess(cookie: inout String) async throws {
        let fpResult = try await HoYo.getDeviceFingerPrint(region: .miyoushe(.genshinImpact), deviceID: deviceID)
        // cookie += "DEVICEFP=\(fpResult.deviceFP); "
        // cookie += "DEVICEFP_SEED_ID=\(fpResult.seedID); "
        // cookie += "DEVICEFP_SEED_TIME=\(fpResult.seedTime); "
        deviceFP = fpResult.deviceFP
    }
}
