// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import GITodayMaterialsKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
@available(watchOS, unavailable)
extension DesktopWidgets {
    public struct MaterialView: View {
        // MARK: Lifecycle

        public init(alternativeLayout: Bool = false, today: GITodayMaterial.AvailableWeekDay? = nil) {
            self.alternativeLayout = alternativeLayout
            self.today = today ?? .today()
        }

        // MARK: Public

        public var body: some View {
            GITodayMaterialsView4Widgets(
                alternativeLayout: alternativeLayout,
                today: today
            ) {
                Text("pzWidgetsKit.material.sunday", bundle: .module)
                    .foregroundColor(PZWidgetsSPM.Colors.TextColor.primaryWhite.suiColor)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
                    .legibilityShadow()
            }
        }

        // MARK: Private

        private let alternativeLayout: Bool
        private var today: GITodayMaterial.AvailableWeekDay? = .today()
    }
}

#endif
