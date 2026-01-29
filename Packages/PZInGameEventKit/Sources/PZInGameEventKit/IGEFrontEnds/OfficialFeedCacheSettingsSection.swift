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
    public struct CacheSettingsViewContent: View {
        // MARK: Lifecycle

        public init() {}

        // MARK: Public

        public var body: some View {
            mainViewSection
        }

        // MARK: Private

        @Default(.officialFeedMostRecentFetchDate) private var officialFeedMostRecentFetchDate: [String: Date]

        private var feedDateMap: [Pizza.SupportedGame: Date] {
            var result = [Pizza.SupportedGame: Date]()
            officialFeedMostRecentFetchDate.forEach { key, value in
                guard let game = Pizza.SupportedGame(rawValue: key) else { return }
                result[game] = value
            }
            return result
        }

        @ViewBuilder private var mainViewSection: some View {
            Section {
                let latestFeedDateMap = feedDateMap
                if latestFeedDateMap.isEmpty {
                    Text(
                        "settings.display.cacheSettings.officialFeed.noOfficialGameEventsCached",
                        bundle: .currentSPM
                    )
                } else {
                    ForEach(Pizza.SupportedGame.allCases) { currentGame in
                        let lastDate = latestFeedDateMap[currentGame]
                        if let lastDate, lastDate.timeIntervalSince1970 > 10 {
                            LabeledContent {
                                Text(lastDate.ISO8601Format())
                            } label: {
                                ViewThatFits {
                                    Text(verbatim: currentGame.localizedDescription)
                                    Text(verbatim: currentGame.localizedShortName)
                                    Text(verbatim: currentGame.localizedDescriptionTrimmed)
                                }
                            }
                            .contextMenu {
                                getDeleteButton(for: currentGame)
                            }
                        }
                    }
                }
            } header: {
                Text(
                    "settings.display.cacheSettings.officialFeed.sectionTitle",
                    bundle: .currentSPM
                )
            } footer: {
                if !officialFeedMostRecentFetchDate.isEmpty {
                    Text(
                        "settings.display.cacheSettings.officialFeed.sectionFooter",
                        bundle: .currentSPM
                    )
                }
            }
            .animation(.default, value: officialFeedMostRecentFetchDate.hashValue)
        }

        @ViewBuilder
        private func getDeleteButton(for game: Pizza.SupportedGame) -> some View {
            Button {
                OfficialFeedFileHandler.removeFeed(for: game)
                Task { @MainActor in
                    await OfficialFeed.getAllFeedEventsOnline(game: game)
                }
            } label: {
                LabeledContent {
                    Text(
                        "settings.display.cacheSettings.officialFeed.clearCachedEventsOfThisGame.button",
                        bundle: .currentSPM
                    )
                } label: {
                    Image(systemSymbol: .trashSlash)
                }
            }
        }
    }
}

#endif
