// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - SaveProfileError

enum SaveProfileError: Error, LocalizedError {
    case saveDataError(Error)
    case missingFieldError(String)

    // MARK: Public

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        switch self {
        case let .saveDataError(error):
            return "\(localizedDescriptionHeaderKey.i18nPZHelper)\(error)."
        case let .missingFieldError(field):
            return "\(localizedDescriptionHeaderKey.i18nPZHelper)\(field)."
        }
    }

    public var localizedDescriptionHeaderKey: String {
        switch self {
        case .saveDataError:
            "profileMgr.error.SaveProfileError.saveDataError:"
        case .missingFieldError:
            "profileMgr.error.SaveProfileError.missingFieldError:"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }

    public var failureReason: String? {
        switch self {
        case let .saveDataError(error):
            return "Save Error: \(error)."
        case let .missingFieldError(field):
            return "Missing Fields: \(field)."
        }
    }

    public var helpAnchor: String? {
        "profileMgr.error.SaveProfileError.helpAnchor".i18nPZHelper
    }
}

// MARK: - GetAccountError

enum GetAccountError: LocalizedError {
    case source(Error)
    case customize(String)

    // MARK: Internal

    var errorDescription: String? {
        switch self {
        case let .source(error):
            return error.localizedDescription
        case let .customize(message):
            return message
        }
    }
}
