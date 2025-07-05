// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

// MARK: - HoYoEventPack

public struct HoYoEventPack: AbleToCodeSendHash {
    public let content: HoYoEventContent
    public let meta: HoYoEventMeta
}

extension HoYoEventPack {
    public struct HoYoEventContent: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
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

        public let annID: Int
        public let title: String
        public let subtitle: String
        public let banner: String?
        public let content: String?
        public let lang: HoYo.APILang

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case annID = "ann_id"
            case title
            case subtitle
            case banner
            case content
            case lang
        }
    }

    public struct PicAnnouncement: AbleToCodeSendHash {
        // MARK: Public

        public let annID: Int
        public let contentType: Int
        public let title: String
        public let subtitle: String
        public let banner: String?
        public let content: String?
        public let lang: HoYo.APILang
        public let img: String?
        public let hrefType: Int
        public let href: String?
        public let picList: [PicListDetail]?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case annID = "ann_id"
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
    public struct HoYoEventMeta: AbleToCodeSendHash, DecodableFromMiHoYoAPIJSONResult {
        // MARK: Public

        public let list: [MetaType]
        public let total: Int
        public let typeList: [TypeList]
        public let alert: Bool
        public let alertID: Int
        public let timezone: Int
        public let t: String
        public let picList: [PicList]
        public let picTotal: Int
        public let picTypeList: [PicTypeList]
        public let picAlert: Bool
        public let picAlertID: Int
        public let staticSign: String
        public let banner: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case list
            case total
            case typeList = "type_list"
            case alert
            case alertID = "alert_id"
            case timezone
            case t
            case picList = "pic_list"
            case picTotal = "pic_total"
            case picTypeList = "pic_type_list"
            case picAlert = "pic_alert"
            case picAlertID = "pic_alert_id"
            case staticSign = "static_sign"
            case banner
        }
    }

    public struct MetaType: AbleToCodeSendHash {
        // MARK: Public

        public let list: [Meta]
        public let typeID: Int?
        public let typeLabel: String?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case list
            case typeID = "type_id"
            case typeLabel = "type_label"
        }
    }

    public struct Meta: AbleToCodeSendHash {
        // MARK: Public

        public let annID: Int
        public let title: String
        public let subtitle: String
        public let banner: String
        public let img: String?
        public let content: String
        public let typeLabel: String
        public let tagLabel: String
        public let tagIcon: String
        public let loginAlert: Int
        public let lang: HoYo.APILang
        public let startTime: String
        public let endTime: String
        public let type: Int
        public let remind: Int
        public let alert: Int
        public let tagStartTime: String
        public let tagEndTime: String
        public let remindVer: Int
        public let hasContent: Bool
        public let extraRemind: Int
        public let tagIconHover: String?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case annID = "ann_id"
            case title
            case subtitle
            case banner
            case img
            case content
            case typeLabel = "type_label"
            case tagLabel = "tag_label"
            case tagIcon = "tag_icon"
            case loginAlert = "login_alert"
            case lang
            case startTime = "start_time"
            case endTime = "end_time"
            case type
            case remind
            case alert
            case tagStartTime = "tag_start_time"
            case tagEndTime = "tag_end_time"
            case remindVer = "remind_ver"
            case hasContent = "has_content"
            case extraRemind = "extra_remind"
            case tagIconHover = "tag_icon_hover"
        }
    }

    public struct TypeList: AbleToCodeSendHash {
        // MARK: Public

        public let id: Int
        public let name: String
        public let mi18nName: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case mi18nName = "mi18n_name"
        }
    }

    public struct PicList: AbleToCodeSendHash {
        // MARK: Public

        public let typeList: [MetaType]
        public let typeID: Int?
        public let typeLabel: String?

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case typeList = "type_list"
            case typeID = "type_id"
            case typeLabel = "type_label"
        }
    }

    public struct PicTypeList: AbleToCodeSendHash {
        // MARK: Public

        public let id: Int
        public let name: String
        public let mi18nName: String

        // MARK: Internal

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case mi18nName = "mi18n_name"
        }
    }
}
