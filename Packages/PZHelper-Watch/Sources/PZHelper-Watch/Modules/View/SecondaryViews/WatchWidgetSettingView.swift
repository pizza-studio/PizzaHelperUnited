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

    var lockscreenWidgetRefreshFrequencyFormated: String {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
            .string(from: allWidgetsSyncFrequencyByMinutes * 60.0)!
    }

    var body: some View {
        List {
            Section {
                ForEach(accounts) { account in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(account.name).bold()
                            Text(account.uidWithGame).font(.footnote)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Image(systemSymbol: .chevronLeft)
                            .foregroundStyle(.secondary)
                            .frame(width: 12, height: 12)
                    }
                    .frame(maxWidth: .infinity)
                }
                .onDelete(perform: { indexSet in
                    for offset in indexSet {
                        let account = accounts[offset]
                        let uuidToRemove = account.uuid
                        PZNotificationCenter.deleteDailyNoteNotification(for: account.asSendable)
                        modelContext.delete(account)
                        do {
                            try modelContext.save()
                            Defaults[.pzProfiles].removeValue(forKey: uuidToRemove.uuidString)
                            UserDefaults.profileSuite.synchronize()
                        } catch {
                            print(error)
                        }
                    }
                })
            } header: {
                Text("watch.profile.manage.title", bundle: .module)
                    .textCase(.none)
            }
            // Section {
            //     NavigationLink {
            //         QueryFrequencySettingView()
            //     } label: {
            //         HStack {
            //             Text("watch.widget.settings.sync.frequency.title", bundle: .module)
            //             Spacer()
            //             Text(
            //                 "watch.widget.settings.sync.speed:\(lockscreenWidgetRefreshFrequencyFormated)",
            //                 bundle: .module
            //             )
            //             .foregroundColor(.accentColor)
            //         }
            //     }
            // }
        }
    }

    // MARK: Private

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var accounts: [PZProfileMO]

    @Default(.allWidgetsSyncFrequencyByMinutes) private var allWidgetsSyncFrequencyByMinutes: Double
}

// MARK: - QueryFrequencySettingView

private struct QueryFrequencySettingView: View {
    // MARK: Internal

    var lockscreenWidgetRefreshFrequencyFormated: String {
        let formatter = DateComponentsFormatter()
        formatter.maximumUnitCount = 2
        formatter.unitsStyle = .short
        formatter.zeroFormattingBehavior = .dropAll
        return formatter
            .string(from: allWidgetsSyncFrequencyByMinutes * 60.0)!
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
                value: $allWidgetsSyncFrequencyByMinutes,
                in: 30 ... 300,
                step: 10,
                label: {
                    Text(verbatim: "\(allWidgetsSyncFrequencyByMinutes)")
                }
            )
        }
    }

    // MARK: Private

    @Default(.allWidgetsSyncFrequencyByMinutes) private var allWidgetsSyncFrequencyByMinutes: Double
}
