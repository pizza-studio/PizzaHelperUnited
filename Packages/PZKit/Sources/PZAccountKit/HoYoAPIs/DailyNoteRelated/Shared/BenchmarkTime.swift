// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - ReferencingBenchmarkTime

public protocol ReferencingBenchmarkTime: BenchmarkTimeEditable {
    var benchmarkTime: Date { get set }
}

// MARK: - BenchmarkTimeEditable

public protocol BenchmarkTimeEditable {
    func replacingBenchmarkTime(_ newBenchmarkTime: Date) -> Self
}

extension ReferencingBenchmarkTime {
    public func replacingBenchmarkTime(_ newBenchmarkTime: Date) -> Self {
        var newEntity = self
        newEntity.benchmarkTime = newBenchmarkTime
        return newEntity
    }
}

// MARK: - BenchmarkTime

@propertyWrapper
public struct BenchmarkTime: Hashable, Sendable {
    // MARK: Lifecycle

    public init() {
        self.projectedValue = nil
    }

    public init(wrappedValue: Date) {
        self.projectedValue = wrappedValue
    }

    // MARK: Public

    public var projectedValue: Date?

    public var wrappedValue: Date {
        get {
            if let projectedValue = projectedValue {
                projectedValue
            } else {
                Date()
            }
        } set {
            projectedValue = newValue
        }
    }
}

// @propertyWrapper
// public struct RecoveryTimeInterval {
//    let fetchedTime: Date
//    var benchmarkTime: Date
//    let recoveryTime: TimeInterval
//
//    public var finishedTime: Date {
//        Date(timeInterval: recoveryTime, since: fetchedTime)
//    }
//
//    public var wrappedValue: TimeInterval {
//        get {
//            let restOfTime = recoveryTime - benchmarkTime.timeIntervalSince(fetchedTime)
//            if restOfTime > 0 {
//                return restOfTime
//            } else {
//                return 0
//            }
//        }
//    }
//
//    init(wrappedValue: TimeInterval, fetchedTime: Date, benchmarkTime: Date) {
//        self.fetchedTime = fetchedTime
//        self.benchmarkTime = benchmarkTime
//        self.recoveryTime = wrappedValue
//    }
// }
