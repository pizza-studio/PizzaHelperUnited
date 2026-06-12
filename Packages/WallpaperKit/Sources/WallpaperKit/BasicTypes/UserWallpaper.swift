// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics
import Foundation
import PZBaseKit
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
        imageSquared: CGImage,
        imageVertical: CGImage? = nil
    ) {
        let data4Horizontal = imageHorizontal.encodeToFileData(as: .jpeg(quality: 0.9))
        let data4Squared = imageSquared.encodeToFileData(as: .jpeg(quality: 0.9))
        guard let data4Squared, let data4Horizontal else { return nil }
        self.id = .init()
        self.timestamp = Date().timeIntervalSince1970
        self.name = givenName ?? ""
        self.b64Data4Horizontal = data4Horizontal.base64EncodedString()
        self.b64Data4Squared = data4Squared.base64EncodedString()
        if let imageVertical {
            let data4Vertical = imageVertical.encodeToFileData(as: .jpeg(quality: 0.9))
            self.b64Data4Vertical = data4Vertical?.base64EncodedString()
        } else {
            self.b64Data4Vertical = nil
        }
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
    public let b64Data4Vertical: String?
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

    /// Vertical crop (200×420) for `systemExtraLargePortrait` desktop widgets.
    /// For wallpapers created before this field was introduced, this returns
    /// a center-cropped 200×420 portion of the squared image, computed at runtime.
    public var imageVertical: CGImage? {
        if let b64Data4Vertical,
           let data = Data(base64Encoded: b64Data4Vertical),
           let cgImage = CGImage.instantiate(data: data) {
            return cgImage
        }
        // Auto-fallback: center-crop 200×420 from the 420×420 squared image.
        guard let squared = imageSquared else { return nil }
        let originX = Double(squared.width - 200) / 2.0
        return squared.crop(to: CGRect(x: originX, y: 0, width: 200, height: 420))
    }

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

extension UserWallpaper: Defaults.Serializable {}

extension UserWallpaper {
    public static var allCases: [UserWallpaper] {
        UserWallpaperFileHandler.getAllUserWallpapers().sorted {
            $0.timestamp > $1.timestamp
        }
    }
}

extension Set where Element == UserWallpaper {
    public init(defaultsValueIDs: Set<String>) {
        let uuids = defaultsValueIDs.compactMap { UUID(uuidString: $0) }
        let validResults = UserWallpaperFileHandler.getAllUserWallpapers().filter {
            uuids.contains($0.id)
        }
        self = .init(validResults)
    }
}
