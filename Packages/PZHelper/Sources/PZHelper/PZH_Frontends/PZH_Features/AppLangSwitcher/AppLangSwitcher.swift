// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI

// MARK: - AppLanguageSwitcher

struct AppLanguageSwitcher: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        // 禁用 iOSSystemAppSettingsPageLink()，因為該功能至少在 Simulator 下無法正常使用。
        // Simulator 可能會找不到披薩小助手。
        Label {
            HStack {
                Text("settings.appLanguage.title".i18nPZHelper)
                Spacer()
                Picker("".description, selection: $selectedLanguageTag) {
                    Text("app.language.followSystemDefault".i18nBaseKit).tag("auto")
                    ForEach(AppLanguage.allCases) { appLang in
                        Text(appLang.localizedDescription).tag(appLang.rawValue)
                    }
                }
                .labelsHidden()
                .react(to: selectedLanguageTag) { oldValue, newValue in
                    if oldValue != newValue, newValue != savedLanguageTag {
                        // Only show alert if the new selection differs from saved value
                        alertPresented = true
                    }
                }
            }
        } icon: {
            Image(systemSymbol: .globe)
        }
        .onAppear {
            loadCurrentLanguageSetting()
        }
        .react(to: appLanguage) {
            // When the @Default(.appLanguage) property changes externally,
            // refresh our local state and dismiss any open alert
            let currentSetting = getCurrentLanguageFromDefaults()
            if currentSetting != savedLanguageTag {
                loadCurrentLanguageSetting()
                alertPresented = false // Make the sheet disappear
            }
        }
        .apply(hookAlert)
    }

    // MARK: Private

    @State private var alertPresented: Bool = false
    @State private var selectedLanguageTag: String = "auto"
    @State private var savedLanguageTag: String = "auto"

    @Default(.appLanguage) private var appLanguage: [String]?

    @ViewBuilder
    private func hookAlert<T: View>(_ target: T) -> some View {
        let title = Text("settings.disclaimer.requiringAppRebootToApplySettings", bundle: .module)
        let message = Text("app.language.restartRequired.description".i18nPZHelper)
            + Text(verbatim: "\n\n⚠️ ")
            + Text("app.language.restartRequired.widgets.description".i18nPZHelper)
        if #available(macCatalyst 15.0, iOS 15.0, macOS 12.0, *) {
            target
                .alert(title, isPresented: $alertPresented) {
                    Button("sys.ok".i18nBaseKit) {
                        // Commit the change to UserDefaults and exit
                        saveLanguageSetting(selectedLanguageTag)
                        exit(0)
                    }
                    Button("sys.cancel".i18nBaseKit) {
                        // Simply revert the picker to the saved value
                        selectedLanguageTag = savedLanguageTag
                    }
                } message: {
                    message
                }
        } else {
            target
                .alert(isPresented: $alertPresented) {
                    Alert(
                        title: title,
                        message: message,
                        primaryButton: .default(Text("sys.ok".i18nBaseKit), action: {
                            // Commit the change to UserDefaults and exit
                            saveLanguageSetting(selectedLanguageTag)
                            exit(0)
                        }),
                        secondaryButton: .cancel(Text("sys.cancel".i18nBaseKit), action: {
                            // Simply revert the picker to the saved value
                            selectedLanguageTag = savedLanguageTag
                        })
                    )
                }
        }
    }

    private func getCurrentLanguageFromDefaults() -> String {
        let loadedValue = (
            UserDefaults.standard.array(forKey: AppLanguage.defaultsKeyName) as? [String] ?? ["auto"]
        ).joined()
        let plistValueNotExist = (
            UserDefaults.standard.object(forKey: AppLanguage.defaultsKeyName) == nil
        )
        let targetToCheck = (plistValueNotExist || loadedValue.isEmpty) ? "auto" : loadedValue
        let targetContained = AppLanguage.allCases.map(\.rawValue).contains(targetToCheck)
        return targetContained ? (plistValueNotExist ? "auto" : loadedValue) : "auto"
    }

    private func loadCurrentLanguageSetting() {
        let currentLanguage = getCurrentLanguageFromDefaults()
        selectedLanguageTag = currentLanguage
        savedLanguageTag = currentLanguage
    }

    private func saveLanguageSetting(_ languageTag: String) {
        var newValue = languageTag
        if newValue.isEmpty || newValue == "auto" {
            UserDefaults.standard.removeObject(forKey: AppLanguage.defaultsKeyName)
        }
        if newValue == "auto" { newValue = "" }
        if !newValue.isEmpty {
            Defaults[.appLanguage] = [newValue]
        } else {
            Defaults[.appLanguage] = nil
        }
        savedLanguageTag = languageTag
    }
}
