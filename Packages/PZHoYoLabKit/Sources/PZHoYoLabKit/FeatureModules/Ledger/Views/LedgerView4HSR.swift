// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - LedgerView4HSR

@available(iOS 17.0, macCatalyst 17.0, *)
public struct LedgerView4HSR: LedgerView {
    // MARK: Lifecycle

    public init(data: LedgerData) {
        self.data = data
        do {
            let encoded = try JSONEncoder().encode(data)
            let string = String(data: encoded, encoding: .utf8) ?? ""
            self.dataText = string
        } catch {
            self.dataText = ""
        }
    }

    // MARK: Public

    public typealias LedgerData = HoYo.LedgerData4HSR

    public static let navTitle = "hylKit.ledger4HSR.view.navTitle".i18nHYLKit

    public static var stellarJadeImage: Image { Image("hsr_misc_stellarJade", bundle: .module) }

    public let data: LedgerData

    public let dataText: String

    public var body: some View {
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
                let dayCountThisMonth = Calendar.gregorian.dateComponents(
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
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Clipboard.currentString = dataText
                } label: {
                    Image(systemSymbol: .clipboardFill)
                }
            }
            #endif
        }
    }

    // MARK: Internal

    @ViewBuilder internal var footerChart: some View {
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
            .frame(width: 280, height: 600)
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

        var body: some View {
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

#if DEBUG
@available(iOS 17.0, macCatalyst 17.0, *) private let demoData: HoYo.LedgerData4HSR = {
    let sampleDataURL = Bundle.module.url(forResource: "ledger_sample_hsr", withExtension: "json")!
    let data = try! Data(contentsOf: sampleDataURL)
    let decoded = try! JSONDecoder().decode(HoYo.LedgerData4HSR.self, from: data)
    return decoded
}()

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    LedgerView4HSR(data: demoData)
}
#endif
