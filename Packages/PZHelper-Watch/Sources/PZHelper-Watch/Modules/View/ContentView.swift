// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - ContentView

public struct ContentView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        NavigationStack {
            if accounts.isEmpty {
                List {
                    Section {
                        LabeledContent {
                            Text("watch.sync.tips", bundle: .module)
                        } label: {
                            VStack {
                                Image(systemSymbol: .icloudAndArrowDown).fixedSize()
                                ProgressView()
                            }
                            .fixedSize()
                        }
                    }
                }
            } else {
                List {
                    ASUpdateNoticeView()
                        .font(.footnote)
                    ForEach(accounts, id: \.uuid) { account in
                        DetailNavigator(account: account)
                    }
                    NavigationLink {
                        WatchWidgetSettingView()
                    } label: {
                        Text("watch.settings.navTitle", bundle: .module)
                    }
                }
                .listStyle(.carousel)
                .refreshable {
                    broadcaster.refreshPage()
                }
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            switch newPhase {
            case .inactive:
                if #available(watchOSApplicationExtension 9.0, *) {
                    WidgetCenter.shared.reloadAllTimelines()
                    WidgetCenter.shared.invalidateConfigurationRecommendations()
                }
            default:
                break
            }
        }
        .alert(item: $connectivityManager.notificationMessage) { message in
            Alert(
                title: Text(message.text),
                dismissButton: .default(Text(verbatim: "sys.done".i18nBaseKit))
            )
        }
        .onChange(of: accounts) {
            Task { @MainActor in
                await PZProfileActor.shared.syncAllDataToUserDefaults()
            }
        }
    }

    // MARK: Internal

    @Query(sort: \PZProfileMO.priority) var accounts: [PZProfileMO]

    @Environment(\.scenePhase) var scenePhase

    @Environment(\.modelContext) var modelContext

    // MARK: Private

    @StateObject private var connectivityManager = AppleWatchSputnik.shared
    @StateObject private var broadcaster = Broadcaster.shared
}

// MARK: - DetailNavigator

private struct DetailNavigator: View {
    // MARK: Lifecycle

    init(account: PZProfileMO) {
        self._dailyNoteViewModel = .init(wrappedValue: DailyNoteViewModel(profile: account))
    }

    // MARK: Internal

    @Environment(\.scenePhase) var scenePhase

    var account: PZProfileMO { dailyNoteViewModel.profile }

    var body: some View {
        Group {
            switch dailyNoteViewModel.dailyNoteStatus {
            case let .succeed(dailyNote, _):
                NavigationLink {
                    WatchAccountDetailView(data: dailyNote, profile: account.asSendable)
                } label: {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(account.name).font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemSymbol: .chevronRight)
                                .foregroundStyle(.secondary)
                                .frame(width: 12, height: 12)
                        }
                        HStack(spacing: 2) {
                            dailyNoteViewModel.profile.game.primaryStaminaAssetIcon
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                            Text(verbatim: "\(dailyNote.staminaIntel.finished)").bold()
                            Spacer()
                            Text(account.uidWithGame).font(.footnote)
                                .minimumScaleFactor(0.5)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            case let .failure(error):
                Button {
                    dailyNoteViewModel.getDailyNoteUncheck()
                } label: {
                    Label {
                        Text(error.localizedDescription)
                    } icon: {
                        Image(systemSymbol: .exclamationmarkCircle)
                            .foregroundColor(.red)
                    }
                }
            case .progress:
                ProgressView()
            }
        }
        .onChange(of: broadcaster.eventForRefreshingCurrentPage) { _, _ in
            dailyNoteViewModel.getDailyNoteUncheck()
        }
        .onAppear {
            dailyNoteViewModel.getDailyNote()
        }
        .onAppBecomeActive {
            Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
        }
    }

    // MARK: Private

    @StateObject private var dailyNoteViewModel: DailyNoteViewModel
    @StateObject private var broadcaster = Broadcaster.shared
}
