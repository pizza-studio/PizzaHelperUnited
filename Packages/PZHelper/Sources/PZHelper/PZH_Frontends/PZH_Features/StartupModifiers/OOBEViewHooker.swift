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
    func hookOOBEView() -> some View {
        modifier(OOBEViewHooker())
    }
}

// MARK: - OOBEViewHooker

@available(iOS 16.2, macCatalyst 16.2, *)
private struct OOBEViewHooker: ViewModifier {
    // MARK: Internal

    func body(content: Content) -> some View {
        if isOOBEViewEverPresented {
            content
        } else {
            content
                .sheet(isPresented: $isSheetShown) {
                    OOBEView(isVisible: $isSheetShown)
                        .interactiveDismissDisabled()
                }
                .react(to: isSheetShown) { _, newValue in
                    guard !isOOBEViewEverPresented else { return }
                    if !newValue {
                        isOOBEViewEverPresented = true
                    }
                }
        }
    }

    // MARK: Private

    @State private var isSheetShown = true

    @Default(.isOOBEViewEverPresented) private var isOOBEViewEverPresented: Bool
}
