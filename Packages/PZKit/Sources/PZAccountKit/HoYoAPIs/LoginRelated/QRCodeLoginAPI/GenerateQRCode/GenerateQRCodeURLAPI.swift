// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)
import CoreImage
import Foundation
import PZBaseKit

/// Ref: https://github.com/TimeRainStarSky/TRSS-Plugin (commit 33b6ed7)
/// 米哈游护照 App API (ma-cn-passport/app/*)，直接返回 stoken 无需 gameToken 转换链。

enum QRCodeShared {
    static let appID = "ddxf5dufpuyo"
    static let clientType = "3"
    static let userAgent = "HYPContainer/1.3.3.182"
    static let url4Create = URL(string: "https://passport-api.mihoyo.com/account/ma-cn-passport/app/createQRLogin")!
    static let url4Query = URL(string: "https://passport-api.mihoyo.com/account/ma-cn-passport/app/queryQRLoginStatus")!
}

extension HoYo {
    public static func generateQRCodeURL(deviceId: UUID) async throws -> (url: URL, ticket: String) {
        let headers: HTTPHeaders = [
            "x-rpc-app_id": QRCodeShared.appID,
            "x-rpc-client_type": QRCodeShared.clientType,
            "x-rpc-device_id": deviceId.uuidString,
            "User-Agent": QRCodeShared.userAgent,
            "Content-Type": "application/json",
        ]

        let data = try await AF.request(
            QRCodeShared.url4Create,
            method: .post,
            parameters: EmptyBody(),
            encoder: JSONParameterEncoder.default,
            headers: headers
        ).serializingData().value

        let resultData = try GenerateQRCodeURLData.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "HoYo.generateQRCodeURL()"
        )

        return (url: resultData.url, ticket: resultData.ticket)
    }

    public static func generateLoginQRCode(deviceId: UUID) async throws -> (qrCode: CGImage, ticket: String) {
        let result = try await generateQRCodeURL(deviceId: deviceId)
        if let qrCode = generateQRCode(from: result.url.absoluteString) {
            return (qrCode, result.ticket)
        } else {
            throw MiHoYoAPIError.other(retcode: -999, message: "Invalid URL \(result.url)")
        }
    }
}

private struct EmptyBody: Encodable {}

private func generateQRCode(from string: String) -> CGImage? {
    let context = CIContext()
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setDefaults()
    filter.setValue(Data(string.utf8), forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")
    if let outputImage = filter.outputImage {
        return context.createCGImage(outputImage, from: outputImage.extent)
    }

    return nil
}

func generate64RandomString() -> String {
    let lettersAndNumbers = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let randomString = String((0 ..< 64).map { _ in lettersAndNumbers.randomElement()! })
    return randomString
}
#endif
