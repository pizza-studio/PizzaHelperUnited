// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - CDGachaMODebugView

public struct CDGachaMODebugView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        Form {
            if delegate.taskState == .busy {
                ProgressView()
            }
            if delegate.managedObjs.isEmpty {
                Text(
                    verbatim:
                    """
                    从云端获取资料可能需要几分钟的时间，抑或是您当前 iCloud 资料库里面没有可继承的旧版抽卡资料。

                    從雲端獲取資料可能需要幾分鐘的時間，抑或是您當前 iCloud 資料庫裡面沒有可繼承的舊版抽卡資料。

                    iCloud アカウントから旧版のガチャ記録を読み込むには多少（数分の）時間がかかります。あるいはお求めの記録は該当 iCloud データベースには不在庫かもしれません。

                    Either no inheritable legacy Gacha records available in your iCloud storage or you might have to wait for a few minutes to let the app fetch all records from the cloud.
                    """
                )
                .font(.caption)
            }
            if let error = delegate.currentError {
                Text(verbatim: "\(error)")
                    .font(.caption)
            }
            ForEach(delegate.managedObjs, id: \.enumID) { gachaItemMO in
                let theEntry = gachaItemMO.asPZGachaEntrySendable.expressible
                GachaEntryBar(entry: theEntry, showDate: true, debug: true)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                HStack {
                    Picker("".description, selection: $delegate.game.animation()) {
                        ForEach(Self.oldGachaGames) { enumeratedGame in
                            Text(enumeratedGame.localizedShortName)
                                .tag(enumeratedGame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: delegate.game, initial: true) {
                        print("Action")
                    }
                }
            }
        }
        .navigationTitle(delegate.game.localizedDescription)
        .navBarTitleDisplayMode(.large)
        .onChange(of: delegate.game, initial: true) {
            delegate.loadData()
        }
    }

    // MARK: Internal

    static let oldGachaGames: [Pizza.SupportedGame] = [.genshinImpact, .starRail]

    @State var delegate = CDGachaMODebugVM()
}

// MARK: CDGachaMODebugView.CDGachaMODebugVM

extension CDGachaMODebugView {
    @Observable
    final class CDGachaMODebugVM: TaskManagedVM {
        @MainActor var game: Pizza.SupportedGame = .genshinImpact
        @MainActor var managedObjs: [any CDGachaMOProtocol] = []

        @MainActor
        func loadData() {
            let game = game // 使其变成 Sendable.
            fireTask(
                animatedPreparationTask: {
                    self.managedObjs.removeAll()
                },
                cancelPreviousTask: true, // 强制重新读入。
                givenTask: {
                    async let fetchedManagedObjs = try GachaActor.shared.cdGachaMOSputnik.allGachaDataMO(for: game)
                    let fetched: [any CDGachaMOProtocol] = try await fetchedManagedObjs
                    return fetched
                },
                completionHandler: { fetched in
                    self.managedObjs = fetched ?? []
                }
            )
        }
    }
}
