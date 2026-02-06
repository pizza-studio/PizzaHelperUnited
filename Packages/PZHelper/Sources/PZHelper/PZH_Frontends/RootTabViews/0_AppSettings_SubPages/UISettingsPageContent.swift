// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperConfigKit
import WallpaperKit

// MARK: - UISettingsPageContent

@available(iOS 17.0, macCatalyst 17.0, *)
struct UISettingsPageContent: View {
    // MARK: Internal

    var body: some View {
        Form {
            Section {
                AppWallpaperSettingsNav()
                    .alignmentGuide(.listRowSeparatorLeading) { d in
                        d[.leading]
                    }
            } header: {
                Text(AppWallpaperSettingsNav.navSectionHeader)
                    .textCase(.none)
            } footer: {
                Text(AppWallpaperSettingsNav.navDescription)
            }

            Section {
                VStack(alignment: .leading) {
                    Toggle(isOn: $reduceUIGlassDecorations) {
                        Text("setting.display.reduceUIGlassDecorations", bundle: .currentSPM)
                    }
                    .disabled(ThisDevice.deviceBannedForUIGlassDecorations)
                    let reasons = reasonsWhyDeviceBannedForUIGlassDecorations.enumerated()
                    ForEach(Array(reasons), id: \.offset) { _, reasonText in
                        reasonText.asInlineTextDescription()
                    }
                }
                .multilineTextAlignment(.leading)
            } header: {
                Text("settings.display.performanceSettings.sectionHeader", bundle: .currentSPM)
            } footer: {
                Text("settings.display.performanceSettings.sectionFooter", bundle: .currentSPM)
            }

            Section {
                Toggle(isOn: $restoreTabOnLaunching) {
                    Text("setting.display.restoreTabOnLaunching", bundle: .currentSPM)
                }
                defaultServerSelector4GI
            } header: {
                Text("settings.display.generalSettings.sectionHeader", bundle: .currentSPM)
            }

            Enka.DisplayOptionViewContents()
        }
        .formStyle(.grouped).disableFocusable()
        .navigationTitle(Text("settings.uiSettings.title", bundle: .currentSPM))
        .navBarTitleDisplayMode(.large)
    }

    // MARK: Private

    @Default(.restoreTabOnLaunching) private var restoreTabOnLaunching: Bool
    @Default(.defaultServer) private var defaultServer4GI: String
    @Default(.reduceUIGlassDecorations) private var reduceUIGlassDecorations: Bool

    private var reasonsWhyDeviceBannedForUIGlassDecorations: [Text] {
        var result = [Text]()
        let threshold = ThisDevice.deviceRAMInsufficientThresholdAsGiB
        let description4DeviceRAMThreshold = Text(
            "setting.display.reduceUIGlassDecorations.explain.deviceRAMInsufficient:\(threshold)",
            bundle: .currentSPM
        )

        let description4IntelMac = Text(
            "setting.display.reduceUIGlassDecorations.explain.intelMac",
            bundle: .currentSPM
        )

        if Pizza.isDebug {
            result.append(description4IntelMac)
            result.append(description4DeviceRAMThreshold)
        } else if ThisDevice.isIntelProcessor, OS.type == .macOS {
            result.append(description4IntelMac)
        } else if ThisDevice.isLegacyDeviceOrInsufficientRAM {
            result.append(description4DeviceRAMThreshold)
        }
        return result
    }

    @ViewBuilder private var defaultServerSelector4GI: some View {
        VStack {
            Picker(selection: $defaultServer4GI) {
                ForEach(HoYo.Server.allCases4GI) { server in
                    Text(
                        server.localizedDescriptionByGame + " (\(server.timeZone.identifier))"
                    ).tag(server.rawValue)
                }
            } label: {
                Text("settings.display.timeZone4OfficialFeedsEtc.title", bundle: .currentSPM)
            }
            Text("settings.display.timeZone4GI.description", bundle: .currentSPM)
                .asInlineTextDescription()
        }
    }
}
