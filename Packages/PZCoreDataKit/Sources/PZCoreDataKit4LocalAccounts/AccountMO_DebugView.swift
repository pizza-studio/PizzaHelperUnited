// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZCoreDataKitShared
import SwiftUI
@preconcurrency import Sworm

// MARK: - AccountMOItemDebugView

@available(macOS 14, *)
@available(macCatalyst 17, *)
@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
private struct AccountMOItemDebugView: View {
    // MARK: Lifecycle

    public init(accountMO: AccountMOProtocol) {
        self.accountMO = accountMO
    }

    // MARK: Public

    public var body: some View {
        Section {
            LabeledContent("game".description) {
                Text(verbatim: accountMO.storedGame.uidPrefix)
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
        "\(accountMO.storedGame.uidPrefix)-\(accountMO.uid) // \(accountMO.uuid.uuidString)"
    }
}

// MARK: - AccountMODebugView

@available(macOS 14, *)
@available(macCatalyst 17, *)
@available(iOS 17, *)
@available(iOSApplicationExtension, unavailable)
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
            let allAccountData = try! Self.sputnik.allAccountData(for: game)
            ForEach(allAccountData, id: \.uuid) { accountMO in
                AccountMOItemDebugView(accountMO: accountMO)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Picker("".description, selection: $game.animation()) {
                    ForEach(casesOfGames) { enumeratedGame in
                        Text(enumeratedGame.uidPrefix)
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

    @State private var game: PZCoreDataKit.StoredGame = .genshinImpact

    private let casesOfGames: [PZCoreDataKit.StoredGame] = [.genshinImpact, .starRail]
}

#endif
