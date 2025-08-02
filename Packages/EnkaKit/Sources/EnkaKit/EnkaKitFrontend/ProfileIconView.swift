// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Defaults
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, *)
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
            Group {
                switch game {
                case .genshinImpact:
                    if let profile = sharedDB.db4GI.getCachedProfileRAW(uid: uid) {
                        profile.localFittingIcon4SUI
                    } else {
                        AnonymousIconView.rawImage4SUI
                            .clipShape(.circle)
                            .task(priority: .background) {
                                try? await Enka.Sputnik.commonActor.queryAndSave(uid: uid, game: game)
                            }
                    }
                case .starRail:
                    if let profile = sharedDB.db4HSR.getCachedProfileRAW(uid: uid) {
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
            .id(latestHash)
        }

        // MARK: Private

        @State private var sharedDB: Enka.Sputnik = .shared
        @StateObject private var broadcaster = Broadcaster.shared

        private var uidWithGame: String { "\(game.uidPrefix)-\(uid)" }

        private var latestHash: Int {
            let mostRecentDate = broadcaster.eventForUpdatingLocalEnkaAvatarCache[uidWithGame]
            let timeInterval = (mostRecentDate ?? .distantPast).timeIntervalSince1970
            return timeInterval.hashValue
        }
    }
}

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *) private let profileHSR: Enka.QueriedProfileHSR = {
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

@available(iOS 17.0, macCatalyst 17.0, *) private let profileGI: Enka.QueriedProfileGI = {
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

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    VStack {
        profileHSR.localFittingIcon4SUI
        profileGI.localFittingIcon4SUI
    }
}

#endif
