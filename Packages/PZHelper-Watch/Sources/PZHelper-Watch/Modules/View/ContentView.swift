// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI
import WidgetKit

// MARK: - ContentView

public struct ContentView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        NavigationStack {
            if profiles.isEmpty {
                List {
                    Section {
                        LabeledContent {
                            Text("watch.sync.tips", bundle: .currentSPM)
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
                    ForEach(profiles, id: \.uuid) { profile in
                        if let dailyNoteVM = multiNoteVM.vmMap[profile.uuid.uuidString] {
                            DetailNavigator()
                                .environmentObject(dailyNoteVM)
                        }
                    }
                    Section {
                        NavigationLink {
                            WatchWidgetSettingView()
                        } label: {
                            Text("watch.settings.navTitle", bundle: .currentSPM)
                        }
                    } footer: {
                        if let versionIntel = try? Bundle.getAppVersionAndBuild() {
                            let versionStr = "\(versionIntel.version) Build \(versionIntel.build)"
                            Text(verbatim: versionStr)
                                .textCase(.none)
                                .lineLimit(1)
                                .fixedSize()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .listStyle(.carousel)
                .refreshable {
                    broadcaster.refreshPage()
                }
            }
        }
        .react(to: scenePhase) { _, newPhase in
            switch newPhase {
            case .inactive:
                WidgetCenter.shared.reloadAllTimelines()
                WidgetCenter.shared.invalidateConfigurationRecommendations()
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
        .react(to: profiles) {
            Task { @MainActor in
                await ProfileManagerVM.shared
                    .profileActor?
                    .syncAllDataToUserDefaults()
            }
        }
    }

    // MARK: Internal

    @Environment(\.scenePhase) var scenePhase

    // MARK: Private

    @StateObject private var connectivityManager = AppleWatchSputnik.shared
    @StateObject private var broadcaster = Broadcaster.shared
    @StateObject private var multiNoteVM = MultiNoteViewModel.shared

    @Default(.pzProfiles) private var pzProfiles: [String: PZProfileSendable]

    private var profiles: [PZProfileSendable] {
        pzProfiles.values.sorted {
            $0.priority < $1.priority
        }
    }
}

// MARK: - DetailNavigator

private struct DetailNavigator: View {
    // MARK: Internal

    @Environment(\.scenePhase) var scenePhase

    var account: PZProfileSendable { dailyNoteViewModel.profile }

    var body: some View {
        Group {
            switch dailyNoteViewModel.dailyNoteStatus {
            case let .succeed(dailyNote, _):
                NavigationLink {
                    WatchProfileDetailView(data: dailyNote, profile: account)
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
        .react(to: broadcaster.eventForRefreshingCurrentPage) { _, _ in
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

    @EnvironmentObject private var dailyNoteViewModel: DailyNoteViewModel
    @StateObject private var broadcaster = Broadcaster.shared
}
