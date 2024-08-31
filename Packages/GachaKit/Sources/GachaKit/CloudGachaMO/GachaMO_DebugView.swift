// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
import Sworm

// MARK: - GachaMOItemDebugView

public struct GachaMOItemDebugView: View {
    // MARK: Lifecycle

    public init(gachaItemMO: GachaMOProtocol) {
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

    private let gachaItemMO: GachaMOProtocol
}

// MARK: - GachaMODebugView

public struct GachaMODebugView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        Form {
            ForEach(try! Self.sputnik.allGachaDataMO(for: game), id: \.enumID) { gachaItemMO in
                GachaMOItemDebugView(gachaItemMO: gachaItemMO)
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
                .padding(4)
                .pickerStyle(.segmented)
                .onChange(of: game, initial: true) {
                    print("Action")
                }
            }
        }
    }

    // MARK: Internal

    @MainActor static let sputnik = try! GachaMOSputnik(
        persistence: .cloud, backgroundContext: false
    )

    @State var game: Pizza.SupportedGame = .genshinImpact
}
