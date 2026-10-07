// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssValueCell

@available(iOS 17.0, macCatalyst 17.0, *)
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

// MARK: - BattleReportSeasonIDLabel

/// 各戰報的賽季編號統一用這個標籤顯示，掛在 Section 標題列的尾端。
/// 取不到賽季編號時不佔任何版面。
@available(iOS 17.0, macCatalyst 17.0, *)
struct BattleReportSeasonIDLabel: View {
    let seasonID: String?

    var body: some View {
        if let seasonID {
            Text("hylKit.battleReport.stat.seasonID".i18nHYLKit + " \(seasonID)")
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

// MARK: - HoYoBattleReportType

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol HoYoBattleReportType: Identifiable, CaseIterable, AbleToCodeSendHash {
    associatedtype BattleReportData: BattleReport
    var localizedTitle: String { get }
}
