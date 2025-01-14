// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI

// MARK: - AppLanguageSwitcher

struct AppLanguageSwitcher: View {
    // MARK: Lifecycle

    public init() {
        _appleLanguageTag = .init(
            get: {
                let loadedValue = (
                    UserDefaults.standard.array(forKey: Self.appleLanguagesKey) as? [String] ?? ["auto"]
                ).joined()
                let plistValueNotExist = (
                    UserDefaults.standard.object(forKey: Self.appleLanguagesKey) == nil
                )
                let targetToCheck = (plistValueNotExist || loadedValue.isEmpty) ? "auto" : loadedValue
                let targetContained = AppLanguage.allCases.map(\.rawValue).contains(targetToCheck)
                return targetContained ? (plistValueNotExist ? "auto" : loadedValue) : "auto"
            }, set: { newValue in
                var newValue = newValue
                if newValue.isEmpty || newValue == "auto" {
                    UserDefaults.standard.removeObject(forKey: Self.appleLanguagesKey)
                }
                if newValue == "auto" { newValue = "" }
                guard Defaults[.appLanguage]?.joined() != newValue else { return }
                if !newValue.isEmpty { Defaults[.appLanguage] = [newValue] }
            }
        )
    }

    // MARK: Public

    public var body: some View {
        #if os(iOS) && !targetEnvironment(macCatalyst)
        Button {
            UIApplication.shared.open(UIApplication.openSettingsURLString.asURL)
        } label: {
            Label {
                Text("settings.appLanguage.title".i18nPZHelper)
                    .foregroundColor(.primary)
            } icon: {
                Image(systemSymbol: .globe)
            }
        }
        #else
        Label {
            VStack {
                HStack {
                    Text("settings.appLanguage.title".i18nPZHelper)
                    Spacer()
                    Picker("".description, selection: $appleLanguageTag) {
                        Text("app.language.followSystemDefault".i18nBaseKit).tag("auto")
                        ForEach(AppLanguage.allCases) { appLang in
                            Text(appLang.localizedDescription).tag(appLang.rawValue)
                        }
                    }.labelsHidden()
                }
                Text("settings.disclaimer.requiringAppRebootToApplySettings".i18nPZHelper)
                    .asInlineTextDescription()
            }
        } icon: {
            Image(systemSymbol: .globe)
        }
        .onChange(of: appLanguage) {
            alertPresented = true
        }
        .alert(
            "settings.disclaimer.requiringAppRebootToApplySettings".i18nPZHelper,
            isPresented: $alertPresented
        ) {
            Button("sys.ok".i18nBaseKit) { exit(0) }
        } message: {
            Text("app.language.restartRequired.description".i18nPZHelper)
        }
        #endif
    }

    // MARK: Private

    private static let appleLanguagesKey = "AppleLanguages"

    @State private var alertPresented: Bool = false
    @Binding private var appleLanguageTag: String

    @Default(.appLanguage) private var appLanguage: [String]?
}
