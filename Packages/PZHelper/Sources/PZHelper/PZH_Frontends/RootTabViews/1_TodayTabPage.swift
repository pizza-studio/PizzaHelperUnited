// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import Foundation
import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import SwiftUI

// MARK: - TodayTabPage

struct TodayTabPage: View {
    // MARK: Lifecycle

    public init(wrappedByNavStack: Bool = true) {
        self.wrappedByNavStack = wrappedByNavStack
    }

    // MARK: Internal

    var body: some View {
        if wrappedByNavStack {
            NavigationStack {
                formContentHooked
                    .scrollContentBackground(.hidden)
                    .listContainerBackground()
            }
        } else {
            formContentHooked
        }
    }

    @ViewBuilder var formContentHooked: some View {
        Form {
            ASUpdateNoticeView()
                .font(.footnote)
                .listRowMaterialBackground()
            OfficialFeed.OfficialFeedSection(game: $game.animation()) {
                todayMaterialNav
            }
            .listRowMaterialBackground()
            if pzProfiles.isEmpty {
                Label {
                    Text("app.dailynote.noCard.suggestion".i18nPZHelper)
                } icon: {
                    Image(systemSymbol: .questionmarkCircle)
                        .foregroundColor(.yellow)
                }
                .listRowMaterialBackground()
            } else {
                ForEach(filteredProfiles) { profile in
                    InAppDailyNoteCardView(profile: profile)
                        .listRowMaterialBackground()
                }
            }
        }
        .formStyle(.grouped)
        .navigationTitle("tab.today.fullTitle".i18nPZHelper)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("".description, systemImage: "arrow.clockwise") { refresh() }
            }
            ToolbarItem(placement: .confirmationAction) {
                gamePicker
                    .pickerStyle(.segmented)
                    .fixedSize()
            }
        }
        .refreshable {
            broadcaster.refreshPage()
        }
        .onAppear {
            if let theGame = game, !games.contains(theGame) {
                withAnimation {
                    game = .none
                }
            }
        }
    }

    @ViewBuilder var todayMaterialNav: some View {
        if shouldShowGenshinTodayMaterial {
            let navName =
                "\(GITodayMaterialsView<EmptyView>.navTitle) (\(Pizza.SupportedGame.genshinImpact.localizedDescriptionTrimmed))"
            NavigationLink {
                GITodayMaterialsView { isWeapon, itemID in
                    if isWeapon {
                        Enka.queryImageAssetSUI(for: "gi_weapon_\(itemID)")?
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(height: 64)
                    } else {
                        if Enka.Sputnik.shared.db4GI.characters.keys.contains(itemID) {
                            CharacterIconView(charID: itemID, cardSize: 64)
                        }
                    }
                }
            } label: {
                Text(navName)
            }
            .listRowMaterialBackground()
        }
    }

    // MARK: Private

    @State private var wrappedByNavStack: Bool
    @State private var game: Pizza.SupportedGame? = .none
    @StateObject private var broadcaster = Broadcaster.shared

    @Default(.pzProfiles) private var pzProfiles: [String: PZProfileSendable]

    private var filteredProfiles: [PZProfileSendable] {
        pzProfiles.values.filter {
            guard let currentGame = game else { return true }
            return $0.game == currentGame
        }.sorted {
            $0.priority < $1.priority
        }
    }

    private var games: [Pizza.SupportedGame] {
        pzProfiles.map(\.value.game).reduce(into: [Pizza.SupportedGame]()) {
            if !$0.contains($1) { $0.append($1) }
        }
        .sorted {
            $0.caseIndex < $1.caseIndex
        }
    }

    private var shouldShowGenshinTodayMaterial: Bool {
        switch game {
        case .genshinImpact where !pzProfiles.isEmpty: true
        case .starRail where !pzProfiles.isEmpty: false
        case .zenlessZone where !pzProfiles.isEmpty: false
        default: true
        }
    }

    @ViewBuilder private var gamePicker: some View {
        if !pzProfiles.isEmpty {
            Picker("".description, selection: $game.animation()) {
                Text(Pizza.SupportedGame?.none.localizedShortName)
                    .tag(nil as Pizza.SupportedGame?)
                ForEach(games) { game in
                    Text(game.localizedShortName)
                        .tag(game as Pizza.SupportedGame?)
                }
            }
        }
    }

    private func refresh() {
        broadcaster.refreshPage()
        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
    }
}
