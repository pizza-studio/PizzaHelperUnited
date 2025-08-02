// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import PZBaseKit

// MARK: - Enka.QueriedResultGI

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    public struct QueriedResultGI: AbleToCodeSendHash, EKQueryResultProtocol {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.detailInfo = try container.decodeIfPresent(QueriedProfileGI.self, forKey: .detailInfo)
            self.ttl = try container.decodeIfPresent(Int.self, forKey: .ttl)
            if let uid = try container.decodeIfPresent(String.self, forKey: .uid) {
                self.uid = uid
                detailInfo?.uid = uid
            } else {
                self.uid = nil
            }
            let primaryMessage = try container.decodeIfPresent(String.self, forKey: .message)
            var secondaryMessage = try container.decodeIfPresent(String.self, forKey: .detail)
            if let message2nd = secondaryMessage {
                secondaryMessage? = "[MicroGG] \(message2nd)"
            }
            self.message = primaryMessage ?? secondaryMessage
            /// 特殊措施：将 avatarInfoList 塞到 detailInfo 里面，方便本地存根。
            if let guardedDetailInfo = detailInfo, guardedDetailInfo.avatarDetailList.isEmpty {
                detailInfo?.avatarDetailList = try container.decodeIfPresent(
                    [Enka.QueriedProfileGI.QueriedAvatar].self,
                    forKey: .avatarInfoList
                ) ?? []
                self.avatarInfoList = nil
            }
        }

        // MARK: Public

        public typealias DBType = Enka.EnkaDB4GI

        public static var game: Enka.GameType { .genshinImpact }

        /// 账号基本资讯
        public var detailInfo: QueriedProfileGI?
        public var ttl: Int?
        /// Enka 偶尔会返回错误讯息。
        public var message: String?
        // MicroGG 错误讯息。
        public var detail: String?

        public var uid: String? {
            didSet {
                if detailInfo != nil, let uid {
                    detailInfo?.uid = uid
                }
            }
        }

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case detailInfo = "playerInfo"
            case avatarInfoList
            case ttl
            case uid
            case message
            case detail
        }

        // MARK: Private

        /// 正在展示的角色的详细资讯
        private var avatarInfoList: [QueriedProfileGI.QueriedAvatar]?
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.QueriedResultGI {
    public static func exampleData() throws -> Self {
        let exampleURL = Bundle.module.url(
            forResource: "testEnkaProfileGI",
            withExtension: "json"
        )!
        let exampleData = try Data(contentsOf: exampleURL)
        return try JSONDecoder().decode(Self.self, from: exampleData)
    }
}
