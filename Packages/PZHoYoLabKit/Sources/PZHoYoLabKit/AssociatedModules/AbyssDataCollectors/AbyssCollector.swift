// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - AbyssDataPackProtocol

public protocol AbyssDataPackProtocol: Codable, Hashable {}

extension AbyssCollector {
    public static let shared = AbyssCollector()
    public typealias CommissionResult = Result<
        ResponseModel,
        ACError
    >

    public struct ResponseModel: Codable {
        public let retcode: Int?
        public let message: String?
    }

    public enum CommissionType: CaseIterable {
        case pzAvatarHolding
        case pzAbyssDB
        case hutaoDB

        // MARK: Internal

        var remoteSettings: (scheme: String, host: String, path: String) {
            return switch self {
            case .hutaoDB: ("https", "homa.snapgenshin.com", "/Record/Upload")
            case .pzAbyssDB: ("http", "81.70.76.222", "/abyss/upload")
            case .pzAvatarHolding: ("http", "81.70.76.222", "/user_holding/upload")
            }
        }

        var defaultsKeyForMD5: Defaults.Key<[String]> {
            switch self {
            case .hutaoDB: .hasUploadedHutaoAbyssReportMD5
            case .pzAbyssDB: .hasUploadedPZAbyssReportMD5
            case .pzAvatarHolding: .hasUploadedAvatarHoldingDataMD5
            }
        }
    }

    public enum ACError: Error {
        case alreadyUploaded
        case cooldownPeriodNotPassed
        case insufficientUserPermission
        case otherError(String)
        case uploadError(String)
        case getResponseError(String)
        case respDecodingError(String)
        case wrongGame
        case insufficientStars
        case avatarMismatch
        case abyssDataNotSupplied
        case inventoryDataNotSupplied
        case dateEncodingFailure
    }

    public static func createAbyssSeasonStr(startTime startTimeStr: String) throws -> Int {
        guard let startTime = Double(startTimeStr) else { throw ACError.dateEncodingFailure }
        let component = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: Date(timeIntervalSince1970: startTime)
        )
        let abyssDataDate =
            Date(timeIntervalSince1970: startTime)
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyyMM"
        let abyssSeasonStr = dateFormatter.string(from: abyssDataDate)
        guard let abyssSeasonInt = Int(abyssSeasonStr) else { throw ACError.dateEncodingFailure }
        if component.day! <= 15 {
            let evenNumber = [0, 2, 4, 6, 8]
            return abyssSeasonInt * 10 + evenNumber.randomElement()!
        } else {
            let oddNumber = [1, 3, 5, 7, 9]
            return abyssSeasonInt * 10 + oddNumber.randomElement()!
        }
    }
}

extension AbyssCollector.CommissionResult {
    public var hasNoCriticalError: Bool {
        switch self {
        case .success: return true
        case let .failure(acError):
            return switch acError {
            case .alreadyUploaded: true
            default: false
            }
        }
    }
}

// MARK: - AbyssCollector

public actor AbyssCollector {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static var isCommissionPermittedByUser: Bool {
        Defaults[.allowAbyssDataCollection]
    }

    public private(set) var cooldownTime: Date = .now

    public func updateCDTime() {
        if let newCDDate = Calendar.current.date(byAdding: .minute, value: 1, to: cooldownTime) {
            cooldownTime = newCDDate
        }
    }
}

extension AbyssCollector {
    public func commitAbyssRecord4HutaoDB(
        profile: PZProfileMO,
        abyssData: HoYo.AbyssReport4GI? = nil,
        inventoryData: HoYo.CharInventory4GI? = nil
    ) async throws
        -> CommissionResult {
        let dataPack = try await SnapHutao.AbyssDataPack(
            profile: profile,
            abyssData: abyssData,
            inventoryData: inventoryData
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let dataToSend = try encoder.encode(dataPack)

        // handle MD5 to see whether it is already uploaded.
        let md5 = "\(profile.uid)\(dataPack.getLocalAbyssSeason())".md5
        guard !Defaults[.hasUploadedHutaoAbyssReportMD5].contains(md5) else {
            throw ACError.alreadyUploaded
        }
        func saveMD5() {
            Defaults[.hasUploadedHutaoAbyssReportMD5].append(md5)
            print(
                "commitAbyssRecord4HutaoDB MD5: \(md5)"
            )
            UserDefaults.logSuite.synchronize()
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "homa.snapgenshin.com"
        components.path = "/Record/Upload"
        guard let url = components.url else {
            throw ACError.uploadError("Remote URL Construction Failed.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = HoYo.HTTPMethod.post.rawValue
        // 设置请求头
        request.allHTTPHeaderFields = [
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
        ]
        request.setValue(
            "Pizza-Helper/5.0",
            forHTTPHeaderField: "User-Agent"
        )
        request.httpBody = dataToSend
        request.setValue(
            "\(dataToSend.count)",
            forHTTPHeaderField: "Content-Length"
        )
        do {
            let (data, responseRAW) = try await URLSession.shared.data(for: request)
            guard let response = responseRAW as? HTTPURLResponse else {
                throw ACError.getResponseError("Not a valid HTTPURLResponse.")
            }
            handleStatus: switch response.statusCode {
            case 200: break handleStatus
            default: throw ACError.getResponseError("Initial HTTP Response is not 200.")
            }
            let decoded = try JSONDecoder().decode(ResponseModel.self, from: data)
            switch decoded.retcode {
            case 0:
                saveMD5()
                return .success(decoded) // 完成工作，退出执行。
            default: throw ACError.getResponseError("Final Server Response is not 0.")
            }
        } catch {
            if error is DecodingError {
                return .failure(.respDecodingError("\(error)"))
            }
            if error is ACError {
                return .failure(.otherError("\(error)"))
            } // 防止俄罗斯套娃。
            return .failure(ACError.uploadError("\(error)"))
        }
    }
}

extension AbyssCollector {
    public func commitAbyssRecord4PZAbyssDB(
        profile: PZProfileMO,
        abyssData: HoYo.AbyssReport4GI? = nil,
        travelStats: HoYo.TravelStatsData4GI? = nil
    ) async throws
        -> CommissionResult {
        let dataPack = try await PZAbyssDB.AbyssDataPack(
            profile: profile,
            abyssData: abyssData,
            travelStats: travelStats
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let dataToSend = try encoder.encode(dataPack)

        // handle MD5 to see whether it is already uploaded.
        let md5 = "\(profile.uid)\(dataPack.getLocalAbyssSeason())".md5
        guard !Defaults[.hasUploadedPZAbyssReportMD5].contains(md5) else {
            throw ACError.alreadyUploaded
        }
        func saveMD5() {
            Defaults[.hasUploadedPZAbyssReportMD5].append(md5)
            print(
                "commitAbyssRecord4PZAbyssDB MD5: \(md5)"
            )
            UserDefaults.logSuite.synchronize()
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "81.70.76.222"
        components.path = "/abyss/upload"
        guard let url = components.url else {
            throw ACError.uploadError("Remote URL Construction Failed.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = HoYo.HTTPMethod.post.rawValue
        // 设置请求头
        request.allHTTPHeaderFields = [
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
        ]
        request.setValue(
            "Pizza-Helper/5.0",
            forHTTPHeaderField: "User-Agent"
        )
        request.httpBody = dataToSend
        request.setValue(
            "\(dataToSend.count)",
            forHTTPHeaderField: "Content-Length"
        )
        PZAbyssDB.writeSaltedHeaders(using: dataToSend, to: &request)
        do {
            let (data, responseRAW) = try await URLSession.shared.data(for: request)
            guard let response = responseRAW as? HTTPURLResponse else {
                throw ACError.getResponseError("Not a valid HTTPURLResponse.")
            }
            handleStatus: switch response.statusCode {
            case 200: break handleStatus
            default: throw ACError.getResponseError("Initial HTTP Response is not 200.")
            }
            let decoded = try JSONDecoder().decode(ResponseModel.self, from: data)
            switch decoded.retcode {
            case 0:
                saveMD5()
                return .success(decoded) // 完成工作，退出执行。
            default:
                if ["uid existed", "Insert Failed"].contains(decoded.message) { saveMD5() }
                throw ACError.getResponseError("Final Server Response is not 0.")
            }
        } catch {
            if error is DecodingError {
                return .failure(.respDecodingError("\(error)"))
            }
            if error is ACError {
                return .failure(.otherError("\(error)"))
            } // 防止俄罗斯套娃。
            return .failure(ACError.uploadError("\(error)"))
        }
    }
}

extension AbyssCollector {
    public func commitUserHoldingData4PZAbyssDB(
        profile: PZProfileMO,
        abyssData: HoYo.AbyssReport4GI? = nil,
        travelStats: HoYo.TravelStatsData4GI? = nil
    ) async throws
        -> CommissionResult {
        let dataPack = try await PZAbyssDB.AvatarHoldingDataPack(
            profile: profile,
            travelStats: travelStats
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let dataToSend = try encoder.encode(dataPack)

        // handle MD5 to see whether it is already uploaded.
        let md5 = String(data: dataToSend, encoding: .utf8)!.md5
        guard !Defaults[.hasUploadedAvatarHoldingDataMD5].contains(md5) else {
            throw ACError.alreadyUploaded
        }
        func saveMD5() {
            Defaults[.hasUploadedAvatarHoldingDataMD5].append(md5)
            print(
                "commitUserHoldingData4PZAbyssDB MD5: \(md5)"
            )
            UserDefaults.logSuite.synchronize()
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = "81.70.76.222"
        components.path = "/user_holding/upload"
        guard let url = components.url else {
            throw ACError.uploadError("Remote URL Construction Failed.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = HoYo.HTTPMethod.post.rawValue
        // 设置请求头
        request.allHTTPHeaderFields = [
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
        ]
        request.setValue(
            "Pizza-Helper/5.0",
            forHTTPHeaderField: "User-Agent"
        )
        request.httpBody = dataToSend
        request.setValue(
            "\(dataToSend.count)",
            forHTTPHeaderField: "Content-Length"
        )
        PZAbyssDB.writeSaltedHeaders(using: dataToSend, to: &request)
        do {
            let (data, responseRAW) = try await URLSession.shared.data(for: request)
            guard let response = responseRAW as? HTTPURLResponse else {
                throw ACError.getResponseError("Not a valid HTTPURLResponse.")
            }
            handleStatus: switch response.statusCode {
            case 200: break handleStatus
            default: throw ACError.getResponseError("Initial HTTP Response is not 200.")
            }
            let decoded = try JSONDecoder().decode(ResponseModel.self, from: data)
            switch decoded.retcode {
            case 0:
                saveMD5()
                return .success(decoded) // 完成工作，退出执行。
            default:
                if ["uid existed", "Insert Failed"].contains(decoded.message) { saveMD5() }
                throw ACError.getResponseError("Final Server Response is not 0.")
            }
        } catch {
            if error is DecodingError {
                return .failure(.respDecodingError("\(error)"))
            }
            if error is ACError {
                return .failure(.otherError("\(error)"))
            } // 防止俄罗斯套娃。
            return .failure(ACError.uploadError("\(error)"))
        }
    }
}

extension AbyssCollector {
    public func commitAbyssRecord(
        profile: PZProfileMO,
        abyssData: HoYo.AbyssReport4GI? = nil,
        inventoryData: HoYo.CharInventory4GI? = nil,
        travelStats: HoYo.TravelStatsData4GI? = nil,
        commissionType dataPackType: CommissionType
    ) async throws
        -> CommissionResult {
        guard AbyssCollector.isCommissionPermittedByUser else {
            throw AbyssCollector.ACError.insufficientUserPermission
        }

        let dataPack: any AbyssDataPackProtocol
        let md5Key = dataPackType.defaultsKeyForMD5
        let md5: String

        switch dataPackType {
        case .hutaoDB:
            let newData = try await SnapHutao.AbyssDataPack(
                profile: profile,
                abyssData: abyssData,
                inventoryData: inventoryData
            )
            md5 = "\(profile.uid)\(newData.getLocalAbyssSeason())".md5
            dataPack = newData
        case .pzAbyssDB:
            let newData = try await PZAbyssDB.AbyssDataPack(
                profile: profile,
                abyssData: abyssData,
                travelStats: travelStats
            )
            md5 = "\(profile.uid)\(newData.getLocalAbyssSeason())".md5
            dataPack = newData
        case .pzAvatarHolding:
            let newData = try await PZAbyssDB.AvatarHoldingDataPack(
                profile: profile,
                travelStats: travelStats
            )
            md5 = newData.hashValue.description.md5 // 与旧版披萨引擎的处理方式不同。
            dataPack = newData
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let dataToSend = try encoder.encode(dataPack)

        guard !Defaults[md5Key].contains(md5) else { throw ACError.alreadyUploaded }

        func saveMD5() {
            Defaults[md5Key].append(md5)
            print("\(dataPackType) MD5: \(md5)")
            UserDefaults.logSuite.synchronize()
        }

        var components = URLComponents()
        components.scheme = dataPackType.remoteSettings.scheme
        components.host = dataPackType.remoteSettings.host
        components.path = dataPackType.remoteSettings.path
        guard let url = components.url else {
            throw ACError.uploadError("Remote URL Construction Failed.")
        }

        var request = URLRequest(url: url)
        request.httpMethod = HoYo.HTTPMethod.post.rawValue
        request.allHTTPHeaderFields = [
            "Accept-Encoding": "gzip, deflate, br",
            "Accept-Language": "zh-CN,zh-Hans;q=0.9",
            "Accept": "*/*",
            "Connection": "keep-alive",
            "Content-Type": "application/json",
        ]
        request.setValue("Pizza-Helper/5.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = dataToSend
        request.setValue("\(dataToSend.count)", forHTTPHeaderField: "Content-Length")

        if [.pzAvatarHolding, .pzAbyssDB].contains(dataPackType) {
            PZAbyssDB.writeSaltedHeaders(using: dataToSend, to: &request)
        }

        do {
            let (data, responseRAW) = try await URLSession.shared.data(for: request)
            guard let response = responseRAW as? HTTPURLResponse else {
                throw ACError.getResponseError("Not a valid HTTPURLResponse.")
            }

            guard response.statusCode == 200 else {
                throw ACError.getResponseError("Initial HTTP Response is not 200.")
            }

            let decoded = try JSONDecoder().decode(ResponseModel.self, from: data)
            switch decoded.retcode {
            case 0:
                saveMD5()
                return .success(decoded)
            default:
                if ["uid existed", "Insert Failed"].contains(decoded.message) {
                    saveMD5()
                }
                throw ACError.getResponseError("Final Server Response is not 0.")
            }
        } catch {
            if error is DecodingError {
                return .failure(.respDecodingError("\(error)"))
            } else if error is ACError {
                return .failure(.otherError("\(error)"))
            }
            return .failure(ACError.uploadError("\(error)"))
        }
    }
}
