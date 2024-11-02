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

// MARK: - WatchWidgetSettingView

struct WatchWidgetSettingView: View {
    // MARK: Internal

    @Query(sort: \PZProfileMO.priority) private var accounts: [PZProfileMO]
    @Default(.lockscreenWidgetSyncFrequencyInMinute) private var lockscreenWidgetSyncFrequencyInMinute: Double
    @Default(.homeCoinRefreshFrequencyInHour) private var homeCoinRefreshFrequency: Double
    @Default(.watchWidgetUseSimplifiedMode) private var watchWidgetUseSimplifiedMode: Bool

    var lockscreenWidgetRefreshFrequencyFormated: String {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
            .string(from: lockscreenWidgetSyncFrequencyInMinute * 60.0)!
    }

    var body: some View {
        List {
            Section {
                ForEach(accounts) { account in
                    Text(account.name)
                }
                .onDelete(perform: { indexSet in
                    for offset in indexSet {
                        let account = accounts[offset]
                        modelContext.delete(account)
                        do {
                            try modelContext.save()
                        } catch {
                            print(error)
                        }
                    }
                })
            } header: {
                Text("watch.profile.manage.title", bundle: .module)
                    .textCase(.none)
            }
            Section {
                NavigationLink {
                    QueryFrequencySettingView()
                } label: {
                    HStack {
                        Text("watch.widget.settings.sync.frequency.title", bundle: .module)
                        Spacer()
                        Text(
                            "watch.widget.settings.sync.speed:\(lockscreenWidgetRefreshFrequencyFormated)",
                            bundle: .module
                        )
                        .foregroundColor(.accentColor)
                    }
                }
            }
            Section {
                Toggle(isOn: $watchWidgetUseSimplifiedMode) {
                    Text("watch.widget.simplifiedMode.title", bundle: .module)
                }
            } footer: {
                Text("watch.widget.simplifiedMode.note", bundle: .module)
            }
            if watchWidgetUseSimplifiedMode {
                Section {
                    NavigationLink {
                        HomeCoinRecoverySettingView()
                    } label: {
                        HStack {
                            Text("watch.widget.realmCurrency.speed", bundle: .module)
                            Spacer()
                            Text(String(
                                format: "watch.realmCurrency.speed.detail".i18nWatch,
                                Int(homeCoinRefreshFrequency)
                            ))
                            .foregroundColor(.accentColor)
                        }
                    }
                } footer: {
                    Text("watch.widget.simplifiedMode.note.realmCurrency", bundle: .module)
                }
            }
        }
        .onChange(of: watchWidgetUseSimplifiedMode) { _, _ in
            WidgetCenter.shared.invalidateConfigurationRecommendations()
        }
    }

    // MARK: Private

    @Environment(\.modelContext) var modelContext
}

// MARK: - QueryFrequencySettingView

private struct QueryFrequencySettingView: View {
    @Default(.lockscreenWidgetSyncFrequencyInMinute) var lockscreenWidgetSyncFrequencyInMinute: Double

    var lockscreenWidgetRefreshFrequencyFormated: String {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
            .string(from: lockscreenWidgetSyncFrequencyInMinute * 60.0)!
    }

    var body: some View {
        VStack {
            Text("watch.widget.settings.sync.frequency.title", bundle: .module).foregroundColor(.accentColor)
            Text(
                "watch.widget.settings.sync.speed:\(lockscreenWidgetRefreshFrequencyFormated)",
                bundle: .module
            )
            .font(.title3)
            Slider(
                value: $lockscreenWidgetSyncFrequencyInMinute,
                in: 30 ... 300,
                step: 10,
                label: {
                    Text(verbatim: "\(lockscreenWidgetSyncFrequencyInMinute)")
                }
            )
        }
    }
}

// MARK: - HomeCoinRecoverySettingView

private struct HomeCoinRecoverySettingView: View {
    @Default(.homeCoinRefreshFrequencyInHour) var homeCoinRefreshFrequency: Double

    var body: some View {
        VStack {
            Text("watch.widget.realmCurrency.speed", bundle: .module).foregroundColor(.accentColor)
            Text(String(
                format: "watch.realmCurrency.speed.detail".i18nWatch,
                Int(homeCoinRefreshFrequency)
            ))
            .font(.title3)
            Slider(
                value: $homeCoinRefreshFrequency,
                in: 4 ... 30,
                step: 2,
                label: {
                    Text(verbatim: "\(homeCoinRefreshFrequency)")
                }
            )
        }
    }
}
