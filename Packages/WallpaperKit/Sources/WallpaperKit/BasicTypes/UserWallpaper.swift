// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Defaults
import Foundation
import PZBaseKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension Defaults.Keys {
    /// User-supplied Wallpapers. API deprecated. Left for data migration purposes.
    /// This API is intentionally marked as non-public.
    internal static let userWallpapers = Key<Set<UserWallpaper>>(
        "userWallpapers",
        default: [],
        suite: .baseSuite
    )
}

// MARK: - UserWallpaper

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public struct UserWallpaper: Identifiable, AbleToCodeSendHash {
    // MARK: Lifecycle

    public init?(defaultsValueID: String?, validateImageData: Bool = false) {
        guard let defaultsValueID else { return nil }
        guard let uuid = UUID(uuidString: defaultsValueID) else { return nil }
        let matched = UserWallpaperFileHandler.getUserWallpaper(uuid: uuid)
        guard let matched else { return nil }
        if validateImageData {
            guard matched.isImageDataValid else { return nil }
        }
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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
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

    public var isImageDataValid: Bool {
        imageSquared != nil && imageHorizontal != nil
    }

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

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension UserWallpaper: Defaults.Serializable {}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension UserWallpaper {
    public static var allCases: [UserWallpaper] {
        UserWallpaperFileHandler.getAllUserWallpapers().sorted {
            $0.timestamp > $1.timestamp
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension Set where Element == UserWallpaper {
    public init(defaultsValueIDs: Set<String>) {
        let uuids = defaultsValueIDs.compactMap { UUID(uuidString: $0) }
        let validResults = UserWallpaperFileHandler.getAllUserWallpapers().filter {
            uuids.contains($0.id)
        }
        self = .init(validResults)
    }
}
