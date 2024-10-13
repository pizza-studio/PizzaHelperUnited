// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
#if canImport(WatchKit)
import WatchKit
#endif

#if os(macOS) || os(iOS) || targetEnvironment(macCatalyst)
public enum Clipboard {
    public static var currentString: String {
        get {
            #if canImport(UIKit) || targetEnvironment(macCatalyst)
            return UIPasteboard.general.string ?? ""
            #endif
            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            return NSPasteboard.general.string(forType: .string) ?? ""
            #endif
        }
        set {
            #if canImport(UIKit) || targetEnvironment(macCatalyst)
            UIPasteboard.general.string = newValue
            #endif
            #if canImport(AppKit) && !targetEnvironment(macCatalyst)
            NSPasteboard.general.setString(newValue, forType: .string)
            #endif
        }
    }
}
#endif
