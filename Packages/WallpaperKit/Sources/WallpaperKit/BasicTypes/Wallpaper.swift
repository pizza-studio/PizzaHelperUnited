// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public enum Wallpaper: Identifiable, AbleToCodeSendHash {
    case bundled(BundledWallpaper)
    case user(UserWallpaper)

    // MARK: Lifecycle

    public init?(id givenID: String?, matchFailureHandler: (() -> Void)? = nil) {
        guard let givenID, givenID != Self.nullLiveActivityWallpaperIdentifier else { return nil }
        let maybeUUID = UUID(uuidString: givenID)
        var isMatchFailureHandled = false
        if maybeUUID != nil {
            let userWP = UserWallpaper(defaultsValueID: givenID)
            if let userWP {
                self = .user(userWP)
                return
            } else {
                matchFailureHandler?()
                isMatchFailureHandled = true
            }
        }
        let matched = BundledWallpaper.allCases.first {
            $0.id == givenID
        }
        guard let matched else {
            if !isMatchFailureHandled, givenID != Self.nullLiveActivityWallpaperIdentifier {
                matchFailureHandler?()
            }
            return nil
        }
        self = .bundled(matched)
    }

    // MARK: Public

    public static let nullLiveActivityWallpaperIdentifier = "_NULL_LAWP"

    public static var finalFallbackValue: Wallpaper {
        .bundled(.defaultValue(for: appGame))
    }

    public static var allCases: [Wallpaper] {
        var result = [Wallpaper]()
        UserWallpaper.allCases.forEach {
            result.append(Wallpaper.user($0))
        }
        BundledWallpaper.allCases.forEach {
            result.append(Wallpaper.bundled($0))
        }
        return result
    }

    public var id: String {
        switch self {
        case let .bundled(bundledWallpaper): bundledWallpaper.id
        case let .user(userWallpaper): userWallpaper.id.uuidString
        }
    }

    public var game: Pizza.SupportedGame? {
        switch self {
        case let .bundled(bundledWallpaper): bundledWallpaper.game
        case .user: nil
        }
    }
}
