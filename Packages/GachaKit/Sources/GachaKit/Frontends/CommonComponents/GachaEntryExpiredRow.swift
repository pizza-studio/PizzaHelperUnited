// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaMetaDB
import PZBaseKit
import SwiftUI

public struct GachaEntryExpiredRow: View {
    // MARK: Lifecycle

    public init(alwaysVisible: Bool, games: [Pizza.SupportedGame?]? = nil) {
        self.alwaysVisible = alwaysVisible
        self.games = games
    }

    // MARK: Public

    @MainActor public var body: some View {
        if isVisible {
            VStack {
                Button {
                    theVM.updateGMDB(for: games)
                } label: {
                    Text("gachaKit.export.clickHereToUpdateGMDB".i18nGachaKit)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                        .background {
                            RoundedRectangle(cornerRadius: 8).foregroundStyle(.primary.opacity(0.1))
                        }
                        .foregroundStyle(.red)
                }
                Text("gachaKit.export.gmdbExpired.explanation".i18nGachaKit)
                    .font(.footnote).foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    // MARK: Fileprivate

    fileprivate let alwaysVisible: Bool
    fileprivate let games: [Pizza.SupportedGame?]?
    @Environment(GachaVM.self) fileprivate var theVM

    fileprivate var isVisible: Bool {
        if case .databaseExpired = theVM.currentError as? GachaMeta.GMDBError {
            return true
        }
        return alwaysVisible
    }
}
