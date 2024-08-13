// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

struct PhotoSpecimenView: View {
    // MARK: Public

    public var body: some View {
        Form {
            Section {
                switch game {
                case .genshinImpact:
                    AllCharacterPhotoSpecimenViewPerGame(
                        for: .genshinImpact,
                        columns: specimenColumns,
                        scroll: false
                    )
                case .starRail:
                    AllCharacterPhotoSpecimenViewPerGame(
                        for: .starRail,
                        columns: specimenColumns,
                        scroll: false
                    )
                }
            } header: {
                switch game {
                case .genshinImpact:
                    Text("enka.photoSpecimen.credit.genshin".i18nEnka)
                        .textCase(.none)
                case .starRail:
                    Text("enka.photoSpecimen.credit.starRail".i18nEnka)
                        .textCase(.none)
                }
            }
        }.formStyle(.grouped)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Picker("", selection: $game.animation()) {
                        Text("game.genshin.shortNameEX".i18nBaseKit)
                            .tag(Enka.GameType.genshinImpact)
                        Text("game.starRail.shortNameEX".i18nBaseKit)
                            .tag(Enka.GameType.starRail)
                    }
                    .padding(4)
                    .pickerStyle(.segmented)
                    .onChange(of: game, initial: true) {
                        print("Action")
                    }
                }
            }
            .navigationTitle("enka.photoSpecimen.navTitle".i18nEnka)
            .navigationBarTitleDisplayMode(.large)
    }

    // MARK: Private

    @State private var game: Enka.GameType = .genshinImpact
    @State private var isBusy: Bool = false

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private var specimenColumns: Int {
        horizontalSizeClass == .compact ? 3 : 6
    }
}
