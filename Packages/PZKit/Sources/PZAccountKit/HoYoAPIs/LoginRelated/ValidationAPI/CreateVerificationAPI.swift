// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
extension HoYo {
    public static func createVerification(
        region: HoYo.AccountRegion,
        cookie: String,
        deviceID: String?,
        deviceFingerPrint: String? = nil,
        challengePathOverride: String? = nil
    ) async throws
        -> Verification {
        let queryItems: [URLQueryItem] = [
            .init(name: "is_high", value: "true"),
        ]

        var additionalHeaders: [String: String] = [:]
        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            additionalHeaders["x-rpc-device_fp"] = deviceFingerPrint
            additionalHeaders["x-rpc-device_id"] = await ThisDevice.getDeviceID4Vendor(deviceID)
        }
        URLRequestConfig.writeXRPCChallengeHeaders4DailyNote(to: &additionalHeaders, for: region)
        if let challengePathOverride {
            additionalHeaders["x-rpc-challenge_path"] = challengePathOverride
        }

        var urlComponents =
            URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/card/wapi/createVerification")!
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!

        var defaultHeaders = try await URLRequestConfig.defaultHeaders(
            region: region,
            deviceID: deviceID,
            additionalHeaders: additionalHeaders
        )
        defaultHeaders["Cookie"] = cookie
        defaultHeaders["DS"] = URLRequestHelper.getDS(
            region: region,
            query: url.query ?? "",
            body: nil
        )

        let data = try await AF.request(
            url,
            method: .get,
            headers: HTTPHeaders(defaultHeaders)
        ).serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.createVerification()")
    }

    @discardableResult
    public static func verifyVerification(
        region: HoYo.AccountRegion,
        challenge: String,
        validate: String,
        challengePathOverride: String? = nil,
        cookie: String,
        deviceFingerPrint: String? = nil,
        deviceID: String? = nil
    ) async throws
        -> VerifyVerification {
        var additionalHeaders: [String: String] = [:]
        if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
            additionalHeaders["x-rpc-device_fp"] = deviceFingerPrint
            additionalHeaders["x-rpc-device_id"] = await ThisDevice.getDeviceID4Vendor(deviceID)
        }
        URLRequestConfig.writeXRPCChallengeHeaders4DailyNote(to: &additionalHeaders, for: region)
        if let challengePathOverride {
            additionalHeaders["x-rpc-challenge_path"] = challengePathOverride
        }

        struct VerifyVerificationBody: Encodable, Sendable {
            let geetestChallenge: String
            let geetestValidate: String
            let geetestSeccode: String
            init(challenge: String, validate: String) {
                self.geetestChallenge = challenge
                self.geetestValidate = validate
                self.geetestSeccode = "\(validate)|jordan"
            }
        }

        let body = VerifyVerificationBody(challenge: challenge, validate: validate)
        let url =
            URLComponents(string: "https://api-takumi-record.mihoyo.com/game_record/app/card/wapi/verifyVerification")!
                .url!

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let bodyData = try encoder.encode(body)

        var defaultHeaders = try await URLRequestConfig.defaultHeaders(
            region: region,
            deviceID: deviceID,
            additionalHeaders: additionalHeaders
        )
        defaultHeaders["Cookie"] = cookie
        defaultHeaders["DS"] = URLRequestHelper.getDS(
            region: region,
            query: url.query ?? "",
            body: bodyData
        )

        let data = try await AF.request(
            url,
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder(encoder: encoder),
            headers: HTTPHeaders(defaultHeaders)
        ).serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.verifyVerification()")
    }
}
