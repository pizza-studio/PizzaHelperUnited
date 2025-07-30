// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import SwiftUI

// MARK: - NavBarTitleDisplayMode compilable for AppKit target.

extension View {
    @ViewBuilder
    public func navBarTitleDisplayMode(_ mode: NavBarTitleDisplayMode?) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
        switch mode {
        case .inline: self.navigationBarTitleDisplayMode(.inline)
        case .large: self.navigationBarTitleDisplayMode(.large)
        case nil: self.navigationBarTitleDisplayMode(.automatic)
        }
        #else
        self
        #endif
    }
}

// MARK: - NavBarTitleDisplayMode

/// This one is compatible to macOS on compilation.
public enum NavBarTitleDisplayMode {
    case inline
    case large
}
