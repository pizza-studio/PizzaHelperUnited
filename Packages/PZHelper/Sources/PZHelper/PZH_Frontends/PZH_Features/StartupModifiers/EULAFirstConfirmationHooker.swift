// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAboutKit
import PZBaseKit
import SwiftUI

extension View {
    @ViewBuilder
    func hookEULACheckerOnOOBE() -> some View {
        modifier(EULAFirstConfirmationHooker())
    }
}

// MARK: - EULAFirstConfirmationHooker

private struct EULAFirstConfirmationHooker: ViewModifier {
    // MARK: Internal

    func body(content: Content) -> some View {
        if isEULAConfirmed {
            content
        } else {
            content
                .sheet(isPresented: $isSheetShown) {
                    EULAView(isOOBE: true)
                        .interactiveDismissDisabled()
                }
        }
    }

    // MARK: Private

    @State private var isSheetShown = true

    @Default(.isEULAConfirmed) private var isEULAConfirmed: Bool
}
