// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - PZGachaProfileMO

@Model
public final class PZGachaProfileMO: GachaProfileIDProtocol {
    // MARK: Lifecycle

    public init(uid: String, game: Pizza.SupportedGame, profileName: String? = nil) {
        self.uid = uid
        self.game = game
        self.gameRAW = game.rawValue
        self.profileName = profileName
    }

    public init?(uidWithGame: String, profileName: String? = nil) {
        let cells = uidWithGame.split(separator: "-")
        guard cells.count == 2 else { return nil }
        let uidStr = cells[1].description
        guard let matchedGame = Pizza.SupportedGame(uidPrefix: cells[0].description) else { return nil }
        guard Int(uidStr) != nil else { return nil }
        self.uid = uidStr
        self.game = matchedGame
        self.gameRAW = matchedGame.rawValue
        self.profileName = profileName
    }

    // MARK: Public

    public var uid: String = "000000000"
    public var game: Pizza.SupportedGame = Pizza.SupportedGame.genshinImpact
    public var gameRAW: String = Pizza.SupportedGame.genshinImpact.rawValue
    public var profileName: String?

    public var asSendable: GachaProfileID {
        GachaProfileID(uid: uid, game: game, profileName: profileName)
    }

    public var id: String { uidWithGame }
}

// MARK: - GachaProfileID

public struct GachaProfileID: GachaProfileIDProtocol, Sendable {
    // MARK: Lifecycle

    public init(uid: String, game: Pizza.SupportedGame, profileName: String? = nil) {
        self.uid = uid
        self.game = game
        self.profileName = profileName
    }

    public init?(uidWithGame: String, profileName: String? = nil) {
        let cells = uidWithGame.split(separator: "-")
        guard cells.count == 2 else { return nil }
        let uidStr = cells[1].description
        guard let matchedGame = Pizza.SupportedGame(uidPrefix: cells[0].description) else { return nil }
        guard Int(uidStr) != nil else { return nil }
        self.uid = uidStr
        self.game = matchedGame
        self.profileName = profileName
    }

    // MARK: Public

    public var uid: String
    public var game: PZBaseKit.Pizza.SupportedGame
    public var profileName: String?

    public var asMO: PZGachaProfileMO {
        PZGachaProfileMO(uid: uid, game: game, profileName: profileName)
    }

    public var id: String { uidWithGame }
}

// MARK: - GachaProfileIDProtocol

public protocol GachaProfileIDProtocol: Identifiable, Equatable, Hashable {
    var uid: String { get set }
    var game: Pizza.SupportedGame { get set }
    var profileName: String? { get set }
}

extension GachaProfileIDProtocol {
    @MainActor @ViewBuilder var photoView: some View {
        Enka.ProfileIconView(uid: uid, game: game)
    }

    @MainActor @ViewBuilder var profileNameView: some View {
        Enka.ProfileNameView(uid: uid, game: game, name: profileName)
    }

    public var uidWithGame: String {
        "\(game.uidPrefix)-\(uid)"
    }
}
