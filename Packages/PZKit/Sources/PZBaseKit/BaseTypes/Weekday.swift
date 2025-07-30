// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// MARK: - Weekday

public enum Weekday: Int, CaseIterable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7

    // MARK: Public
}

// MARK: CustomStringConvertible

@available(iOS 15.0, macCatalyst 15.0, *)
extension Weekday: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sunday: String(localized: "sys.weekday.sunday", bundle: .module)
        case .monday: String(localized: "sys.weekday.monday", bundle: .module)
        case .tuesday: String(localized: "sys.weekday.tuesday", bundle: .module)
        case .wednesday: String(localized: "sys.weekday.wednesday", bundle: .module)
        case .thursday: String(localized: "sys.weekday.thursday", bundle: .module)
        case .friday: String(localized: "sys.weekday.friday", bundle: .module)
        case .saturday: String(localized: "sys.weekday.saturday", bundle: .module)
        }
    }
}
