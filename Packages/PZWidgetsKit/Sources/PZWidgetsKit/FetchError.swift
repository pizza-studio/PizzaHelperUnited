// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - FetchError

// TODO: This file might not be necessary.

public enum FetchError: Error, Equatable {
    case noFetchInfo

    case cookieInvalid(Int, String) // 10001
    case unmachedAccountCookie(Int, String) // 10103, 10104
    case accountInvalid(Int, String) // 1008
    case dataNotFound(Int, String) // -1, 10102

    case notLoginError(Int, String) // -100

    case decodeError(String)

    case requestError(RequestError)

    case unknownError(Int, String)

    case defaultStatus

    case accountUnbound

    case errorWithCode(Int)

    case accountAbnormal(Int) // 1034

    case noStoken

    // MARK: Public

    public static func == (lhs: FetchError, rhs: FetchError) -> Bool {
        lhs.description == rhs.description && lhs.message == rhs.message
    }
}

extension FetchError {
    public var description: String {
        switch self {
        case .defaultStatus:
            return "error.refresh".i18nWidgets
        case .noFetchInfo:
            return "error.selectAccount".i18nWidgets
        case let .cookieInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "error.cookieInvalid:%lld",
                    comment: "错误码%@：Cookie失效，请重新登录"
                ),
                retcode
            )
        case let .unmachedAccountCookie(retcode, _):
            return String(
                format: NSLocalizedString(
                    "error.uidNotMatch:%lld",
                    comment: "错误码%@：米游社账号与UID不匹配"
                ),
                retcode
            )
        case let .accountInvalid(retcode, _):
            return String(
                format: NSLocalizedString(
                    "error.uidError:%lld",
                    comment: "错误码%@：UID有误"
                ),
                retcode
            )
        case .dataNotFound:
            return "error.gotoHoyolab".i18nWidgets
        case .decodeError:
            return "error.decodeError".i18nWidgets
        case .requestError:
            return "error.networkError".i18nWidgets
        case .notLoginError:
            return "settings.account.error.failedFromFetchingAccountInformation".i18nWidgets
        case let .unknownError(retcode, _):
            return String(
                format: NSLocalizedString("error.unknown:%lld", comment: "error.unknown:%lld"),
                retcode
            )
        case .accountAbnormal:
            return "requestRelated.accountStatusAbnormal.errorMessage".i18nWidgets
        case .noStoken:
            return "settings.notification.note.relogin".i18nWidgets
        default:
            return ""
        }
    }

    public var message: String {
        switch self {
        case .defaultStatus:
            return ""

        case .noFetchInfo:
            return ""
        case let .notLoginError(retcode, message):
            return "(\(retcode))" + message
        case .cookieInvalid:
            return ""
        case let .unmachedAccountCookie(_, message):
            return message
        case let .accountInvalid(_, message):
            return message
        case let .dataNotFound(retcode, message):
            return "(\(retcode))" + message
        case let .decodeError(message):
            return message
        case let .requestError(requestError):
            switch requestError {
            case let .dataTaskError(message):
                return "\(message)"
            case .noResponseData:
                return "error.noReturnBack".i18nWidgets
            case .responseError:
                return "error.noResponse".i18nWidgets
            default:
                return "error.unknown".i18nWidgets
            }
        case .accountAbnormal:
            return "requestRelated.accountStatusAbnormal.promptForVerificationInApp".i18nWidgets
        case let .unknownError(_, message):
            return message
        case .noStoken:
            return "settings.notification.note.relogin".i18nWidgets
        default:
            return ""
        }
    }
}
