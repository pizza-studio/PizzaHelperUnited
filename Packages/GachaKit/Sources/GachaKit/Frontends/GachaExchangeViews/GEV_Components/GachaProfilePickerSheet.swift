// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - GachaProfilePickerSheet

public struct GachaProfilePickerSheet: View {
    @Binding public var chosenGPIDs: [GachaProfileWithPicker]

    @MainActor public var body: some View {
        NavigationStack {
            Form {
                ForEach(chosenGPIDs) { gpidPair in
                    @Bindable var gpidPair = gpidPair
                }
            }.formStyle(.grouped)
        }
    }
}

// MARK: - GachaProfileWithPicker

@Observable
public final class GachaProfileWithPicker: @unchecked Sendable, Identifiable {
    // MARK: Lifecycle

    public init(id: GachaProfileID) {
        self.id = id
    }

    // MARK: Public

    public let id: GachaProfileID
    public var isChosen: Bool = false
}
