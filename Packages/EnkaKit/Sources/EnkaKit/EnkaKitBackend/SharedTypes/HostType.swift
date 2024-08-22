// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - Enka.HostType

extension Enka {
    public enum HostType: Int, Codable, RawRepresentable, Hashable {
        case mainlandChina = 0
        case enkaGlobal = 1

        // MARK: Lifecycle

        public init(uid: String) {
            var theUID = uid
            while theUID.count > 9 {
                theUID = theUID.dropFirst().description
            }
            guard let initial = theUID.first, let initialInt = Int(initial.description) else {
                self = .enkaGlobal
                return
            }
            switch initialInt {
            case 1 ... 5: self = .mainlandChina
            default: self = .enkaGlobal
            }
        }

        // MARK: Public

        public var viceVersa: Self {
            switch self {
            case .enkaGlobal: return .mainlandChina
            case .mainlandChina: return .enkaGlobal
            }
        }

        public var srsModelURL: URL {
            var urlStr: String = {
                switch self {
                case .mainlandChina: return "https://www.gitlink.org.cn/api/ShikiSuen/StarRailScore/raw/"
                case .enkaGlobal: return "https://raw.githubusercontent.com/Mar-7th/StarRailScore/master/"
                }
            }()
            urlStr += "score.json"
            if self == .mainlandChina {
                urlStr = Self.gitLinkURLWrapper(urlStr, branch: "master")
            }
            // swiftlint:disable force_unwrapping
            return .init(string: urlStr)!
            // swiftlint:enable force_unwrapping
        }

        public func enkaDBSourceURL(type: Enka.JSONType) -> URL {
            var urlStr: String = {
                switch self {
                case .mainlandChina: return "https://www.gitlink.org.cn/api/ShikiSuen/EnkaDBGenerator/raw/"
                case .enkaGlobal: return "https://raw.githubusercontent.com/ShikiSuen/EnkaDBGenerator/master/"
                }
            }()
            // swiftlint:disable force_unwrapping
            urlStr += type.repoFileInternalPath
            if self == .mainlandChina {
                urlStr = Self.gitLinkURLWrapper(urlStr, branch: "main")
            }
            return .init(string: urlStr)!
            // swiftlint:enable force_unwrapping
        }

        public func enkaProfileQueryURL(uid: String, game: Enka.GameType) -> URL {
            // swiftlint:disable force_unwrapping
            .init(string: profileQueryURLPrefix(game) + uid + profileQueryURLSuffix(game))!
            // swiftlint:enable force_unwrapping
        }

        // MARK: Internal

        static func gitLinkURLWrapper(_ urlStr: String, branch: String) -> String {
            "https://gitlink.org.cn/attachments/entries/get_file?download_url=\(urlStr)?ref=\(branch)"
        }

        // MARK: Private

        private func profileQueryURLPrefix(_ game: Enka.GameType) -> String {
            switch (self, game) {
            case (.mainlandChina, .starRail): return "https://api.mihomo.me/sr_info/"
            case (.enkaGlobal, .starRail): return "https://enka.network/api/hsr/uid/"
            case (.mainlandChina, .genshinImpact): return "https://profile.microgg.cn/api/uid/"
            case (.enkaGlobal, .genshinImpact): return "https://enka.network/api/uid/"
            }
        }

        private func profileQueryURLSuffix(_ game: Enka.GameType) -> String {
            switch (self, game) {
            case (.mainlandChina, .starRail): return "?is_force_update=true"
            default: return ""
            }
        }
    }
}