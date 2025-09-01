// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - OfficialFeed.OfficialFeedSection

@available(iOS 17.0, macCatalyst 17.0, *)
extension OfficialFeed {
    @available(watchOS, unavailable)
    public struct OfficialFeedSection<TT: View, HH: View>: View {
        // MARK: Lifecycle

        public init(
            game: Binding<Pizza.SupportedGame?>,
            @ViewBuilder peripheralViews: @escaping (() -> TT) = { EmptyView() },
            @ViewBuilder sectionHeader: @escaping (() -> HH) = { EmptyView() }
        ) {
            self.peripheralViews = peripheralViews
            self.sectionHeader = sectionHeader
            self._game = game
        }

        // MARK: Public

        public var body: some View {
            MainComponent(
                supportedGames: supportedGames.animation(),
                eventContents: eventContentsFiltered.animation(),
                isFeedSheetShown: $isFeedSheetShown,
                peripheralViews: peripheralViews,
                sectionHeader: sectionHeader
            )
            .listRowMaterialBackground()
            .react(to: scenePhase) { _, newPhase in
                switch newPhase {
                case .active:
                    getCurrentEvent()
                default:
                    break
                }
            }
            .react(to: broadcaster.eventForRefreshingCurrentPage) { _, _ in
                getCurrentEvent()
            }
            .onAppear {
                if theVM.eventContents.isEmpty {
                    getCurrentEvent()
                }
            }
            // #if DEBUG
            // Text(verbatim: Set(eventContents.map(\.game.localizedDescription)).joined())
            // #endif
        }

        // MARK: Internal

        typealias EventModel = OfficialFeed.FeedEvent

        func getCurrentEvent() {
            theVM.updateEvent()
        }

        // MARK: Private

        @Environment(\.scenePhase) private var scenePhase
        @Binding private var game: Pizza.SupportedGame?
        @StateObject private var broadcaster = Broadcaster.shared
        @State private var theVM: OfficialFeedVM = .init()
        @State private var isFeedSheetShown: Bool = false

        private let peripheralViews: () -> TT
        private let sectionHeader: () -> HH

        private var supportedGames: Binding<Set<Pizza.SupportedGame>> {
            .init(get: {
                if let game {
                    return [game]
                } else {
                    return Set<Pizza.SupportedGame>(Pizza.SupportedGame.allCases)
                }
            }, set: { _ in })
        }

        private var eventContentsFiltered: Binding<[EventModel]> {
            .init(get: {
                theVM.eventContents.filter { supportedGames.wrappedValue.contains($0.game) }
            }, set: { _ in })
        }
    }
}

// MARK: - OfficialFeed.OfficialFeedSection.MainComponent

@available(iOS 17.0, macCatalyst 17.0, *)
extension OfficialFeed.OfficialFeedSection {
    private struct MainComponent<T: View, H: View>: View {
        // MARK: Public

        public var body: some View {
            Section {
                peripheralViews()
                if !$eventContents.animation().wrappedValue.isEmpty {
                    Button {
                        isFeedSheetShown.toggle()
                    } label: {
                        VStack(alignment: .leading) {
                            LabeledContent {
                                Image(systemSymbol: .newspaper)
                            } label: {
                                Text("igev.gameEvents.pendingEvents.title", bundle: .module)
                            }
                            VStack(spacing: 7) {
                                let eventContentsValid = validEventContents.prefix(3)
                                if eventContentsValid.isEmpty {
                                    HStack {
                                        Spacer()
                                        Text("igev.gameEvents.noCurrentEventInfo", bundle: .module)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                } else {
                                    ForEach(eventContentsValid, id: \.id) { content in
                                        content.textListItemRenderable()
                                    }
                                }
                            }
                            .padding(.top, 2)
                            .id(defaultServer4GI)
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                    .listRowMaterialBackground()
                    .sheet(isPresented: $isFeedSheetShown) {
                        NavigationStack {
                            OfficialFeed.OfficialFeedAllListView(eventContents: eventContents)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction) {
                                        Button("sys.close".i18nBaseKit) {
                                            isFeedSheetShown.toggle()
                                        }
                                    }
                                }
                        }
                    }
                } else {
                    ProgressView()
                }
            } header: {
                sectionHeader()
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

        // MARK: Private

        @Environment(\.colorScheme) private var colorScheme
        @Default(.defaultServer) private var defaultServer4GI: String
        @Binding public var supportedGames: Set<Pizza.SupportedGame>
        @Binding public var eventContents: [EventModel]
        @Binding public var isFeedSheetShown: Bool
        public let peripheralViews: () -> T
        public let sectionHeader: () -> H

        private var viewBackgroundColor: UIColor {
            colorScheme == .light ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }

        private var sectionBackgroundColor: UIColor {
            colorScheme == .dark ? UIColor.secondarySystemBackground : UIColor.systemBackground
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
@Observable
private final class OfficialFeedVM: TaskManagedVM {
    public static let shared = OfficialFeedVM()

    public var eventContents: [OfficialFeed.FeedEvent] = []

    public func updateEvent() {
        fireTask(
            givenTask: {
                await OfficialFeed.getAllFeedEventsOnline()
            },
            completionHandler: { eventCluster in
                self.eventContents = (eventCluster ?? []).sorted {
                    $0.endAtDate.timeIntervalSince1970 < $1.endAtDate.timeIntervalSince1970
                        && $0.id < $1.id
                }
            }
        )
    }
}

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *)
private struct TestOfficialFeedSectionView: View {
    @State var game: Pizza.SupportedGame?

    var body: some View {
        NavigationStack {
            Form {
                OfficialFeed.OfficialFeedSection(game: $game)
            }.formStyle(.grouped).disableFocusable()
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    TestOfficialFeedSectionView()
}
#endif
#endif
