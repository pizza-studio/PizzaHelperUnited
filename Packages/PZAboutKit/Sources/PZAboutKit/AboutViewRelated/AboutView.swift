// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - AboutView

public struct AboutView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = {
        let locVal: String.LocalizationValue = "aboutKit.aboutView.navTitle"
        return String(localized: locVal, bundle: .module)
    }()

    @ViewBuilder public static var navIcon: some View {
        Image("icon.product.pzHelper", bundle: .module)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    public var body: some View {
        NavigationStack {
            Form {
                switch isShowingCrew {
                case false: AppAboutViewSections().task {
                        await ASMetaSputnik.shared.updateMeta()
                    }
                case true: DevCrewViewSections()
                }
            }
            .formStyle(.grouped)
            .navigationTitle(internalNavTitle)
            .navBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Picker(selection: $isShowingCrew.animation()) {
                        Text("aboutKit.aboutView.tab.app", bundle: .module).tag(false)
                        Text("aboutKit.aboutView.tab.crew", bundle: .module).tag(true)
                    } label: {
                        EmptyView()
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
            }
        }
    }

    // MARK: Private

    @State private var isShowingCrew: Bool = false

    private var internalNavTitle: String {
        let locVal: String.LocalizationValue = switch isShowingCrew {
        case false: "aboutKit.aboutView.navTitle.app"
        case true: "aboutKit.aboutView.navTitle.crew"
        }
        return String(localized: locVal, bundle: .module)
    }
}

// MARK: - AppAboutViewSections

struct AppAboutViewSections: View {
    // MARK: Internal

    typealias LinkType = LinkLabelItem.ItemType

    var body: some View {
        Section {
            ContributorItem(
                isExpanded: true,
                main: true,
                icon: "icon.product.pzHelper",
                titleKey: "aboutKit.ourApps.pzHelper",
                subtitleKey: "aboutKit.ourApps.pzHelper.description"
            ) {
                LinkType.github(userID: "pizza-studio/PizzaHelperUnited")
            }
        } header: {
            HStack {
                if let versionIntel = try? Bundle.getAppVersionAndBuild() {
                    let versionStr = "\(versionIntel.version) Build \(versionIntel.build)"
                    Text(verbatim: versionStr)
                        .textCase(.none)
                        .lineLimit(1)
                        .fixedSize()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                let hasNewVersion = cachedAppStoreMeta?.isNewerThanCurrentVersion ?? false
                if hasNewVersion, let url = URL(string: "https://apps.apple.com/app/id1635319193") {
                    Link(destination: url) {
                        Text("aboutKit.ourApps.clickHereToUpdate", bundle: .module)
                            .textCase(.none)
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
            }
        } footer: {
            VStack(alignment: .leading, spacing: 10) {
                Text(verbatim: "桂ICP备2023009538号-2A")
                    .textCase(.none)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("aboutKit.ourApps.miHoYoCopyrightNotice", bundle: .module)
                    .textCase(.none)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("aboutKit.ourApps.pizzaStudioCopyrightNotice", bundle: .module)
                    .textCase(.none)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity)
        }

        Section {
            ContributorItem(
                main: false,
                icon: "icon.product.pzHelper4GI",
                titleKey: "aboutKit.ourApps.pzHelper4GI",
                subtitleKey: "aboutKit.ourApps.pzHelper4GI.description"
            ) {
                LinkType.github(userID: "pizza-studio/GenshinPizzaHelper")
            }
            ContributorItem(
                main: false,
                icon: "icon.product.pzHelper4HSR",
                titleKey: "aboutKit.ourApps.pzHelper4HSR",
                subtitleKey: "aboutKit.ourApps.pzHelper4HSR.description"
            ) {
                LinkType.github(userID: "pizza-studio/HSRPizzaHelper")
            }
            ContributorItem(
                main: false,
                icon: "icon.product.pzHelper4BA",
                titleKey: "aboutKit.ourApps.pzHelper4BA",
                subtitleKey: "aboutKit.ourApps.pzHelper4BA.description"
            ) {
                LinkType.github(userID: "pizza-studio/BAPizzaHelper")
                LinkType.appStore(url: "https://apps.apple.com/app/id6455496812")
            }
        }

        // app contact
        Section(
            header: Text("aboutKit.chatrooms.header", bundle: .module),
            footer: Text(groupFooterText).textCase(.none)
        ) {
            ContributorItem(main: false, icon: "icon.qq", titleKey: "aboutKit.chatrooms.joinQQGroup") {
                LinkType.qqChannel(id: "9z504ipbc")
                LinkType.qqGroup(id: "813912474")
                LinkType.qqGroup(id: "829996515")
                LinkType.qqGroup(id: "736320270")
            }
            .alignmentGuide(.listRowSeparatorLeading) { d in
                d[.leading] + 40
            }

            ContributorItem(main: false, icon: "icon.telegram", titleKey: "aboutKit.chatrooms.joinTelegram") {
                LinkType.telegram(id: "ophelper_zh", titleOverride: "Telegram 中文频道", verbatim: true)
                LinkType.telegram(id: "ophelper_en", titleOverride: "Telegram English Channel", verbatim: true)
                LinkType.telegram(id: "ophelper_ru", titleOverride: "Telegram Русскоязычный Канал", verbatim: true)
            }
            .alignmentGuide(.listRowSeparatorLeading) { d in
                d[.leading] + 40
            }

            LinkType.discord(url: "https://discord.gg/g8nCgKsaMe").asView
                .fontWidth(.condensed).fontWeight(.bold)
        }

        // TODO: 择日单独设立授权合约之页面。
        Section {
            NavigationLink(EULAView.navTitle) {
                EULAView()
            }
            NavigationLink(PrivacyPolicyView.navTitle) {
                PrivacyPolicyView()
            }
            NavigationLink(destination: ListOf3rdPartyComponentsView()) {
                Text(ListOf3rdPartyComponentsView.navTitle)
            }
        }
    }

    // MARK: Private

    @Default(.cachedAppStoreMeta) private var cachedAppStoreMeta: ASMeta?

    private var groupFooterText: String {
        var text = ""
        if Locale.isUILanguageSimplifiedChinese {
            text = "我们推荐您加入QQ频道。QQ群都即将满员，而在QQ频道则可以与更多朋友们交流，第一时间获取来自开发者的消息，同时还有官方消息的转发和其他更多功能！"
        } else if Locale.isUILanguageTraditionalChinese {
            text = "我們推薦您加入QQ頻道。QQ群都即將滿員，而在QQ頻道則可以與更多朋友們交流，第一時間獲取來自開發者的消息，同時還有官方消息的轉發和其他更多功能！"
        }
        return text
    }
}

// MARK: - DevCrewViewSections

struct DevCrewViewSections: View {
    // MARK: Internal

    typealias Link = LinkLabelItem.ItemType

    var body: some View {
        Section {
            ContributorItem(
                main: true,
                icon: "icon.product.pzHelper",
                titleKey: "aboutKit.ourApps.pizzaStudio",
                subtitleKey: "aboutKit.ourApps.pizzaStudio.description"
            ) {
                Link.homePageOfficial(urlStr: "https://pizzastudio.org")
                Link.email("contact@pizzastudio.org")
                Link.github(userID: "pizza-studio")
                if isJapaneseUI {
                    Link.twitter(id: "PizzaStudio_jp")
                }
            }
            ForEach(Contributor.mainCrew) { contributor in
                contributor.asView(
                    big: contributor.isCrewMember,
                    subtitle: contributor.subtitleAsMainCrew
                )
            }
        } header: {
            Text("aboutKit.contributors.category.mainCrew", bundle: .module)
                .textCase(.none)
        }

        Section {
            ForEach(Contributor.assetCrew) { contributor in
                contributor.asView(
                    big: false,
                    subtitle: contributor.subtitleAsAssetCrew
                )
            }
        } header: {
            Text("aboutKit.contributors.category.assets", bundle: .module)
                .textCase(.none)
        }

        Section {
            ForEach(Contributor.i18nCrewCurrent) { contributor in
                contributor.asView(
                    big: false,
                    subtitle: contributor.subtitleAsL10nLanguagesCurrent
                )
            }
        } header: {
            Text("aboutKit.contributors.category.i18n.current", bundle: .module)
                .textCase(.none)
        } footer: {
            Text("aboutKit.contributors.category.i18n.current.description", bundle: .module)
        }

        Section {
            ForEach(Contributor.i18nCrewPrevious) { contributor in
                contributor.asView(
                    big: false,
                    subtitle: contributor.subtitleAsL10nLanguagesPrevious
                )
            }
        } header: {
            Text("aboutKit.contributors.category.i18n.previous", bundle: .module)
                .textCase(.none)
        }
    }

    // MARK: Private

    private var isJapaneseUI: Bool {
        Bundle.module.preferredLocalizations.first == "ja"
    }
}

#Preview {
    AboutView()
}
