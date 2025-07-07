// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZAboutKit
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
extension View {
    @ViewBuilder
    func hookPrivacyPolicyCheckerOnOOBE() -> some View {
        modifier(PrivacyPolicyFirstConfirmationHooker())
    }
}

// MARK: - PrivacyPolicyFirstConfirmationHooker

@available(iOS 17.0, macCatalyst 17.0, *)
private struct PrivacyPolicyFirstConfirmationHooker: ViewModifier {
    // MARK: Internal

    func body(content: Content) -> some View {
        if isPrivacyPolicyConfirmed {
            content
        } else {
            content
                .sheet(isPresented: $isSheetShown) {
                    PrivacyPolicyView(isOOBE: true)
                        .interactiveDismissDisabled()
                }
        }
    }

    // MARK: Private

    @State private var isSheetShown = true

    @Default(.isPrivacyPolicyConfirmed) private var isPrivacyPolicyConfirmed: Bool
}
