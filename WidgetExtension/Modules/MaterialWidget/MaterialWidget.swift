// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import GITodayMaterialsKit
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import SwiftUI
import WidgetKit

// MARK: - MaterialWidget

@available(watchOS, unavailable)
struct MaterialWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MaterialWidget",
            provider: MaterialWidgetProvider()
        ) { entry in
            MaterialWidgetView(entry: entry)
        }
        .configurationDisplayName("pzWidgetsKit.material.title".i18nWidgets)
        .description("pzWidgetsKit.material.description".i18nWidgets)
        .supportedFamilies([.systemMedium])
        .containerBackgroundRemovable(false)
    }
}

// MARK: - MaterialWidgetView

@available(watchOS, unavailable)
struct MaterialWidgetView: View {
    let entry: MaterialWidgetEntry

    var weekday: String {
        let formatter = DateFormatter.Gregorian()
        formatter.dateFormat = "EEE"
        return formatter.string(from: Date())
    }

    var dayOfMonth: String {
        let formatter = DateFormatter.Gregorian()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(weekday)
                        .font(.caption)
                        .foregroundColor(Color("textColor.calendarWeekday", bundle: .main))
                        .bold()
                    Text(dayOfMonth)
                        .font(.system(
                            size: 35,
                            weight: .regular,
                            design: .rounded
                        ))
                }
                .legibilityShadow()
                Spacer()
                ZStack(alignment: .trailing) {
                    if entry.materialWeekday != nil {
                        MaterialView(alternativeLayout: true)
                    } else {
                        Image(systemSymbol: .checkmarkCircleFill)
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .legibilityShadow(isText: false)
                    }
                }
                .frame(height: 35)
            }
            .frame(height: 40)
            .padding(.bottom, 12)
            if let events = entry.events, !events.isEmpty {
                EventView(events: events)
                    .legibilityShadow(isText: true)
            }
        }
        .foregroundColor(Color("textColor3", bundle: .main))
        .myWidgetContainerBackground(withPadding: 0) {
            WidgetBackgroundView(
                background: .randomNamecardBackground4Game(.genshinImpact),
                darkModeOn: true
            )
        }
    }
}

// MARK: - EventView

@available(watchOS, unavailable)
private struct EventView: View {
    let events: [EventModel]

    var body: some View {
        HStack(spacing: 4) {
            if events.isEmpty {
                Button(intent: WidgetRefreshIntent()) {
                    Image(systemSymbol: .arrowClockwiseCircle)
                        .font(.title3)
                        .foregroundColor(Color("textColor3", bundle: .main))
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
            }
            ViewThatFits(in: .vertical) {
                VStack(spacing: 5) {
                    ForEach(
                        getEvents(4),
                        id: \.id
                    ) { content in
                        eventItem(event: content)
                    }
                }
                VStack(spacing: 7) {
                    ForEach(
                        getEvents(4),
                        id: \.id
                    ) { content in
                        eventItem(event: content)
                    }
                }
                VStack(spacing: 7) {
                    ForEach(
                        getEvents(3),
                        id: \.id
                    ) { content in
                        eventItem(event: content)
                    }
                }
            }
            .padding(.leading, 7)
            .overlay(alignment: .leading) {
                Rectangle()
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .offset(x: 1)
            }
        }
    }

    @ViewBuilder
    func eventItem(event: EventModel) -> some View {
        HStack {
            Text(verbatim: " \(getLocalizedContent(event.name))")
                .lineLimit(1)
            Spacer()
            Text(timeIntervalFormattedString(getRemainTimeInterval(
                event
                    .endAt
            )))
            .allowsTightening(true)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
        }
        .font(.caption)
    }

    func getEvents(_ prefix: Int) -> [EventModel] {
        events
            .filter { getRemainTimeInterval($0.endAt) > 0 }
            .shuffled()
            .prefix(prefix)
            .sorted(by: {
                getRemainTimeInterval($0.endAt) <
                    getRemainTimeInterval($1.endAt)
            })
    }

    func getRemainTimeInterval(_ endAt: String) -> TimeInterval {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = (HoYo.Server(rawValue: Defaults[.defaultServer]) ?? .asia(.genshinImpact)).timeZone
        let endDate = dateFormatter.date(from: endAt)!
        return endDate.timeIntervalSinceReferenceDate - Date()
            .timeIntervalSinceReferenceDate
    }

    func timeIntervalFormattedString(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .short
        formatter.maximumUnitCount = 1
        return formatter.string(
            from: Date(),
            to: Date(timeIntervalSinceNow: timeInterval)
        )!
    }

    func getLocalizedContent(
        _ content: EventModel
            .MultiLanguageContents
    )
        -> String {
        let locale = Bundle.main.preferredLocalizations.first
        switch locale {
        case "zh-Hans":
            return content.CHS
        case "zh-Hant", "zh-HK":
            return content.CHT
        case "en":
            return content.EN
        case "ja":
            return content.JP
        case "ru":
            return content.RU
        default:
            return content.EN
        }
    }
}

@available(watchOS, unavailable)
extension View {
    fileprivate func myWidgetContainerBackground<V: View>(
        withPadding padding: CGFloat,
        @ViewBuilder _ content: @escaping () -> V
    )
        -> some View {
        modifier(ContainerBackgroundModifier(padding: padding, background: content))
    }
}

// MARK: - ContainerBackgroundModifier

@available(watchOS, unavailable)
private struct ContainerBackgroundModifier<V: View>: ViewModifier {
    let padding: CGFloat
    let background: () -> V

    func body(content: Content) -> some View {
        content.containerBackground(for: .widget) {
            background()
        }
    }
}
