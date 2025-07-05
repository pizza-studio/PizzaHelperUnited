// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
struct LinkLabelItem: View {
    // MARK: Lifecycle

    public init(_ type: ItemType) {
        self = switch type {
        case let .staticText(verbatim, imageKey, url):
            .init(verbatim: verbatim, imageKey: imageKey, url: url)
        case let .localizedText(key, imageKey, url):
            .init(key, imageKey: imageKey, url: url)
        case let .email(email):
            .init(email: email)
        case let .qqPersonal(id):
            .init(qqPersonal: id)
        case let .qqGroup(id, titleOverride, verbatim):
            .init(qqGroup: id, titleOverride: titleOverride, verbatim: verbatim)
        case let .qqChannel(id):
            .init(qqChannel: id)
        case let .homePagePersonal(urlStr):
            .init(homePage: urlStr)
        case let .homePageOfficial(urlStr):
            .init(officialWebsite: urlStr)
        case let .twitter(id, titleOverride, verbatim):
            .init(twitter: id, titleOverride: titleOverride, verbatim: verbatim)
        case let .blueSky(id, titleOverride, verbatim):
            .init(blueSky: id, titleOverride: titleOverride, verbatim: verbatim)
        case let .telegram(id: id, titleOverride: titleOverride, verbatim: verbatim):
            .init(telegram: id, titleOverride: titleOverride, verbatim: verbatim)
        case let .youtube(urlStr):
            .init(youtube: urlStr)
        case let .bilibiliSpace(bUID):
            .init(bilibiliSpace: bUID)
        case let .github(userID):
            .init(github: userID)
        case let .neteaseMusic(artistID):
            .init(neteaseMusic: artistID)
        case let .tiktokGlobal(id: id):
            .init(tiktokGlobal: id)
        case let .tiktokCN(url: url):
            .init(tiktokCN: url)
        case let .discord(url: url):
            .init(discord: url)
        case let .facebook(url):
            .init(facebook: url)
        case let .appStore(url: url):
            .init(appStore: url)
        }
    }

    private init(verbatim: String, imageKey: String, url: String) {
        self.text = verbatim
        self.imageKey = imageKey
        self.destination = URL(string: url)!
    }

    private init(_ textKey: String, imageKey: String, url: String) {
        self.text = String(localized: .init(stringLiteral: textKey), bundle: .module)
        self.imageKey = imageKey
        self.destination = URL(string: url)!
    }

    private init(email: String) {
        self.text = email
        self.imageKey = "icon.email"
        self.destination = URL(string: "mailto:\(email)")!
    }

    private init(qqPersonal: String) {
        var urlStr = "mqqapi://card/show_pslcard?"
        urlStr.append("src_type=internal&version=1&uin=\(qqPersonal)")
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.qq.personal"), bundle: .module)
        self.imageKey = "icon.qq.circle"
        self.destination = URL(string: urlStr)!
    }

    private init(
        qqGroup: String,
        titleOverride: String? = nil,
        verbatim: Bool = false
    ) {
        var urlStr = "mqqapi://card/show_pslcard?"
        urlStr.append("src_type=internal&version=1&card_type=group&uin=\(qqGroup)")
        let fallbackKeyHeader: String.LocalizationValue = "aboutKit.contactMethod.qq.group.initials"
        let fallbackKey = String(localized: fallbackKeyHeader, bundle: .module) + qqGroup
        if verbatim {
            self.text = titleOverride ?? fallbackKey
        } else {
            if let titleOverride {
                self.text = String(localized: .init(stringLiteral: titleOverride), bundle: .module)
            } else {
                self.text = fallbackKey
            }
        }
        self.imageKey = "icon.qq"
        self.destination = URL(string: urlStr)!
    }

    private init(qqChannel: String) {
        let urlStr = "https://pd.qq.com/s/\(qqChannel)"
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.qq.channel"), bundle: .module)
        self.imageKey = "icon.qq.channel"
        self.destination = URL(string: urlStr)!
    }

    private init(homePage: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.homepage"), bundle: .module)
        self.imageKey = "icon.homepage"
        self.destination = URL(string: homePage)!
    }

    private init(officialWebsite: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.officialWebsite"), bundle: .module)
        self.imageKey = "icon.homepage"
        self.destination = URL(string: officialWebsite)!
    }

    private init(
        telegram tgID: String,
        titleOverride: String? = nil,
        verbatim: Bool = false
    ) {
        let fallbackKey = "aboutKit.contactMethod.telegram"
        if verbatim {
            self.text = titleOverride ?? String(localized: .init(stringLiteral: fallbackKey), bundle: .module)
        } else {
            self.text = String(localized: .init(stringLiteral: titleOverride ?? fallbackKey), bundle: .module)
        }
        self.imageKey = "icon.telegram"
        self.destination = URL(string: "https://t.me/\(tgID)")!
    }

    private init(
        twitter twitterName: String,
        titleOverride: String? = nil,
        verbatim: Bool = false
    ) {
        let fallbackKey = "aboutKit.contactMethod.twitter"
        if verbatim {
            self.text = titleOverride ?? String(localized: .init(stringLiteral: fallbackKey), bundle: .module)
        } else {
            self.text = String(localized: .init(stringLiteral: titleOverride ?? fallbackKey), bundle: .module)
        }
        self.imageKey = "icon.twitter"
        self.destination = URL(string: "https://twitter.com/\(twitterName)")!
    }

    private init(
        blueSky bskyName: String,
        titleOverride: String? = nil,
        verbatim: Bool = false
    ) {
        let fallbackKey = "aboutKit.contactMethod.blueSky"
        if verbatim {
            self.text = titleOverride ?? String(localized: .init(stringLiteral: fallbackKey), bundle: .module)
        } else {
            self.text = String(localized: .init(stringLiteral: titleOverride ?? fallbackKey), bundle: .module)
        }
        self.imageKey = "icon.bsky"
        self.destination = URL(string: "https://twitter.com/\(bskyName)")!
    }

    private init(youtube youtubeURLStr: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.youtube"), bundle: .module)
        self.imageKey = "icon.youtube"
        self.destination = URL(string: youtubeURLStr)!
    }

    private init(bilibiliSpace buid: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.bilibili"), bundle: .module)
        self.imageKey = "icon.bilibili"
        self.destination = URL(string: "https://space.bilibili.com/\(buid)")!
    }

    private init(github ghName: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.github"), bundle: .module)
        self.imageKey = "icon.github"
        self.destination = URL(string: "https://github.com/\(ghName)")!
    }

    private init(neteaseMusic artistID: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.163MusicArtistHP"), bundle: .module)
        self.imageKey = "icon.163CloudMusic"
        self.destination = URL(string: "https://music.163.com/#/artist/desc?id=\(artistID)")!
    }

    private init(tiktokGlobal tiktokID: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.tiktok"), bundle: .module)
        self.imageKey = "icon.tiktok"
        self.destination = URL(string: "https://www.tiktok.com/@\(tiktokID)")!
    }

    private init(tiktokCN urlStr: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.douyin"), bundle: .module)
        self.imageKey = "icon.tiktok"
        self.destination = urlStr.asURL
    }

    private init(discord urlStr: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.discord"), bundle: .module)
        self.imageKey = "icon.discord"
        self.destination = urlStr.asURL
    }

    private init(facebook urlStr: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.facebook"), bundle: .module)
        self.imageKey = "icon.facebook"
        self.destination = urlStr.asURL
    }

    private init(appStore urlStr: String) {
        self.text = String(localized: .init(stringLiteral: "aboutKit.contactMethod.appStore"), bundle: .module)
        self.imageKey = "icon.appStore"
        self.destination = urlStr.asURL
    }

    // MARK: Public

    public enum ItemType: Identifiable {
        case staticText(verbatim: String, imageKey: String, url: String)
        case localizedText(key: String, imageKey: String, url: String)
        case email(_ email: String)
        case qqPersonal(id: String)
        case qqGroup(id: String, titleOverride: String? = nil, verbatim: Bool = false)
        case qqChannel(id: String)
        case homePagePersonal(urlStr: String)
        case homePageOfficial(urlStr: String)
        case twitter(id: String, titleOverride: String? = nil, verbatim: Bool = false)
        case blueSky(id: String, titleOverride: String? = nil, verbatim: Bool = false)
        case youtube(urlStr: String)
        case bilibiliSpace(bUID: String)
        case github(userID: String)
        case neteaseMusic(artistID: String)
        case tiktokGlobal(id: String)
        case tiktokCN(url: String)
        case discord(url: String)
        case facebook(url: String)
        case appStore(url: String)
        case telegram(id: String, titleOverride: String? = nil, verbatim: Bool = false)

        // MARK: Public

        public var id: String { String(describing: self) }

        @MainActor @ViewBuilder public var asView: some View {
            LinkLabelItem(self)
        }

        @MainActor @ViewBuilder public var asMenuItem4MacOS: some View {
            LinkLabelItem(self).bodyAsMenuItemForMacOS
        }
    }

    public var body: some View {
        Link(destination: destination) {
            Label {
                Text(verbatim: text)
            } icon: {
                Image(imageKey, bundle: .module)
                    .resizable()
                    .scaledToFit()
            }
            .alignmentGuide(.listRowSeparatorLeading) { d in
                d[.leading] + 40
            }
        }
    }

    @ViewBuilder public var bodyAsMenuItemForMacOS: some View {
        Link(destination: destination) {
            Text(verbatim: text)
        }
    }

    // MARK: Private

    private let text: String
    private let imageKey: String
    private let destination: URL

    private static func isAppInstalled(urlString: String?) -> Bool {
        #if os(iOS)
        let url = urlString?.asURL
        guard let url else { return false }
        return UIApplication.shared.canOpenURL(url)
        #else
        return false
        #endif
    }
}
