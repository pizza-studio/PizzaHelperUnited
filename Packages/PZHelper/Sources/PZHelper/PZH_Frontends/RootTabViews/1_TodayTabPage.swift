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
        self.rootTabNavBinding = GlobalNavVM.shared.rootTabNavBindingNullable
        self.wrappedByNavStack = wrappedByNavStack
    }

    // MARK: Internal

    let rootTabNavBinding: Binding<AppTabNav?>

    var body: some View {
        if wrappedByNavStack {
            NavigationStack {
                formContentHooked
                    .navBarTitleDisplayMode(.large)
                    .scrollContentBackground(.hidden)
                    .listContainerBackground()
            }
        } else {
            formContentHooked
        }
    }

    @ViewBuilder var formContentToHook: some View {
        ASUpdateNoticeView()
            .font(.footnote)
            .listRowMaterialBackground()
        OfficialFeed.OfficialFeedSection(game: $game.animation()) {
            todayMaterialNav
        } sectionHeader: {
            if !wrappedByNavStack {
                HStack {
                    Spacer()
                    gamePicker
                        .pickerStyle(.menu)
                        .buttonStyle(.borderless)
                    Button {
                        refresh()
                    } label: {
                        Image(systemSymbol: .arrowClockwise)
                    }
                    .buttonStyle(.borderless)
                }
                .textCase(.none)
            }
        }
        .listRowMaterialBackground()
        if pzProfiles.isEmpty {
            Section {
                Label {
                    Text("app.dailynote.noCard.suggestion".i18nPZHelper)
                } icon: {
                    Image(systemSymbol: .questionmarkCircle)
                        .foregroundColor(.yellow)
                }
                .listRowMaterialBackground()
                tabNavVM.gotoSettingsButtonIfAppropriate
            }
        } else {
            ForEach(filteredProfiles) { profile in
                InAppDailyNoteCardView(profile: profile)
                    .listRowMaterialBackground()
            }
        }
    }

    @ViewBuilder var formContentHooked: some View {
        let pd: CGFloat = OS.liquidGlassThemeSuspected ? 15 : 12
        Group {
            Form {
                formContentToHook
                    .listRowInsets(
                        .init(top: pd, leading: pd, bottom: pd, trailing: pd)
                    )
            }
            .formStyle(.grouped)
            .background(alignment: .bottom) {
                if !wrappedByNavStack {
                    // 这个隐形 List 不要删除，否则 NavSplitView 全局导航会失效。
                    List(selection: rootTabNavBinding) {}
                        .fixedSize()
                        .frame(height: 0)
                        .opacity(0)
                }
            }
            .safeAreaInset(edge: .bottom, content: tabNavVM.iOSBottomTabBarForBuggyOS25ReleasesOn)
        }
        .navigationTitle("tab.today.fullTitle".i18nPZHelper)
        .contextMenu {
            if !wrappedByNavStack {
                Button("sys.refresh".i18nBaseKit, systemImage: "arrow.clockwise") { refresh() }
                if !games.isEmpty {
                    Divider()
                    gamePicker
                        .pickerStyle(.menu)
                }
            }
        }
        .toolbar {
            if wrappedByNavStack {
                ToolbarItem(placement: .confirmationAction) {
                    Button("sys.refresh".i18nBaseKit, systemImage: "arrow.clockwise") { refresh() }
                }
                if !games.isEmpty {
                    ToolbarItem(placement: .confirmationAction) {
                        // ViewThatFits 不适用于此种场景。
                        gamePicker
                            .pickerStyle(.segmented)
                    }
                }
            }
        }
        .refreshable {
            broadcaster.refreshTodayTab()
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
            Button {
                isTodayMaterialSheetShown.toggle()
            } label: {
                LabeledContent {
                    Image(systemSymbol: .calendarBadgeClock)
                } label: {
                    Text(navName)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .listRowMaterialBackground()
            .sheet(isPresented: $isTodayMaterialSheetShown) {
                NavigationStack {
                    giTodayMaterialsView
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("sys.close".i18nBaseKit) {
                                    isTodayMaterialSheetShown.toggle()
                                }
                            }
                        }
                }
            }
        }
    }

    // MARK: Private

    @State private var isTodayMaterialSheetShown: Bool = false
    @State private var wrappedByNavStack: Bool
    @State private var game: Pizza.SupportedGame? = .none
    @StateObject private var tabNavVM = GlobalNavVM.shared
    @StateObject private var broadcaster = Broadcaster.shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @Default(.pzProfiles) private var pzProfiles: [String: PZProfileSendable]

    private let isAppKit = OS.type == .macOS && !OS.isCatalyst

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
            Picker(game.localizedShortName, selection: $game.animation()) {
                Text(Pizza.SupportedGame?.none.localizedShortName)
                    .tag(nil as Pizza.SupportedGame?)
                ForEach(games) { game in
                    Text(game.localizedShortName)
                        .tag(game as Pizza.SupportedGame?)
                }
            }
            .labelsHidden()
            .fixedSize()
        }
    }

    @ViewBuilder private var giTodayMaterialsView: some View {
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
    }

    private func refresh() {
        broadcaster.refreshTodayTab()
        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
    }
}
