// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - GachaRecordRootView

public struct GachaRecordRootView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = "gachaKit.GachaRecordRootView.navTitle".i18nGachaKit

    public static var navIcon: Image { Image("GachaRecordMgr_NavIcon", bundle: .module) }

    @MainActor public var body: some View {
        coreBody
            .navigationTitle(theVM.currentGPIDTitle ?? Self.navTitle)
            .navBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    GachaProfileSwitcherView()
                }
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .confirmationAction) {
                        ProgressView()
                    }
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
                        }.disabled(pzGachaProfileIDs.isEmpty)
                        if CDGachaMOSputnik.shared.hasData {
                            Divider()
                            Button("IMPORT_DATA".description) {
                                theVM.migrateOldGachasIntoProfiles()
                            }
                        }
                        Button("REFRESH_GACHA_UID_LIST".description) {
                            theVM.refreshGachaUIDList()
                        }
                    } label: {
                        Image(systemSymbol: .goforwardPlus)
                    }
                }
            }
            .saturation(theVM.taskState == .busy ? 0 : 1)
            .environment(theVM)
    }

    // MARK: Fileprivate

    @Environment(\.modelContext) fileprivate var modelContext
    @Query(sort: \PZProfileMO.priority) fileprivate var pzProfiles: [PZProfileMO]
    @Query fileprivate var pzGachaProfileIDs: [PZGachaProfileMO]
    @State fileprivate var theVM: GachaVM = .shared
}

extension GachaRecordRootView {
    @MainActor @ViewBuilder public var coreBody: some View {
        Form {
            if theVM.currentGPID != nil {
                GachaProfileView()
            } else if !pzGachaProfileIDs.isEmpty {
                Text("gachaKit.prompt.pleaseChooseGachaProfile".i18nGachaKit)
            } else {
                Text("gachaKit.prompt.noGachaProfileFound".i18nGachaKit)
            }
        }
        .formStyle(.grouped)
    }
}
