// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - AlternativeWatchCornerResinWidget

struct AlternativeWatchCornerResinWidget: Widget {
    let kind: String = "AlternativeWatchCornerResinWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: SelectOnlyAccountIntent.self,
            provider: LockScreenWidgetProvider(recommendationsTag: "watch.info.resin")
        ) { entry in
            AlternativeWatchCornerResinWidgetView(entry: entry)
        }
        .configurationDisplayName("树脂")
        .description("widget.intro.resin")
        #if os(watchOS)
            .supportedFamilies([.accessoryCorner])
        #endif
    }
}

// MARK: - AlternativeWatchCornerResinWidgetView

struct AlternativeWatchCornerResinWidgetView: View {
    @Environment(\.widgetFamily) var family: WidgetFamily
    let entry: LockScreenWidgetProvider.Entry

    var result: Result<any Note4GI, any Error> { entry.result }
    var accountName: String? { entry.accountName }

    var body: some View {
        switch result {
        case let .success(data):
            resinView(resinInfo: data.resinInfo)
        case .failure:
            failureView()
        }
    }

    @ViewBuilder
    func resinView(resinInfo: ResinInformation) -> some View {
        Image("icon.resin")
            .resizable()
            .scaledToFit()
            .padding(4)
            .widgetLabel {
                Gauge(
                    value: Double(resinInfo.calculatedCurrentResin(referTo: entry.date)),
                    in: 0 ... Double(resinInfo.maxResin)
                ) {
                    Text("app.dailynote.card.resin.label")
                } currentValueLabel: {
                    Text("\(resinInfo.calculatedCurrentResin(referTo: entry.date))")
                } minimumValueLabel: {
                    Text("\(resinInfo.calculatedCurrentResin(referTo: entry.date))")
                } maximumValueLabel: {
                    Text("")
                }
            }
    }

    @ViewBuilder
    func failureView() -> some View {
        Image("icon.resin")
            .resizable()
            .scaledToFit()
            .padding(6)
            .widgetLabel {
                Gauge(value: 0, in: 0 ... Double(ResinInfo.defaultMaxResin)) {
                    Text(verbatim: "0")
                }
            }
    }
}
