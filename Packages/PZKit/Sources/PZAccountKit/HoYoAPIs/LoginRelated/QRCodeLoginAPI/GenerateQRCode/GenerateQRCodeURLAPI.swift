// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)
import Alamofire
import CoreImage
import Foundation

extension HoYo {
    public static func generateQRCodeURL(deviceId: UUID) async throws -> (url: URL, ticket: String) {
        struct Body: Encodable {
            let appId: String
            let device: String
        }

        let parameters = Body(appId: QRCodeShared.appID, device: deviceId.uuidString)

        let data = try await AF.request(
            QRCodeShared.url4Fetch,
            method: .post,
            parameters: parameters,
            encoder: JSONParameterEncoder(encoder: {
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                return encoder
            }())
        ).serializingData().value

        let resultData = try GenerateQRCodeURLData.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "HoYo.generateQRCodeURL()"
        )

        let resultURL = resultData.url
        let urlComponents = URLComponents(url: resultURL, resolvingAgainstBaseURL: false)
        let ticket = urlComponents?.queryItems?.first(where: { item in
            item.name == "ticket"
        })?.value

        guard let ticket else { throw MiHoYoAPIError.other(retcode: -999, message: "Invalid URL \(resultURL)") }

        return (url: resultURL, ticket: ticket)
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
