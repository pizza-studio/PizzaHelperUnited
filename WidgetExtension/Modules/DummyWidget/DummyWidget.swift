// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI
import WidgetKit

// MARK: - DummyWidget

@available(iOS, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macCatalyst, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macOS, introduced: 11.0, deprecated: 14.0, message: "DISABLED")
@available(watchOS, introduced: 7.0, deprecated: 10.0, message: "DISABLED")
struct DummyWidget: Widget {
    // MARK: Internal

    static var familiesSupported: [WidgetFamily] {
        guard !systemRequirementsAreMet else { return [] }
        var result = [WidgetFamily]()
        #if os(iOS) || targetEnvironment(macCatalyst) || os(macOS)
        result.append(.systemMedium)
        #endif
        return result
    }

    let kind: String = "PizzaHelperDummyWidget4iOS14"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DummyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("dummyWidget.title")
        .description(
            "dummyWidget.description"
        )
        .supportedFamilies(Self.familiesSupported)
    }

    // MARK: Private

    private static var systemRequirementsAreMet: Bool {
        if #unavailable(iOS 17.0, macCatalyst 17.0, watchOS 10.0) {
            return false
        }
        return true
    }
}

// MARK: - Provider

@available(iOS, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macCatalyst, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macOS, introduced: 11.0, deprecated: 14.0, message: "DISABLED")
@available(watchOS, introduced: 7.0, deprecated: 10.0, message: "DISABLED")
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), resin: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), resin: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        let entry = SimpleEntry(date: Date(), resin: 100) // Example data
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

// MARK: - SimpleEntry

@available(iOS, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macCatalyst, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macOS, introduced: 11.0, deprecated: 14.0, message: "DISABLED")
@available(watchOS, introduced: 7.0, deprecated: 10.0, message: "DISABLED")
struct SimpleEntry: TimelineEntry {
    let date: Date
    let resin: Int
}

// MARK: - DummyWidgetEntryView

@available(iOS, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macCatalyst, introduced: 14.0, deprecated: 17.0, message: "DISABLED")
@available(macOS, introduced: 11.0, deprecated: 14.0, message: "DISABLED")
@available(watchOS, introduced: 7.0, deprecated: 10.0, message: "DISABLED")
struct DummyWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("dummyWidget.description")
                .font(.headline)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()
