// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftUI

// MARK: - TravelStats

public protocol TravelStats: Codable, Hashable, Sendable, DecodableFromMiHoYoAPIJSONResult {
    associatedtype Stats: TravelStatsTable
    associatedtype ViewType: TravelStatsView where Self == ViewType.StatsData
    var stats: Stats { get }
}

extension TravelStats {
    @MainActor @ViewBuilder
    public func asView() -> some View {
        ViewType(data: self)
    }
}

// MARK: - TravelStatsTable

public protocol TravelStatsTable: Codable, Sendable, Equatable, Hashable {}

// MARK: - TravelStatsView

@MainActor
public protocol TravelStatsView: View {
    associatedtype StatsData: TravelStats where Self == StatsData.ViewType
    init(data: StatsData)
    var data: StatsData { get }
    @MainActor @ViewBuilder var body: Self.Body { get }
}

// MARK: - TravelStatLabel

struct TravelStatLabel: View {
    // MARK: Lifecycle

    init(symbol: Image, label: LocalizedStringKey, value: String) {
        self.symbol = symbol
        self.label = label
        self.value = value
    }

    init(label: LocalizedStringKey, value: String) {
        self.symbol = nil
        self.label = label
        self.value = value
    }

    // MARK: Internal

    let symbol: Image?
    let label: LocalizedStringKey
    let value: String

    @MainActor var body: some View {
        if let symbol {
            Label {
                HStack {
                    Text(label, bundle: .module)
                    Spacer()
                    Text(verbatim: value)
                }
            } icon: {
                symbol.resizable().scaledToFit()
                    .frame(height: 30)
            }
        } else {
            HStack {
                Text(label, bundle: .module)
                Spacer()
                Text(verbatim: value)
            }
        }
    }
}
