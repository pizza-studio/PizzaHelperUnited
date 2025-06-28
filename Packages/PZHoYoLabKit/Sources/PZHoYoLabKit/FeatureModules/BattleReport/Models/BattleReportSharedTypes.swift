// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import Foundation
import PZAccountKit
import SwiftUI

// MARK: - AbyssValueCell

struct AbyssValueCell: Identifiable, Hashable {
    // MARK: Lifecycle

    public init(value: String, description: String, avatarID: Int? = nil) {
        self.avatarID = avatarID
        self.value = value
        self.description = description.i18nHYLKit
    }

    public init(value: Int?, description: String, avatarID: Int? = nil) {
        self.avatarID = avatarID
        self.value = (value ?? -1).description
        self.description = description.i18nHYLKit
    }

    // MARK: Internal

    let id: Int = UUID().hashValue
    let avatarID: Int?
    var value: String
    var description: String

    @MainActor @ViewBuilder
    func makeAvatar() -> some View {
        switch avatarID {
        case .none: EmptyView()
        case let .some(avatarID):
            CharacterIconView(
                charID: avatarID.description,
                size: 48,
                circleClipped: true,
                clipToHead: true
            ).frame(width: 52, alignment: .center)
        }
    }
}
