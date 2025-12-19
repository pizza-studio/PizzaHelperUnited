// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

/// 这里只给选项，所以只给出 Sections 就可以了。用的时候塞到 Form 里面即可。

import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    public struct DisplayOptionViewContents: View {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public var body: some View {
            mainView
                .alert(
                    "settings.display.customizingNameForKunikuzushi.prompt".i18nEnka,
                    isPresented: $isCustomizedNameForWandererAlertVisible,
                    actions: {
                        TextField(
                            "settings.display.customizingNameForKunikuzushi.currentValueLabel".i18nEnka,
                            text: $customizedNameForWanderer
                        ).react(to: customizedNameForWanderer) { oldValue, newValue in
                            guard oldValue != newValue else { return }
                            limitText(20)
                        }
                        .autocorrectionDisabled(true)
                        Button {
                            isCustomizedNameForWandererAlertVisible.toggle()
                        } label: {
                            Text("sys.done".i18nBaseKit)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                )
        }

        // MARK: Internal

        @ViewBuilder var mainView: some View {
            Section {
                Toggle(isOn: $artifactRatingRules.bind(.enabled, animate: true).animation()) {
                    Text("settings.display.artifactRating.enabled".i18nEnka)
                }
                if artifactRatingRules.contains(.enabled) {
                    VStack {
                        Toggle(isOn: $artifactRatingRules.bind(.considerSwirls)) {
                            Text("settings.display.artifactRating.considerSwirls".i18nEnka)
                        }
                        Text("settings.display.artifactRating.considerSwirls.explanation".i18nEnka)
                            .asInlineTextDescription()
                    }
                    VStack {
                        Toggle(isOn: $artifactRatingRules.bind(.considerHyperbloomElectroRoles)) {
                            Text("settings.display.artifactRating.considerHyperBloomElectroRoles".i18nEnka)
                        }
                        Text("settings.display.artifactRating.considerHyperBloomElectroRoles.explanation".i18nEnka)
                            .asInlineTextDescription()
                    }
                }
            } header: {
                Text("settings.display.artifactRating.sectionTitle".i18nEnka)
            }

            Section {
                VStack {
                    Toggle(isOn: $colorizeArtifactSubPropCounts) {
                        Text("settings.display.showCase.colorizeArtifactSubPropCounts".i18nEnka)
                    }
                    Text("settings.display.showCase.colorizeArtifactSubPropCounts.explain".i18nEnka)
                        .asInlineTextDescription()
                }
                Toggle(isOn: $useNameCardBGWithGICharacters) {
                    Text("settings.display.showCase.useNameCardBGWithGICharacters".i18nEnka)
                }
                Toggle(isOn: $useTotemWithGenshinIDPhotos) {
                    Text("settings.display.showCase.useTotemWithGenshinIDPhotos".i18nEnka)
                }
                VStack {
                    Toggle(isOn: $useGenshinStyleCharacterPhotos) {
                        Text("settings.display.showCase.useGenshinStyleCharacterPhotos".i18nEnka)
                    }
                    Text(try! AttributedString(
                        markdown: "enka.genshinStylePhotosForHSR.featureOption.disclaimer"
                            .i18nEnka
                    ))
                    .asInlineTextDescription()
                }
            } header: {
                Text("settings.display.showCase.sectionTitle".i18nEnka)
            } footer: {
                NavigationLink(destination: PhotoSpecimenView()) {
                    Text("enka.photoSpecimen.navTitle".i18nEnka)
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Section {
                VStack {
                    Toggle(isOn: $useAlternativeCharacterNames.animation()) {
                        Text("settings.display.showCase.useAlternativeCharacterNames".i18nEnka)
                    }
                    Text("settings.display.showCase.useAlternativeCharacterNames.explain".i18nEnka)
                        .asInlineTextDescription()
                }
                VStack {
                    Toggle(isOn: $forceCharacterWeaponNameFixed) {
                        Text("settings.display.showCase.forceCharacterWeaponNameFixed".i18nEnka)
                    }
                    Text("settings.display.showCase.forceCharacterWeaponNameFixed.explain".i18nEnka)
                        .asInlineTextDescription()
                }
                if !useAlternativeCharacterNames {
                    HStack {
                        Text("settings.display.customizingNameForKunikuzushi".i18nEnka)
                        Spacer()
                        Button(currentOfficialTranslationForWanderer) {
                            isCustomizedNameForWandererAlertVisible.toggle()
                        }.buttonStyle(.borderless)
                    }
                }

            } header: {
                Text("settings.display.showCase.namingPrefs.sectionTitle".i18nEnka)
            }

            Section {
                if lastEnkaDBDataCheckDate.timeIntervalSince1970 > 10 {
                    LabeledContent {
                        Text(lastEnkaDBDataCheckDate.ISO8601Format())
                    } label: {
                        Text("settings.display.enkaStatus.lastEnkaDBCheckDate".i18nEnka)
                    }
                }
                VStack {
                    Picker(selection: $defaultDBQueryHost) {
                        Text("settings.display.enkaStatus.defaultDBQueryHost.GitLink".i18nEnka)
                            .tag(Enka.HostType.mainlandChina)
                        Text("settings.display.enkaStatus.defaultDBQueryHost.GitHub".i18nEnka)
                            .tag(Enka.HostType.enkaGlobal)
                    } label: {
                        Text("settings.display.enkaStatus.defaultDBQueryHost".i18nEnka)
                    }
                    Text("settings.display.enkaStatus.defaultDBQueryHost.explanation".i18nEnka)
                        .asInlineTextDescription()
                }
            } header: {
                Text("settings.display.enkaStatus.sectionTitle".i18nEnka)
            }
        }

        // MARK: Private

        @State private var isCustomizedNameForWandererAlertVisible: Bool = false

        @Default(.useNameCardBGWithGICharacters) private var useNameCardBGWithGICharacters: Bool
        @Default(.useGenshinStyleCharacterPhotos) private var useGenshinStyleCharacterPhotos: Bool
        @Default(.useTotemWithGenshinIDPhotos) private var useTotemWithGenshinIDPhotos: Bool
        @Default(.colorizeArtifactSubPropCounts) private var colorizeArtifactSubPropCounts: Bool
        @Default(.artifactRatingRules) private var artifactRatingRules: ArtifactRating.Rules
        @Default(.useAlternativeCharacterNames) private var useAlternativeCharacterNames: Bool
        @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
        @Default(.customizedNameForWanderer) private var customizedNameForWanderer: String
        @Default(.lastEnkaDBDataCheckDate) private var lastEnkaDBDataCheckDate: Date
        @Default(.defaultDBQueryHost) private var defaultDBQueryHost: Enka.HostType

        private var currentOfficialTranslationForWanderer: String {
            Enka.Sputnik.shared.db4GI.getTranslationFor(id: "10000075", realName: false)
        }

        // Function to keep text length in limits
        private func limitText(_ upper: Int) {
            if customizedNameForWanderer.count > upper {
                customizedNameForWanderer = String(customizedNameForWanderer.prefix(upper))
            }
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    Form {
        Enka.DisplayOptionViewContents()
    }
    .formStyle(.grouped).disableFocusable()
    .frame(height: 800)
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}
