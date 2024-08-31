// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
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
        }
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
            Text(Pizza.SupportedGame.genshinImpact.localizedShortName)
                .tag(Pizza.SupportedGame.genshinImpact as Pizza.SupportedGame?)
            Text(Pizza.SupportedGame.starRail.localizedShortName)
                .tag(Pizza.SupportedGame.starRail as Pizza.SupportedGame?)
            Text(Pizza.SupportedGame.zenlessZone.localizedShortName)
                .tag(Pizza.SupportedGame.zenlessZone as Pizza.SupportedGame?)
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
