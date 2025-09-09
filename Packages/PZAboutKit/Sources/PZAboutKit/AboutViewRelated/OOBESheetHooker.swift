// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI

@available(iOS 16.2, macCatalyst 16.2, *)
extension View {
    @ViewBuilder
    public func hookOOBESheet() -> some View {
        modifier(OOBESheetHooker())
    }
}

// MARK: - OOBESheetHooker

@available(iOS 16.2, macCatalyst 16.2, *)
private struct OOBESheetHooker: ViewModifier {
    // MARK: Lifecycle

    public init() {
        self.isSheetVisible = false // 该值会被 react API 覆盖。
    }

    // MARK: Internal

    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isSheetVisible) {
                Group {
                    switch currentStep {
                    case .confirmingEULA:
                        EULAView {
                            isEULAConfirmed = true
                        }
                    case .confirmingPrivacyPolicy:
                        PrivacyPolicyView {
                            isPrivacyPolicyConfirmed = true
                        }
                    case .readingOOBEMessages:
                        OOBEView {
                            isOOBEViewEverPresented = true
                        }
                    case nil:
                        EmptyView()
                    }
                }
                .animation(.default, value: currentStep)
                .interactiveDismissDisabled()
            }
            .react(to: currentStep, initial: true) { _, newValue in
                isSheetVisible = newValue != nil
            }
    }

    // MARK: Private

    private enum OOBEStep: Int {
        case confirmingEULA
        case confirmingPrivacyPolicy
        case readingOOBEMessages
    }

    @State private var isSheetVisible: Bool

    @Default(.isEULAConfirmed) private var isEULAConfirmed: Bool
    @Default(.isPrivacyPolicyConfirmed) private var isPrivacyPolicyConfirmed: Bool
    @Default(.isOOBEViewEverPresented) private var isOOBEViewEverPresented: Bool

    private var currentStep: OOBEStep? {
        guard isEULAConfirmed else { return .confirmingEULA }
        guard isPrivacyPolicyConfirmed else { return .confirmingPrivacyPolicy }
        guard isOOBEViewEverPresented else { return .readingOOBEMessages }
        return nil
    }
}
