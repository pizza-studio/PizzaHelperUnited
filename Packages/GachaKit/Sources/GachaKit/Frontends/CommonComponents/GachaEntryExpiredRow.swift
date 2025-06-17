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

    public var body: some View {
        if isVisible {
            VStack {
                Button {
                    theVM.currentError = nil
                    theVM.currentSceneStep4Import = .chooseFormat
                    theVM.updateGMDB(for: games)
                } label: {
                    Text("gachaKit.GMDB.clickHereToUpdateGMDB", bundle: .module)
                        .fontWeight(.bold)
                        .fontWidth(.condensed)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(8)
                        .background {
                            Capsule().foregroundStyle(.primary.opacity(0.1))
                        }
                        .foregroundStyle(.red)
                }
                Text("gachaKit.GMDB.gmdbExpired.explanation", bundle: .module)
                    .asInlineTextDescription()
            }
        }
    }

    // MARK: Private

    @Environment(GachaVM.self) private var theVM

    private let alwaysVisible: Bool
    private let games: [Pizza.SupportedGame?]?

    private var isVisible: Bool {
        if case .databaseExpired = theVM.currentError as? GachaMeta.GMDBError {
            return true
        }
        return alwaysVisible
    }
}
