// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

public struct TravelStatsView4GI: TravelStatsView {
    // MARK: Lifecycle

    public init(data: StatsData) {
        self.data = data
    }

    // MARK: Public

    public typealias StatsData = HoYo.TravelStatsData4GI

    public static let navTitle = "hylKit.travelStats4GI.navTitle".i18nHYLKit

    public static var treasureBoxImage: Image { Image("gi_travelStats_treasureBox_gradeHigh", bundle: .module) }

    public let data: StatsData

    @MainActor public var body: some View {
        List {
            Section {
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.daysActive",
                    value: "\(data.stats.activeDayNumber)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.characters",
                    value: "\(data.stats.avatarNumber)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.abyss",
                    value: data.stats.spiralAbyss
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.achievements",
                    value: "\(data.stats.achievementNumber)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.waypoints",
                    value: "\(data.stats.wayPointNumber)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.domains",
                    value: "\(data.stats.domainNumber)"
                )
            }
            .listRowMaterialBackground()

            Section {
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.chest.1",
                    value: "\(data.stats.commonChestNumber)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.chest.3",
                    value: "\(data.stats.preciousChestNumber)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.chest.2",
                    value: "\(data.stats.exquisiteChestNumber)"
                )
                TravelStatLabel(
                    label: "hylKit.travelStats4GI.chest.4",
                    value: "\(data.stats.luxuriousChestNumber)"
                )
            }
            .listRowMaterialBackground()

            Section {
                TravelStatLabel(
                    symbol: Image("gi_travelStats_eyeball_Anemoculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.anemo",
                    value: "\(data.stats.anemoculusNumber)"
                )
                TravelStatLabel(
                    symbol: Image("gi_travelStats_eyeball_Geoculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.geo",
                    value: "\(data.stats.geoculusNumber)"
                )
                TravelStatLabel(
                    symbol: Image("gi_travelStats_eyeball_Electroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.electro",
                    value: "\(data.stats.electroculusNumber)"
                )
                TravelStatLabel(
                    symbol: Image("gi_travelStats_eyeball_Dendroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.dendro",
                    value: "\(data.stats.dendroculusNumber)"
                )
                TravelStatLabel(
                    symbol: Image("gi_travelStats_eyeball_Hydroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.hydro",
                    value: "\(data.stats.hydroculusNumber)"
                )
                TravelStatLabel(
                    symbol: Image("gi_travelStats_eyeball_Pyroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.pyro",
                    value: "\(data.stats.pyroculusNumber)"
                )
                if let cryoculusTotal = data.stats.cryoculusNumber {
                    TravelStatLabel(
                        symbol: Image("gi_travelStats_eyeball_Cryoculus", bundle: .module),
                        label: "hylKit.travelStats4GI.eyeball.cryo",
                        value: "\(cryoculusTotal)"
                    )
                }
            }
            .listRowMaterialBackground()

            Section {
                ForEach(data.worldExplorations.sortedDataWithDeduplication, id: \.id) { worldData in
                    WorldExplorationView(worldData: worldData)
                }
            }
            .listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle(Self.navTitle)
    }

    // MARK: Private

    private struct WorldExplorationView: View {
        struct WorldDataLabel: View {
            @Environment(\.colorScheme) private var colorScheme
            let worldData: HoYo.TravelStatsData4GI.WorldExploration

            @MainActor var body: some View {
                Label {
                    Text(verbatim: worldData.name)
                    Spacer()
                    let explorationRate = Double(worldData.explorationPercentage) / Double(1000)
                    Text(Self.calculatePercentage(value: explorationRate))
                } icon: {
                    if let url = URL(string: worldData.icon) {
                        AsyncImage(url: url, content: { image in
                            let basicResponse = image
                                .resizable().scaledToFit().frame(height: 30)
                            if colorScheme == .light {
                                basicResponse.colorInvert()
                            } else {
                                basicResponse
                            }
                        }) {
                            if let imageAssetName = worldData.fallbackLocalAssetName {
                                let basicResponse = Image(imageAssetName, bundle: .module)
                                    .resizable().scaledToFit().frame(height: 30)
                                if colorScheme == .light {
                                    basicResponse.colorInvert()
                                } else {
                                    basicResponse
                                }
                            } else {
                                ProgressView()
                            }
                        }
                    }
                }
            }

            static func calculatePercentage(value: Double) -> String {
                let formatter = NumberFormatter()
                formatter.numberStyle = .percent
                return formatter.string(from: value as NSNumber) ?? "Error"
            }
        }

        let worldData: HoYo.TravelStatsData4GI.WorldExploration

        @MainActor var body: some View {
            if !worldData.offerings.isEmpty {
                DisclosureGroup {
                    ForEach(worldData.offerings, id: \.name) { offering in
                        Label {
                            Text(verbatim: offering.name)
                            Spacer()
                            Text(verbatim: "Lv. \(offering.level)")
                        } icon: {
                            if let url = URL(string: offering.icon) {
                                AsyncImage(url: url, content: { image in
                                    image.resizable().scaledToFit().frame(height: 30)
                                }) {
                                    ProgressView()
                                }
                            }
                        }
                    }
                } label: {
                    WorldDataLabel(worldData: worldData)
                }
            } else {
                WorldDataLabel(worldData: worldData)
            }
        }
    }
}
