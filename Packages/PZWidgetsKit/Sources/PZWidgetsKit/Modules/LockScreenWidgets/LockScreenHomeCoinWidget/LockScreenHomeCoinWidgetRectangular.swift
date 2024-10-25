// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidgetRectangular

struct LockScreenHomeCoinWidgetRectangular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    @MainActor var body: some View {
        switch widgetRenderingMode {
        case .fullColor:
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    Grid(alignment: .leading) {
                        GridRow {
                            let size: CGFloat = 10
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                let iconSize: CGFloat = size * 4 / 5
                                Text("\(Image("icon.resin"))")
                                    .font(.system(size: iconSize))
                                    .offset(x: -2)
                                Text(
                                    "LockScreenHomeCoinWidgetRectangular.resin"
                                        .i18nWidgets
                                )
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            }
                            .foregroundColor(Color("iconColor.resin"))
                            Spacer()
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                let iconSize: CGFloat = size * 8 / 9
                                Text("\(Image("icon.homeCoin"))")
                                    .font(.system(size: iconSize))
                                Text(
                                    "LockScreenHomeCoinWidgetRectangular.homeCoin"
                                        .i18nWidgets
                                )
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            }
                            .foregroundColor(Color("iconColor.homeCoin"))
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            let size: CGFloat = 23
                            Text("\(data.resinInfo.currentResinDynamic)")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            Spacer()
                            Text("\(data.homeCoinInfo.currentHomeCoinDynamic)")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            Spacer()
                        }
                        .fixedSize()
                        .foregroundColor(.primary)
                        .widgetAccentable()
                        GridRow(alignment: .lastTextBaseline) {
                            if data.resinInfo.currentResinDynamic >= data.resinInfo
                                .maxResin {
                                Text("widget.resin.full")
                            } else {
                                Text(
                                    "\(format(data.resinInfo.resinRecoveryTime))"
                                )
                            }
                            Spacer()
                            if data.homeCoinInfo.currentHomeCoinDynamic >= data
                                .homeCoinInfo.maxHomeCoin {
                                Text("widget.resin.full")
                            } else {
                                Text(
                                    "\(format(data.homeCoinInfo.fullTime))"
                                )
                            }
                            Spacer()
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                default: EmptyView()
                }
            case .failure:
                Grid(alignment: .leading) {
                    GridRow(alignment: .lastTextBaseline) {
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            let size: CGFloat = 20
                            let iconSize: CGFloat = size * 4 / 5
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text("…")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                        }
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 20
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Image("icon.homeCoin"))")
                                .font(.system(size: iconSize))
                            Text("…")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                        }
                    }
                    .fixedSize()
                    .foregroundColor(.primary)
                    .widgetAccentable()
                    GridRow(alignment: .lastTextBaseline) {
                        Text("…")
                        Text("…")
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
        default:
            switch result {
            case let .success(data):
                switch data {
                case let data as any Note4GI:
                    Grid(alignment: .leading) {
                        GridRow {
                            let size: CGFloat = 10
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                let iconSize: CGFloat = size * 4 / 5
                                Text("\(Image("icon.resin"))")
                                    .font(.system(size: iconSize))
                                    .offset(x: -2)
                                Text(
                                    "LockScreenHomeCoinWidgetRectangular.resin"
                                        .i18nWidgets
                                )
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            }
                            Spacer()
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                let iconSize: CGFloat = size * 8 / 9
                                Text("\(Image("icon.homeCoin"))")
                                    .font(.system(size: iconSize))
                                Text(
                                    "LockScreenHomeCoinWidgetRectangular.homeCoin"
                                        .i18nWidgets
                                )
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            }
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            let size: CGFloat = 23
                            Text("\(data.resinInfo.currentResinDynamic)")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            Spacer()
                            Text("\(data.homeCoinInfo.currentHomeCoinDynamic)")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            Spacer()
                        }
                        .fixedSize()
                        .foregroundColor(.primary)
                        .widgetAccentable()
                        GridRow(alignment: .lastTextBaseline) {
                            if data.resinInfo.currentResinDynamic >= data.resinInfo
                                .maxResin {
                                Text("widget.resin.full")
                            } else {
                                Text(
                                    "\(format(data.resinInfo.resinRecoveryTime))"
                                )
                            }
                            Spacer()
                            if data.homeCoinInfo.currentHomeCoinDynamic >= data
                                .homeCoinInfo.maxHomeCoin {
                                Text("widget.resin.full")
                            } else {
                                Text(
                                    "\(format(data.homeCoinInfo.fullTime))"
                                )
                            }
                            Spacer()
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                default: EmptyView()
                }
            case .failure:
                Grid(alignment: .leading) {
                    GridRow {
                        let size: CGFloat = 10
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            let iconSize: CGFloat = size * 4 / 5
                            Text("\(Image("icon.resin"))")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.resin"
                                    .i18nWidgets
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Image("icon.homeCoin"))")
                                .font(.system(size: iconSize))
                            Text(
                                "LockScreenHomeCoinWidgetRectangular.homeCoin"
                                    .i18nWidgets
                            )
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        }
                        Spacer()
                    }
                    GridRow(alignment: .lastTextBaseline) {
                        let size: CGFloat = 23
                        Text("…")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                        Text("…")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                    }
                    .fixedSize()
                    .foregroundColor(.primary)
                    .widgetAccentable()
                    GridRow(alignment: .lastTextBaseline) {
                        Text("…")
                        Spacer()
                        Text("…")
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                }
            }
        }
    }
}

private func format(_ date: Date) -> String {
    let relationIdentifier: Date.RelationIdentifier =
        .getRelationIdentifier(of: date)
    let formatter = DateFormatter.Gregorian()
    var component = Locale.Components(locale: Locale.current)
    component.hourCycle = .zeroToTwentyThree
    formatter.locale = Locale(components: component)
    formatter.dateFormat = "H:mm"
    let datePrefix: String
    switch relationIdentifier {
    case .today:
        datePrefix = "app.today"
    case .tomorrow:
        datePrefix = "app.tomorrow"
    case .other:
        datePrefix = ""
        formatter.dateFormat = "EEE H:mm"
    }
    return datePrefix.i18nWidgets + formatter.string(from: date)
}
