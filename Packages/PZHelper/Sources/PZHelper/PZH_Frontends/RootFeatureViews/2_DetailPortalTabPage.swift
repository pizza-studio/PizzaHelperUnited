// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import Observation
import PZAccountKit
import SFSafeSymbols
import SwiftData
import SwiftUI

@MainActor
struct DetailPortalTabPage: View {
    // MARK: Lifecycle

    public init() {
        self.currentPZProfile = profiles.first
    }

    // MARK: Internal

    var body: some View {
        NavigationStack {
            Form {
                if let currentPZProfile {
                    switch currentPZProfile.game {
                    case .genshinImpact:
                        Text(verbatim: "# GI ShowCase Under Construction.")
                        CaseQuerySection(theDB: sharedDB.db4GI)
                    // ShowCaseListView(profile: currentPZProfile, enkaDB: sharedDB.db4GI)
                    case .starRail:
                        Text(verbatim: "# HSR ShowCase Under Construction.")
                        CaseQuerySection(theDB: sharedDB.db4HSR)
                        // ShowCaseListView(profile: currentPZProfile, enkaDB: sharedDB.db4HSR)
                    }
                } else {
                    CaseQuerySection(theDB: sharedDB.db4GI)
                    CaseQuerySection(theDB: sharedDB.db4HSR)
                }
            }
            .formStyle(.grouped)
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
                ToolbarItem(placement: .topBarTrailing) {
                    accountSwitcherMenuContent
                }
            }
        }
    }

    @ViewBuilder var accountSwitcherMenuContent: some View {
        Menu {
            Button {
                currentPZProfile = nil
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
            .labelStyle(.titleAndIcon)
            Divider()
            ForEach(profiles) { enumeratedProfile in
                Button {
                    currentPZProfile = enumeratedProfile
                } label: {
                    enumeratedProfile.asAccountMenuLabel4SUI()
                }
                .labelStyle(.titleAndIcon)
            }
        } label: {
            let dimension: CGFloat = 35
            Group {
                if let profile = currentPZProfile {
                    Enka.ProfileIconView(uid: profile.uid, game: profile.game).frame(width: dimension)
                } else {
                    Image(systemSymbol: .magnifyingglassCircleFill).frame(width: dimension)
                }
            }
            .background {
                Circle()
                    .strokeBorder(Color.accentColor, lineWidth: 9)
                    .frame(width: dimension, height: dimension)
            }
            .frame(width: dimension, height: dimension)
            .compositingGroup()
        }
    }

    // MARK: Private

    @State private var currentPZProfile: PZProfileMO?
    @State private var sharedDB: Enka.Sputnik = .shared
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]
    @Default(.queriedEnkaProfiles4GI) private var profiles4GI
    @Default(.queriedEnkaProfiles4HSR) private var profiles4HSR
}
