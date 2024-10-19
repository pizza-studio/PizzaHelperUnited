// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - GIOngoingEventAllListView

struct GIOngoingEventAllListView: View {
    // MARK: Lifecycle

    public init(eventContents: [EventModel]) {
        self.eventContents = eventContents
    }

    // MARK: Internal

    typealias EventModel = GIOngoingEvents.EventList.EventModel

    static var navTitle: String {
        "igev.gi.gameEvents.pendingEvents.title".i18nIGEV
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
                    GIOngoingEvents.getRemainDays($0.endAt)?.second! ?? 0 >= 0
                }).count <= 0 {
                    Spacer(minLength: 50)
                    Text("igev.gi.gameEvents.noCurrentEventInfo", bundle: .module)
                        .padding()
                    Text("igev.gi.gameEvents.intelligenceProvider", bundle: .module)
                        .font(.caption)
                }
                ForEach(eventContents, id: \.id) { content in
                    if GIOngoingEvents.getRemainDays(content.endAt)?.second! ?? 0 >= 0 {
                        NavigationLink(
                            destination: eventDetail(event: content)
                        ) {
                            CardView(content: content)
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listContainerBackground()
        .navigationTitle(Self.navTitle)
        .navBarTitleDisplayMode(.inline)
        .background(Color(cgColor: viewBackgroundColor.cgColor))
    }

    // MARK: CARD VIEW

    @ViewBuilder
    func CardView(content: EventModel) -> some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    Text(verbatim: "\(getLocalizedContent(content.name))")
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .font(.caption)
                }
                AsyncImage(
                    url: getLocalizedContent(content.banner).asURL,
                    transaction: Transaction(animation: .default)
                ) { phase in
                    switch phase {
                    case let .success(image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    default:
                        ProgressView()
                            .onAppear {
                                print("imageData is nil")
                            }
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
                                if GIOngoingEvents.getRemainDays(content.endAt) == nil {
                                    Text(content.endAt)
                                } else if GIOngoingEvents.getRemainDays(content.endAt)!
                                    .day! > 0 {
                                    Text(
                                        "igev.gi.gameEvents.daysLeft:\(GIOngoingEvents.getRemainDays(content.endAt)!.day!)",
                                        bundle: .module
                                    )
                                } else {
                                    Text(
                                        "igev.gi.gameEvents.hoursLeft:\(GIOngoingEvents.getRemainDays(content.endAt)!.hour!)",
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
            banner: getLocalizedContent(event.banner),
            nameFull: getLocalizedContent(event.nameFull),
            content: getLocalizedContent(event.description)
        )
        webview
            .navBarTitleDisplayMode(.inline)
            .navigationTitle(getLocalizedContent(event.name))
    }

    func getIndex(Card: EventModel) -> Int {
        eventContents.firstIndex { currentCard in
            currentCard.id == Card.id
        } ?? 0
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

    // MARK: Private

    private let eventContents: [EventModel]
}

extension View {
    fileprivate func opacityMaterial() -> some View {
        background(.thinMaterial, in: Capsule())
    }
}

#endif
