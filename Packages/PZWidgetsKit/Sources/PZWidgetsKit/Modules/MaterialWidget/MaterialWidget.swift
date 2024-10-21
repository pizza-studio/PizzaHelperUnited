// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
import SwiftUI
import WidgetKit

// MARK: - MaterialWidget

struct MaterialWidget: Widget {
    var body: some WidgetConfiguration {
        if #available(iOS 17.0, *) {
            return configuration
                .containerBackgroundRemovable(false)
        } else {
            return configuration
        }
    }

    var configuration: some WidgetConfiguration {
        StaticConfiguration(
            kind: "MaterialWidget",
            provider: MaterialWidgetProvider()
        ) { entry in
            MaterialWidgetView(entry: entry)
        }
        .configurationDisplayName("widget.material.title")
        .description("widget.material.description")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - MaterialWidgetView

struct MaterialWidgetView: View {
    let entry: MaterialWidgetEntry

    var weaponMaterials: [WeaponOrTalentMaterial] { entry.weaponMaterials }
    var talentMaterials: [WeaponOrTalentMaterial] { entry.talentMateirals }

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
            VStack(alignment: .leading, spacing: 1) {
                Text(weekday)
                    .font(.caption)
                    .foregroundColor(Color("textColor.calendarWeekday"))
                    .bold()
                    .shadow(radius: 2)
                HStack(spacing: 6) {
                    Text(dayOfMonth)
                        .font(.system(
                            size: 35,
                            weight: .regular,
                            design: .rounded
                        ))
                        .shadow(radius: 5)
                    Spacer()
                    if entry.materialWeekday != .sunday {
                        MaterialRow(
                            materials: weaponMaterials +
                                talentMaterials
                        )
                    } else {
                        Image("派蒙挺胸").resizable().scaledToFit()
                            .clipShape(Circle())
                    }
                }
                .frame(height: 35)
            }
            .frame(height: 40)
            .padding(.top)
            .padding(.bottom, 12)
            if let events = entry.events, !events.isEmpty {
                EventView(events: events)
            }
            Spacer()
        }
        .foregroundColor(Color("textColor3"))
        .myWidgetContainerBackground(withPadding: 0) {
            WidgetBackgroundView(
                background: .randomNamecardBackground,
                darkModeOn: true
            )
        }
    }
}

// MARK: - EventView

private struct EventView: View {
    let events: [EventModel]

    var body: some View {
        HStack(spacing: 4) {
            Rectangle()
                .frame(width: 2, height: 77.5)
                .offset(x: 1)
            VStack(spacing: 7) {
                ForEach(
                    events
                        .filter { getRemainTimeInterval($0.endAt) > 0 }
                        .shuffled()
                        .prefix(4)
                        .sorted(by: {
                            getRemainTimeInterval($0.endAt) <
                                getRemainTimeInterval($1.endAt)
                        }),
                    id: \.id
                ) { content in
                    eventItem(event: content)
                }
            }
        }
        .shadow(radius: 3)
    }

    @ViewBuilder
    func eventItem(event: EventModel) -> some View {
        HStack {
            Text(" \(getLocalizedContent(event.name))")
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

    func getRemainTimeInterval(_ endAt: String) -> TimeInterval {
        let dateFormatter = DateFormatter.Gregorian()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = (Server(rawValue: Defaults[.defaultServer]) ?? Server.asia).timeZone()
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

// MARK: - MaterialRow

private struct MaterialRow: View {
    let materials: [WeaponOrTalentMaterial]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(materials, id: \.imageString) { material in
                Image(material.imageString)
                    .resizable()
                    .scaledToFit()
            }
        }
        .shadow(radius: 1)
    }
}

// MARK: - MaterialWidgetEntry

struct MaterialWidgetEntry: TimelineEntry {
    // MARK: Lifecycle

    init(events: [EventModel]?) {
        self.date = Date()
        self.materialWeekday = .today()
        self.talentMateirals = TalentMaterialProvider(weekday: materialWeekday)
            .todaysMaterials
        self.weaponMaterials = WeaponMaterialProvider(weekday: materialWeekday)
            .todaysMaterials
        self.events = events
    }

    // MARK: Internal

    let date: Date
    let materialWeekday: MaterialWeekday
    let talentMateirals: [WeaponOrTalentMaterial]
    let weaponMaterials: [WeaponOrTalentMaterial]
    let events: [EventModel]?
}

// MARK: - MaterialWidgetProvider

struct MaterialWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> MaterialWidgetEntry {
        .init(events: nil)
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (MaterialWidgetEntry) -> Void
    ) {
        API.OpenAPIs.fetchCurrentEvents { result in
            switch result {
            case let .success(data):
                completion(.init(events: .init(data.event.values)))
            case .failure:
                completion(.init(events: nil))
            }
        }
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<MaterialWidgetEntry>) -> Void
    ) {
        API.OpenAPIs.fetchCurrentEvents { result in
            switch result {
            case let .success(data):
                completion(.init(
                    entries: [.init(events: .init(data.event.values))],
                    policy: .after(
                        Calendar.current
                            .date(byAdding: .hour, value: 4, to: Date())!
                    )
                ))
            case .failure:
                completion(
                    .init(
                        entries: [.init(events: nil)],
                        policy: .after(
                            Calendar.current
                                .date(byAdding: .hour, value: 1, to: Date())!
                        )
                    )
                )
            }
        }
    }
}

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

private struct ContainerBackgroundModifier<V: View>: ViewModifier {
    let padding: CGFloat
    let background: () -> V

    func body(content: Content) -> some View {
        if #available(iOS 17, *) {
            content.containerBackground(for: .widget) {
                background()
            }
        } else {
            content
                .padding(.horizontal)
                .background {
                    background()
                }
        }
    }
}
