// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

public struct TravelStatsView4GI: View {
    // MARK: Lifecycle

    public init(data: HoYo.TravelStatsData4GI) {
        self.data = data
    }

    // MARK: Public

    public static let navTitle = "hylKit.travelStats4GI.navTitle".i18nHYLKit

    public static var treasureBoxImage: Image { Image("gi_travelStats_treasureBox_gradeHigh", bundle: .module) }

    public let data: HoYo.TravelStatsData4GI

    public var body: some View {
        List {
            Section {
                DataDisplayView(label: "hylKit.travelStats4GI.daysActive", value: "\(data.stats.activeDayNumber)")
                DataDisplayView(label: "hylKit.travelStats4GI.characters", value: "\(data.stats.avatarNumber)")
                DataDisplayView(label: "hylKit.travelStats4GI.abyss", value: data.stats.spiralAbyss)
                DataDisplayView(
                    label: "hylKit.travelStats4GI.achievements",
                    value: "\(data.stats.achievementNumber)"
                )
                DataDisplayView(
                    label: "hylKit.travelStats4GI.waypoints",
                    value: "\(data.stats.wayPointNumber)"
                )
                DataDisplayView(
                    label: "hylKit.travelStats4GI.domains",
                    value: "\(data.stats.domainNumber)"
                )
            }
            .listRowMaterialBackground()

            Section {
                DataDisplayView(label: "hylKit.travelStats4GI.chest.1", value: "\(data.stats.commonChestNumber)")
                DataDisplayView(
                    label: "hylKit.travelStats4GI.chest.3",
                    value: "\(data.stats.preciousChestNumber)"
                )
                DataDisplayView(
                    label: "hylKit.travelStats4GI.chest.2",
                    value: "\(data.stats.exquisiteChestNumber)"
                )
                DataDisplayView(
                    label: "hylKit.travelStats4GI.chest.4",
                    value: "\(data.stats.luxuriousChestNumber)"
                )
            }
            .listRowMaterialBackground()

            Section {
                DataDisplayView(
                    symbol: Image("gi_travelStats_eyeball_Anemoculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.anemo",
                    value: "\(data.stats.anemoculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("gi_travelStats_eyeball_Geoculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.geo",
                    value: "\(data.stats.geoculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("gi_travelStats_eyeball_Electroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.electro",
                    value: "\(data.stats.electroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("gi_travelStats_eyeball_Dendroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.dendro",
                    value: "\(data.stats.dendroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("gi_travelStats_eyeball_Hydroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.hydro",
                    value: "\(data.stats.hydroculusNumber)"
                )
                DataDisplayView(
                    symbol: Image("gi_travelStats_eyeball_Pyroculus", bundle: .module),
                    label: "hylKit.travelStats4GI.eyeball.pyro",
                    value: "\(data.stats.pyroculusNumber)"
                )
                if let cryoculusTotal = data.stats.cryoculusNumber {
                    DataDisplayView(
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

    private struct DataDisplayView: View {
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

        var body: some View {
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

    private struct WorldExplorationView: View {
        struct WorldDataLabel: View {
            @Environment(\.colorScheme) private var colorScheme
            let worldData: HoYo.TravelStatsData4GI.WorldExploration

            var body: some View {
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

        var body: some View {
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
