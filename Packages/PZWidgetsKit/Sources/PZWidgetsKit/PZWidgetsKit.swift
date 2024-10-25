// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - PZWidgets

public enum PZWidgets {}

extension PZWidgets {
    static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.doesRelativeDateFormatting = true
        fmt.dateStyle = .short
        fmt.timeStyle = .short
        return fmt
    }()

    static let intervalFormatter: DateComponentsFormatter = {
        let dateComponentFormatter = DateComponentsFormatter()
        dateComponentFormatter.allowedUnits = [.hour, .minute]
        dateComponentFormatter.maximumUnitCount = 2
        dateComponentFormatter.unitsStyle = .brief
        return dateComponentFormatter
    }()
}
