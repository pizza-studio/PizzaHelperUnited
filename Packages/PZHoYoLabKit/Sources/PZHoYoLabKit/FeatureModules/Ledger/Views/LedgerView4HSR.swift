// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - LedgerView

public struct LedgerView4HSR: LedgerView {
    // MARK: Lifecycle

    public init(data: LedgerData) {
        self.data = data
    }

    // MARK: Public

    public typealias LedgerData = HoYo.LedgerData4HSR

    public static let navTitle = "hylKit.ledger4HSR.view.navTitle".i18nHYLKit

    public static var stellarJadeImage: Image { Image("hsr_misc_stellarJade", bundle: .module) }

    public let data: LedgerData

    @MainActor public var body: some View {
        List {
            Section {
                LabelWithDescription(
                    title: "hylKit.ledger4HSR.stellarJade",
                    memo: "hylKit.ledger4HSR.compare",
                    icon: "hsr_misc_stellarJade",
                    mainValue: data.dayData.currentStellarJades,
                    previousValue: data.dayData.prevStellarJade
                )
                LabelWithDescription(
                    title: "hylKit.ledger4HSR.srPass",
                    memo: "hylKit.ledger4HSR.compare",
                    icon: "hsr_misc_srPass",
                    mainValue: data.dayData.currentPasses,
                    previousValue: data.dayData.prevPasses
                )
            } header: {
                HStack {
                    Text("hylKit.ledger4HSR.todayAcquisition.title", bundle: .module)
                    Spacer()
                    Text(verbatim: "\(data.date ?? "")")
                }
                .secondaryColorVerseBackground()
            } footer: {
                Text("hylKit.ledger4HSR.tip", bundle: .module)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .secondaryColorVerseBackground()
            }
            .listRowMaterialBackground()

            Section {
                let dayCountThisMonth = Calendar.current.dateComponents(
                    [.day],
                    from: Date()
                ).day
                LabelWithDescription(
                    title: "hylKit.ledger4HSR.stellarJade",
                    memo: "hylKit.ledger4HSR.compare.month",
                    icon: "hsr_misc_stellarJade",
                    mainValue: data.monthData.currentStellarJades,
                    previousValue: data.monthData.prevStellarJade / (dayCountThisMonth ?? 1)
                )
                LabelWithDescription(
                    title: "hylKit.ledger4HSR.srPass",
                    memo: "hylKit.ledger4HSR.compare.month",
                    icon: "hsr_misc_srPass",
                    mainValue: data.monthData.currentPasses,
                    previousValue: data.monthData.prevPasses / (dayCountThisMonth ?? 1)
                )
            } header: {
                Text("hylKit.ledger4HSR.billThisMonth:\(data.dataMonth.description)", bundle: .module)
                    .secondaryColorVerseBackground()
            } footer: {
                footerChart
            }
            .listRowMaterialBackground()
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle(Self.navTitle)
    }

    // MARK: Internal

    @MainActor @ViewBuilder internal var footerChart: some View {
        HStack(alignment: .center) {
            Spacer()
            PieChartView(
                values: data.monthData.groupBy.map(\.num),
                names: data.monthData.groupBy.map(\.actionTyped.localized),
                formatter: { value in String(format: "%.0f", value) },
                colors: [
                    .blue,
                    .green,
                    .orange,
                    .yellow,
                    .purple,
                    .gray,
                    .brown,
                    .cyan,
                ],
                backgroundColor: .clear,
                widthFraction: 1,
                innerRadiusFraction: 0.6
            )
            .frame(minWidth: 280, maxWidth: 280, minHeight: 600, maxHeight: 600)
            .padding(.vertical)
            .padding(.top)
            Spacer()
        }
    }

    // MARK: Private

    private struct LabelWithDescription: View {
        @Environment(\.colorScheme) var colorScheme

        let title: LocalizedStringKey
        let memo: LocalizedStringKey
        let icon: String
        let mainValue: Int
        let previousValue: Int?

        var valueDelta: Int { mainValue - (previousValue ?? 0) }

        var brightnessDelta: Double {
            colorScheme == .dark ? 0 : -0.35
        }

        @MainActor var body: some View {
            Label {
                VStack(alignment: .leading) {
                    HStack {
                        Text(title, bundle: .module)
                        Spacer()
                        Text(mainValue.description)
                    }
                    if previousValue != nil {
                        HStack {
                            Text(memo, bundle: .module).foregroundColor(.secondary)
                            Spacer()
                            switch valueDelta {
                            case 1...: Text(verbatim: "+\(valueDelta)")
                                .foregroundStyle(.green).brightness(brightnessDelta)
                            default: Text(verbatim: "\(valueDelta)")
                                .foregroundStyle(.red).brightness(brightnessDelta)
                            }
                        }.font(.footnote).opacity(0.8)
                    }
                }
            } icon: {
                Image(icon, bundle: .module)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
