// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
struct PhotoSpecimenView: View {
    // MARK: Public

    public var body: some View {
        NavigationStack {
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
            .formStyle(.grouped).disableFocusable()
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Picker("".description, selection: $game.animation()) {
                        Text("game.genshin.shortNameEX".i18nBaseKit)
                            .tag(Enka.GameType.genshinImpact)
                        Text("game.starRail.shortNameEX".i18nBaseKit)
                            .tag(Enka.GameType.starRail)
                    }
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
            }
            .navigationTitle("enka.photoSpecimen.navTitle".i18nEnka)
            .navBarTitleDisplayMode(.large)
        }
    }

    // MARK: Private

    @State private var game: Enka.GameType = .genshinImpact

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
}
