// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import SwiftUI

public struct GachaEntryBar: View {
    // MARK: Lifecycle

    public init(entry: GachaEntryExpressible, showDate: Bool = false) {
        self.entry = entry
        self.drawCount = entry.drawCount < 0 ? nil : entry.drawCount
        self.showDate = showDate
    }

    // MARK: Public

    @MainActor public var body: some View {
        HStack {
            HStack {
                entry.icon(35)
                HStack {
                    entry.nameView
                        .fontWeight(.medium)
                        .fontWidth(.condensed)
                    itemIDText
                        .fontWidth(.condensed)
                    Spacer()

                    VStack(alignment: .trailing) {
                        if let drawCount, entry.rarity != .rank3 {
                            Text(drawCount.description)
                                .font((showDate ?? false) ? .caption2 : .body)
                        }
                        if showDate ?? false {
                            Text(Self.dateFormatter.string(from: entry.time))
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                    }
                }
            }
            #if DEBUG
            .contextMenu {
                    Text(verbatim: "Debug Info")
                    Divider()
                    Text(entry.itemType.getTranslatedRaw(game: entry.game))
                    Text(entry.pool.localizedTitle)
                    Divider()
                    Text(entry.id)
                }
            #endif
        }
    }

    // MARK: Internal

    let entry: GachaEntryExpressible
    let drawCount: Int?
    let showDate: Bool?

    @MainActor var itemIDText: Text {
        if showDate ?? false {
            Text(verbatim: "\(entry.itemID)")
                .font(.caption).foregroundColor(.secondary)
        } else {
            Text(verbatim: "")
        }
    }

    // MARK: Private

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
}
