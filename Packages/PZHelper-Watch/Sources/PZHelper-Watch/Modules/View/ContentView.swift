// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Combine
@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI
import WidgetKit

// MARK: - ContentView

private let refreshSubject: PassthroughSubject<Void, Never> = .init()

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
                    refreshSubject.send(())
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

    var resinImageAssetName: String {
        switch dailyNoteViewModel.profile.game {
        case .genshinImpact: "gi_note_resin"
        case .starRail: "hsr_note_trailblazePower"
        case .zenlessZone: "zzz_note_battery"
        }
    }

    var body: some View {
        Group {
            switch dailyNoteViewModel.dailyNoteStatus {
            case let .succeed(dailyNote, _):
                NavigationLink {
                    WatchAccountDetailView(data: dailyNote, accountName: account.name, uid: account.uid)
                } label: {
                    HStack {
                        VStack {
                            Text(account.name).font(.headline)
                            HStack {
                                AccountKit.imageAsset(resinImageAssetName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                Text(verbatim: "\(dailyNote.staminaIntel.existing)")
                            }
                        }
                        Spacer()
                        Image(systemSymbol: .chevronRight)
                            .foregroundStyle(.secondary)
                    }
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
        .onReceive(refreshSubject) { _ in
            dailyNoteViewModel.getDailyNoteUncheck()
        }
        .onAppear {
            dailyNoteViewModel.getDailyNote()
        }
    }

    // MARK: Private

    @StateObject private var dailyNoteViewModel: DailyNoteViewModel
}
