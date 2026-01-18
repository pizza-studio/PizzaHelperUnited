// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import Foundation
import PZBaseKit
import SwiftUI
import UniformTypeIdentifiers
import WallpaperKit

// MARK: - UserWallpaperPack

/// 该结构仅用作导出内容之用途。
@available(iOS 14, macCatalyst 14, *)
public struct UserWallpaperPack: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        let model = try JSONDecoder().decode(
            Set<UserWallpaper>.self,
            from: configuration.file.regularFileContents ?? .init([])
        )
        self.model = model
        let timeStampStr = UserWallpaper.makeDateString(forFileName: true)
        self.fileNameStem = "UserWallpapers_\(timeStampStr)"
    }

    public init(model: Set<UserWallpaper>) {
        self.model = model
        let timeStampStr = UserWallpaper.makeDateString(forFileName: true)
        self.fileNameStem = "UserWallpapers_\(timeStampStr)"
    }

    // MARK: Public

    public typealias FileType = Set<UserWallpaper>

    public static let readableContentTypes: [UTType] = [.json]

    public let model: Set<UserWallpaper>

    public var fileNameStem: String

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let dateFormatter = DateFormatter.GregorianPOSIX()
        dateFormatter.dateFormat = "yyyyMMddHHmm"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let data = try encoder.encode(model)
        return FileWrapper(regularFileWithContents: data)
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension UserWallpaperPack {
    public enum FileParseException: Error, LocalizedError {
        case urlNull
        case dataNotFetchable
        case decodingError(Error)
    }

    @discardableResult
    public static func loadAndParse(_ url: URL?) throws -> Int {
        guard let url else { throw FileParseException.urlNull }
        guard let data = try? Data(contentsOf: url) else { throw FileParseException.dataNotFetchable }
        do {
            let decoded = try JSONDecoder().decode(Set<UserWallpaper>.self, from: data)
            return loadAndParseANewWallpaperSet(decoded)
        } catch {
            throw FileParseException.decodingError(error)
        }
    }

    @discardableResult
    public static func loadAndParseANewWallpaperSet(_ decoded: Set<UserWallpaper>) -> Int {
        var allUserWallpapers = UserWallpaperFileHandler.getAllUserWallpapers()
        let oldWallpapers = allUserWallpapers
        var inserted = 0
        decoded.forEach { currentWallpaper in
            var currentWallpaper = currentWallpaper
            guard currentWallpaper.imageSquared != nil else { return }
            guard currentWallpaper.imageHorizontal != nil else { return }
            if currentWallpaper.name.isEmpty {
                currentWallpaper.name = currentWallpaper.dateString
            }
            allUserWallpapers = allUserWallpapers.filter {
                $0.id != currentWallpaper.id
                    && $0.b64Data4Squared != currentWallpaper.b64Data4Squared
                    && $0.b64Data4Horizontal != currentWallpaper.b64Data4Horizontal
            }
            allUserWallpapers.insert(currentWallpaper)
            inserted += 1
        }
        guard inserted > 0 else { return 0 }
        let entriesToDelete = oldWallpapers.subtracting(allUserWallpapers)
        let entriesToAdd = allUserWallpapers.subtracting(oldWallpapers)
        entriesToDelete.forEach {
            UserWallpaperFileHandler.removeWallpaper(uuid: $0.id)
        }
        UserWallpaperFileHandler.saveUserWallpapersToDisk(entriesToAdd)
        defer {
            Task { @MainActor in
                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
            }
        }
        return inserted
    }
}

#endif
