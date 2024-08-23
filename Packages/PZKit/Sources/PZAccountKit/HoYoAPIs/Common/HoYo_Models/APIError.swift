// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

public enum MiHoYoAPIError: Error, LocalizedError {
    case verificationNeeded
    case fingerPrintNeeded
    case noSTokenV2
    case other(retcode: Int, message: String)

    // MARK: Lifecycle

    public init(retcode: Int, message: String) {
        if retcode == 1034 || retcode == 10035 {
            self = .verificationNeeded
        } else if retcode == 5003 {
            self = .fingerPrintNeeded
        } else {
            self = .other(retcode: retcode, message: message)
        }
    }

    // MARK: Public

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        switch self {
        case .verificationNeeded: "MiHoYoAPIError.verificationNeeded".i18nAK
        case .fingerPrintNeeded: "MiHoYoAPIError.fingerPrintNeeded".i18nAK
        case .noSTokenV2: "MiHoYoAPIError.noSTokenV2".i18nAK
        case let .other(retcode, message):
            "[HoYoAPIErr] Ret: \(retcode); Msg: \(message)"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }
}
