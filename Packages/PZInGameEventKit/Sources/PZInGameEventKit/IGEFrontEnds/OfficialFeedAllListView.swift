// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import Defaults
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - GIOngoingEventAllListView

extension OfficialFeed {
    struct OfficialFeedAllListView: View {
        // MARK: Lifecycle

        public init(eventContents: [EventModel]) {
            self.eventContents = eventContents
        }

        // MARK: Internal

        typealias EventModel = OfficialFeed.FeedEvent

        static var navTitle: String {
            "igev.gameEvents.pendingEvents.title".i18nIGEV
        }

        @Environment(\.colorScheme) var colorScheme

        @State var expandCards: Bool = false
        @State var currentCard: EventModel?
        @State var showDetailTransaction: Bool = false
        @Namespace var animation

        var viewBackgroundColor: UIColor {
            colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }

        var sectionBackgroundColor: UIColor {
            colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }

        var body: some View {
            ScrollView {
                VStack {
                    if eventContents.filter({
                        $0.endAtTime.second ?? 0 >= 0
                    }).count <= 0 {
                        Spacer(minLength: 50)
                        Text("igev.gameEvents.noCurrentEventInfo", bundle: .module)
                            .padding()
                    }
                    ForEach(eventContents, id: \.id) { content in
                        if content.endAtTime.second ?? 0 >= 0 {
                            NavigationLink(
                                destination: eventDetail(event: content)
                            ) {
                                cardView(content: content)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                .id(defaultServer4GI)
            }
            .scrollContentBackground(.hidden)
            .listContainerBackground()
            .navigationTitle(Self.navTitle)
            .navBarTitleDisplayMode(.inline)
            .background(Color(cgColor: viewBackgroundColor.cgColor))
        }

        // MARK: CARD VIEW

        @ViewBuilder
        func cardView(content: EventModel) -> some View {
            VStack {
                ZStack {
                    HStack {
                        Spacer()
                        Text(verbatim: content.title)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .font(.caption)
                    }
                    AsyncImage(
                        url: content.banner.asURL,
                        transaction: Transaction(animation: .default)
                    ) { phase in
                        switch phase {
                        case let .success(image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .scaleEffect(content.game == .starRail ? 1.07 : 1)
                        default:
                            ProgressView()
                        }
                    }
                    .scaledToFill()
                    .cornerRadius(20)
                    .padding(.horizontal)
                    VStack {
                        Spacer()
                        HStack {
                            HStack(spacing: 2) {
                                Image(systemSymbol: .hourglassCircle)
                                    .font(.caption)
                                Group {
                                    let endAtIntel = content.endAtTime
                                    if let dayLeft = endAtIntel.day, dayLeft > 0 {
                                        Text(
                                            "igev.gameEvents.daysLeft:\(dayLeft)",
                                            bundle: .module
                                        )
                                    } else if let hoursLeft = endAtIntel.hour, hoursLeft > 0 {
                                        Text(
                                            "igev.gameEvents.hoursLeft:\(hoursLeft)",
                                            bundle: .module
                                        )
                                    }
                                }
                                .padding(.trailing, 2)
                                .font(.caption)
                            }
                            .padding(2)
                            .opacityMaterial()
                            Spacer()
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
        }

        @ViewBuilder
        func eventDetail(event: EventModel) -> some View {
            let webview = EventDetailWebView(
                banner: event.banner,
                nameFull: event.title,
                content: event.description
            )
            webview
                .navBarTitleDisplayMode(.inline)
                .navigationTitle(event.title)
        }

        func getIndex(Card: EventModel) -> Int {
            eventContents.firstIndex { currentCard in
                currentCard.id == Card.id
            } ?? 0
        }

        // MARK: Private

        @Default(.defaultServer) private var defaultServer4GI: String

        private let eventContents: [EventModel]
    }
}

extension View {
    @ViewBuilder
    fileprivate func opacityMaterial() -> some View {
        background(.thinMaterial, in: Capsule())
    }
}

#endif
