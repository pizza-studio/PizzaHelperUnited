// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZAccountKit
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - GIOngoingEventAllListView

@available(iOS 17.0, macCatalyst 17.0, *)
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

        var filteredEventContents: [EventModel] {
            // 此处不过滤了，因为在 OfficialFeedSection 的 MainComponent 已经有做过过滤处理。
            // let allGamesToKept: Set<Pizza.SupportedGame>
            // if filterNonRegisteredGamesFromEventFeed, !pzProfiles.isEmpty {
            //     allGamesToKept = .init(pzProfiles.values.map(\.game))
            // } else {
            //     allGamesToKept = .init(Pizza.SupportedGame.allCases)
            // }
            eventContents.filter {
                $0.endAtTime.second ?? 0 >= 0 // && allGamesToKept.contains($0.game)
            }
        }

        var body: some View {
            ScrollView {
                VStack {
                    let contentsToHandle = filteredEventContents
                    if contentsToHandle.isEmpty {
                        Spacer(minLength: 50)
                        Text("igev.gameEvents.noCurrentEventInfo", bundle: .currentSPM)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                            .blurMaterialBackground(
                                enabled: true,
                                shape: RoundedRectangle(cornerRadius: 20),
                                interactive: true
                            )
                    }
                    ForEach(contentsToHandle, id: \.id) { content in
                        NavigationLink(
                            destination: eventDetail(event: content)
                        ) {
                            SingleEventCardView(content: content)
                        }
                        .buttonStyle(.borderless)
                    }
                }
                .id(defaultServer4GI)
                .padding(.horizontal)
            }
            .scrollContentBackground(.hidden)
            .listContainerBackground()
            .navigationTitle(Self.navTitle)
            .navBarTitleDisplayMode(.inline)
            .background(Color(cgColor: viewBackgroundColor.cgColor))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Toggle(isOn: $filterNonRegisteredGamesFromEventFeed) {
                            Text(
                                "igev.gameEvents.toggle.filterNonRegisteredGamesFromEventFeed",
                                bundle: .currentSPM
                            )
                        }
                    } label: {
                        Image(systemSymbol: .filemenuAndSelection)
                    }
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
            #if os(macOS) && !targetEnvironment(macCatalyst)
                .frame(height: 563)
            #endif
        }

        func getIndex(Card: EventModel) -> Int {
            eventContents.firstIndex { currentCard in
                currentCard.id == Card.id
            } ?? 0
        }

        // MARK: Private

        @Default(.defaultServer) private var defaultServer4GI: String
        @Default(.pzProfiles) private var pzProfiles: [String: PZProfileSendable]
        @Default(.filterNonRegisteredGamesFromEventFeed) private var filterNonRegisteredGamesFromEventFeed: Bool

        private let eventContents: [EventModel]
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension OfficialFeed.OfficialFeedAllListView {
    private struct SingleEventCardView: View {
        // MARK: Lifecycle

        public init(content data: EventModel) {
            self.data = data
        }

        // MARK: Public

        public var body: some View {
            let theCardShape = RoundedRectangle(cornerRadius: 20)
            AsyncImage(
                url: data.banner.asURL,
                transaction: Transaction(animation: .default)
            ) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(data.game == .starRail ? 1.07 : 1)
                default:
                    HStack {
                        Text(verbatim: data.title)
                            .fontWeight(.medium)
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                        WinUI3ProgressRing()
                    }
                    .padding()
                    .padding(.bottom, 35)
                    .frame(maxWidth: .infinity, minHeight: 70, alignment: .topLeading)
                    .blurMaterialBackground(
                        enabled: true,
                        shape: RoundedRectangle(cornerRadius: 20),
                        interactive: true
                    )
                }
            }
            .overlay(alignment: .bottom) {
                if cardRatio < 1.7 {
                    Color.black.opacity(0.5).frame(height: canvasSize.height / 2.6)
                        .overlay(alignment: .topLeading) {
                            Text(verbatim: data.title)
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontDesign(.serif)
                                .shadow(radius: 4)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .padding()
                        }
                }
            }
            .overlay(alignment: .bottomLeading) {
                HStack {
                    HStack(spacing: 2) {
                        Image(systemSymbol: .hourglassCircle)
                            .font(.caption)
                        Group {
                            let endAtIntel = data.endAtTime
                            if let dayLeft = endAtIntel.day, dayLeft > 0 {
                                Text(
                                    "igev.gameEvents.daysLeft:\(dayLeft)",
                                    bundle: .currentSPM
                                )
                            } else if let hoursLeft = endAtIntel.hour, hoursLeft > 0 {
                                Text(
                                    "igev.gameEvents.hoursLeft:\(hoursLeft)",
                                    bundle: .currentSPM
                                )
                            }
                        }
                        .padding(.trailing, 2)
                        .font(.caption)
                    }
                    .padding(2)
                    .blurMaterialBackground(
                        enabled: true,
                        shape: .capsule,
                        interactive: true
                    )
                }
                .foregroundColor(.primary)
                .padding()
            }
            .clipShape(theCardShape)
            .contentShape(theCardShape)
            .trackCanvasSize { canvasDimension in
                canvasSize = canvasDimension
            }
        }

        // MARK: Private

        @State private var canvasSize: CGSize = .init(width: 300, height: 100)

        private let data: EventModel

        private var cardRatio: Double {
            Swift.max(canvasSize.width, 1) / Swift.max(canvasSize.height, 1)
        }
    }
}

#endif
