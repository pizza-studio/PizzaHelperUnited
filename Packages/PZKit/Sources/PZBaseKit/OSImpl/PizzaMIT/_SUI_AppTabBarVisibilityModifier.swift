// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

#if !os(watchOS)
import Foundation
import Observation
import SwiftUI

@available(iOS 15.0, macCatalyst 15.0, *)
extension View {
    @ViewBuilder
    public func appTabBarVisibility(_ visibility: SwiftUI.Visibility) -> some View {
        #if targetEnvironment(macCatalyst)
        if #available(macCatalyst 16.0, *) {
            toolbar(visibility, for: .tabBar)
        } else {
            self
        }
        #elseif os(iOS)
        if #available(iOS 16.0, *) {
            toolbar(visibility, for: .tabBar)
        } else {
            self
        }
        #elseif os(macOS)
        self
        #else
        self
        #endif
    }
}

#endif
