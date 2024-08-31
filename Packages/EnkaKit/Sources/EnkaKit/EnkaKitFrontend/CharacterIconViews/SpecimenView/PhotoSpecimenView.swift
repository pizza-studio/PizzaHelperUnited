// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

struct PhotoSpecimenView: View {
    // MARK: Public

    @MainActor public var body: some View {
        Form {
            Section {
                switch game {
                case .genshinImpact:
                    AllCharacterPhotoSpecimenViewPerGame(
                        for: .genshinImpact,
                        scroll: false
                    )
                case .starRail:
                    AllCharacterPhotoSpecimenViewPerGame(
                        for: .starRail,
                        scroll: false
                    )
                case .zenlessZone: EmptyView()
                }
            } header: {
                switch game {
                case .genshinImpact:
                    Text("enka.photoSpecimen.credit.genshin".i18nEnka)
                        .textCase(.none)
                case .starRail:
                    Text("enka.photoSpecimen.credit.starRail".i18nEnka)
                        .textCase(.none)
                case .zenlessZone: EmptyView()
                }
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Picker("".description, selection: $game.animation()) {
                    Text("game.genshin.shortNameEX".i18nBaseKit)
                        .tag(Enka.GameType.genshinImpact)
                    Text("game.starRail.shortNameEX".i18nBaseKit)
                        .tag(Enka.GameType.starRail)
                }
                .padding(4)
                .pickerStyle(.segmented)
            }
        }
        .navigationTitle("enka.photoSpecimen.navTitle".i18nEnka)
        .navBarTitleDisplayMode(.large)
    }

    // MARK: Private

    @State private var game: Enka.GameType = .genshinImpact
    @State private var isBusy: Bool = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
}
