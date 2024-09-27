// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - GachaRequestAuthentication

public struct GachaRequestAuthentication: Sendable {
    public let authenticationKey: String
    public let authenticationKeyVersion: String
    public let signType: String
    public let server: HoYo.Server
}

// MARK: - GachaError

public enum GachaError: Error, Sendable {
    case fetchDataError(page: Int, size: Int, gachaTypeRaw: String, error: Error)
}

// MARK: - ParseGachaURLError

public enum ParseGachaURLError: String, Error, LocalizedError {
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

public enum GenGachaURLError: Error {
    case genURLError(message: String)
}
