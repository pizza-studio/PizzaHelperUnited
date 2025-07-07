// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - GachaRequestAuthentication

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaRequestAuthentication: Sendable {
    public let authenticationKey: String
    public let authenticationKeyVersion: String
    public let signType: String
    public let server: HoYo.Server
}

// MARK: - GachaError

@available(iOS 17.0, macCatalyst 17.0, *)
public enum GachaError: Error, Sendable {
    case fetchDataError(page: Int, size: Int, gachaTypeRaw: String, error: Error)
}

// MARK: - ParseGachaURLError

@available(iOS 17.0, macCatalyst 17.0, *)
public enum ParseGachaURLError: String, Error, LocalizedError {
    case urlGenerationFailure
    case invalidURL
    case noAuthenticationKey
    case noAuthenticationKeyVersion
    case noServer
    case invalidServer
    case noSignType

    // MARK: Public

    public var description: String {
        "gachaKit.ParseGachaURLError.\(rawValue)".i18nGachaKit
    }

    public var errorDescription: String? {
        description
    }

    public var localizedDescription: String {
        description
    }
}

// MARK: - GetGachaError

@available(iOS 17.0, macCatalyst 17.0, *)
public enum GetGachaError: Error, Equatable {
    case incorrectAuthkey
    case authkeyTimeout
    case visitTooFrequently
    case networkError(message: String)
    case incorrectUrl
    case decodeError(message: String)
    case unknownError(retcode: Int, message: String)
    case genAuthKeyError(message: String)
}

// MARK: - GenGachaURLError

@available(iOS 17.0, macCatalyst 17.0, *)
public enum GenGachaURLError: Error {
    case genURLError(message: String)
}

// MARK: - GachaFetchRange

@available(iOS 17.0, macCatalyst 17.0, *)
public enum GachaFetchRange: Int, CaseIterable {
    case allAvailable = 0
    case recent72Hours = 72
    case recentWeek = 168
    case recent30Days = 720
    case recent60Days = 1440

    // MARK: Public

    public var actualTimeInterval: TimeInterval { Double(rawValue) * 3600 }
    public var isUnlimited: Bool { self == .allAvailable }

    public var localizedLabel: String {
        let rawTag: String.LocalizationValue = switch self {
        case .allAvailable:
            "gachaKit.getRecord.fetchRange.allAvailable"
        case .recent72Hours:
            "gachaKit.getRecord.fetchRange.recent72Hours"
        case .recentWeek:
            "gachaKit.getRecord.fetchRange.recentWeek"
        case .recent30Days:
            "gachaKit.getRecord.fetchRange.recent30Days"
        case .recent60Days:
            "gachaKit.getRecord.fetchRange.recent60Days"
        }
        return String(localized: rawTag, bundle: .module)
    }

    public func verifyWhetherOutOfRange(against givenTarget: Date) -> Bool {
        guard !isUnlimited else { return false }
        let timeIntervalToVeryfy = abs(givenTarget.timeIntervalSinceNow)
        return timeIntervalToVeryfy > actualTimeInterval
    }
}
