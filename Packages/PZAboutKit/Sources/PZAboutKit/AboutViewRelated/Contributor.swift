// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - Contributor

enum Contributor: String, Identifiable, Sendable, CaseIterable {
    case lava
    case hakubill
    case shikisuen
    case xinzoruo
    case koni
    case yulijushi
    case pan93412
    case taotao
    case art34222
    case ngo
    case qiFrench
    case escartem

    // MARK: Public

    public typealias LinkType = LinkLabelItem.ItemType

    public var id: String { rawValue }

    public var isCrewMember: Bool {
        switch self {
        case .lava: true
        case .hakubill: true
        case .shikisuen: true
        default: false
        }
    }

    public var iconAssetName: String {
        switch self {
        case .lava: "avatar.lava"
        case .hakubill: "avatar.hakubill"
        case .shikisuen: "avatar.shikisuen"
        case .art34222: "avatar.art34222"
        case .yulijushi: "avatar.jushi"
        case .pan93412: "avatar.pan93412"
        case .koni: "avatar.koni"
        case .ngo: "avatar.ngo"
        case .qiFrench: "avatar.qi"
        case .escartem: "avatar.escartem"
        case .taotao: "avatar.tao"
        case .xinzoruo: "avatar.xinzoruo"
        }
    }

    public var title: String {
        let rawNameKey: String.LocalizationValue = switch self {
        case .lava: "aboutKit.contributors.name.lava"
        case .hakubill: "aboutKit.contributors.name.hakubill"
        case .shikisuen: "aboutKit.contributors.name.shikisuen"
        case .art34222: "aboutKit.contributors.name.art34222"
        case .yulijushi: "aboutKit.contributors.name.yulijushi"
        case .pan93412: "aboutKit.contributors.name.pan93412"
        case .koni: "aboutKit.contributors.name.koni"
        case .ngo: "aboutKit.contributors.name.ngo"
        case .qiFrench: "aboutKit.contributors.name.qi"
        case .escartem: "aboutKit.contributors.name.escartem"
        case .taotao: "aboutKit.contributors.name.tao"
        case .xinzoruo: "aboutKit.contributors.name.xinzoruo"
        }
        return String(localized: rawNameKey, bundle: .module)
    }

    @ArrayBuilder<LinkType?> public var links: [LinkType?] {
        switch self {
        case .lava:
            LinkType.email("daicanglong@gmail.com")
            LinkType.bilibiliSpace(bUID: "13079935")
            LinkType.github(userID: "CanglongCl")
        case .hakubill:
            LinkType.homePagePersonal(urlStr: "https://hakubill.tech")
            LinkType.email("i@hakubill.tech")
            LinkType.twitter(id: "Haku_Bill")
            LinkType.youtube(
                urlStr: "https://www.youtube.com/channel/UC0ABPKMmJa2hd5nNKh5HGqw"
            )
            LinkType.bilibiliSpace(bUID: "158463764")
            LinkType.github(userID: "Bill-Haku")
        case .shikisuen:
            LinkType.neteaseMusic(artistID: "60323623")
            LinkType.homePagePersonal(urlStr: "https://shikisuen.github.io/")
            LinkType.email("shikisuen@yeah.net")
            LinkType.twitter(id: "ShikiSuen")
            LinkType.bilibiliSpace(bUID: "911304")
            LinkType.github(userID: "ShikiSuen")
            LinkType.blueSky(id: "shikisuen")
        case .art34222: nil
        case .pan93412:
            LinkType.github(userID: "pan93412")
        case .yulijushi:
            LinkType.qqPersonal(id: "2251435011")
        case .koni:
            LinkType.homePagePersonal(urlStr: "https://lit.link/en/koni1")
        case .ngo:
            LinkType.facebook(url: "https://www.facebook.com/ngo.phi.phuongg")
        case .qiFrench: nil
        case .escartem:
            LinkType.homePagePersonal(urlStr: "https://escartem.moe")
            LinkType.github(userID: "Escartem")
        case .taotao:
            LinkType.twitter(id: "taotao_hoyo")
            LinkType.youtube(urlStr: "https://youtube.com/c/hutao_taotao")
            LinkType.tiktokGlobal(id: "taotao_hoyo")
        case .xinzoruo:
            LinkType.twitter(id: "xinzoruo")
        }
    }

    public var retireDate: Date? {
        switch self {
        case .lava:
            // 2024-OCT-01, GMT+8
            Date(timeIntervalSince1970: 1727712000)
        case .hakubill:
            // 2024-MAY-20, GMT+8
            Date(timeIntervalSince1970: 1716134400)
        case .shikisuen: nil
        default: nil
        }
    }

    public var subtitleAsMainCrew: String? {
        let key: String.LocalizationValue? = switch self {
        case .lava: "aboutKit.contributor.subtitleAsMainCrew.lava"
        case .hakubill: "aboutKit.contributor.subtitleAsMainCrew.hakubill"
        case .shikisuen: "aboutKit.contributor.subtitleAsMainCrew.shikisuen"
        default: nil
        }
        guard let key else { return nil }
        return String(localized: key, bundle: .module)
    }

    public var subtitleAsAssetCrew: String? {
        let key: String.LocalizationValue? = switch self {
        case .lava: "aboutKit.contributor.subtitleAsAssetCrew.lava"
        case .koni: "aboutKit.contributor.subtitleAsAssetCrew.koni"
        case .xinzoruo: "aboutKit.contributor.subtitleAsAssetCrew.xinzoruo"
        case .yulijushi: "aboutKit.contributor.subtitleAsAssetCrew.yulijushi"
        default: nil
        }
        guard let key else { return nil }
        return String(localized: key, bundle: .module)
    }

    public var subtitleAsL10nLanguagesCurrent: String? {
        // 回头把新的翻译者记录在此处即可。
        switch self {
        case .shikisuen: "zh-Hans, zh-Hant, en-US, ja-JP"
        case .lava: "zh-Hans (fixes)"
        case .hakubill: "zh-Hans (fixes)"
        case .escartem: "fr (fixes)"
        case .pan93412: "[GPT] fil, fr, de, it, ko-KR, ru, es, vi"
        default: nil
        }
    }

    public var subtitleAsL10nLanguagesPrevious: String? {
        switch self {
        case .lava: "en-US"
        case .hakubill: "ja-JP"
        case .shikisuen: "zh-Hant: en-US: ja-JP"
        case .qiFrench: "fr-FR"
        case .taotao: "ja-JP"
        case .ngo: "vi-VI"
        case .art34222: "ru-RU"
        default: nil
        }
    }
}

extension Contributor {
    public static var mainCrew: [Self] {
        allCases.filter(\.isCrewMember)
    }

    public static var i18nCrewPrevious: [Self] {
        allCases.filter { $0.subtitleAsL10nLanguagesPrevious != nil }
    }

    public static var i18nCrewCurrent: [Self] {
        allCases.filter { $0.subtitleAsL10nLanguagesCurrent != nil }
    }

    public static var assetCrew: [Self] {
        allCases.filter { $0.subtitleAsAssetCrew != nil }
    }

    @MainActor @ViewBuilder
    func asView(
        big: Bool,
        subtitle: String? = nil
    )
        -> some View {
        ContributorItem(
            main: big,
            icon: iconAssetName,
            title: title,
            subtitle: subtitle,
            retireDate: retireDate
        ) {
            for link in links { link }
        }
    }
}
