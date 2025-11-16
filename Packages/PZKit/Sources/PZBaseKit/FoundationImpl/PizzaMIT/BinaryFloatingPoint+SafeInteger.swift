// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

// MARK: - BinaryFloatingPoint + Safe Integer Conversion

extension BinaryFloatingPoint {
    /// Converts the floating-point value to an `Int` only when it is finite and located within the representable `Int` range.
    /// Returns `nil` instead of trapping when the conversion is unsafe.
    @inlinable
    public func asIntIfFinite() -> Int? {
        guard isFinite else { return nil }
        let maximum = Self(Int.max)
        let minimum = Self(Int.min)
        guard self <= maximum, self >= minimum else { return nil }
        return Int(self)
    }
}
