// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

extension ProfileManagerVM {
    func profilesFilteredByGame(
        _ games: Set<Pizza.SupportedGame> = []
    )
        -> [PZProfileSendable] {
        games.isEmpty ? profiles : profiles.filter { games.contains($0.game) }
    }

    @ViewBuilder
    func profileSwitcherMenu4DPV(
        _ target: Binding<PZProfileSendable?>,
        games: Set<Pizza.SupportedGame>
    )
        -> some View {
        Menu {
            profileSwitcherMenuContents4DPV(target, games: games)
        } label: {
            profileSwitcherMenuLabel(target)
        }
        .menuStyle(.button)
    }

    @ViewBuilder
    func profileSwitcherMenuContents4DPV(
        _ target: Binding<PZProfileSendable?>,
        games: Set<Pizza.SupportedGame>
    )
        -> some View {
        Button {
            withAnimation {
                target.wrappedValue = nil
            }
        } label: {
            switch OS.type {
            case .macOS:
                Text("dpv.query.menuCommandTitle".i18nPZHelper)
                    .multilineTextAlignment(.leading)
                    .fontWidth(.condensed)
                    .frame(maxWidth: .infinity)
            default:
                LabeledContent {
                    Text("dpv.query.menuCommandTitle".i18nPZHelper)
                        .multilineTextAlignment(.leading)
                        .fontWidth(.condensed)
                        .frame(maxWidth: .infinity)
                } label: {
                    Image(systemSymbol: .magnifyingglassCircleFill)
                        .frame(width: 48)
                        .clipShape(.circle)
                        .padding(.trailing, 4)
                }
            }
        }
        Divider()
        ForEach(profilesFilteredByGame(games)) { enumeratedProfile in
            Button {
                withAnimation {
                    target.wrappedValue = enumeratedProfile
                }
            } label: {
                enumeratedProfile.asMenuLabel4SUI()
            }
        }
    }

    @ViewBuilder
    func profileSwitcherMenuLabel(
        _ target: Binding<PZProfileSendable?>
    )
        -> some View {
        LabeledContent {
            let dimension: CGFloat = 30
            Group {
                if let profile: PZProfileSendable = target.wrappedValue {
                    Enka.ProfileIconView(uid: profile.uid, game: profile.game)
                        .frame(width: dimension)
                } else {
                    Image(systemSymbol: .personCircleFill)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: dimension - 8)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .background {
                // Compiler optimization.
                AnyView(
                    erasing: {
                        Circle()
                            .strokeBorder(Color.accentColor, lineWidth: 8)
                            .frame(width: dimension, height: dimension)
                    }()
                )
            }
            .frame(width: dimension, height: dimension)
            .clipShape(.circle)
            .compositingGroup()
        } label: {
            if let profile: PZProfileSendable = target.wrappedValue {
                Text(profile.uidWithGame).fontWidth(.condensed)
            } else {
                Text("dpv.query.menuCommandTitle".i18nPZHelper)
            }
        }
        .padding(4).padding(.leading, 12)
        .blurMaterialBackground(enabled: !OS.liquidGlassThemeSuspected)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
