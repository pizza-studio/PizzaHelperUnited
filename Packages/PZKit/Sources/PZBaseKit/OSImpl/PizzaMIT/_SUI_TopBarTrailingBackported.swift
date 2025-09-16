// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Foundation
import SwiftUI

@available(watchOS 10.0, *)
extension ToolbarItemPlacement {
    public static var topBarTrailing4AllOS: ToolbarItemPlacement {
        #if os(macOS) && !targetEnvironment(macCatalyst)
        return .confirmationAction
        #else // iOS
        return .topBarTrailing
        #endif
    }
}
