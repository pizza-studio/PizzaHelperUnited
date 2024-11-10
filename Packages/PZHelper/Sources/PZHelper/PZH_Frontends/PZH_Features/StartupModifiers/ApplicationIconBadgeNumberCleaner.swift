// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI
import UserNotifications

// MARK: - ApplicationIconBadgeNumberCleaner

private struct ApplicationIconBadgeNumberCleaner: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                Task { @MainActor in
                    try? await PZNotificationCenter.center.setBadgeCount(0)
                }
            }
    }
}

extension View {
    func cleanApplicationIconBadgeNumber() -> some View {
        modifier(ApplicationIconBadgeNumberCleaner())
    }
}
