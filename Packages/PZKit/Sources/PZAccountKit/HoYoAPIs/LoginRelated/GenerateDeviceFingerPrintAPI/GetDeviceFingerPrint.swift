// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
extension Defaults.Keys {
    public static let lastDefaultFingerprintRefreshDate = Key<Date>(
        "lastDefaultFingerprintRefreshDate",
        default: .init(timeIntervalSince1970: 0),
        suite: .baseSuite
    )
}

extension HoYo {
    public struct FingerPrintDataSet: Sendable {
        public let deviceFP: String
        public let seedID: String
        public let seedTime: String
    }

    public static func getDeviceFingerPrint(
        region: HoYo.AccountRegion, deviceID: String? = nil, forceClean: Bool = false
    ) async throws
        -> FingerPrintDataSet {
        struct DeviceFingerPrintResult: DecodableFromMiHoYoAPIJSONResult {
            let msg: String
            // swiftlint:disable:next identifier_name
            let device_fp: String
            let code: Int
        }
        if Date(timeIntervalSince1970: 0) == Defaults[.lastDefaultFingerprintRefreshDate] || forceClean {
            Defaults[.lastDefaultFingerprintRefreshDate] = .init() // 确保 UserDefaults 有写入的值、而不是每次读取时都给默认值。
        }
        let refreshDate = Defaults[.lastDefaultFingerprintRefreshDate]
        let url = "\(region.publicDataHostURLHeader)/device-fp/api/getFp"
        let initialDeviceID = ThisDevice.getDeviceID4Vendor(deviceID)
        let deviceId = (initialDeviceID + refreshDate.timeIntervalSince1970.description).md5
        let seedID = generateSeed()
        let epochSeconds = Date().timeIntervalSince1970.asIntIfFinite() ?? 0
        let seedTime = "\(epochSeconds)000"
        let initialRandomFp = String(deviceId.md5.shuffled().prefix(13)) // 根据 deviceId 生成初始指纹。
        let body: [String: String] = [
            "seed_id": seedID,
            "device_id": deviceId,
            "platform": region.platformID,
            "seed_time": "\(seedTime)",
            "ext_fields": region.getFpExtFields(deviceID: deviceId),
            "app_name": region.rawValue,
            "device_fp": initialRandomFp,
        ]

        let data = try await AF.request(
            url,
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder.default
        ).serializingData().value

        #if DEBUG
        print(String(data: data, encoding: .utf8) ?? "")
        #endif

        let fingerPrint = try DeviceFingerPrintResult
            .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.getDeviceFingerPrint()")
            .device_fp
        return .init(deviceFP: fingerPrint, seedID: seedID, seedTime: seedTime)
    }
}

private func generateSeed(_ length: Int = 16) -> String {
    let length = Swift.max(0, length) // 防呆
    let characters = "0123456789abcdef".map(\.description)
    var result = ""
    while result.count < length, let randE = characters.randomElement() {
        result.append(randE)
    }
    return result
}

extension HoYo.AccountRegion {
    fileprivate var platformID: String {
        switch self {
        case .hoyoLab: "5"
        case .miyoushe: "1"
        }
    }

    fileprivate var publicDataHostURLHeader: String {
        switch self {
        case .miyoushe: "https://public-data-api.mihoyo.com"
        case .hoyoLab: "https://sg-public-data-api.hoyoverse.com"
        }
    }

    fileprivate func getFpExtFields(deviceID: String) -> String {
        switch self {
        case .miyoushe:
            // swiftlint:disable line_length
            """
            {"ramCapacity":"3746","hasVpn":"0","proxyStatus":"0","screenBrightness":"0.550","packageName":"com.miHoYo.mhybbs","romRemain":"100513","deviceName":"iPhone","isJailBreak":"0","magnetometer":"-160.495300x-206.488358x58.534348","buildTime":"1706406805675","ramRemain":"97","accelerometer":"-0.419876x-0.748367x-0.508057","cpuCores":"6","cpuType":"CPU_TYPE_ARM64","packageVersion":"2.20.1","gyroscope":"0.133974x-0.051780x-0.062961","batteryStatus":"45","appUpdateTimeDiff":"1707130080397","appMemory":"57","screenSize":"414×896","vendor":"--","model":"iPhone12,5","IDFV":"\(
                deviceID
                    .uppercased()
            )","romCapacity":"488153","isPushEnabled":"1","appInstallTimeDiff":"1696756955347","osVersion":"17.2.1","chargeStatus":"1","isSimInserted":"1","networkType":"WIFI"}
            """
        // swiftlint:enable line_length
        case .hoyoLab:
            // swiftlint:disable line_length
            """
            {"userAgent":"\(
                URLRequestConfig
                    .getUserAgent(region: self)
            )","browserScreenSize":"387904","maxTouchPoints":"5","isTouchSupported":"1","browserLanguage":"zh-CN","browserPlat":"Linux aarch64","browserTimeZone":"Asia/Shanghai","webGlRender":"Adreno (TM) 640","webGlVendor":"Qualcomm","numOfPlugins":"0","listOfPlugins":"unknown","screenRatio":"2.625","deviceMemory":"4","hardwareConcurrency":"8","cpuClass":"unknown","ifNotTrack":"unknown","ifAdBlock":"0","hasLiedLanguage":"0","hasLiedResolution":"1","hasLiedOs":"0","hasLiedBrowser":"0","canvas":"\(
                generateSeed(64)
            )","webDriver":"0","colorDepth":"24","pixelRatio":"2.625","packageName":"unknown","packageVersion":"2.27.0","webgl":"\(
                generateSeed(64)
            )"}
            """
            // swiftlint:enable line_length
        }
    }
}
