// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SwiftUI
import WidgetKit

extension View {
    @ViewBuilder
    func checkAndReloadWidgetTimeline() -> some View {
        modifier(WidgetTimelineReloader())
    }
}

// MARK: - WidgetTimelineReloader

private struct WidgetTimelineReloader: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                reloadAllTimelines()
            }
    }

    func reloadAllTimelines() {
        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
    }
}
