// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation

extension HoYo {
    static public func queryQRCodeStatus(deviceId: UUID, ticket: String) async throws -> QueryQRCodeStatus {
        struct Body: Encodable {
            let appId: String
            let device: String
            let ticket: String
        }

        let parameters = Body(appId: QRCodeShared.appID, device: deviceId.uuidString, ticket: ticket)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let data = try await AF.request(
            QRCodeShared.url4Query,
            method: .post,
            parameters: parameters,
            encoder: JSONParameterEncoder(encoder: encoder)
        ).serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.queryQRCodeStatus()")
    }
}
