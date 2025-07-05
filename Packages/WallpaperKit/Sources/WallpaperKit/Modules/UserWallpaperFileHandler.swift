// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit

// MARK: - UserWallpaperFileHandler

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
public enum UserWallpaperFileHandler {}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, watchOS 10.0, *)
extension UserWallpaperFileHandler {
    /// 如果已经迁移过的话，这个函式不会有任何作用。
    public static func migrateUserWallpapersFromUserDefaultsToFiles() {
        UserDefaults.baseSuite.removeObject(forKey: "backgrounds4LiveActivity")
        UserDefaults.baseSuite.removeObject(forKey: "background4App")
        UserDefaults.baseSuite.removeObject(forKey: "userWallpapers4LiveActivity")
        UserDefaults.baseSuite.removeObject(forKey: "userWallpaper4App")
        let userWallpapersLeft = Defaults[.userWallpapers]
        guard !userWallpapersLeft.isEmpty else { return }
        var results = Set<Bool>()
        userWallpapersLeft.forEach {
            results.insert(saveUserWallpaperToDisk($0, broadcastNotificationChanges: false))
        }
        if results == [true] {
            Defaults.reset(.userWallpapers)
            Task { @MainActor in
                Broadcaster.shared.userWallpaperEntryChangesDidSave()
            }
        }
        Task { @MainActor in
            Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
        }
    }

    public static func getAllUserWallpapers() -> Set<UserWallpaper> {
        var result = Set<UserWallpaper>()
        let resourceKeys = [URLResourceKey]([.nameKey, .isRegularFileKey])
        let directoryEnumerator = FileManager.default.enumerator(
            at: userWallpaperFolderURL,
            includingPropertiesForKeys: resourceKeys,
            options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants]
        )
        guard let directoryEnumerator else { return result }
        for case let fileURL as URL in directoryEnumerator {
            let resourceValues = try? fileURL.resourceValues(forKeys: Set(resourceKeys))
            guard let isFile = resourceValues?.isRegularFile, isFile else { continue }
            guard let fileName = resourceValues?.name else { continue }
            let fileNameStem = fileName.split(separator: ".").prefix(1).joined()
            guard let fileNameUUID = UUID(uuidString: fileNameStem) else { continue }
            // Read file into the set.
            guard let userWallpaper = getUserWallpaper(uuid: fileNameUUID) else { continue }
            result.insert(userWallpaper)
        }
        return result
    }

    public static func removeWallpapers(uuids: Set<UUID>) {
        uuids.forEach {
            removeWallpaper(uuid: $0, broadcastChanges: false)
        }
        Task { @MainActor in
            Broadcaster.shared.userWallpaperEntryChangesDidSave()
        }
    }

    public static func removeWallpaper(uuid: UUID, broadcastChanges: Bool = true) {
        let fileURL = getURL4UserWallpaper(uuid: uuid)
        do {
            try FileManager.default.removeItem(at: fileURL)
            if broadcastChanges {
                Task { @MainActor in
                    Broadcaster.shared.userWallpaperEntryChangesDidSave()
                }
            }
        } catch {
            print(error)
            print("[FAILURE] Unable to remove user wallpaper at: \(fileURL)")
        }
    }

    public static func saveUserWallpapersToDisk(_ userWallpaper: Set<UserWallpaper>) {
        var results = Set<Bool>()
        userWallpaper.forEach {
            results.insert(saveUserWallpaperToDisk($0, broadcastNotificationChanges: false))
        }
        if results == [true] {
            Task { @MainActor in
                Broadcaster.shared.userWallpaperEntryChangesDidSave()
            }
        }
    }

    @discardableResult
    public static func saveUserWallpaperToDisk(
        _ userWallpaper: UserWallpaper,
        broadcastNotificationChanges: Bool = true
    )
        -> Bool {
        let encodedData = try? JSONEncoder().encode(userWallpaper)
        guard let encodedData else { return false }
        do {
            try encodedData.write(
                to: getURL4UserWallpaper(uuid: userWallpaper.id),
                options: .atomic
            )
            if broadcastNotificationChanges {
                Task { @MainActor in
                    Broadcaster.shared.userWallpaperEntryChangesDidSave()
                }
            }
            return true
        } catch {
            return false
        }
    }

    public static func getUserWallpaper(uuid: UUID) -> UserWallpaper? {
        let fileData = try? Data(contentsOf: getURL4UserWallpaper(uuid: uuid))
        guard let fileData else { return nil }
        let parsed = try? fileData.parseAs(UserWallpaper.self)
        guard let parsed, parsed.id == uuid else { return nil }
        return parsed
    }

    /// We assume that this API never fails.
    private static var userWallpaperFolderURL: URL {
        let backgroundFolderURL: URL = {
            switch Pizza.isAppStoreRelease {
            case false: break
            case true:
                guard let groupContainerURL else { break }
                return groupContainerURL
                    .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                    .appendingPathComponent("UserWallpapers", isDirectory: true)
            }
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                .appendingPathComponent("UserWallpapers", isDirectory: true)
        }()

        try? FileManager.default.createDirectory(
            at: backgroundFolderURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderURL
    }

    private static func getURL4UserWallpaper(uuid: UUID) -> URL {
        userWallpaperFolderURL.appendingPathComponent(
            "\(uuid.uuidString).json", isDirectory: false
        )
    }
}
