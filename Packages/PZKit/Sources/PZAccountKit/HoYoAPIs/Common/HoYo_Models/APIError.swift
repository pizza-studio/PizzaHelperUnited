// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - MiHoYoAPIError

public enum MiHoYoAPIError: Error {
    case verificationNeeded
    case fingerPrintInvalidOrMissing
    case sTokenV2InvalidOrMissing
    case reloginRequired
    case serverUnderMaintenanceUpgrade
    case insufficientDataVisibility
    case countryRegionRestriction
    case other(retcode: Int, message: String)

    // MARK: Lifecycle

    public init(retcode: Int, message: String) {
        self = switch retcode {
        case 1034, 10035: .verificationNeeded
        case 5003, 10041: .fingerPrintInvalidOrMissing
        case 10102: .insufficientDataVisibility
        case -100, 10001: .reloginRequired
        case 10307: .serverUnderMaintenanceUpgrade
        case 403 where message.contains("Our services are not available in your country or region"):
            .countryRegionRestriction
        default: .other(retcode: retcode, message: message)
        }
    }
}

// MARK: LocalizedError

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, watchOS 8.0, *)
extension MiHoYoAPIError: LocalizedError {
    public var description: String { localizedDescription }

    public var localizedDescription: String {
        switch self {
        case .verificationNeeded: "MiHoYoAPIError.verificationNeeded".i18nAK
        case .fingerPrintInvalidOrMissing: "MiHoYoAPIError.fingerPrintInvalidOrMissing".i18nAK
        case .sTokenV2InvalidOrMissing: "MiHoYoAPIError.sTokenV2InvalidOrMissing".i18nAK
        case .reloginRequired: "MiHoYoAPIError.reloginRequired".i18nAK
        case .serverUnderMaintenanceUpgrade: "MiHoYoAPIError.serverUnderMaintenanceUpgrade".i18nAK
        case .insufficientDataVisibility: "MiHoYoAPIError.insufficientDataVisibility".i18nAK
        case .countryRegionRestriction: "MiHoYoAPIError.countryRegionRestriction".i18nAK
        case let .other(retcode, message): "[HoYoAPIErr] Ret: \(retcode); Msg: \(message)"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }
}

// MARK: MiHoYoAPIError.HoYoLABServerMsg

extension MiHoYoAPIError {
    struct HoYoLABServerMsg: AbleToCodeSendHash, CustomStringConvertible {
        let error: Int
        let message: String

        var description: String { "[HoYoAPIErr] Ret: \(error); Msg: \(message)" }
    }
}
