// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAboutKit
import PZBaseKit
import SwiftUI

@available(iOS 16.2, macCatalyst 16.2, *)
extension View {
    @ViewBuilder
    func hookEULACheckerOnOOBE() -> some View {
        modifier(EULAFirstConfirmationHooker())
    }
}

// MARK: - EULAFirstConfirmationHooker

@available(iOS 16.2, macCatalyst 16.2, *)
private struct EULAFirstConfirmationHooker: ViewModifier {
    // MARK: Internal

    func body(content: Content) -> some View {
        if isEULAConfirmed {
            content
        } else {
            content
                .sheet(isPresented: $isSheetShown) {
                    EULAView(isVisible: $isSheetShown)
                        .interactiveDismissDisabled()
                }
                .react(to: isSheetShown) { _, newValue in
                    guard !isEULAConfirmed else { return }
                    if !newValue {
                        isEULAConfirmed = true
                    }
                }
        }
    }

    // MARK: Private

    @State private var isSheetShown = true

    @Default(.isEULAConfirmed) private var isEULAConfirmed: Bool
}
