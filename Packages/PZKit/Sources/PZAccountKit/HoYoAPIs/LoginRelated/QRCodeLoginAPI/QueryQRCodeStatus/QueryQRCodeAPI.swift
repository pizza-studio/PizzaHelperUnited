// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZBaseKit

extension HoYo {
    private static let sharedURLSession4QRCodeStatus: Session = {
        let configuration = URLSessionConfiguration.background(
            withIdentifier: sharedBundleIDHeader + ".qrCodeSession"
        )
        configuration.timeoutIntervalForRequest = 120 // 设置请求超时
        configuration.timeoutIntervalForResource = 240 // 设置资源超时
        configuration.allowsCellularAccess = true // 允许蜂窝网络访问
        configuration.isDiscretionary = true
        configuration.sessionSendsLaunchEvents = true

        // 创建 Alamofire 的 Session
        let session = Alamofire.Session(configuration: configuration)
        return session
    }()

    static public func queryQRCodeStatus(deviceId: UUID, ticket: String) async throws -> QueryQRCodeStatus {
        struct Body: Encodable {
            let appId: String
            let device: String
            let ticket: String
        }

        let parameters = Body(appId: QRCodeShared.appID, device: deviceId.uuidString, ticket: ticket)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try await Self.sharedURLSession4QRCodeStatus.request(
            QRCodeShared.url4Query,
            method: .post,
            parameters: parameters,
            encoder: JSONParameterEncoder(encoder: encoder)
        ).serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.queryQRCodeStatus()")
    }
}
