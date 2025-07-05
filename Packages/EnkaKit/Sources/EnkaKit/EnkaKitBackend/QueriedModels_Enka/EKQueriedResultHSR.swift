// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit

// MARK: - Enka.QueriedResultHSR

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension Enka {
    public struct QueriedResultHSR: AbleToCodeSendHash, EKQueryResultProtocol {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.detailInfo = try container.decodeIfPresent(QueriedProfileHSR.self, forKey: .detailInfo)
            self.uid = try container.decodeIfPresent(String.self, forKey: .uid)
            self.detail = try container.decodeIfPresent(String.self, forKey: .detail)
            let primaryMessage = try container.decodeIfPresent(String.self, forKey: .message)
            var secondaryMessage = try container.decodeIfPresent(String.self, forKey: .detail)
            if let message2nd = secondaryMessage {
                secondaryMessage? = "[miHoMo] \(message2nd)"
            }
            self.message = primaryMessage ?? secondaryMessage
        }

        // MARK: Public

        public typealias QueriedProfileType = Enka.QueriedProfileHSR
        public typealias DBType = Enka.EnkaDB4HSR

        public static var game: Enka.GameType { .starRail }

        public var detailInfo: QueriedProfileHSR?
        public var uid: String?
        /// Enka 偶尔会返回错误讯息。
        public var message: String?
        // MicroGG 错误讯息。
        public var detail: String?

        // MARK: Private

        private enum CodingKeys: CodingKey {
            case detailInfo
            case uid
            case message
            case detail
        }
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension Enka.QueriedResultHSR {
    public static func exampleData() throws -> Self {
        let exampleURL = Bundle.module.url(
            forResource: "testEnkaProfileHSR",
            withExtension: "json"
        )!
        let exampleData = try Data(contentsOf: exampleURL)
        return try JSONDecoder().decode(Self.self, from: exampleData)
    }
}
