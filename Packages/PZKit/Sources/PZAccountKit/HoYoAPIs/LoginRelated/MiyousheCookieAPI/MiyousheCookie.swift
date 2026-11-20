// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - HoYo.MiyousheCookie

extension HoYo {
    /// 米游社账号 Cookie 的规范化表示。
    ///
    /// 旧版 `account_id` / `cookie_token` / `ltoken` / `ltuid` 已自 2026-11-20 起被服务端废弃，
    /// 读取旧存档时仅作 V2 字段缺失时的兼容来源，写出时一律只写 V2 字段与本机签名所需的 `stoken` 三元组。
    public struct MiyousheCookie: Sendable, Hashable {
        // MARK: Lifecycle

        public init(
            accountIDV2: String = "",
            cookieTokenV2: String = "",
            ltokenV2: String = "",
            ltuidV2: String = "",
            mid: String = "",
            stoken: String = "",
            stuid: String = ""
        ) {
            self.accountIDV2 = accountIDV2
            self.cookieTokenV2 = cookieTokenV2
            self.ltokenV2 = ltokenV2
            self.ltuidV2 = ltuidV2
            self.mid = mid
            self.stoken = stoken
            self.stuid = stuid
        }

        /// 从 `key=value; key=value` 形式的 Cookie 文本解析，兼容旧版字段名与 V2 字段别名。
        public init(cookieString: String) {
            func nonEmpty(_ value: String?) -> String? {
                guard let value, !value.isEmpty else { return nil }
                return value
            }

            var canonical: [String: String] = [:]
            var aliased: [String: String] = [:]
            for segment in cookieString.split(whereSeparator: { $0 == ";" || $0.isNewline }) {
                let text = segment.trimmingCharacters(in: .whitespaces)
                guard let separator = text.firstIndex(of: "="),
                      separator != text.startIndex
                else { continue }
                let key = text[..<separator].trimmingCharacters(in: .whitespaces)
                let value = String(text[text.index(after: separator)...].trimmingCharacters(in: .whitespaces))
                guard !value.isEmpty else { continue }
                switch key {
                case "account_mid_v2", "ltmid_v2":
                    aliased["mid"] = value
                default:
                    if Self.fieldNames.contains(key) {
                        canonical[key] = value
                    } else if let legacyField = Self.legacyFieldNames[key] {
                        aliased[legacyField] = value
                    }
                }
            }

            func read(_ field: String) -> String {
                nonEmpty(canonical[field]) ?? nonEmpty(aliased[field]) ?? ""
            }

            let uid = nonEmpty(read("ltuid_v2")) ?? nonEmpty(read("account_id_v2")) ?? read("stuid")
            self.init(
                accountIDV2: nonEmpty(read("account_id_v2")) ?? uid,
                cookieTokenV2: read("cookie_token_v2"),
                ltokenV2: read("ltoken_v2"),
                ltuidV2: nonEmpty(read("ltuid_v2")) ?? uid,
                mid: read("mid"),
                stoken: read("stoken"),
                stuid: nonEmpty(read("stuid")) ?? uid
            )
        }

        // MARK: Public

        /// `account_id_v2`
        public var accountIDV2: String
        /// `cookie_token_v2`
        public var cookieTokenV2: String
        /// `ltoken_v2`
        public var ltokenV2: String
        /// `ltuid_v2`
        public var ltuidV2: String
        /// `mid`
        public var mid: String
        /// `stoken`。字段名自 V2 起未变，仍是换票的源头凭据。
        public var stoken: String
        /// `stuid`
        public var stuid: String

        /// 落库与复制用的 Cookie 文本，空字段省略。
        /// - Note: 网页端凭据与 App 端 `stoken` 三元组会一并写入，
        ///   让单一 Cookie 文本同时满足战绩、养成与 App 端签名等各类接口。
        public var cookieString: String {
            header(keys: Self.storedFields)
        }

        /// 米游社 App 端签名接口（K2 等 App salt）所需的 Cookie 头。
        public var appSigningCookieHeader: String {
            header(keys: ["mid", "stoken", "stuid"])
        }

        /// 米游社网页端接口所需的 V2 Cookie 头，`mid` 同时以两个别名下发。
        public var webCookieHeader: String {
            header(keys: [
                "account_id_v2", "account_mid_v2", "cookie_token_v2", "ltmid_v2", "ltoken_v2", "ltuid_v2",
            ])
        }

        /// 是否具备 `stoken` 换票所需的凭据。
        public var hasSTokenCredentials: Bool {
            !stuid.isEmpty && !stoken.isEmpty && !mid.isEmpty
        }

        // MARK: Private

        private enum Field: String {
            case accountIDV2 = "account_id_v2"
            case cookieTokenV2 = "cookie_token_v2"
            case ltokenV2 = "ltoken_v2"
            case ltuidV2 = "ltuid_v2"
            case mid
            case stoken
            case stuid
        }

        private static let canonicalFields: [String] = [
            Field.accountIDV2.rawValue, Field.cookieTokenV2.rawValue, Field.ltokenV2.rawValue,
            Field.ltuidV2.rawValue, Field.mid.rawValue, Field.stoken.rawValue, Field.stuid.rawValue,
        ]

        private static let storedFields: [String] = [
            "account_id_v2", "account_mid_v2", "cookie_token_v2", "ltmid_v2", "ltoken_v2", "ltuid_v2",
            "mid", "stoken", "stuid",
        ]

        private static let fieldNames: Set<String> = Set(canonicalFields)

        private static let legacyFieldNames: [String: String] = [
            "account_id": Field.accountIDV2.rawValue,
            "cookie_token": Field.cookieTokenV2.rawValue,
            "ltoken": Field.ltokenV2.rawValue,
            "ltuid": Field.ltuidV2.rawValue,
        ]

        private var allFields: [String: String] {
            [
                "account_id_v2": accountIDV2,
                "account_mid_v2": mid,
                "cookie_token_v2": cookieTokenV2,
                "ltmid_v2": mid,
                "ltoken_v2": ltokenV2,
                "ltuid_v2": ltuidV2,
                "mid": mid,
                "stoken": stoken,
                "stuid": stuid,
            ]
        }

        private func header(keys: [String]) -> String {
            let fields = allFields
            return keys.sorted()
                .compactMap { key in fields[key].flatMap { $0.isEmpty ? nil : "\(key)=\($0);" } }
                .joined()
        }
    }
}
