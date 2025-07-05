// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI
import UserNotifications

// MARK: - ApplicationIconBadgeNumberCleaner

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension View {
    @ViewBuilder
    func cleanApplicationIconBadgeNumber() -> some View {
        modifier(ApplicationIconBadgeNumberCleaner())
    }
}
