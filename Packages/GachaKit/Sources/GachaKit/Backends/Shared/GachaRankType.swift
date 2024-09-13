// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI

// MARK: - GachaItemRankType

public enum GachaItemRankType: Int, Identifiable, Sendable, Hashable, Codable {
    case rank3 = 3
    case rank4 = 4
    case rank5 = 5

    // MARK: Lifecycle

    public init?(rawValueStr: String, game: Pizza.SupportedGame) {
        guard var intRawValue = Int(rawValueStr) else { return nil }
        if game == .zenlessZone { intRawValue += 1 }
        switch intRawValue {
        case 3: self = .rank3
        case 4: self = .rank4
        case 5: self = .rank5
        default: return nil
        }
    }

    // MARK: Public

    public var id: Int { rawValue }

    public func uigfRankType(game: Pizza.SupportedGame) -> String {
        var rawValueInt = rawValue
        if game == .zenlessZone { rawValueInt -= 1 }
        return rawValueInt.description
    }
}

// MARK: - Background Gradients.

extension GachaItemRankType {
    private var gradientColors: [CGColor] {
        switch self {
        case .rank3: [
                CGColor(red: 0.34, green: 0.45, blue: 0.59, alpha: 1.00),
                CGColor(red: 0.33, green: 0.57, blue: 0.72, alpha: 1.00),
            ]
        case .rank4: [
                CGColor(red: 0.37, green: 0.34, blue: 0.54, alpha: 1.00),
                CGColor(red: 0.61, green: 0.46, blue: 0.72, alpha: 1.00),
            ]
        case .rank5: [
                CGColor(red: 0.58, green: 0.36, blue: 0.17, alpha: 1.00),
                CGColor(red: 0.70, green: 0.45, blue: 0.19, alpha: 1.00),
            ]
        }
    }

    public var backgroundGradient: LinearGradient {
        .init(colors: gradientColors.map { Color(cgColor: $0) }, startPoint: .top, endPoint: .bottom)
    }
}
