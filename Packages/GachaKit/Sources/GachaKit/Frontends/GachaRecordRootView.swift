// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - GachaRecordRootView

public struct GachaRecordRootView: View {
    // MARK: Lifecycle

    public init(legacyImporter: (() -> Void)?) {
        self.importLegacyRecords = legacyImporter
    }

    // MARK: Public

    public static var navTitle: String = "gachaKit.GachaRecordRootView.navTitle".i18nGachaKit

    public static var navIcon: Image { Image("GachaRecordMgr_NavIcon", bundle: .module) }

    @MainActor public var body: some View {
        coreBody
            .navigationTitle(Self.navTitle)
            .navBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Menu {
                        Text("Temporary PlaceHolder".description)
                    } label: {
                        Image(systemSymbol: .goforwardPlus)
                    }
                }
            }
    }

    // MARK: Private

    private let importLegacyRecords: (() -> Void)?
    @Query(sort: \PZGachaEntryMO.id) private var profiles: [PZGachaEntryMO]

    private var allowImporingOldRecords: Bool { importLegacyRecords != nil }
}

extension GachaRecordRootView {
    @MainActor @ViewBuilder public var coreBody: some View {
        List {
            Text("Under construction".description)
        }
    }
}
