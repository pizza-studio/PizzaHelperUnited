// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit

@available(iOS 17.0, macCatalyst 17.0, *)
extension GetCookieQRCodeView {
    /// 获取设备指纹并写回资料库，供本机后续的战绩接口使用。
    func refreshDeviceFingerPrint() async throws {
        let fpResult = try await HoYo.getDeviceFingerPrint(region: .miyoushe(game), deviceID: deviceID)
        deviceFP = fpResult.deviceFP
    }
}
