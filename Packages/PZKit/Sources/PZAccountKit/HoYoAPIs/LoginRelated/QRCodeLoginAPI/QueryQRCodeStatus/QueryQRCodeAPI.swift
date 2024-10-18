// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

extension HoYo {
    static public func queryQRCodeStatus(deviceId: UUID, ticket: String) async throws -> QueryQRCodeStatus {
        var request = URLRequest(url: QRCodeShared.url4Query)
        request.httpMethod = "POST"

        struct Body: Encodable {
            let appId: String
            let device: String
            let ticket: String
        }

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let body = Body(appId: QRCodeShared.appID, device: deviceId.uuidString, ticket: ticket)
        let bodyData = try encoder.encode(body)
        request.httpBody = bodyData

        let (resultData, _) = try await URLSession.shared.data(for: request)
        return try .decodeFromMiHoYoAPIJSONResult(data: resultData, debugTag: "HoYo.queryQRCodeStatus()")
    }
}
