// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI
import UserNotifications

// MARK: - ApplicationIconBadgeNumberCleaner

@available(iOS 16.2, macCatalyst 16.2, *)
private struct ApplicationIconBadgeNumberCleaner: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                Task { @MainActor in
                    try? await PZNotificationCenter.center.setBadgeCount(0)
                }
            }
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension View {
    @ViewBuilder
    func cleanApplicationIconBadgeNumber() -> some View {
        modifier(ApplicationIconBadgeNumberCleaner())
    }
}
