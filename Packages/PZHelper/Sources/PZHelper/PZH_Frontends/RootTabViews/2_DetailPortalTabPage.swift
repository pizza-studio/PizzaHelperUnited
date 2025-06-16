// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import Observation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - DetailPortalTabPage

struct DetailPortalTabPage: View {
    // MARK: Lifecycle

    public init(wrappedByNavStack: Bool = true, showProfileSwitcher: Bool = true) {
        self.showProfileSwitcher = showProfileSwitcher
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
            formContent
        }
        .formStyle(.grouped)
        .safeAreaInset(edge: .bottom) {
            tabNavVM.tabBarForMacCatalyst
                .fixedSize(horizontal: false, vertical: true)
        }
        .refreshable {
            refreshAction()
        }
        .navigationTitle("tab.details.fullTitle".i18nPZHelper)
        .apply(hookNavigationDestinations)
        .apply(hookToolbar)
        .onAppear {
            if let profile = vmDPV.currentProfile, !sortedProfiles.contains(profile) {
                vmDPV.currentProfile = nil
            }
        }
    }

    @ViewBuilder var formContent: some View {
        ASUpdateNoticeView()
            .font(.footnote)
            .listRowMaterialBackground()
        let query4GI = CaseQuerySection(theDB: sharedDB.db4GI, focus: $uidInputFieldFocus)
            .listRowMaterialBackground()
        let query4HSR = CaseQuerySection(theDB: sharedDB.db4HSR, focus: $uidInputFieldFocus)
            .listRowMaterialBackground()
        if let profile = vmDPV.currentProfile {
            switch profile.game {
            case .genshinImpact:
                ProfileShowCaseSections(theDB: sharedDB.db4GI, pzProfile: profile) {
                    CharInventoryNav(theVM: vmDPV)
                } onTapGestureAction: {
                    uidInputFieldFocus = false
                }
                .listRowMaterialBackground()
                .id(profile.uidWithGame) // 很重要，否则在同款游戏之间的账号切换不会生效。
                query4GI
            case .starRail:
                ProfileShowCaseSections(theDB: sharedDB.db4HSR, pzProfile: profile) {
                    CharInventoryNav(theVM: vmDPV)
                } onTapGestureAction: {
                    uidInputFieldFocus = false
                }
                .listRowMaterialBackground()
                .id(profile.uidWithGame) // 很重要，否则在同款游戏之间的账号切换不会生效。
                query4HSR
            case .zenlessZone: EmptyView()
            }
            // Peripheral Nav Sections.
            Section {
                AbyssReportNav(theVM: vmDPV)
                LedgerNav(theVM: vmDPV)
            } footer: {
                Text("dpv.peripherals.footer.whySomeContentsAreRemoved".i18nPZHelper)
            }
            .listRowMaterialBackground()
            // .onTapGesture { uidInputFieldFocus = false } // 备忘：不要启用这一行，否则这些导航会失效。
        } else {
            query4GI
            query4HSR
        }
    }

    @ViewBuilder var profileSwitcherMenuLabel: some View {
        LabeledContent {
            let dimension: CGFloat = 30
            Group {
                if let profile: PZProfileSendable = vmDPV.currentProfile {
                    Enka.ProfileIconView(uid: profile.uid, game: profile.game)
                        .frame(width: dimension)
                } else {
                    Image(systemSymbol: .personCircleFill)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: dimension - 8)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .background {
                // Compiler optimization.
                AnyView(erasing: {
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 8)
                        .frame(width: dimension, height: dimension)
                }())
            }
            .frame(width: dimension, height: dimension)
            .clipShape(.circle)
            .compositingGroup()
        } label: {
            if let profile: PZProfileSendable = vmDPV.currentProfile {
                Text(profile.uidWithGame).fontWidth(.condensed)
            } else {
                Text("dpv.query.menuCommandTitle".i18nPZHelper)
            }
        }
        .padding(4).padding(.leading, 12)
        .blurMaterialBackground(enabled: !OS.liquidGlassThemeSuspected)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    func profileSwitcherMenu() -> some View {
        pfMgrVM.profileSwitcherMenu4DPV(
            $vmDPV.currentProfile,
            games: [.genshinImpact, .starRail]
        )
    }

    @ViewBuilder
    func hookNavigationDestinations(_ content: some View) -> some View {
        content
            .navigationDestination(for: Enka.QueriedProfileGI.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4GI
                )
                .scrollContentBackground(.hidden)
                .listContainerBackground()
            }
            .navigationDestination(for: Enka.QueriedProfileHSR.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4HSR
                )
                .scrollContentBackground(.hidden)
                .listContainerBackground()
            }
    }

    @ViewBuilder
    func hookToolbar(_ content: some View) -> some View {
        if !sortedProfiles.isEmpty {
            content.toolbar {
                if vmDPV.currentProfile != nil {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("".description, systemImage: "arrow.clockwise") {
                            refreshAction()
                        }
                    }
                }
                if showProfileSwitcher {
                    ToolbarItem(placement: .confirmationAction) {
                        profileSwitcherMenu()
                    }
                }
            }
        } else {
            content
        }
    }

    // MARK: Private

    @State private var wrappedByNavStack: Bool
    @State private var showProfileSwitcher: Bool
    @State private var sharedDB: Enka.Sputnik = .shared
    @StateObject private var vmDPV: DetailPortalViewModel = .init()
    @StateObject private var pfMgrVM: ProfileManagerVM = .shared
    @StateObject private var tabNavVM = GlobalNavVM.shared
    @StateObject private var broadcaster = Broadcaster.shared
    @FocusState private var uidInputFieldFocus: Bool

    @Default(.pzProfiles) private var profiles: [String: PZProfileSendable]

    @Default(.queriedEnkaProfiles4GI) private var profiles4GI
    @Default(.queriedEnkaProfiles4HSR) private var profiles4HSR

    private var sortedProfiles: [PZProfileSendable] {
        profiles.map(\.value).sorted { $0.priority < $1.priority }
            .filter { $0.game != .zenlessZone } // 临时设定。
    }

    private func refreshAction() {
        broadcaster.refreshPage()
    }
}
