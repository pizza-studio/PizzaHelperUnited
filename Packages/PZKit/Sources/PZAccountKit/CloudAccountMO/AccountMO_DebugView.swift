// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI
@preconcurrency import Sworm

// MARK: - AccountMOItemDebugView

@available(watchOS, unavailable)
public struct AccountMOItemDebugView: View {
    // MARK: Lifecycle

    public init(accountMO: AccountMOProtocol) {
        self.accountMO = accountMO
    }

    // MARK: Public

    public var body: some View {
        Section {
            LabeledContent("game".description) {
                Text(verbatim: accountMO.game.localizedShortName)
            }
            LabeledContent("allowNotification".description) {
                Text(verbatim: accountMO.allowNotification.description)
            }
            LabeledContent("cookie".description) {
                Text(verbatim: accountMO.cookie)
            }
            LabeledContent("deviceFingerPrint".description) {
                Text(verbatim: accountMO.deviceFingerPrint)
            }
            LabeledContent("name".description) {
                Text(verbatim: accountMO.name)
            }
            LabeledContent("priority".description) {
                Text(verbatim: accountMO.priority.description)
            }
            LabeledContent("serverRawValue".description) {
                Text(verbatim: accountMO.serverRawValue)
            }
            LabeledContent("sTokenV2".description) {
                Text(verbatim: accountMO.sTokenV2 ?? "N/A")
            }
        } header: {
            Text(verbatim: headerText)
        }
    }

    // MARK: Private

    private let accountMO: AccountMOProtocol

    private var headerText: String {
        "\(accountMO.game.uidPrefix)-\(accountMO.uid) // \(accountMO.uuid.uuidString)"
    }
}

// MARK: - AccountMODebugView

@available(watchOS, unavailable)
public struct AccountMODebugView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        Form {
            Text(
                verbatim:
                "This view enumerates all accountMO data from previous PizzaHelper4Genshin and PizzaHelper4HSR."
            )
            .font(.caption)
            ForEach(try! Self.sputnik.allAccountDataMO(for: game), id: \.uuid) { accountMO in
                AccountMOItemDebugView(accountMO: accountMO)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Picker("".description, selection: $game.animation()) {
                    ForEach(casesOfGames) { enumeratedGame in
                        Text(enumeratedGame.localizedShortName)
                            .tag(enumeratedGame)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                .onChange(of: game, initial: true) {
                    print("Action")
                }
            }
        }
    }

    // MARK: Private

    @MainActor private static let sputnik: AccountMOSputnik = .shared

    @State private var game: Pizza.SupportedGame = .genshinImpact

    private let casesOfGames: [Pizza.SupportedGame] = [.genshinImpact, .starRail]
}
