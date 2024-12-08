// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import Foundation
import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import SwiftData
import SwiftUI

// MARK: - TodayTabPage

struct TodayTabPage: View {
    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                Group {
                    switch game {
                    case .genshinImpact where !profiles.isEmpty:
                        GIOngoingEvents.EventListSection {
                            todayMaterialNav
                        }
                    case .starRail where !profiles.isEmpty:
                        NavigationLink(NewsKitHSR.NewsView.navEntryName) {
                            NewsKitHSR.NewsView()
                        }
                    case .zenlessZone where !profiles.isEmpty:
                        EmptyView()
                    default:
                        GIOngoingEvents.EventListSection {
                            Group {
                                NavigationLink(NewsKitHSR.NewsView.navEntryName) {
                                    NewsKitHSR.NewsView()
                                }
                                todayMaterialNav
                            }
                        }
                    }
                }
                .listRowMaterialBackground()
                if profiles.isEmpty {
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
            .scrollContentBackground(.hidden)
            .listContainerBackground()
            .navigationTitle("tab.today.fullTitle".i18nPZHelper)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("".description, systemImage: "arrow.clockwise") { refresh() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    gamePicker
                        .pickerStyle(.segmented)
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
    }

    @ViewBuilder var todayMaterialNav: some View {
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

    // MARK: Private

    @StateObject private var broadcaster = Broadcaster.shared
    @State private var game: Pizza.SupportedGame? = .none
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]

    private var filteredProfiles: [PZProfileMO] {
        profiles.filter {
            guard let currentGame = game else { return true }
            return $0.game == currentGame
        }
    }

    private var games: [Pizza.SupportedGame] {
        profiles.map(\.game).reduce(into: [Pizza.SupportedGame]()) {
            if !$0.contains($1) { $0.append($1) }
        }
    }

    @ViewBuilder private var gamePicker: some View {
        Picker("".description, selection: $game.animation()) {
            Text(Pizza.SupportedGame?.none.localizedShortName)
                .tag(nil as Pizza.SupportedGame?)
            ForEach(games) { game in
                Text(game.localizedShortName)
                    .tag(game as Pizza.SupportedGame?)
            }
        }
    }

    private func refresh() {
        broadcaster.refreshPage()
        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
    }
}
