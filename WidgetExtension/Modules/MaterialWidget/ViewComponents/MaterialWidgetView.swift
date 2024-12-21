// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZInGameEventKit
import SwiftUI

// MARK: - MaterialWidgetView

@available(watchOS, unavailable)
struct MaterialWidgetView: View {
    let entry: MaterialWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                WeekdayDisplayView()
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

// MARK: MaterialWidgetView.EventView

@available(watchOS, unavailable)
extension MaterialWidgetView {
    struct EventView: View {
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
                    VStack(spacing: 7) {
                        ForEach(
                            getEvents(4),
                            id: \.id
                        ) { content in
                            eventItem(event: content)
                        }
                    }
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
            let line = event.textListItemRaw()
            HStack {
                Text(verbatim: " \(line.title)")
                    .lineLimit(1)
                Spacer()
                Text(line.remainingDays)
                    .allowsTightening(true)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .font(.caption)
            .fontWidth(.condensed)
        }

        func getEvents(_ prefix: Int) -> [EventModel] {
            let filtered = events
                .filter { $0.endAtDate.timeIntervalSince1970 >= Date.now.timeIntervalSince1970 }
                .prefix(prefix)
            return .init(filtered)
        }
    }
}
