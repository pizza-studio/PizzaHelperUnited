// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

public struct TravelStatsView4HSR: TravelStatsView {
    // MARK: Lifecycle

    public init(data: StatsData) {
        self.data = data
    }

    // MARK: Public

    public typealias StatsData = HoYo.TravelStatsData4HSR

    public static let navTitle = "hylKit.travelStats4HSR.navTitle".i18nHYLKit

    public static var treasureBoxImage: Image { Image("hsr_travelStats_treasureBox_gradeHigh", bundle: .module) }

    public let data: StatsData

    @MainActor public var body: some View {
        List {
            Section {
                TravelStatLabel(
                    label: "hylKit.travelStats4HSR.daysActive",
                    value: "\(data.stats.activeDays)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4HSR.characters",
                    value: "\(data.stats.avatarNum)"
                )
                if !data.stats.abyssProcess.isEmpty {
                    TravelStatLabel(
                        label: "hylKit.travelStats4HSR.abyss",
                        value: data.stats.abyssProcess
                    )
                }
                TravelStatLabel(
                    label: "hylKit.travelStats4HSR.achievements",
                    value: "\(data.stats.achievementNum)"
                )
            }
            .listRowMaterialBackground()

            Section {
                TravelStatLabel(
                    label: "hylKit.travelStats4HSR.chest",
                    value: "\(data.stats.chestNum)"
                )
            }
            .listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle(Self.navTitle)
    }
}
