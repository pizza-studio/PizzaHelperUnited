// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import Observation
import PZAccountKit
import PZBaseKit
import SwiftUI

#if os(iOS) && !targetEnvironment(macCatalyst)
@available(iOS 17.0, macCatalyst 17.0, *)
extension DetailPortalTabPage: KeyboardReadable {}
#endif

// MARK: - DetailPortalTabPage

@available(iOS 17.0, macCatalyst 17.0, *)
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
                    .navBarTitleDisplayMode(.large)
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
        .formStyle(.grouped).disableFocusable()
        .refreshable {
            refreshAction()
        }
        .navigationTitle(
            screenVM.isExtremeCompact
                ? rootNavVM.rootPageNav.labelNameText
                : Text("tab.details.fullTitle".i18nPZHelper)
        )
        .apply(hookToolbar)
        .safeAreaInset(edge: .bottom) {
            if !isKeyboardVisible {
                rootNavVM.iOSBottomTabBarForBuggyOS25ReleasesOn
            }
        }
        .onAppear {
            if let profile = vmDPV.currentProfile, !sortedProfiles.contains(profile) {
                vmDPV.currentProfile = nil
            }
        }
        #if os(iOS) && !targetEnvironment(macCatalyst)
        .onReceive(keyboardPublisher) { keyboardComesOut in
            withAnimation {
                isKeyboardVisible = keyboardComesOut
            }
        }
        #endif
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
                ProfileShowCaseSections(theDB4GI: sharedDB.db4GI, pzProfile: profile) {
                    AnyView(CharInventoryNav(theVM: vmDPV))
                } onTapGestureAction: {
                    uidInputFieldFocus = false
                }
                .listRowMaterialBackground()
                .id(profile.uidWithGame) // 很重要，否则在同款游戏之间的账号切换不会生效。
                query4GI
            case .starRail:
                ProfileShowCaseSections(theDB4HSR: sharedDB.db4HSR, pzProfile: profile) {
                    AnyView(CharInventoryNav(theVM: vmDPV))
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
                BattleReportNav(theVM: vmDPV)
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

    @ViewBuilder
    func profileSwitcherMenu() -> some View {
        pfMgrVM.profileSwitcherMenu4DPV(
            $vmDPV.currentProfile,
            games: [.genshinImpact, .starRail]
        )
    }

    @ViewBuilder
    func hookToolbar(_ content: some View) -> some View {
        if !sortedProfiles.isEmpty {
            content.toolbar {
                if vmDPV.currentProfile != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("".description, systemImage: "arrow.clockwise") {
                            refreshAction()
                        }
                    }
                }
                if #available(iOS 26.0, macCatalyst 26.0, macOS 26.0, *) {
                    ToolbarSpacer(.flexible, placement: .primaryAction)
                }
                if showProfileSwitcher {
                    ToolbarItem(placement: .primaryAction) {
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
    @State private var vmDPV: DetailPortalViewModel = .shared
    @StateObject private var pfMgrVM: ProfileManagerVM = .shared
    @State private var rootNavVM = RootNavVM.shared
    @State private var screenVM: ScreenVM = .shared
    @StateObject private var broadcaster = Broadcaster.shared
    @FocusState private var uidInputFieldFocus: Bool
    @State private var isKeyboardVisible = false

    @Default(.pzProfiles) private var profiles: [String: PZProfileSendable]

    private var sortedProfiles: [PZProfileSendable] {
        profiles.map(\.value).sorted { $0.priority < $1.priority }
            .filter { $0.game != .zenlessZone } // 临时设定。
    }

    private func refreshAction() {
        broadcaster.refreshPage()
    }
}
