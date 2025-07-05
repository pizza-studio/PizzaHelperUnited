// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - DesktopWidgets.MetaBlockView4Desktop

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    // MARK: - MetaBlockView4Desktop

    public struct MetaBlockView4Desktop: View {
        // MARK: Lifecycle

        public init(
            dailyNote: any DailyNoteProtocol,
            viewConfig: WidgetViewConfig,
            spacing: CGFloat = 13
        ) {
            self.dailyNote = dailyNote
            self.viewConfig = viewConfig
            self.spacing = spacing
        }

        // MARK: Public

        public var lineHeightMax: CGFloat {
            viewConfig.useTinyGlassDisplayStyle ? 17 : 25
        }

        public var body: some View {
            VStack(alignment: .leading, spacing: spacing) {
                ForEach(Array(allMetaBars.enumerated()), id: \.offset) { offset, currentMetaBar in
                    AnyView(currentMetaBar.body)
                        .frame(maxHeight: lineHeightMax)
                        .tag(offset)
                }
            }
        }

        // MARK: Private

        private let dailyNote: any DailyNoteProtocol
        private let viewConfig: WidgetViewConfig
        private let spacing: CGFloat

        private var allMetaBars: [any MetaBar] {
            dailyNote.getMetaBlockContents(config: viewConfig)
        }
    }
}

#if DEBUG && !os(watchOS)

#Preview {
    let viewConfig = WidgetViewConfig()
    NavigationStack {
        Form {
            DesktopWidgets.MetaBlockView4Desktop(
                dailyNote: Pizza.SupportedGame.genshinImpact.exampleDailyNoteData,
                viewConfig: viewConfig,
                spacing: 0
            )
            DesktopWidgets.MetaBlockView4Desktop(
                dailyNote: Pizza.SupportedGame.starRail.exampleDailyNoteData,
                viewConfig: viewConfig,
                spacing: 0
            )
            DesktopWidgets.MetaBlockView4Desktop(
                dailyNote: Pizza.SupportedGame.zenlessZone.exampleDailyNoteData,
                viewConfig: viewConfig,
                spacing: 0
            )
        }.formStyle(.grouped)
    }
}

#endif
