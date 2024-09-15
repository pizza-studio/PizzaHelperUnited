// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import GachaMetaDB
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - GachaView

public struct GachaView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        GachaRecordRootView()
    }
}

// MARK: - GachaRecordRootView

public struct GachaRecordRootView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static var navTitle: String = "gachaKit.GachaRecordRootView.navTitle".i18nGachaKit

    public static var navIcon: Image { Image("GachaRecordMgr_NavIcon", bundle: .module) }

    @MainActor public var body: some View {
        coreBody
            .navigationTitle(Self.navTitle)
            .navBarTitleDisplayMode(noDataAvailable ? .large : .none)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    profileSwitcherMenu()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Menu {
                        NavigationLink("gachaKit.home.get_gacha_record") {
                            EmptyView() // GetGachaRecordView()
                        }
                        NavigationLink("gachaKit.home.manage_gacha_record") {
                            EmptyView() // ManageGachaRecordView()
                        }
                        NavigationLink("gachaKit.manage.uigf.import") {
                            EmptyView() // ImportGachaView()
                        }
                        NavigationLink("gachaKit.manage.uigf.export") {
                            EmptyView() // ExportGachaView()
                        }.disabled(noDataAvailable)
                        if CDGachaMOSputnik.shared.hasData {
                            Divider()
                            Button("IMPORT_DATA".description) {
                                isBusy = true
                                Task(priority: .background) {
                                    defer { isBusy = false }
                                    try? await GachaActor.migrateOldGachasIntoProfiles()
                                }
                            }
                        }
                    } label: {
                        Image(systemSymbol: .goforwardPlus)
                    }
                }
            }
            .onAppear {
                if delegate.currentGachaProfile == nil {
                    resetDefaultProfile()
                } else if let profile = delegate.currentGachaProfile, !pzGachaProfileIDs.contains(profile) {
                    delegate.currentGachaProfile = nil
                }
            }
    }

    // MARK: Fileprivate

    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(\.horizontalSizeClass) fileprivate var horizontalSizeClass: UserInterfaceSizeClass?
    @State fileprivate var enkaDB = Enka.Sputnik.shared
    @State fileprivate var metaDB = GachaMeta.sharedDB
    @State fileprivate var isBusy = false
    @Query fileprivate var entries: [PZGachaEntryMO]
    @Query(sort: \PZProfileMO.priority) fileprivate var pzProfiles: [PZProfileMO]
    @Query fileprivate var pzGachaProfileIDs: [PZGachaProfileMO]
    @State fileprivate var delegate: Coordinator = .init()

    fileprivate var sortedGachaProfiles: [PZGachaProfileMO] {
        pzGachaProfileIDs.sorted { $0.uidWithGame < $1.uidWithGame }
    }
}

extension GachaRecordRootView {
    @MainActor @ViewBuilder public var coreBody: some View {
        Form {
            if let gachaProfile = delegate.currentGachaProfile {
                Text(gachaProfile.uidWithGame) + Text("in action".description)
            } else {
                Text("gachaKit.noGachaProfileChoosen".i18nGachaKit)
            }
        }
        .formStyle(.grouped)
    }

    @MainActor @ViewBuilder
    func profileSwitcherMenu() -> some View {
        let nameIDMap = nameIDMap
        Menu {
            ForEach(sortedGachaProfiles) { profileIDObj in
                Button {
                    withAnimation {
                        delegate.currentGachaProfile = profileIDObj
                    }
                } label: {
                    Label {
                        if let name = nameIDMap[profileIDObj.uidWithGame] {
                            #if targetEnvironment(macCatalyst)
                            Text(name + " // \(profileIDObj.uidWithGame)")
                            #else
                            Text(name + "\n\(profileIDObj.uidWithGame)")
                            #endif
                        } else {
                            Text(profileIDObj.uidWithGame)
                        }
                    } icon: {
                        profileIDObj.photoView
                    }
                    .id(profileIDObj.uidWithGame)
                }
            }
        } label: {
            profileSwitcherMenuLabel
        }
    }

    @MainActor @ViewBuilder var profileSwitcherMenuLabel: some View {
        LabeledContent {
            let dimension: CGFloat = 30
            Group {
                if let profile: PZGachaProfileMO = delegate.currentGachaProfile {
                    profile.photoView.frame(width: dimension)
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
            if let profile: PZGachaProfileMO = delegate.currentGachaProfile {
                Text(profile.uidWithGame).monospacedDigit()
            } else {
                Text("gachaKit.noGachaProfileChoosen".i18nGachaKit)
            }
        }
        .padding(4).padding(.leading, 12)
        .blurMaterialBackground()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

extension GachaRecordRootView {
    fileprivate var noDataAvailable: Bool { pzGachaProfileIDs.isEmpty }

    fileprivate var nameIDMap: [String: String] {
        var nameMap = [String: String]()
        try? modelContext.enumerate(FetchDescriptor<PZProfileMO>(), batchSize: 1) { pzProfile in
            if nameMap[pzProfile.uidWithGame] == nil { nameMap[pzProfile.uidWithGame] = pzProfile.name }
        }
        return nameMap
    }

    fileprivate func resetDefaultProfile() {
        guard let matched = pzProfiles.first else { return }
        let firstExistingProfile = sortedGachaProfiles.first {
            $0.uid == matched.uid && $0.game == matched.game
        }
        guard let firstExistingProfile else { return }
        delegate.currentGachaProfile = firstExistingProfile
    }
}

// MARK: GachaRecordRootView.Coordinator

extension GachaRecordRootView {
    @Observable
    public class Coordinator: @unchecked Sendable {
        public var currentGachaProfile: PZGachaProfileMO?
    }
}
