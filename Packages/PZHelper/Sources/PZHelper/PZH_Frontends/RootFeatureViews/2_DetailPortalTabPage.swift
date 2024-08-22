// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import Observation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - DetailPortalTabPage

@MainActor
struct DetailPortalTabPage: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                let query4GI = CaseQuerySection(theDB: sharedDB.db4GI, focus: $uidInputFieldFocus)
                let query4HSR = CaseQuerySection(theDB: sharedDB.db4HSR, focus: $uidInputFieldFocus)
                if let profile = delegate.currentPZProfile {
                    switch profile.game {
                    case .genshinImpact:
                        ProfileShowCaseSections(theDB: sharedDB.db4GI, pzProfile: profile)
                            .id(profile.uid) // 很重要，否则在同款游戏之间的帐号切换不会生效。
                            .onTapGesture { uidInputFieldFocus = false }
                        query4GI
                    case .starRail:
                        ProfileShowCaseSections(theDB: sharedDB.db4HSR, pzProfile: profile)
                            .id(profile.uid) // 很重要，否则在同款游戏之间的帐号切换不会生效。
                            .onTapGesture { uidInputFieldFocus = false }
                        query4HSR
                    }
                } else {
                    query4GI
                    query4HSR
                }
            }
            .formStyle(.grouped)
            .refreshable {
                broadcaster.refreshPage()
            }
            .navigationTitle("tab.details.fullTitle".i18nPZHelper)
            .navigationDestination(for: Enka.QueriedProfileGI.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4GI
                )
            }
            .navigationDestination(for: Enka.QueriedProfileHSR.self) { result in
                ShowCaseListView(
                    profile: result,
                    enkaDB: sharedDB.db4HSR
                )
            }
            .toolbar {
                // if delegate.currentPZProfile == nil, !profiles.isEmpty {
                if !profiles.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        accountSwitcherMenu()
                    }
                }
            }
        }
    }

    @ViewBuilder
    func accountSwitcherMenu(staticIcon useStaticIcon: Bool = false) -> some View {
        Menu {
            Button {
                withAnimation {
                    delegate.currentPZProfile = nil
                }
            } label: {
                LabeledContent {
                    Text("dpv.query.menuCommandTitle".i18nPZHelper)
                        .multilineTextAlignment(.leading)
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity)
                } label: {
                    Image(systemSymbol: .magnifyingglassCircleFill).frame(width: 48).padding(.trailing, 4)
                }
            }
            Divider()
            ForEach(sortedProfiles) { enumeratedProfile in
                Button {
                    withAnimation {
                        delegate.currentPZProfile = enumeratedProfile
                    }
                } label: {
                    enumeratedProfile.asMenuLabel4SUI()
                }
            }
        } label: {
            LabeledContent {
                let dimension: CGFloat = 30
                Group {
                    if let profile = delegate.currentPZProfile {
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
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 8)
                        .frame(width: dimension, height: dimension)
                }
                .frame(width: dimension, height: dimension)
                .clipShape(.circle)
                .compositingGroup()
            } label: {
                if let profile = delegate.currentPZProfile {
                    Text(profile.uidWithGame)
                } else {
                    Text("dpv.query.menuCommandTitle".i18nPZHelper)
                }
            }
            .padding(4).padding(.leading, 12)
            .blurMaterialBackground()
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: Private

    @State private var sharedDB: Enka.Sputnik = .shared
    @State private var delegate: Coordinator = .init()
    @State private var broadcaster = ViewEventBroadcaster.shared
    @FocusState private var uidInputFieldFocus: Bool
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]
    @Default(.queriedEnkaProfiles4GI) private var profiles4GI
    @Default(.queriedEnkaProfiles4HSR) private var profiles4HSR

    private var sortedProfiles: [PZProfileMO] {
        profiles.sorted { $0.priority < $1.priority }
    }
}

// MARK: DetailPortalTabPage.Coordinator

extension DetailPortalTabPage {
    @MainActor @Observable
    public final class Coordinator {
        // MARK: Lifecycle

        public init() {
            let pzProfiles = try? PersistenceController.shared.modelContainer
                .mainContext.fetch(FetchDescriptor<PZProfileMO>())
                .sorted { $0.priority < $1.priority }
            self.currentPZProfile = pzProfiles?.first
        }

        // MARK: Internal

        var currentPZProfile: PZProfileMO?
    }
}
