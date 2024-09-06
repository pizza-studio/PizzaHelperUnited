// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - AbyssReportSetView

public struct AbyssReportSetView<Report: AbyssReport>: View {
    // MARK: Lifecycle

    public init(data: SetData) {
        self.data = data
    }

    // MARK: Public

    public typealias SetData = AbyssReportSetTyped<Report>

    public let data: SetData

    @MainActor public var body: some View {
        container
    }

    @MainActor @ViewBuilder public var container: some View {
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
                    placement: .navigationBarTrailing
                ) {
                    Picker("", selection: $showPreviousSeason.animation()) {
                        Text("hylKit.abyssReport.seasonPicker.current".i18nHYLKit).tag(false)
                        Text("hylKit.abyssReport.seasonPicker.previous".i18nHYLKit).tag(true)
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                    .background(
                        RoundedRectangle(cornerRadius: 8).foregroundStyle(.thinMaterial)
                    )
                }
            }
        }
    }

    // MARK: Internal

    @MainActor @ViewBuilder var currentSeasonContent: some View {
        data.current.asView()
    }

    @MainActor @ViewBuilder var previousSeasonContent: some View {
        data.previous?.asView()
    }

    // MARK: Private

    @State private var showPreviousSeason = false

    private var hasPreviousSeasonContent: Bool { data.previous != nil }
}
