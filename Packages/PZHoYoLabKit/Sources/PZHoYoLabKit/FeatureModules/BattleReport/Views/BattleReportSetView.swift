// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - BattleReportSetView

public struct BattleReportSetView<Report: BattleReport>: View {
    // MARK: Lifecycle

    public init(data: SetData, profile: PZProfileSendable?) {
        self.data = data
        self.profile = profile
    }

    // MARK: Public

    public typealias SetData = BattleReportSetTyped<Report>

    public let data: SetData

    public let profile: PZProfileSendable?

    public var body: some View {
        container
            .navBarTitleDisplayMode(.inline)
            .fontWidth(screenVM.isExtremeCompact ? .compressed : nil)
    }

    @ViewBuilder public var container: some View {
        Group {
            if showPreviousSeason, hasPreviousSeasonContent {
                previousSeasonContent
            } else {
                currentSeasonContent
            }
        }
        .listContainerBackground()
        .toolbar {
            if hasPreviousSeasonContent {
                ToolbarItem(
                    placement: .confirmationAction
                ) {
                    Picker("".description, selection: $showPreviousSeason.animation()) {
                        Text("hylKit.battleReport.seasonPicker.current".i18nHYLKit).tag(false)
                        Text("hylKit.battleReport.seasonPicker.previous".i18nHYLKit).tag(true)
                    }
                    .labelsHidden()
                    .apply { thePicker in
                        if screenVM.isExtremeCompact {
                            thePicker.pickerStyle(.menu)
                        } else {
                            thePicker.pickerStyle(.segmented)
                        }
                    }
                    .fixedSize()
                }
            }
        }
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        .appTabBarVisibility(.hidden)
    }

    // MARK: Internal

    @ViewBuilder var currentSeasonContent: some View {
        data.current.asView(profile: profile)
    }

    @ViewBuilder var previousSeasonContent: some View {
        data.previous?.asView(profile: profile)
    }

    // MARK: Private

    @State private var showPreviousSeason = false
    @StateObject private var screenVM: ScreenVM = .shared

    private var hasPreviousSeasonContent: Bool { data.previous != nil }
}
