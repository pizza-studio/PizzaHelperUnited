// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

// Author: Shiki Suen

import Foundation
import SwiftUI

// MARK: - OnlineImageFS

@available(iOS 16.2, macCatalyst 16.2, *)
public enum OnlineImageFS {
    /// We assume that this API never fails.
    public static var onlineImageCacheFolderURL: URL {
        let backgroundFolderURL: URL = {
            switch Pizza.isAppStoreRelease {
            case false: break
            case true:
                guard let groupContainerURL else { break }
                return
                    groupContainerURL
                        .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                        .appendingPathComponent("OnlineImageCache", isDirectory: true)
            }
            return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                .appendingPathComponent("OnlineImageCache", isDirectory: true)
        }()

        try? FileManager.default.createDirectory(
            at: backgroundFolderURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return backgroundFolderURL
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension OnlineImageFS {
    public enum OIFSException: Error {
        case fileStemNameEmpty
        case dataEncodingFailure
        case dataWriteFailure(Error)
        case existingDataRemovalFailure(Error)
    }

    public static func makeFileURL(fileNameStem: String, useJPG: Bool) -> URL {
        onlineImageCacheFolderURL.appendingPathComponent(
            "\(fileNameStem).\(useJPG ? "jpg" : "png")",
            isDirectory: false
        )
    }

    public static func getCGImageFromFS(_ fileNameStem: String, useJPG: Bool) -> CGImage? {
        guard !fileNameStem.isEmpty else { return nil }
        let url = makeFileURL(fileNameStem: fileNameStem, useJPG: useJPG)
        return CGImage.instantiate(url: url)
    }

    public static func checkExistence(_ fileNameStem: String, useJPG: Bool) -> Bool {
        guard !fileNameStem.isEmpty else { return false }
        let url = makeFileURL(fileNameStem: fileNameStem, useJPG: useJPG)
        var isDirectory: ObjCBool = true
        let exists = FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
        return exists && !isDirectory.boolValue
    }

    public static func insertCGImageToFSIfMissing(
        _ fileNameStem: String,
        cgImage: CGImage,
        useJPG: Bool
    ) throws(OIFSException) {
        guard !fileNameStem.isEmpty else { throw .fileStemNameEmpty }
        let url = makeFileURL(fileNameStem: fileNameStem, useJPG: useJPG)
        var isDirectory: ObjCBool = true
        let exists = FileManager.default.fileExists(atPath: url.path(), isDirectory: &isDirectory)
        if exists {
            guard isDirectory.boolValue else { return } // 不再写入本地。
            do {
                try FileManager.default.removeItem(at: url)
            } catch {
                throw .existingDataRemovalFailure(error)
            }
        }
        let data = cgImage.encodeToFileData(as: useJPG ? .jpeg(quality: 0.8) : .png)
        guard let data else { throw .dataEncodingFailure }
        do {
            try data.write(to: url, options: .atomic)
        } catch {
            throw .dataWriteFailure(error)
        }
    }
}
