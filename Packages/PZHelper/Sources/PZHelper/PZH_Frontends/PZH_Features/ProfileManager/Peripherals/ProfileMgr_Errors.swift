// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - SaveProfileError

@available(iOS 16.2, macCatalyst 16.2, *)
enum SaveProfileError: Error, LocalizedError {
    case saveDataError(Error)
    case missingFieldError(String)

    // MARK: Public

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        let i18nInitial = localizedDescriptionHeaderKey.i18nPZHelper
        return switch self {
        case let .saveDataError(error): "\(i18nInitial)\(error)."
        case let .missingFieldError(field): "\(i18nInitial)\(field)."
        }
    }

    public var localizedDescriptionHeaderKey: String {
        switch self {
        case .saveDataError: "profileMgr.error.SaveProfileError.saveDataError:"
        case .missingFieldError: "profileMgr.error.SaveProfileError.missingFieldError:"
        }
    }

    public var errorDescription: String? {
        localizedDescription
    }

    public var failureReason: String? {
        switch self {
        case let .saveDataError(error): "Save Error: \(error)."
        case let .missingFieldError(field): "Missing Fields: \(field)."
        }
    }

    public var helpAnchor: String? {
        "profileMgr.error.SaveProfileError.helpAnchor".i18nPZHelper
    }
}

// MARK: - GetAccountError

@available(iOS 16.2, macCatalyst 16.2, *)
enum GetAccountError: LocalizedError {
    case source(Error)
    case customize(String)

    // MARK: Public

    public var errorDescription: String? { localizedDescription }

    public var description: String { localizedDescription }

    public var localizedDescription: String {
        switch self {
        case let .source(error): error.localizedDescription
        case let .customize(message): message
        }
    }
}
