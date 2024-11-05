// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZBaseKit
import PZHoYoLabKit
import SwiftUI

struct PrivacySettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        List {
            Section {
                Toggle(isOn: $allowAbyssDataCollection) {
                    Text("settings.privacy.abyssDataCollect".i18nPZHelper)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("settings.privacy.abyssDataCollect.detail".i18nPZHelper)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    NavigationLink {
                        WebBrowserView(url: Self.privacyFAQURL.absoluteString)
                            .navigationTitle("FAQ")
                            .navBarTitleDisplayMode(.inline)
                    } label: {
                        Text("settings.privacy.abyssDataCollect.faqLink".i18nPZHelper)
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .navigationTitle("settings.privacy.title".i18nPZHelper)
    }

    // MARK: Private

    private static let privacyFAQURL: URL = {
        switch Bundle.main.preferredLocalizations.first?.prefix(2) {
        case "zh": "https://gi.pizzastudio.org/static/faq_abyss.html".asURL
        case "en": "https://gi.pizzastudio.org/static/faq_abyss_en.html".asURL
        case "ja": "https://gi.pizzastudio.org/static/faq_abyss_ja.html".asURL
        default: "https://gi.pizzastudio.org/static/faq_abyss_en.html".asURL
        }
    }()

    @Default(.allowAbyssDataCollection) private var allowAbyssDataCollection: Bool
}
