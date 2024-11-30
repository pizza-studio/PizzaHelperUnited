// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaKit
import SwiftUI

// MARK: - ShowAvatarPercentageView

struct ShowAvatarPercentageView: View {
    // MARK: Internal

    @Environment(AbyssRankViewModel.self) var vmAbyssRank

    let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    var result: FetchHomeModelResult<AvatarPercentageModel>? {
        switch vmAbyssRank.showingType {
        case .fullStarHoldingRate: vmAbyssRank.fullStarAvatarHoldingResult
        case .holdingRate: vmAbyssRank.avatarHoldingResult
        case .abyssAvatarsUtilization: vmAbyssRank.utilizationDataFetchModelResult
        case .pvpUtilization: vmAbyssRank.pvpUtilizationDataFetchModelResult
        default: nil
        }
    }

    var body: some View {
        Form {
            if let result = result {
                switch result {
                case let .success(data):
                    let data = data.data
                    Section {
                        Text(
                            "abyssRankKit.stat.2:\(data.totalUsers)\(vmAbyssRank.paramsDescription)",
                            bundle: .module
                        )
                        .font(.footnote)
                        .textCase(.none)
                    }
                    Section {
                        ForEach(data.avatars.sorted(by: {
                            switch vmAbyssRank.showingType {
                            case .abyssAvatarsUtilization, .pvpUtilization,
                                 .teamUtilization:
                                ($0.percentage ?? 0) > ($1.percentage ?? 0)
                            case .fullStarHoldingRate, .holdingRate:
                                $0.charId < $1.charId
                            }
                        }), id: \.charId) { avatar in
                            renderLine(avatar)
                        }
                    }
                case let .failure(error):
                    Text(verbatim: "\(error)")
                }
            } else {
                ProgressView()
            }
        }
    }

    @ViewBuilder
    func renderLine(_ avatar: AvatarPercentageModel.Avatar) -> some View {
        HStack {
            if let avatarIdentified = Enka.AvatarSummarized.CharacterID(id: avatar.charId.description) {
                let name = useRealCharacterNames
                    ? avatarIdentified.nameObj.description
                    : avatarIdentified.nameObj.officialDescription
                Label {
                    Text(name).font(.headline).fontWidth(.condensed)
                } icon: {
                    CharacterIconView(
                        charID: avatar.charId.description,
                        size: 32,
                        circleClipped: true,
                        clipToHead: true
                    )
                }
            } else {
                Label {
                    Text(avatar.charId.description)
                        .font(.headline)
                        .fontWidth(.condensed)
                } icon: {
                    AnonymousIconView(32, cutType: .circleClipped)
                }
            }
            Spacer()
            Text(percentageFormatter.string(from: (avatar.percentage ?? 0.0) as NSNumber)!)
        }
    }

    // MARK: Private

    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
}
