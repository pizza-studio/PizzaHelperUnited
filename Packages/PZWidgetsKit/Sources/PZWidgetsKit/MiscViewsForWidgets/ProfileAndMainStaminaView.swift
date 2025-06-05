// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WidgetKit

// MARK: - MainInfo

@available(watchOS, unavailable)
public struct ProfileAndMainStaminaView<RefreshIntent: AppIntent>: View {
    // MARK: Lifecycle

    public init(
        profile: PZProfileSendable?,
        dailyNote: any DailyNoteProtocol,
        refreshIntent: RefreshIntent
    ) {
        self.profile = profile
        self.dailyNote = dailyNote
        self.refreshIntent = refreshIntent
    }

    // MARK: Public

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let profileName = profile?.name {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Image(systemSymbol: .personFill)
                        .legibilityShadow(isText: false)
                    Text(profileName)
                        .allowsTightening(true)
                        .lineLimit(1)
                        .fixedSize()
                        .minimumScaleFactor(0.5)
                        .legibilityShadow()
                }
                .font(.footnote)
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                let staminaIntel = dailyNote.staminaIntel
                Text(staminaIntel.finished.description)
                    .font(.system(size: 50, design: .rounded))
                    .fontWeight(.medium)
                    .minimumScaleFactor(0.1)
                    .legibilityShadow()
                dailyNote.game.primaryStaminaAssetIcon
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 30)
                    .alignmentGuide(.firstTextBaseline) { context in
                        context[.bottom] - 0.17 * context.height
                    }
                    .legibilityShadow(isText: false)
            }
            Spacer()
            HStack {
                Button(intent: refreshIntent) {
                    Image(systemSymbol: .arrowClockwiseCircle)
                        .font(.title3)
                        .clipShape(.circle)
                }
                .buttonStyle(.plain)
                .legibilityShadow()
                StaminaRecoveryTimeText(data: dailyNote)
            }
        }
        .foregroundColor(.primary)
        .environment(\.colorScheme, .dark)
    }

    // MARK: Internal

    let profile: PZProfileSendable?
    let dailyNote: any DailyNoteProtocol
    let refreshIntent: RefreshIntent
}
