// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import WidgetKit

#if !os(watchOS)
@available(iOS 16.2, macCatalyst 16.2, *)
extension Font {
    public static func customWidgetFont(size: CGFloat) -> Font? {
        switch Defaults[.widgetStaminaFontPref] {
        case .systemRounded: return nil
        case .systemSansSerif: return Font.system(size: size, design: .default)
        case .systemSerif: return Font.system(size: size, design: .serif)
        case .custom:
            let familyName = Defaults[.widgetStaminaFontFamilyName]
            if familyName == "Hitmarker VF" {
                let url = Bundle.module.url(forResource: "HMVF", withExtension: "ttf")
                guard let url else { return nil }
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
            return Font.custom(familyName, size: size)
        }
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension Defaults.Keys {
    public static let widgetStaminaFontPref = Key<WidgetStaminaFontStyle>(
        "widgetStaminaFontPref",
        default: .systemRounded,
        suite: .baseSuite
    )

    public static let widgetStaminaFontFamilyName = Key<String>(
        "widgetStaminaFontFamilyName",
        default: "Galvji", // iOS 13+ 开始引入的字型。
        suite: .baseSuite
    )

    public static let fetchGenshinNamecardBGOnline = Key<Bool>(
        "fetchGenshinNamecardBGOnline",
        default: true,
        suite: .baseSuite
    )
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension PZWidgetsSPM {
    public struct WidgetSharedSettingsView: View {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public static let navTitle: String = .init(
            localized: "settings.widgets.navTitle", bundle: .module
        )

        public static let navTitleShortened: String = .init(
            localized: "settings.widgets.navTitle.shortened", bundle: .module
        )

        public var body: some View {
            Form {
                VStack {
                    Image(systemSymbol: .platter2FilledIphone)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(Color.accentColor)
                        .frame(width: 64, height: 64)
                        .padding(8)
                    Text("settings.widgets.howToUse.explanation", bundle: .module)
                        .font(.caption)
                }
                .frame(maxWidth: .infinity)
                .alignmentGuide(.listRowSeparatorLeading) { d in
                    d[.leading]
                }

                Section {
                    VStack {
                        Toggle(isOn: $fetchGenshinNamecardBGOnline) {
                            Text("settings.widgets.fetchGenshinNamecardBGOnline", bundle: .module)
                        }
                        Text("settings.widgets.fetchGenshinNamecardBGOnline.explain", bundle: .module)
                            .asInlineTextDescription()
                    }
                }

                Section {
                    VStack {
                        Picker(selection: $widgetStaminaFontPref) {
                            Text("settings.widgets.staminaFontPref.systemRounded", bundle: .module)
                                .tag(WidgetStaminaFontStyle.systemRounded)
                            Text("settings.widgets.staminaFontPref.systemSansSerif", bundle: .module)
                                .tag(WidgetStaminaFontStyle.systemSansSerif)
                            Text("settings.widgets.staminaFontPref.systemSerif", bundle: .module)
                                .tag(WidgetStaminaFontStyle.systemSerif)
                            Text("settings.widgets.staminaFontPref.custom", bundle: .module)
                                .tag(WidgetStaminaFontStyle.custom)
                        } label: {
                            Text("settings.widgets.staminaFontPref.fieldName", bundle: .module)
                        }
                    }
                    .alert(
                        Text("settings.widgets.staminaFontPref.fontFamilyName.prompt", bundle: .module),
                        isPresented: $isWidgetStaminaFontFamilyNameAlertVisible,
                        actions: {
                            TextField(
                                text: $widgetStaminaFontFamilyName
                            ) {
                                Text("settings.widgets.staminaFontPref.fontFamilyName", bundle: .module)
                            }
                            .autocorrectionDisabled(true)
                            Button {
                                isWidgetStaminaFontFamilyNameAlertVisible.toggle()
                                WidgetCenter.shared.reloadAllTimelines()
                            } label: {
                                Text("sys.done".i18nBaseKit)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    )
                    .react(to: widgetStaminaFontPref) { _, _ in
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                    if widgetStaminaFontPref == .custom {
                        HStack {
                            Text("settings.widgets.staminaFontPref.fontFamilyName", bundle: .module)
                            Spacer()
                            Button {
                                isWidgetStaminaFontFamilyNameAlertVisible.toggle()
                            } label: {
                                if widgetStaminaFontFamilyName.isEmpty {
                                    Text(verbatim: "……")
                                } else {
                                    Text(verbatim: widgetStaminaFontFamilyName)
                                }
                            }.buttonStyle(.borderless)
                        }
                    }
                }
            }
            .formStyle(.grouped).disableFocusable()
            .navBarTitleDisplayMode(.large)
            .navigationTitle(Self.navTitleShortened)
        }

        // MARK: Private

        @State private var isWidgetStaminaFontFamilyNameAlertVisible: Bool = false

        @Default(.fetchGenshinNamecardBGOnline) private var fetchGenshinNamecardBGOnline: Bool
        @Default(.widgetStaminaFontFamilyName) private var widgetStaminaFontFamilyName: String
        @Default(.widgetStaminaFontPref) private var widgetStaminaFontPref: WidgetStaminaFontStyle
    }
}

public enum WidgetStaminaFontStyle: Int, CaseIterable, Identifiable, Defaults.Serializable {
    case systemRounded = 0
    case systemSansSerif = 1
    case systemSerif = 2
    case custom = 3

    // MARK: Public

    public var id: Int { rawValue }
}

#endif
