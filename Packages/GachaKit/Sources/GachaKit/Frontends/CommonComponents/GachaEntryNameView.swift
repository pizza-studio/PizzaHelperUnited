// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaKit
import GachaMetaDB
import SwiftUI

public struct GachaEntryNameView: View {
    // MARK: Lifecycle

    public init(entry: GachaEntryExpressible) {
        self.entry = entry
    }

    // MARK: Public

    @MainActor public var body: some View {
        Text(nameLocalized())
    }

    // MARK: Internal

    @State var enkaDB = Enka.Sputnik.shared
    @State var metaDB = GachaMeta.sharedDB
    @Default(.useRealCharacterNames) var useRealCharacterNames: Bool

    func nameLocalized(for lang: GachaLanguage = .current) -> String {
        switch entry.game {
        case .genshinImpact:
            var result: String?
            if lang == .current {
                result = enkaDB.db4GI.getFailableTranslationFor(
                    id: entry.itemID, realName: useRealCharacterNames
                )
            } else {
                result = nil
            }
            return result
                ?? metaDB.mainDB4GI.plainQueryForNames(
                    itemID: entry.itemID, langID: lang.rawValue
                )
                ?? entry.name
        case .starRail:
            var result: String?
            if lang == .current {
                result = enkaDB.db4HSR.getFailableTranslationFor(
                    id: entry.itemID, realName: useRealCharacterNames
                )
            } else {
                result = nil
            }
            return result
                ?? metaDB.mainDB4HSR.plainQueryForNames(
                    itemID: entry.itemID, langID: lang.rawValue
                )
                ?? entry.name
        case .zenlessZone: return entry.name // 暂不处理。
        }
    }

    // MARK: Private

    private let entry: GachaEntryExpressible
}
