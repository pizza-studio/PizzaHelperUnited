// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CryptoKit
import Foundation
import GachaMetaDB
import PZBaseKit
import SQLite3
import SwiftUI
import UniformTypeIdentifiers

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

    /// Represents a gacha archive (UID) from Snap.Hutao
    public struct GachaArchive: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(innerId: String, uid: String, isSelected: Bool = false) {
            self.innerId = innerId
            self.uid = uid
            self.isSelected = isSelected
        }

        // MARK: Public

        public let innerId: String
        public let uid: String
        public let isSelected: Bool
    }

    /// Represents a gacha item from Snap.Hutao
    public struct GachaItem: Codable, Hashable, Sendable {
        // MARK: Lifecycle

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

        // MARK: Public

        public let innerId: String
        public let archiveId: String
        public let gachaType: String
        public let queryType: String
        public let itemId: UInt32
        public let time: String // ISO 8601 format
        public let id: Int64
    }

    public var gachaArchives: [GachaArchive]
    public var gachaItems: [GachaItem]

    /// Read Hutao refugee file from a SQLite database URL
    public static func fromDatabase(url: URL) throws -> HutaoRefugeeFile {
        let fileManager = FileManager.default

        let tempWorkingDirectory: URL = {
            if let hashedURL = try? stagingDirectory(forOriginalURL: url) {
                return hashedURL
            }
            return fileManager.temporaryDirectory
                .appendingPathComponent("hutao-import-\(UUID().uuidString)", isDirectory: true)
        }()

        if fileManager.fileExists(atPath: tempWorkingDirectory.path) {
            try fileManager.removeItem(at: tempWorkingDirectory)
        }
        try fileManager.createDirectory(at: tempWorkingDirectory, withIntermediateDirectories: true)
        defer { try? fileManager.removeItem(at: tempWorkingDirectory) }

        // Copy primary database file to the sandbox-safe workspace.
        let tempDBURL = tempWorkingDirectory.appendingPathComponent(url.lastPathComponent)
        try fileManager.copyItem(at: url, to: tempDBURL)

        // Preserve sidecar files if the original database uses WAL/SHM so SQLite can read them without
        // touching the user-selected location (macCatalyst sandbox blocks creating them in-place).
        try copySidecarIfPresent(suffix: "-wal", from: url, to: tempDBURL)
        try copySidecarIfPresent(suffix: "-shm", from: url, to: tempDBURL)

        var db: OpaquePointer?
        var gachaArchives: [GachaArchive] = []
        var gachaItems: [GachaItem] = []

        // Allow SQLite to create transient WAL files within our sandbox copy.
        let sqliteFlags = SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX | SQLITE_OPEN_PRIVATECACHE
        guard sqlite3_open_v2(tempDBURL.path, &db, sqliteFlags, nil) == SQLITE_OK else {
            sqlite3_close(db)
            throw HutaoRefugeeError.databaseOpenFailed
        }
        defer { sqlite3_close(db) }

        // Keep the connection read-only from a SQL perspective while still permitting journaling files.
        sqlite3_exec(db, "PRAGMA query_only = ON;", nil, nil, nil)

        // Read gacha_archives table
        let archiveQuery = "SELECT InnerId, Uid, IsSelected FROM gacha_archives"
        var archiveStmt: OpaquePointer?

        if sqlite3_prepare_v2(db, archiveQuery, -1, &archiveStmt, nil) == SQLITE_OK {
            while sqlite3_step(archiveStmt) == SQLITE_ROW {
                guard let innerIdPtr = sqlite3_column_text(archiveStmt, 0),
                      let uidPtr = sqlite3_column_text(archiveStmt, 1) else {
                    continue
                }
                let innerId = String(cString: innerIdPtr)
                let uid = String(cString: uidPtr)
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
                guard let innerIdPtr = sqlite3_column_text(itemStmt, 0),
                      let archiveIdPtr = sqlite3_column_text(itemStmt, 1),
                      let timeTextPtr = sqlite3_column_text(itemStmt, 5) else {
                    continue
                }
                let innerId = String(cString: innerIdPtr)
                let archiveId = String(cString: archiveIdPtr)
                let gachaType = Int(sqlite3_column_int(itemStmt, 2))
                let queryType = Int(sqlite3_column_int(itemStmt, 3))
                let itemId = UInt32(sqlite3_column_int(itemStmt, 4))
                let timeText = String(cString: timeTextPtr)
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
}

// MARK: - Private helpers

extension HutaoRefugeeFile {
    private static func stagingDirectory(forOriginalURL url: URL) throws -> URL {
        let fileManager = FileManager.default
        let hash = try sha256Hex(of: url)
        return fileManager.temporaryDirectory.appendingPathComponent("hutao-import-\(hash)", isDirectory: true)
    }

    private static func sha256Hex(of url: URL) throws -> String {
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }

        var hasher = SHA256()
        while autoreleasepool(invoking: {
            let chunk = fileHandle.readData(ofLength: 1_048_576)
            if !chunk.isEmpty {
                hasher.update(data: chunk)
                return true
            }
            return false
        }) {}

        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    private static func copySidecarIfPresent(suffix: String, from originalURL: URL, to tempURL: URL) throws {
        let fileManager = FileManager.default
        let sourcePath = originalURL.path + suffix
        let destinationURL = URL(fileURLWithPath: tempURL.path + suffix)
        guard fileManager.fileExists(atPath: sourcePath) else { return }

        let sourceURL = URL(fileURLWithPath: sourcePath)
        if fileManager.fileExists(atPath: destinationURL.path) {
            try fileManager.removeItem(at: destinationURL)
        }
        try fileManager.copyItem(at: sourceURL, to: destinationURL)
    }
}

// MARK: - HutaoRefugeeDocument

@available(iOS 17.0, macCatalyst 17.0, *)
public struct HutaoRefugeeDocument: FileDocument {
    // MARK: Lifecycle

    public init(configuration: ReadConfiguration) throws {
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
    private static let timeZoneOffsetRegex: NSRegularExpression = {
        // Matches trailing timezone like +08:00 or -05:30.
        let pattern = "([+-])(\\d{2}):(\\d{2})$"
        // pattern is constant; crash loudly if it ever fails to compile in development.
        return try! NSRegularExpression(pattern: pattern, options: [])
    }()

    /// Convert Hutao refugee data to UIGFv4 format
    public func toUIGFv4() async throws -> UIGFv4 {
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
            var gachaItemsGI: [UIGFv4.GachaItemGI] = []
            for item in items {
                // Parse time - Snap.Hutao stores UTC time as ISO 8601
                let timeFormatted = formatTime(item.time, uid: archive.uid)

                // Map gacha types (queryType in Snap.Hutao corresponds to UIGF gacha type)
                guard let gachaType = mapGachaType(item.queryType) else {
                    continue
                }

                // 此处得用 GachaMetaDB 根据 item.itemId 查询到当前物品 rankType。
                // 至于原神 `gacha_id` 预设用 0 即可。
                // itemName 则由下文的 `gachaItemsGI.updateLanguage()` 负责。

                let itemType = GachaItemType(
                    itemID: String(item.itemId),
                    game: .genshinImpact
                ).getTranslatedRaw(
                    for: .langCHS,
                    game: .genshinImpact
                )

                let rarity = GachaItemRankType(
                    itemID: String(item.itemId),
                    game: .genshinImpact
                ) ?? .rank3

                let result = UIGFv4.GachaItemGI(
                    count: "1",
                    gachaID: "0",
                    gachaType: gachaType,
                    id: String(item.id),
                    itemID: String(item.itemId),
                    itemType: itemType,
                    name: nil,
                    rankType: rarity.rawValue.description,
                    time: timeFormatted
                )

                gachaItemsGI.append(result)
            }

            guard !gachaItemsGI.isEmpty else { continue }

            try gachaItemsGI.updateLanguage(.langCHS)

            // Create profile
            let profile = UIGFv4.ProfileGI(
                lang: .langCHS, // Language will be determined by the system
                list: gachaItemsGI,
                timezone: GachaKit.getServerTimeZoneDelta(
                    uid: archive.uid, game: .genshinImpact
                ),
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
    private func formatTime(_ timeString: String, uid: String) -> String {
        // Snap.Hutao persists `DateTimeOffset` values as SQLite TEXT produced by EF Core, for example
        // "2023-05-07 02:47:00+00:00" or "2023-05-07 02:47:00.123456+08:00" (note the space instead of 'T').
        // The trailing offset (part B) reflects the server timezone at capture time, but some legacy Hutao builds
        // zeroed it out. We therefore prefer the persisted offset when it is non-zero, otherwise fall back to the
        // region inferred from the UID to keep timestamps consistent with the player server.

        let serverOffsetSeconds = GachaKit.getServerTimeZoneDelta(
            uid: uid,
            game: .genshinImpact
        ) * 3600
        let parsedOffsetSeconds = extractTimeZoneOffsetSeconds(timeString)
        let preferredOffsetSeconds = parsedOffsetSeconds.flatMap { $0 != 0 ? $0 : nil } ?? serverOffsetSeconds
        let outputFormatter = DateFormatter.forUIGFEntry(timeZoneDeltaAsSeconds: preferredOffsetSeconds)

        let parser = DateFormatter.GregorianPOSIX()
        parser.timeZone = .init(secondsFromGMT: parsedOffsetSeconds ?? serverOffsetSeconds)

        let candidateFormats = [
            "yyyy-MM-dd HH:mm:ssxxxxx",
            "yyyy-MM-dd HH:mm:ssZZZZZ",
            "yyyy-MM-dd HH:mm:ss.SSSSSSxxxxx",
            "yyyy-MM-dd HH:mm:ss.SSSSSSZZZZZ",
            "yyyy-MM-dd HH:mm:ss.SSSSSSSxxxxx",
            "yyyy-MM-dd HH:mm:ss.SSSSSSSZZZZZ",
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSSXXXXX",
            "yyyy-MM-dd HH:mm:ss",
        ]

        for format in candidateFormats {
            parser.dateFormat = format
            if let date = parser.date(from: timeString) {
                return outputFormatter.string(from: date)
            }
        }

        // Fallback to ISO-8601 parsing just in case unforeseen variants appear
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        }

        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: timeString) {
            return outputFormatter.string(from: date)
        }

        // Fallback: return as-is if parsing fails
        return timeString
    }

    private func extractTimeZoneOffsetSeconds(_ timeString: String) -> Int? {
        if timeString.hasSuffix("Z") { return 0 }
        let range = NSRange(timeString.startIndex ..< timeString.endIndex, in: timeString)
        guard let match = HutaoRefugeeFile.timeZoneOffsetRegex.firstMatch(in: timeString, range: range) else {
            return nil
        }

        let nsString = timeString as NSString
        let signString = nsString.substring(with: match.range(at: 1))
        let hourString = nsString.substring(with: match.range(at: 2))
        let minuteString = nsString.substring(with: match.range(at: 3))

        guard let hours = Int(hourString), let minutes = Int(minuteString) else {
            return nil
        }

        let totalMinutes = hours * 60 + minutes
        let signedMinutes = signString == "-" ? -totalMinutes : totalMinutes
        return signedMinutes * 60
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
