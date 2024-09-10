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
        case .fullStarHoldingRate:
            return vmAbyssRank.fullStaAvatarHoldingResult
        case .holdingRate:
            return vmAbyssRank.avatarHoldingResult
        case .abyssAvatarsUtilization:
            return vmAbyssRank.utilizationDataFetchModelResult
        case .pvpUtilization:
            return vmAbyssRank
                .pvpUtilizationDataFetchModelResult
        default:
            return nil
        }
    }

    @MainActor var body: some View {
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
                                return ($0.percentage ?? 0) >
                                    ($1.percentage ?? 0)
                            case .fullStarHoldingRate, .holdingRate:
                                return $0.charId < $1.charId
                            }
                        }), id: \.charId) { avatar in
                            renderLine(avatar)
                        }
                    }
                case let .failure(error):
                    Text("\(error)")
                }
            } else {
                ProgressView()
            }
        }
    }

    @MainActor @ViewBuilder
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
                Color.gray.clipShape(.circle).frame(width: 32, height: 32)
            }
            Spacer()
            Text(percentageFormatter.string(from: (avatar.percentage ?? 0.0) as NSNumber)!)
        }
    }

    // MARK: Private

    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
}
