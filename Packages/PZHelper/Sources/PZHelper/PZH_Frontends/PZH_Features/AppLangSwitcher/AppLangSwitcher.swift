// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI

// MARK: - AppLanguageSwitcher

@available(iOS 17.0, macCatalyst 17.0, *)
struct AppLanguageSwitcher: View {
    // MARK: Lifecycle

    public init() {
        _appleLanguageTag = .init(
            get: {
                let loadedValue = (
                    UserDefaults.standard.array(forKey: AppLanguage.defaultsKeyName) as? [String] ?? ["auto"]
                ).joined()
                let plistValueNotExist = (
                    UserDefaults.standard.object(forKey: AppLanguage.defaultsKeyName) == nil
                )
                let targetToCheck = (plistValueNotExist || loadedValue.isEmpty) ? "auto" : loadedValue
                let targetContained = AppLanguage.allCases.map(\.rawValue).contains(targetToCheck)
                return targetContained ? (plistValueNotExist ? "auto" : loadedValue) : "auto"
            }, set: { newValue in
                var newValue = newValue
                if newValue.isEmpty || newValue == "auto" {
                    UserDefaults.standard.removeObject(forKey: AppLanguage.defaultsKeyName)
                }
                if newValue == "auto" { newValue = "" }
                guard Defaults[.appLanguage]?.joined() != newValue else { return }
                if !newValue.isEmpty { Defaults[.appLanguage] = [newValue] }
            }
        )
    }

    // MARK: Public

    public var body: some View {
        // 禁用 iOSSystemAppSettingsPageLink()，因為該功能至少在 Simulator 下無法正常使用。
        // Simulator 可能會找不到披薩小助手。
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
                    .onChange(of: appleLanguageTag) { oldValue, newValue in
                        if oldValue != newValue {
                            previousLanguageTag = oldValue
                        }
                    }
                }
                Text("settings.disclaimer.requiringAppRebootToApplySettings".i18nPZHelper)
                    .asInlineTextDescription()
            }
        } icon: {
            Image(systemSymbol: .globe)
        }
        .onAppear {
            previousLanguageTag = appleLanguageTag
        }
        .react(to: appLanguage) {
            // Don't show alert if we're currently reverting or if alert is already presented
            guard !isReverting && !alertPresented else { return }
            alertPresented = true
        }
        .alert(
            "settings.disclaimer.requiringAppRebootToApplySettings".i18nPZHelper,
            isPresented: $alertPresented
        ) {
            Button("sys.ok".i18nBaseKit) { exit(0) }
            Button("sys.cancel".i18nBaseKit) {
                // Set the reverting flag to prevent alert loops
                isReverting = true
                
                // Revert by updating the picker binding, let the binding handle the rest
                appleLanguageTag = previousLanguageTag
                
                // Keep the flag set longer to ensure all async updates complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isReverting = false
                }
            }
        } message: {
            Text("app.language.restartRequired.description".i18nPZHelper)
                + Text(verbatim: "\n\n⚠️ ")
                + Text("app.language.restartRequired.widgets.description".i18nPZHelper)
        }
    }

    // MARK: Private

    @State private var alertPresented: Bool = false
    @State private var previousLanguageTag: String = ""
    @State private var isReverting: Bool = false
    @Binding private var appleLanguageTag: String

    @Default(.appLanguage) private var appLanguage: [String]?
}
