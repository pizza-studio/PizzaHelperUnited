// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI
import UniformTypeIdentifiers

#if canImport(SQLite3)
import SQLite3
#endif

// MARK: - HutaoRefugeeFile

/// Represents data imported from Snap.Hutao's SQLite database
public struct HutaoRefugeeFile: Codable, Hashable, Sendable {
    // MARK: Lifecycle

    public init(
        gachaArchives: [GachaArchive] = [],
        gachaItems: [GachaItem] = []
    ) {
        self.gachaArchives = gachaArchives
        self.gachaItems = gachaItems
    }

    // MARK: Public

    public var gachaArchives: [GachaArchive]
    public var gachaItems: [GachaItem]

    #if canImport(SQLite3)
    /// Read Hutao refugee file from a SQLite database URL
    public static func fromDatabase(url: URL) throws -> HutaoRefugeeFile {
        var db: OpaquePointer?
        var gachaArchives: [GachaArchive] = []
        var gachaItems: [GachaItem] = []

        // Open database
        guard sqlite3_open(url.path, &db) == SQLITE_OK else {
            sqlite3_close(db)
            throw HutaoRefugeeError.databaseOpenFailed
        }
        defer { sqlite3_close(db) }

        // Read gacha_archives table
        let archiveQuery = "SELECT InnerId, Uid, IsSelected FROM gacha_archives"
        var archiveStmt: OpaquePointer?

        if sqlite3_prepare_v2(db, archiveQuery, -1, &archiveStmt, nil) == SQLITE_OK {
            while sqlite3_step(archiveStmt) == SQLITE_ROW {
                let innerId = String(cString: sqlite3_column_text(archiveStmt, 0))
                let uid = String(cString: sqlite3_column_text(archiveStmt, 1))
                let isSelected = sqlite3_column_int(archiveStmt, 2) != 0

                gachaArchives.append(.init(
                    innerId: innerId,
                    uid: uid,
                    isSelected: isSelected
                ))
            }
        }
        sqlite3_finalize(archiveStmt)

        // Read gacha_items table
        let itemQuery = """
            SELECT InnerId, ArchiveId, GachaType, QueryType, ItemId, Time, Id
            FROM gacha_items
            ORDER BY Id
            """
        var itemStmt: OpaquePointer?

        if sqlite3_prepare_v2(db, itemQuery, -1, &itemStmt, nil) == SQLITE_OK {
            while sqlite3_step(itemStmt) == SQLITE_ROW {
                let innerId = String(cString: sqlite3_column_text(itemStmt, 0))
                let archiveId = String(cString: sqlite3_column_text(itemStmt, 1))
                let gachaType = Int(sqlite3_column_int(itemStmt, 2))
                let queryType = Int(sqlite3_column_int(itemStmt, 3))
                let itemId = UInt32(sqlite3_column_int(itemStmt, 4))
                let timeText = String(cString: sqlite3_column_text(itemStmt, 5))
                let id = sqlite3_column_int64(itemStmt, 6)

                gachaItems.append(.init(
                    innerId: innerId,
                    archiveId: archiveId,
                    gachaType: String(gachaType),
                    queryType: String(queryType),
                    itemId: itemId,
                    time: timeText,
                    id: id
                ))
            }
        }
        sqlite3_finalize(itemStmt)

        return HutaoRefugeeFile(gachaArchives: gachaArchives, gachaItems: gachaItems)
    }
    #endif

    // MARK: - Nested Types

    /// Represents a gacha archive (UID) from Snap.Hutao
    public struct GachaArchive: Codable, Hashable, Sendable {
        public let innerId: String
        public let uid: String
        public let isSelected: Bool

        public init(innerId: String, uid: String, isSelected: Bool = false) {
            self.innerId = innerId
            self.uid = uid
            self.isSelected = isSelected
        }
    }

    /// Represents a gacha item from Snap.Hutao
    public struct GachaItem: Codable, Hashable, Sendable {
        public let innerId: String
        public let archiveId: String
        public let gachaType: String
        public let queryType: String
        public let itemId: UInt32
        public let time: String // ISO 8601 format
        public let id: Int64

        public init(
            innerId: String,
            archiveId: String,
            gachaType: String,
            queryType: String,
            itemId: UInt32,
            time: String,
            id: Int64
        ) {
            self.innerId = innerId
            self.archiveId = archiveId
            self.gachaType = gachaType
            self.queryType = queryType
            self.itemId = itemId
            self.time = time
            self.id = id
        }
    }
}

// MARK: - HutaoRefugeeDocument

@available(iOS 17.0, macCatalyst 17.0, *)
public struct HutaoRefugeeDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
        #if canImport(SQLite3)
        guard let data = configuration.file.regularFileContents else {
            throw HutaoRefugeeError.invalidFile
        }

        // Write data to temporary file for SQLite to read
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("db")
        try data.write(to: tempURL)
        defer {
            try? FileManager.default.removeItem(at: tempURL)
        }

        // Read from SQLite database
        self.model = try HutaoRefugeeFile.fromDatabase(url: tempURL)
        #else
        throw HutaoRefugeeError.sqliteNotAvailable
        #endif
    }

    public init(file: HutaoRefugeeFile) {
        self.model = file
    }

    // MARK: Public

    public static var readableContentTypes: [UTType] {
        // SQLite database files
        if let sqliteType = UTType(filenameExtension: "db") {
            return [sqliteType]
        }
        return []
    }

    public let model: HutaoRefugeeFile

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // Writing is not supported for this document type
        throw HutaoRefugeeError.writingNotSupported
    }
}

// MARK: - HutaoRefugeeError

public enum HutaoRefugeeError: Error, LocalizedError {
    case invalidFile
    case databaseOpenFailed
    case sqliteNotAvailable
    case writingNotSupported
    case conversionFailed(String)

    // MARK: Public

    public var errorDescription: String? {
        switch self {
        case .invalidFile:
            return "Invalid Snap.Hutao database file"
        case .databaseOpenFailed:
            return "Failed to open Snap.Hutao database"
        case .sqliteNotAvailable:
            return "SQLite is not available on this platform"
        case .writingNotSupported:
            return "Writing Hutao refugee files is not supported"
        case let .conversionFailed(reason):
            return "Failed to convert data: \(reason)"
        }
    }
}

// MARK: - Conversion to UIGFv4

@available(iOS 17.0, macCatalyst 17.0, *)
extension HutaoRefugeeFile {
    /// Convert Hutao refugee data to UIGFv4 format
    public func toUIGFv4() throws -> UIGFv4 {
        // Group items by archive
        var itemsByArchive: [String: [GachaItem]] = [:]
        for item in gachaItems {
            itemsByArchive[item.archiveId, default: []].append(item)
        }

        // Convert each archive to a UIGFv4 profile
        var giProfiles: [UIGFv4.ProfileGI] = []

        for archive in gachaArchives {
            guard let items = itemsByArchive[archive.innerId] else { continue }

            // Convert items to UIGFv4.GachaItemGI
            let gachaItemsGI: [UIGFv4.GachaItemGI] = items.compactMap { item in
                // Parse time - Snap.Hutao stores UTC time as ISO 8601
                let timeFormatted = formatTime(item.time)

                // Map gacha types (queryType in Snap.Hutao corresponds to UIGF gacha type)
                guard let gachaType = mapGachaType(item.queryType) else {
                    return nil
                }

                return UIGFv4.GachaItemGI(
                    count: "1",
                    gachaID: "0",
                    gachaType: gachaType,
                    id: String(item.id),
                    itemID: String(item.itemId),
                    itemType: nil,
                    name: nil,
                    rankType: nil,
                    time: timeFormatted
                )
            }

            guard !gachaItemsGI.isEmpty else { continue }

            // Create profile
            let profile = UIGFv4.ProfileGI(
                lang: nil, // Language will be determined by the system
                list: gachaItemsGI,
                timezone: 0, // Snap.Hutao stores UTC time
                uid: archive.uid
            )
            giProfiles.append(profile)
        }

        // Create UIGFv4 document
        let info = UIGFv4.Info(
            exportApp: "Snap.Hutao",
            exportAppVersion: "N/A",
            exportTimestamp: String(Int(Date().timeIntervalSince1970)),
            version: "v4.1",
            previousFormat: "Snap.Hutao Database"
        )

        return UIGFv4(
            info: info,
            giProfiles: giProfiles.isEmpty ? nil : giProfiles,
            hsrProfiles: nil,
            zzzProfiles: nil
        )
    }

    // MARK: Private

    /// Format time string from Snap.Hutao format to UIGFv4 format
    private func formatTime(_ timeString: String) -> String {
        // Snap.Hutao stores time as UTC ISO 8601 format
        // UIGFv4 expects format: "yyyy-MM-dd HH:mm:ss"

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Try with fractional seconds first
        if let date = isoFormatter.date(from: timeString) {
            let formatter = DateFormatter.forUIGFEntry(timeZoneDelta: 0)
            return formatter.string(from: date)
        }

        // Try without fractional seconds
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: timeString) {
            let formatter = DateFormatter.forUIGFEntry(timeZoneDelta: 0)
            return formatter.string(from: date)
        }

        // Fallback: return as-is if parsing fails
        return timeString
    }

    /// Map Snap.Hutao gacha type to GachaTypeGI
    private func mapGachaType(_ typeString: String) -> GachaTypeGI? {
        // Snap.Hutao uses UIGF gacha types:
        // 100: Novice Wish (Beginner's Wish)
        // 200: Standard Wish
        // 301: Character Event Wish
        // 302: Weapon Event Wish
        // 400: Character Event Wish-2 (newer format, treated same as 301)
        // 500: Chronicled Wish

        guard let typeValue = Int(typeString) else { return nil }

        switch typeValue {
        case 100: return .beginnersWish
        case 200: return .standardWish
        case 301, 400: return .characterEventWish1
        case 302: return .weaponEventWish
        case 500: return .chronicledWish
        default: return nil
        }
    }
}
