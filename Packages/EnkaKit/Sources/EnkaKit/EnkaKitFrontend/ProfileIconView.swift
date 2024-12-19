// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZBaseKit
import SwiftUI

extension EKQueriedProfileProtocol {
    @MainActor
    public func onlineIcon(imageHandler: ((Image) -> Image)? = nil) -> AsyncImage<some View> {
        AsyncImage(url: onlineAssetURLStr.asURL) { imgObj in
            if let imageHandler {
                imageHandler(imgObj)
            } else {
                imgObj.resizable()
            }
        } placeholder: {
            AnonymousIconView.rawImage4SUI
        }
    }

    @MainActor @ViewBuilder public var localFittingIcon4SUI: some View {
        Group {
            if let local = Enka.queryImageAssetSUI(for: iconAssetName) {
                local.resizable().aspectRatio(contentMode: .fit)
            } else {
                onlineIcon().aspectRatio(contentMode: .fit)
            }
        }.background {
            Color(cgColor: .init(red: 0.94, green: 0.88, blue: 0.48, alpha: 1.00))
        }
        .clipShape(.circle)
    }
}

// MARK: - Enka.ProfileIconView

extension Enka {
    public struct ProfileIconView: View {
        // MARK: Lifecycle

        public init(uid: String, game: Enka.GameType) {
            self.uid = uid
            self.game = game
        }

        // MARK: Public

        public let uid: String
        public let game: Enka.GameType

        public var body: some View {
            switch game {
            case .genshinImpact:
                if let profile = profiles4GI[uid] {
                    profile.localFittingIcon4SUI
                } else {
                    AnonymousIconView.rawImage4SUI
                        .clipShape(.circle)
                        .task(priority: .background) {
                            try? await Enka.Sputnik.commonActor.queryAndSave(uid: uid, game: game)
                        }
                }
            case .starRail:
                if let profile = profiles4HSR[uid] {
                    profile.localFittingIcon4SUI
                } else {
                    AnonymousIconView.rawImage4SUI
                        .clipShape(.circle)
                        .task(priority: .background) {
                            try? await Enka.Sputnik.commonActor.queryAndSave(uid: uid, game: game)
                        }
                }
            case .zenlessZone: AnonymousIconView.rawImage4SUI.clipShape(.circle) // 临时设定。
            }
        }

        // MARK: Private

        @Default(.queriedEnkaProfiles4GI) private var profiles4GI
        @Default(.queriedEnkaProfiles4HSR) private var profiles4HSR
    }
}

#if DEBUG

private let profileHSR: Enka.QueriedProfileHSR = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4HSR(locTag: "zh-cn")
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileHSR.json"
    let dataURL = URL(fileURLWithPath: filePath)
    let profile = try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultHSR.self).detailInfo!
    return profile
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

private let profileGI: Enka.QueriedProfileGI = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4GI(locTag: "zh-cn")
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileGI.json"
    let dataURL = URL(fileURLWithPath: filePath)
    let profile = try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultGI.self).detailInfo!
    return profile
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

#Preview {
    VStack {
        profileHSR.localFittingIcon4SUI
        profileGI.localFittingIcon4SUI
    }
}

#endif
