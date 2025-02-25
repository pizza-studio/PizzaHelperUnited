// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - LockScreenHomeCoinWidgetRectangular

@available(macOS, unavailable)
struct LockScreenHomeCoinWidgetRectangular: View {
    let entry: any TimelineEntry
    @Environment(\.widgetRenderingMode) var widgetRenderingMode

    let result: Result<any DailyNoteProtocol, any Error>

    var body: some View {
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
                                Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                    .font(.system(size: iconSize))
                                    .offset(x: -2)
                                Text("pzWidgetsKit.stamina", bundle: .main)
                                    .font(.system(
                                        size: size,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                            }
                            .foregroundColor(Color("iconColor.resin", bundle: .main))
                            Spacer()
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                let iconSize: CGFloat = size * 8 / 9
                                Text("\(Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetSVG)")
                                    .font(.system(size: iconSize))
                                Text("pzWidgetsKit.homeCoin", bundle: .main)
                                    .font(.system(
                                        size: size,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                            }
                            .foregroundColor(Color("iconColor.homeCoin", bundle: .main))
                            Spacer()
                        }
                        GridRow(alignment: .lastTextBaseline) {
                            let size: CGFloat = 23
                            Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            Spacer()
                            Text(verbatim: "\(data.homeCoinInfo.currentHomeCoin)")
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
                                Text("pzWidgetsKit.stamina.full", bundle: .main)
                            } else {
                                Text(verbatim: "\(format(data.resinInfo.resinRecoveryTime))")
                            }
                            Spacer()
                            if data.homeCoinInfo.currentHomeCoin >= data
                                .homeCoinInfo.maxHomeCoin {
                                Text("pzWidgetsKit.stamina.full", bundle: .main)
                            } else {
                                Text(verbatim: "\(format(data.homeCoinInfo.fullTime))")
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
                            Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text(verbatim: "…")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                        }
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let size: CGFloat = 20
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetSVG)")
                                .font(.system(size: iconSize))
                            Text(verbatim: "…")
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
                        Text(verbatim: "…")
                        Text(verbatim: "…")
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
                                Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                    .font(.system(size: iconSize))
                                    .offset(x: -2)
                                Text("pzWidgetsKit.stamina", bundle: .main)
                                    .font(.system(
                                        size: size,
                                        weight: .medium,
                                        design: .rounded
                                    ))
                            }
                            Spacer()
                            HStack(alignment: .lastTextBaseline, spacing: 2) {
                                let iconSize: CGFloat = size * 8 / 9
                                Text("\(Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetSVG)")
                                    .font(.system(size: iconSize))
                                Text("pzWidgetsKit.homeCoin", bundle: .main)
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
                            Text(verbatim: "\(data.resinInfo.currentResinDynamic)")
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                            Spacer()
                            Text(verbatim: "\(data.homeCoinInfo.currentHomeCoin)")
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
                                Text("pzWidgetsKit.stamina.full", bundle: .main)
                            } else {
                                Text(verbatim: "\(format(data.resinInfo.resinRecoveryTime))")
                            }
                            Spacer()
                            if data.homeCoinInfo.currentHomeCoin >= data
                                .homeCoinInfo.maxHomeCoin {
                                Text("pzWidgetsKit.stamina.full", bundle: .main)
                            } else {
                                Text(verbatim: "\(format(data.homeCoinInfo.fullTime))")
                            }
                            Spacer()
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                default:
                    let staminaIntel = data.staminaIntel
                    Grid(alignment: .leading) {
                        GridRow {
                            let size: CGFloat = 10
                            HStack(alignment: .lastTextBaseline, spacing: 0) {
                                let iconSize: CGFloat = size * 4 / 5
                                Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                    .font(.system(size: iconSize))
                                    .offset(x: -2)
                                Text("pzWidgetsKit.stamina", bundle: .main)
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
                            Text(verbatim: "\(staminaIntel.finished)")
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
                            if staminaIntel.isAccomplished {
                                Text("pzWidgetsKit.stamina.full", bundle: .main)
                            } else {
                                Text(verbatim: "\(format(data.staminaFullTimeOnFinish))")
                            }
                            Spacer()
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }
            case .failure:
                Grid(alignment: .leading) {
                    GridRow {
                        let size: CGFloat = 10
                        HStack(alignment: .lastTextBaseline, spacing: 0) {
                            let iconSize: CGFloat = size * 4 / 5
                            Text("\(Pizza.SupportedGame(dailyNoteResult: result).primaryStaminaAssetSVG)")
                                .font(.system(size: iconSize))
                                .offset(x: -2)
                            Text("pzWidgetsKit.stamina", bundle: .main)
                                .font(.system(
                                    size: size,
                                    weight: .medium,
                                    design: .rounded
                                ))
                        }
                        Spacer()
                        HStack(alignment: .lastTextBaseline, spacing: 2) {
                            let iconSize: CGFloat = size * 8 / 9
                            Text("\(Pizza.SupportedGame.genshinImpact.giRealmCurrencyAssetSVG)")
                                .font(.system(size: iconSize))
                            Text("pzWidgetsKit.homeCoin", bundle: .main)
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
                        Text(verbatim: "…")
                            .font(.system(
                                size: size,
                                weight: .medium,
                                design: .rounded
                            ))
                        Spacer()
                        Text(verbatim: "…")
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
                        Text(verbatim: "…")
                        Spacer()
                        Text(verbatim: "…")
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
    let formatter = DateFormatter.CurrentLocale()
    var component = Locale.Components(locale: Locale.current)
    component.hourCycle = .zeroToTwentyThree
    formatter.locale = Locale(components: component)
    formatter.dateFormat = "H:mm"
    let datePrefix: String
    switch relationIdentifier {
    case .today:
        datePrefix = "date.relative.today".i18nBaseKit
    case .tomorrow:
        datePrefix = "date.relative.tomorrow".i18nBaseKit
    case .other:
        datePrefix = ""
        formatter.dateFormat = "E H:mm"
    }
    return datePrefix + formatter.string(from: date)
}
