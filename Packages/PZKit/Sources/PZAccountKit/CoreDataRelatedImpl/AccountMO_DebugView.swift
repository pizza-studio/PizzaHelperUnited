// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)
import PZCoreDataKit4LocalAccounts
import PZCoreDataKitShared
import SwiftUI
@preconcurrency import Sworm

// MARK: - AccountMOItemDebugView

@available(iOS 17.0, macCatalyst 17.0, *)
private struct AccountMOItemDebugView: View {
    // MARK: Lifecycle

    public init(accountMO: AccountMOProtocol) {
        self.accountMO = accountMO
    }

    // MARK: Public

    public var body: some View {
        Section {
            LabeledContent("game".description) {
                Text(verbatim: accountMO.cdStoredGame.uidPrefix)
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
        "\(accountMO.cdStoredGame.uidPrefix)-\(accountMO.uid) // \(accountMO.uuid.uuidString)"
    }
}

// MARK: - AccountMODebugView

@available(iOS 17.0, macCatalyst 17.0, *)
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
            .react(to: game, initial: true) {
                Task { @MainActor in
                    allAccountData = try! await Self.sputnik?.allAccountData(for: game) ?? []
                }
            }
            ForEach(allAccountData, id: \.uuid) { accountMO in
                AccountMOItemDebugView(accountMO: accountMO)
            }
        }
        .formStyle(.grouped).disableFocusable()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Picker("".description, selection: $game.animation()) {
                    ForEach(casesOfGames) { enumeratedGame in
                        Text(enumeratedGame.uidPrefix)
                            .tag(enumeratedGame)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
                .react(to: game, initial: true) {
                    print("Action")
                }
            }
        }
    }

    // MARK: Private

    @MainActor private static let sputnik: CDAccountMOActor? = .shared

    @State private var game: PZCoreDataKit.CDStoredGame = .genshinImpact

    @State private var allAccountData: [any AccountMOProtocol] = []

    private let casesOfGames: [PZCoreDataKit.CDStoredGame] = [.genshinImpact, .starRail]
}

#endif
