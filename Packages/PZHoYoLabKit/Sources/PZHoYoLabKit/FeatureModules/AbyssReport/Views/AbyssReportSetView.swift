// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssReportSetView

public struct AbyssReportSetView<Report: AbyssReport>: View {
    // MARK: Lifecycle

    public init(data: SetData, profile: PZProfileSendable?) {
        self.data = data
        self.profile = profile
    }

    // MARK: Public

    public typealias SetData = AbyssReportSetTyped<Report>

    public let data: SetData

    public let profile: PZProfileSendable?

    public var body: some View {
        container
            .navBarTitleDisplayMode(.inline)
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
                        Text("hylKit.abyssReport.seasonPicker.current".i18nHYLKit).tag(false)
                        Text("hylKit.abyssReport.seasonPicker.previous".i18nHYLKit).tag(true)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .fixedSize()
                }
            }
        }
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        #if os(iOS) || targetEnvironment(macCatalyst)
        .toolbar(.hidden, for: .tabBar)
        #endif
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

    private var hasPreviousSeasonContent: Bool { data.previous != nil }
}
