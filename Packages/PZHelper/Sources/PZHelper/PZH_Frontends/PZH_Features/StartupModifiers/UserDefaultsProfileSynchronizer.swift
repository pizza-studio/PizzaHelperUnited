// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import UserNotifications

// MARK: - UserDefaultsProfileSynchronizer

@available(iOS 16.2, macCatalyst 16.2, *)
private struct UserDefaultsProfileSynchronizer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                Task { @MainActor in
                    await ProfileManagerVM.shared
                        .profileActor?
                        .syncAllDataToUserDefaults()
                }
            }
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension View {
    @ViewBuilder
    func syncProfilesToUserDefaults() -> some View {
        modifier(UserDefaultsProfileSynchronizer())
    }
}
