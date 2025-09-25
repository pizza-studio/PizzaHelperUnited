// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - LedgerView4GI

@available(iOS 17.0, macCatalyst 17.0, *)
public struct LedgerView4GI: LedgerView {
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

    public typealias LedgerData = HoYo.LedgerData4GI

    public static let navTitle = "hylKit.ledger4GI.view.navTitle".i18nHYLKit

    public static var primogemImage: Image { Image("gi_misc_primogem", bundle: .module) }

    public let data: LedgerData

    public let dataText: String

    public var body: some View {
        Form {
            Section {
                LabelWithDescription(
                    title: "hylKit.ledger4GI.primogems",
                    memo: "hylKit.ledger4GI.compare",
                    icon: "gi_misc_primogem",
                    mainValue: data.dayData.currentPrimogems,
                    previousValue: data.dayData.lastPrimogems
                )
                LabelWithDescription(
                    title: "hylKit.ledger4GI.mora",
                    memo: "hylKit.ledger4GI.compare",
                    icon: "gi_misc_mora",
                    mainValue: data.dayData.currentMora,
                    previousValue: data.dayData.lastMora
                )
            } header: {
                HStack {
                    Text("hylKit.ledger4GI.todayAcquisition.title", bundle: .module)
                    Spacer()
                    Text(verbatim: "\(data.date ?? "")")
                }
                .headerFooterTextVisibilityEnhanced()
            } footer: {
                Text("hylKit.ledger4GI.tip", bundle: .module)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .headerFooterTextVisibilityEnhanced()
            }
            .listRowMaterialBackground()

            Section {
                let dayCountThisMonth = Calendar.gregorian.dateComponents(
                    [.day],
                    from: Date()
                ).day
                LabelWithDescription(
                    title: "hylKit.ledger4GI.primogems",
                    memo: "hylKit.ledger4GI.compare.month",
                    icon: "gi_misc_primogem",
                    mainValue: data.monthData.currentPrimogems,
                    previousValue: data.monthData.lastPrimogems / (dayCountThisMonth ?? 1)
                )
                LabelWithDescription(
                    title: "hylKit.ledger4GI.mora",
                    memo: "hylKit.ledger4GI.compare.month",
                    icon: "gi_misc_mora",
                    mainValue: data.monthData.currentMora,
                    previousValue: data.monthData.lastMora / (dayCountThisMonth ?? 1)
                )
            } header: {
                Text("hylKit.ledger4GI.billThisMonth:\(data.dataMonth.description)", bundle: .module)
                    .headerFooterTextVisibilityEnhanced()
            } footer: {
                footerChart
            }
            .listRowMaterialBackground()
        }
        .formStyle(.grouped).disableFocusable()
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle(Self.navTitle)
        .toolbar {
            #if DEBUG
            ToolbarItem(placement: .primaryAction) {
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
@available(iOS 17.0, macCatalyst 17.0, *) private let demoData: HoYo.LedgerData4GI = {
    let sampleDataURL = Bundle.module.url(forResource: "ledger_sample_gi", withExtension: "json")!
    let data = try! Data(contentsOf: sampleDataURL)
    let decoded = try! JSONDecoder().decode(HoYo.LedgerData4GI.self, from: data)
    return decoded
}()

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    LedgerView4GI(data: demoData)
}
#endif
