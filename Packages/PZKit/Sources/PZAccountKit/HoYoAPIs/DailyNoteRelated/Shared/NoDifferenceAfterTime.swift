// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - CalculatableWithDifferentTime

protocol CalculatableWithDifferentTime {
    func after(_ timeInterval: TimeInterval) -> Self
}

// MARK: - NoDifferenceAfterTime

protocol NoDifferenceAfterTime: CalculatableWithDifferentTime {}

extension NoDifferenceAfterTime {
    func after(_ timeInterval: TimeInterval) -> Self { self }
}
