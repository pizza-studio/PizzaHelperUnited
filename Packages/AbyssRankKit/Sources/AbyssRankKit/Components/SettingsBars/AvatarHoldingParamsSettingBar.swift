// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import SwiftUI

// MARK: - AvatarHoldingParamsSettingBar

struct AvatarHoldingParamsSettingBar: View {
    @Binding var params: AvatarHoldingAPIParameters

    @MainActor var body: some View {
        Picker(params.serverChoice.describe(), selection: $params.serverChoice.animation()) {
            Text("abyssRankKit.rank.server.filter.all", bundle: .module).tag(ServerChoice.all)
            ForEach(HoYo.Server.allCases4GI, id: \.id) { server in
                Text(server.localizedDescriptionByGame).tag(ServerChoice.server(server))
            }
        }.pickerStyle(.menu).fixedSize()
        DatePicker("".description, selection: $params.date, displayedComponents: [.date])
    }
}

// MARK: - AvatarHoldingAPIParameters

struct AvatarHoldingAPIParameters: Sendable, Equatable {
    var date: Date = Calendar.current.date(
        byAdding: .day,
        value: -30,
        to: Date()
    )!
    var serverChoice: ServerChoice = .all

    var server: HoYo.Server? {
        switch serverChoice {
        case .all: nil
        case let .server(server): server
        }
    }

    func describe() -> String {
        let dateString: String = {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }()
        return String(
            format: NSLocalizedString("abyssRankKit.rank.note.3", comment: ""),
            dateString
        )
    }

    func detail() -> String {
        "\(serverChoice.describe())"
    }
}
