// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HoYoEventPack

public enum HoYoEventPack {
    public struct HoYoEventContent: DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public let list: [Announcement]
        public let total: Int
        public let picList: [PicAnnouncement]?
        public let picTotal: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case list
            case total
            case picList = "pic_list"
            case picTotal = "pic_total"
        }
    }

    public struct Announcement: AbleToCodeSendHash {
        // MARK: Public

        public let annId: Int
        public let title: String
        public let subtitle: String
        public let banner: String?
        public let content: String?
        public let lang: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case annId = "ann_id"
            case title
            case subtitle
            case banner
            case content
            case lang
        }
    }

    public struct PicAnnouncement: AbleToCodeSendHash {
        // MARK: Public

        public let annId: Int
        public let contentType: Int
        public let title: String
        public let subtitle: String
        public let banner: String?
        public let content: String?
        public let lang: String
        public let img: String?
        public let hrefType: Int
        public let href: String?
        public let picList: [PicListDetail]?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case annId = "ann_id"
            case contentType = "content_type"
            case title
            case subtitle
            case banner
            case content
            case lang
            case img
            case hrefType = "href_type"
            case href
            case picList = "pic_list"
        }
    }

    public struct PicListDetail: AbleToCodeSendHash {
        // MARK: Public

        public let title: String
        public let img: String
        public let hrefType: Int
        public let href: String?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case title
            case img
            case hrefType = "href_type"
            case href
        }
    }
}

extension HoYoEventPack {
    public struct HoYoEventMeta: DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public let list: [AnnouncementContentType]
        public let picTotal: Int

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case list
            case picTotal = "pic_total"
        }
    }

    public struct AnnouncementContentType: AbleToCodeSendHash {
        // MARK: Public

        public let list: [AnnouncementContent]
        public let typeId: Int
        public let typeLabel: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case list
            case typeId = "type_id"
            case typeLabel = "type_label"
        }
    }

    public struct AnnouncementContent: AbleToCodeSendHash {
        // MARK: Public

        public let annId: Int
        public let title: String
        public let subtitle: String
        public let banner: String
        public let content: String
        public let lang: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case annId = "ann_id"
            case title
            case subtitle
            case banner
            case content
            case lang
        }
    }
}
