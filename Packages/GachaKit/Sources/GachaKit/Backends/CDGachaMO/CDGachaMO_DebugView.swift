// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
@preconcurrency import Sworm

// MARK: - CDGachaMOItemDebugView

public struct CDGachaMOItemDebugView: View {
    // MARK: Lifecycle

    public init(gachaItemMO: CDGachaMOProtocol) {
        self.gachaItemMO = gachaItemMO
    }

    // MARK: Public

    @MainActor public var body: some View {
        LabeledContent {
            VStack(alignment: .trailing) {
                Text(verbatim: gachaItemMO.time.formatted())
                Text(verbatim: gachaItemMO.uid)
            }.font(.footnote)
        } label: {
            Text(verbatim: gachaItemMO.name)
        }
        .navigationTitle("# Gacha Cloud Debug".description)
    }

    // MARK: Private

    private let gachaItemMO: CDGachaMOProtocol
}

// MARK: - CDGachaMODebugView

public struct CDGachaMODebugView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        Form {
            ForEach(try! CDGachaMOSputnik.shared.allGachaDataMO(for: game), id: \.enumID) { gachaItemMO in
                CDGachaMOItemDebugView(gachaItemMO: gachaItemMO)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Picker("".description, selection: $game.animation()) {
                    ForEach(Pizza.SupportedGame.allCases) { enumeratedGame in
                        Text(enumeratedGame.localizedShortName)
                            .tag(enumeratedGame)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: game, initial: true) {
                    print("Action")
                }
            }
        }
    }

    // MARK: Internal

    @State var game: Pizza.SupportedGame = .genshinImpact
}
