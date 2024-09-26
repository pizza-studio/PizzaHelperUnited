// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import EnkaKit
import SwiftUI

// MARK: - ShowAvatarPercentageViewWithSection

struct ShowAvatarPercentageViewWithSection: View {
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

    var avatarSectionDatas: [[AvatarPercentageModel.Avatar]]? {
        switch vmAbyssRank.showingType {
        case .abyssAvatarsUtilization:
            getDataSection(
                data: vmAbyssRank.utilizationDataFetchModelResult
            )
        case .pvpUtilization:
            getDataSection(
                data: vmAbyssRank.pvpUtilizationDataFetchModelResult
            )
        default:
            getDataSection(
                data: vmAbyssRank.utilizationDataFetchModelResult
            )
        }
    }

    @MainActor var body: some View {
        Form {
            if let result = result, let avatarSectionDatas = avatarSectionDatas {
                switch result {
                case let .success(data):
                    let data = data.data
                    Section {
                        VStack(alignment: .leading) {
                            Text(
                                "abyssRankKit.stat.2:\(data.totalUsers)\(vmAbyssRank.paramsDescription)",
                                bundle: .module
                            )
                            .padding(.bottom, 5)
                            Text("abyssRankKit.rank.usageRate.disclaimer", bundle: .module)
                        }
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                    }
                    ForEach(0 ..< avatarSectionDatas.count, id: \.self) { i in
                        Section {
                            ForEach(avatarSectionDatas[i], id: \.charId) { avatar in
                                renderLine(avatar)
                            }
                        } header: {
                            VStack(alignment: .leading) {
                                if (0 ... 5).contains(i) {
                                    let rawStr = Text("abyssRankKit.rank.usageRate.recommended.t\(i)".i18nAbyssRank)
                                    Text(verbatim: "T\(i) ") + rawStr
                                }
                            }
                            .textCase(.none)
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

    func getDataSection(data: FetchHomeModelResult<AvatarPercentageModel>?)
        -> [[AvatarPercentageModel.Avatar]]? {
        guard let data = data else {
            return nil
        }
        switch data {
        case let .success(dataSuccess):
            let avatarsSrc = dataSuccess.data.avatars
            let avatars = avatarsSrc.sorted(by: {
                ($0.percentage ?? 0) > ($1.percentage ?? 0)
            })

            var sectionIndexes = [Int]()
            var gaps = [Int: Double]()
            guard !avatars.isEmpty else { return nil }
            for i in 0 ..< avatars.count - 1 {
                guard let percentage = avatars[i].percentage,
                      let percentage2 = avatars[i + 1].percentage else {
                    continue
                }
                if percentage > 0.05 {
                    gaps.updateValue(
                        (percentage - percentage2) *
                            (Double(i / avatars.count) * 8 + 1),
                        forKey: i
                    )
                }
            }
            let gapsSorted = gaps.sorted(by: {
                $0.value > $1.value
            })
            for item in gapsSorted {
                if item.value >= 0.07 * (avatars[item.key].percentage ?? 1.0) {
                    sectionIndexes.append(item.key)
                    if sectionIndexes.count > 4 {
                        break
                    }
                }
            }

            var resLists = [[AvatarPercentageModel.Avatar]]()
            var curList = [AvatarPercentageModel.Avatar]()
            for i in 0 ..< avatars.count {
                curList.append(avatars[i])
                if sectionIndexes.contains(i) {
                    resLists.append(curList)
                    curList.removeAll()
                }
            }
            resLists.append(curList)
            return resLists

        case .failure:
            return nil
        }
    }

    // MARK: Private

    @Default(.useRealCharacterNames) private var useRealCharacterNames: Bool
    @Default(.forceCharacterWeaponNameFixed) private var forceCharacterWeaponNameFixed: Bool
}
