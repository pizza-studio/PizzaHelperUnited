// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - OfficialFeed.OfficialFeedSection

extension OfficialFeed {
    public struct OfficialFeedSection<TT: View>: View {
        // MARK: Lifecycle

        public init(peripheralViews: @escaping (() -> TT) = { EmptyView() }) {
            self.peripheralViews = peripheralViews
        }

        // MARK: Public

        public var body: some View {
            MainComponent(eventContents: $eventContents, peripheralViews: peripheralViews)
                .listRowMaterialBackground()
                .onChange(of: scenePhase) { _, newPhase in
                    switch newPhase {
                    case .active:
                        getCurrentEvent()
                    default:
                        break
                    }
                }
                .onAppear {
                    if eventContents.isEmpty {
                        getCurrentEvent()
                    }
                }
            Text(verbatim: Set(eventContents.map(\.game.localizedDescription)).joined())
        }

        // MARK: Internal

        typealias EventModel = OfficialFeed.FeedEvent

        func getCurrentEvent() {
            Task {
                let events = await OfficialFeed.getAllFeedEventsOnline()
                if !events.isEmpty {
                    withAnimation {
                        eventContents = events // Already sorted.
                    }
                }
            }
        }

        // MARK: Private

        @Environment(\.scenePhase) private var scenePhase

        @State private var eventContents: [EventModel] = []

        private let peripheralViews: () -> TT
    }
}

// MARK: - OfficialFeed.OfficialFeedSection.MainComponent

extension OfficialFeed.OfficialFeedSection {
    private struct MainComponent<T: View>: View {
        // MARK: Public

        public var body: some View {
            Section {
                peripheralViews()
                if !$eventContents.animation().wrappedValue.isEmpty {
                    VStack {
                        NavigationLink {
                            OfficialFeedAllListView(eventContents: eventContents)
                        } label: {
                            Text("igev.gi.gameEvents.pendingEvents.title", bundle: .module)
                        }
                        VStack(spacing: 7) {
                            let eventContentsValid = validEventContents.prefix(3)
                            if eventContentsValid.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("igev.gi.gameEvents.noCurrentEventInfo", bundle: .module)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            } else {
                                ForEach(eventContentsValid, id: \.id) { content in
                                    eventItem(event: content)
                                }
                            }
                        }
                        .padding(.top, 2)
                        .id(defaultServer4GI)
                    }
                } else {
                    ProgressView()
                }
            }
        }

        // MARK: Internal

        typealias EventModel = OfficialFeed.FeedEvent

        typealias IntervalDate = Date.IntervalDate

        var validEventContents: [EventModel] {
            eventContents.filter {
                ($0.endAtTime.day ?? 0) >= 0
                    && ($0.endAtTime.hour ?? 0) >= 0
                    && ($0.endAtTime.minute ?? 0) >= 0
            }
        }

        @ViewBuilder
        func eventItem(event: EventModel) -> some View {
            HStack {
                Text(verbatim: " \(event.title)")
                    .lineLimit(1)
                Spacer()
                let endAtIntel = event.endAtTime
                if let dayLeft = endAtIntel.day, dayLeft > 0 {
                    Text(
                        "igev.gi.gameEvents.daysLeft:\(dayLeft)",
                        bundle: .module
                    )
                } else if let hoursLeft = endAtIntel.hour, hoursLeft > 0 {
                    Text(
                        "igev.gi.gameEvents.hoursLeft:\(hoursLeft)",
                        bundle: .module
                    )
                }
            }
            .font(.caption)
            .foregroundColor(.primary)
        }

        // MARK: Private

        @Environment(\.colorScheme) private var colorScheme
        @Default(.defaultServer) private var defaultServer4GI: String
        @Binding public var eventContents: [EventModel]
        public let peripheralViews: () -> T

        private var viewBackgroundColor: UIColor {
            colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }

        private var sectionBackgroundColor: UIColor {
            colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        Form {
            OfficialFeed.OfficialFeedSection()
        }.formStyle(.grouped)
    }
}
#endif
#endif
