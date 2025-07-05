// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct GachaEntryBar: View {
    // MARK: Lifecycle

    public init(
        entry: GachaEntryExpressible,
        showDate: Bool = false,
        debug: Bool = false,
        debugMenu: Bool = false
    ) {
        self.entry = entry
        self.drawCount = entry.drawCount < 0 ? nil : entry.drawCount
        self.showDate = showDate
        self.debug = debug
        self.debugMenu = debugMenu
    }

    // MARK: Public

    public var body: some View {
        HStack {
            HStack {
                entry.icon(35)
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            entry.nameView
                                .environment(theVM)
                                .fontWeight(.medium)
                                .fontWidth(.condensed)
                            itemIDText
                                .fontWidth(.condensed)
                        }
                        if debug {
                            HStack {
                                Text(verbatim: entry.id)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .fontWidth(.condensed)
                            }
                        }
                    }
                    Spacer()

                    VStack(alignment: .trailing) {
                        if let drawCount, entry.rarity != .rank3 {
                            Text(drawCount.description)
                                .font(showDate ? .caption2 : .body)
                        } else if debug {
                            Text(entry.uidWithGame)
                                .font(.caption2)
                                .fontWidth(.condensed)
                        }
                        if showDate {
                            Text(Self.dateFormatter.string(from: entry.time))
                                .foregroundColor(.secondary)
                                .font(.caption2)
                        }
                    }
                }
            }
            .apply { theContent in
                if !debug || !debugMenu {
                    theContent
                } else {
                    theContent
                        .contextMenu {
                            Text(verbatim: "Debug Info")
                            Divider()
                            Text(entry.itemType.getTranslatedRaw(game: entry.game))
                            Text(entry.pool.localizedTitle)
                            Divider()
                            Text(entry.id)
                        }
                }
            }
        }
    }

    // MARK: Internal

    let entry: GachaEntryExpressible
    let drawCount: Int?
    let showDate: Bool
    let debug: Bool
    let debugMenu: Bool

    @MainActor var itemIDText: Text {
        if showDate {
            Text(verbatim: "\(entry.itemID)")
                .font(.caption).foregroundColor(.secondary)
        } else {
            Text(verbatim: "")
        }
    }

    // MARK: Private

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter
    }()

    @Environment(GachaVM.self) private var theVM
}
