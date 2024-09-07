// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ShowTeamPercentageView

struct ShowTeamPercentageView: View {
    static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    @Environment(\.colorScheme) var colorScheme
    @Environment(AbyssRankViewModel.self) var vmAbyssRank
    let sectionCornerSize = CGSize(width: Font.baseFontSizeSmall, height: Font.baseFontSizeSmall)

    var result: TeamUtilizationDataFetchModelResult? {
        vmAbyssRank.teamUtilizationDataFetchModelResult
    }

    var viewBackgroundColor: UIColor {
        colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var sectionBackgroundColor: UIColor {
        colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
    }

    var body: some View {
        ScrollView(.vertical) {
            HStack {
                Spacer()
                VStack(spacing: 2) {
                    if let data = extractDataPackage() {
                        let teams = extractTeams(from: data)
                        renderHeaderSection(data: data)
                        Spacer().frame(height: Font.baseFontSizeSmall)
                        VStack(spacing: 1) {
                            Section {
                                ForEach(Array(teams.enumerated()), id: \.offset) { index, team in
                                    renderTeamLine(team: team, index: index)
                                }
                            }
                        }.clipShape(RoundedRectangle(cornerSize: sectionCornerSize))
                    }
                    if let errorText = dataExtractionErrorText() {
                        Text(errorText)
                    }
                }
                .frame(maxWidth: 414)
                Spacer()
            }
            if result == nil {
                ProgressView()
            }
        }
        .background(Color(viewBackgroundColor))
    }

    static func getMatchedSFSymbol(raw: String) -> SFSymbol? {
        let matchedSymbol = SFSymbol(rawValue: raw)
        return SFSymbol.allSymbols.contains(matchedSymbol) ? matchedSymbol : nil
    }

    static func percentageViewAssets(value: Double, index: Int) -> (String, SFSymbol?)? {
        guard let perc = percentageFormatter.string(from: value as NSNumber) else { return nil }
        return (perc, Self.getMatchedSFSymbol(raw: "\(index + 1).circle"))
    }

    func extractDataPackage() -> TeamUtilizationData? {
        guard case let .success(dataPkg) = result else { return nil }
        return dataPkg.data
    }

    func dataExtractionErrorText() -> String? {
        guard case let .failure(error) = result else { return nil }
        return error.localizedDescription
    }

    func extractTeams(from data: TeamUtilizationData) -> [TeamUtilizationData.Team] {
        let result: [TeamUtilizationData.Team]
        switch vmAbyssRank.teamUtilizationParams.half {
        case .all: result = data.teams
        case .firstHalf: result = data.teamsFH
        case .secondHalf: result = data.teamsSH
        }
        return result.sorted(by: { $0.percentage > $1.percentage })
    }

    @ViewBuilder
    func renderTeamLine(team: TeamUtilizationData.Team, index: Int) -> some View {
        HStack(spacing: ThisDevice.isSmallestHDScreenPhone ? 2 : nil) {
            ForEach(team.team.sorted(by: <), id: \.self) { avatarId in
                CharacterIconView(
                    charID: avatarId.description,
                    size: 48,
                    circleClipped: false,
                    clipToHead: true
                )
            }
            let rest = 4 - team.team.count
            if rest > 0 {
                ForEach((0 ..< rest).map(\.description), id: \.self) { _ in
                    AnonymousIconView(48, cutType: .roundRectangle)
                }
            }
            Spacer()
            percentageView(value: team.percentage, index: index)
        }
        .padding(.horizontal, Font.baseFontSizeSmall)
        .padding(.vertical, 4)
        .background(
            Color(sectionBackgroundColor)
        )
    }

    @ViewBuilder
    func percentageView(value: Double, index: Int) -> some View {
        if let assets = Self.percentageViewAssets(value: value, index: index) {
            Text(assets.0).font(.system(size: 16, weight: .heavy)).fontWidth(.compressed)
            if let symbol = assets.1 {
                Image(systemSymbol: symbol).font(.system(size: 14, weight: .light))
            }
        }
    }

    @ViewBuilder
    func renderHeaderSection(data: TeamUtilizationData) -> some View {
        Section {
            HStack {
                Text(
                    "abyssRankKit.stat.2:\(data.totalUsers)\(vmAbyssRank.paramsDescription)",
                    bundle: .module
                )
                .font(.footnote)
                .textCase(.none)
                Spacer()
            }
            .padding(Font.baseFontSizeSmall)
            .background(
                Color(sectionBackgroundColor),
                in: RoundedRectangle(cornerSize: sectionCornerSize)
            )
        }
    }
}
