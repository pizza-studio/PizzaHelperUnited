// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI
import UserNotifications

// MARK: - EnkaDBSanityChecker

private struct EnkaDBSanityChecker: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppBecomeActive {
                Task { @MainActor in
                    try? await Enka.Sputnik.shared.db4HSR.reinitIfLocMismatches()
                    try? await Enka.Sputnik.shared.db4GI.reinitIfLocMismatches()
                    _ = try? Enka.Sputnik.shared.db4HSR.reinitOnlyIfBundledDBIsNewer()
                    _ = try? Enka.Sputnik.shared.db4GI.reinitOnlyIfBundledDBIsNewer()
                }
            }
    }
}

extension View {
    @ViewBuilder
    func performEnkaDBSanityCheck() -> some View {
        modifier(EnkaDBSanityChecker())
    }
}
