// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit
import PZIntentKit
import WidgetKit

struct LockScreenHomeCoinWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> AccountOnlyEntry {
        AccountOnlyEntry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping @Sendable (AccountOnlyEntry) -> Void) {
        let entry = AccountOnlyEntry(
            date: Date(),
            result: .success(GeneralNote4GI.exampleData()),
            accountName: "荧",
            accountUUIDString: nil
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping @Sendable (Timeline<AccountOnlyEntry>) -> Void) {}

    func getTimelineAsync(
        in context: Context,
        completion: @escaping @Sendable (Timeline<AccountOnlyEntry>) -> Void
    ) async {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let refreshDate = Calendar.current.date(
            byAdding: .minute,
            value: 7,
            to: currentDate
        )!

        let configs = await PZProfileActor.shared.getSendableProfiles()

        guard !configs.isEmpty else {
            let entry = AccountOnlyEntry(
                date: currentDate,
                result: .failure(FetchError.noFetchInfo),
                accountUUIDString: nil
            )
            let timeline = Timeline<AccountOnlyEntry>(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            return
        }

        guard configuration.account != nil else {
            // 如果还未选择账号，默认获取第一个
            configs.first!.fetchResult { result in
                let entry = AccountOnlyEntry(
                    date: currentDate,
                    result: result,
                    accountName: configs.first!.name
                )
                let timeline = Timeline(
                    entries: [entry],
                    policy: .after(refreshDate)
                )
                completion(timeline)
                print("Widget Fetch succeed")
            }
            return
        }

        let selectedAccountUUID = UUID(
            uuidString: configuration.account!
                .identifier!
        )
        print(configs.first!.uuid!, configuration)

        guard let config = configs
            .first(where: { $0.uuid == selectedAccountUUID }) else {
            // 有时候删除账号，Intent没更新就会出现这样的情况
            let entry = AccountOnlyEntry(
                date: currentDate,
                result: .failure(.noFetchInfo)
            )
            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            print("Need to choose account")
            return
        }

        // 正常情况
        config.fetchResult { result in
            let entry = AccountOnlyEntry(
                date: currentDate,
                result: result,
                accountName: config.name
            )

            switch result {
            case let .success(userData):
                #if !os(watchOS)
                UserNotificationCenter.shared.createAllNotification(
                    for: config.name ?? "",
                    with: userData,
                    uid: config.uid!
                )
                #endif
            case .failure:
                break
            }

            let timeline = Timeline(
                entries: [entry],
                policy: .after(refreshDate)
            )
            completion(timeline)
            print("Widget Fetch succeed")
        }
    }
}
