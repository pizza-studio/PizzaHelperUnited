// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - RequestError

public enum RequestError: Error, LocalizedError {
    case dataTaskError(String)
    case noResponseData
    case responseError
    case decodeError(String)
    case errorWithCode(Int)

    // MARK: Public

    public var errorDescription: String? { localizedDescription }

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        func wrapString(_ str: String) -> String {
            "=======\n\(str)\n======="
        }
        let msg = switch self {
        case let .dataTaskError(string): "Data Task Error:\n\(wrapString(string))\n"
        case .noResponseData: "Data is not attached in the HTTP response."
        case .responseError: "HTTP Response Error. (RequestError.responseError)"
        case let .decodeError(string): "JSON Decode Error. Raw Contents:\n\(wrapString(string))\n"
        case let .errorWithCode(int): "Request Error (Code \(int))."
        }
        return "[PZReqErr] " + msg
    }
}
