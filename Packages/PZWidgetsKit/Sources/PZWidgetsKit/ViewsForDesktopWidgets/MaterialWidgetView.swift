// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import GITodayMaterialsKit
import SwiftUI

@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct MaterialWidgetView: View {
        // MARK: Lifecycle

        public init(
            entry: MaterialWidgetEntry
        ) {
            self.entry = entry
        }

        // MARK: Public

        public let entry: MaterialWidgetEntry

        public var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    WeekdayDisplayView()
                    Spacer()
                    ZStack(alignment: .trailing) {
                        if entry.materialWeekday != nil {
                            MaterialView(alternativeLayout: true)
                        } else {
                            Image(systemSymbol: .checkmarkCircleFill)
                                .resizable()
                                .scaledToFit()
                                .clipShape(Circle())
                                .legibilityShadow(isText: false)
                        }
                    }
                    .frame(height: 35)
                }
                .frame(height: 40)
                .padding(.bottom, 12)
                OfficialFeedList4WidgetsView(
                    events: entry.events,
                    showLeadingBorder: true
                )
            }
            .padding()
            .environment(\.colorScheme, .dark)
            .pzWidgetContainerBackground(viewConfig: viewConfig)
        }

        // MARK: Private

        private let viewConfig: WidgetViewConfig = {
            var result = WidgetViewConfig()
            result.randomBackground = false
            result.selectedBackgrounds = [
                WidgetBackground.randomNamecardBackground4Game(.genshinImpact),
            ]
            result.isDarkModeRespected = true
            return result
        }()
    }
}
