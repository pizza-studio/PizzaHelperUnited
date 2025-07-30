// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

public enum Pizza {
    public static let isDebug: Bool = {
        #if DEBUG
        true
        #else
        false
        #endif
    }()
}
