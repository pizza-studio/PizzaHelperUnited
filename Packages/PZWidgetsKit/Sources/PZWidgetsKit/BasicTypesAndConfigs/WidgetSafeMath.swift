// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - WidgetSafeMath

enum WidgetSafeMath {
    @inlinable
    static func normalizedRatio(numerator: Double, denominator: Double) -> Double {
        guard denominator.isFinite, denominator != 0, numerator.isFinite else { return 0 }
        let quotient = numerator / denominator
        guard quotient.isFinite else { return 0 }
        return clamp(quotient, to: 0 ... 1)
    }

    @inlinable
    static func normalizedRatio(numerator: Int, denominator: Int) -> Double {
        normalizedRatio(numerator: Double(numerator), denominator: Double(denominator))
    }

    @inlinable
    static func sanitizedGaugeInputs(
        current: Double,
        maxValue: Double,
        minValue: Double = 0
    )
        -> (value: Double, range: ClosedRange<Double>) {
        let safeMin = minValue.isFinite ? minValue : 0
        var safeMax = maxValue.isFinite ? maxValue : safeMin
        if safeMax <= safeMin {
            safeMax = safeMin + 1
        }
        let range = safeMin ... safeMax
        let rawValue = current.isFinite ? current : safeMin
        let safeValue = clamp(rawValue, to: range)
        return (safeValue, range)
    }

    @inlinable
    static func nonNegativeInterval(_ interval: TimeInterval) -> TimeInterval {
        guard interval.isFinite else { return 0 }
        return max(0, interval)
    }

    @inlinable
    static func clamp<T: Comparable>(_ value: T, to limits: ClosedRange<T>) -> T {
        min(max(value, limits.lowerBound), limits.upperBound)
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension PZWidgetsSPM {
    static func formattedInterval(until targetDate: Date, fallback: String = "—") -> String {
        formattedInterval(for: TimeInterval.sinceNow(to: targetDate), fallback: fallback)
    }

    static func formattedInterval(for interval: TimeInterval, fallback: String = "—") -> String {
        let sanitized = WidgetSafeMath.nonNegativeInterval(interval)
        return intervalFormatter.string(from: sanitized) ?? fallback
    }
}
