// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI
import WidgetKit

@available(iOS 16.2, macCatalyst 16.2, *)
extension View {
    @ViewBuilder
    func checkAndReloadWidgetTimeline() -> some View {
        modifier(WidgetTimelineReloader())
    }
}

// MARK: - WidgetTimelineReloader

@available(iOS 16.2, macCatalyst 16.2, *)
private struct WidgetTimelineReloader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
            }
    }
}
