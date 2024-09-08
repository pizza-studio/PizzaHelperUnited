// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - TodayTabPage

struct TodayTabPage: View {
    // MARK: Internal

    @MainActor var body: some View {
        NavigationStack {
            Form {
                if profiles.isEmpty {
                    todayMaterialNav
                    Label {
                        Text("app.dailynote.noCard.suggestion".i18nPZHelper)
                    } icon: {
                        Image(systemSymbol: .questionmarkCircle)
                            .foregroundColor(.yellow)
                    }
                    .listRowMaterialBackground()
                } else {
                    if game == .genshinImpact || game == nil {
                        todayMaterialNav
                    }
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
                    Button("", systemImage: "arrow.clockwise") { refresh() }
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

    @MainActor @ViewBuilder var todayMaterialNav: some View {
        let navName =
            "\(GITodayMaterialsView.navTitle) (\(Pizza.SupportedGame.genshinImpact.localizedDescriptionTrimmed))"
        NavigationLink {
            GITodayMaterialsView()
        } label: {
            Text(navName)
        }
        .listRowMaterialBackground()
    }

    // MARK: Private

    @State private var broadcaster = Broadcaster.shared
    @State private var game: Pizza.SupportedGame? = .none
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]

    private var filteredProfiles: [PZProfileMO] {
        profiles.filter {
            guard let currentGame = game else { return true }
            return $0.game == currentGame
        }
    }

    @ViewBuilder
    @MainActor private var gamePicker: some View {
        Picker("".description, selection: $game.animation()) {
            Text(Pizza.SupportedGame?.none.localizedShortName)
                .tag(nil as Pizza.SupportedGame?)
            ForEach(games) { game in
                Text(game.localizedShortName)
                    .tag(game as Pizza.SupportedGame?)
            }
        }
    }

    private var games: [Pizza.SupportedGame] {
        profiles.map(\.game).reduce(into: [Pizza.SupportedGame]()) {
            if !$0.contains($1) { $0.append($1) }
        }
    }

    private func refresh() {
        broadcaster.refreshPage()
        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
    }
}

// MARK: - AddNewProfileButton

private struct AddNewProfileButton: View {
    @MainActor var body: some View {
        VStack {
            NavigationLink {
                ProfileManagerPageContent()
                    .scrollContentBackground(.visible)
                    .tint(.blue)
                #if os(iOS) || targetEnvironment(macCatalyst)
                    .toolbar(.hidden, for: .tabBar)
                #endif
            } label: {
                HStack {
                    Spacer()
                    Label("profileMgr.new".i18nPZHelper, systemSymbol: .plusCircle)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(.blue, lineWidth: 4)
                        )
                        .background(
                            .regularMaterial,
                            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                        )
                        .contentShape(RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        ))
                        .clipShape(RoundedRectangle(
                            cornerRadius: 20,
                            style: .continuous
                        ))
                    Spacer()
                }
            }
        }
    }

    // MARK: Private
}
