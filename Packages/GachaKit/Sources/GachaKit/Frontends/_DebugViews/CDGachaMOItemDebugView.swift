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
            let managedObjs = try! GachaActor.shared.cdGachaMOSputnik.allGachaDataMO(for: game)
            if managedObjs.isEmpty {
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
            ForEach(managedObjs, id: \.enumID) { gachaItemMO in
                let theEntry = gachaItemMO.asPZGachaEntrySendable.expressible
                GachaEntryBar(entry: theEntry, showDate: true, debug: true)
            }
        }
        .formStyle(.grouped)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Picker("".description, selection: $game.animation()) {
                    ForEach(Self.oldGachaGames) { enumeratedGame in
                        Text(enumeratedGame.localizedShortName)
                            .tag(enumeratedGame)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: game, initial: true) {
                    print("Action")
                }
            }
        }
        .navigationTitle(game.localizedDescription)
        .navBarTitleDisplayMode(.large)
    }

    // MARK: Internal

    static let oldGachaGames: [Pizza.SupportedGame] = [.genshinImpact, .starRail]

    @State var game: Pizza.SupportedGame = .genshinImpact
}
