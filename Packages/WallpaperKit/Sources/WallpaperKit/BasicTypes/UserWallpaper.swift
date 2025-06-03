// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Defaults
import Foundation
import PZBaseKit

extension Defaults.Keys {
    // User-supplied Wallpapers.
    public static let userWallpapers = Key<Set<UserWallpaper>>(
        "userWallpapers",
        default: [],
        suite: .baseSuite
    )
    // User wallpapers for live activity view.
    public static let userWallpapers4LiveActivity = Key<Set<String>>(
        "userWallpapers4LiveActivity",
        default: [],
        suite: .baseSuite
    )
    // User wallpaper for app view.
    public static let userWallpaper4App = Key<String?>(
        "userWallpaper4App",
        default: nil,
        suite: .baseSuite
    )
}

// MARK: - UserWallpaper

public struct UserWallpaper: Identifiable, AbleToCodeSendHash {
    // MARK: Lifecycle

    public init?(defaultsValueID: String?) {
        guard let defaultsValueID else { return nil }
        guard let uuid = UUID(uuidString: defaultsValueID) else { return nil }
        let matched = Defaults[.userWallpapers].first { $0.id == uuid }
        guard let matched else { return nil }
        self = matched
    }

    public init?(
        name givenName: String? = nil,
        imageHorizontal: CGImage,
        imageSquared: CGImage
    ) {
        let data4Horizontal = imageHorizontal.encodeToFileData(as: .jpeg(quality: 0.9))
        let data4Squared = imageSquared.encodeToFileData(as: .jpeg(quality: 0.9))
        guard let data4Squared, let data4Horizontal else { return nil }
        self.id = .init()
        self.timestamp = Date().timeIntervalSince1970
        self.name = givenName ?? ""
        self.b64Data4Horizontal = data4Horizontal.base64EncodedString()
        self.b64Data4Squared = data4Squared.base64EncodedString()
        if givenName == nil {
            self.name = dateString
        }
    }

    // MARK: Public

    public var id: UUID
    public var name: String
    public let timestamp: Double
    public let b64Data4Horizontal: String
    public let b64Data4Squared: String
}

extension UserWallpaper {
    public var imageHorizontal: CGImage? {
        guard let data = Data(base64Encoded: b64Data4Horizontal) else { return nil }
        return CGImage.instantiate(data: data)
    }

    public var imageSquared: CGImage? {
        guard let data = Data(base64Encoded: b64Data4Squared) else { return nil }
        return CGImage.instantiate(data: data)
    }

    public var dateString: String { Self.makeDateString(timestamp: timestamp) }

    public static func makeDateString(
        timestamp: TimeInterval = Date().timeIntervalSince1970,
        forFileName: Bool = false
    )
        -> String {
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = forFileName ? "yyyyMMddHHmmss" : "yyyy-MM-dd HH:mm:ss"
        let date = Date(timeIntervalSince1970: timestamp)
        return dateFormatter.string(from: date)
    }
}

// MARK: Defaults.Serializable

extension UserWallpaper: Defaults.Serializable {}

extension UserWallpaper {
    public static var allCases: [UserWallpaper] {
        Defaults[.userWallpapers].sorted {
            $0.timestamp > $1.timestamp
        }
    }
}

extension Set where Element == UserWallpaper {
    public init(defaultsValueIDs: Set<String>) {
        let uuids = defaultsValueIDs.compactMap { UUID(uuidString: $0) }
        let validResults = Defaults[.userWallpapers].filter { uuids.contains($0.id) }
        self = .init(validResults)
    }
}
