// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import Observation

// MARK: - ASMetaSputnik

public actor ASMetaSputnik: Sendable {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let shared = ASMetaSputnik()

    @discardableResult
    public func updateMeta() async -> Bool {
        guard Date.now.timeIntervalSince1970 - lastTimeCheckingUpdates.timeIntervalSince1970 > 60 else { return false }
        guard let url = URL(string: Self.apiURLStr) else { return false }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return false }
        guard let decoded = try? JSONDecoder().decode(ASMetaResult.self, from: data) else { return false }
        guard let meta = decoded.results.first else { return false }
        Defaults[.cachedAppStoreMeta] = meta
        return true
    }

    // MARK: Private

    private static let apiURLStr = "https://itunes.apple.com/lookup?id=1635319193"

    private var lastTimeCheckingUpdates: Date = .distantPast
}

// MARK: - ASMetaResult

public struct ASMetaResult: AbleToCodeSendHash {
    public let resultCount: Int
    public let results: [ASMeta]
}

// MARK: - ASMeta

public struct ASMeta: AbleToCodeSendHash, Defaults.Serializable {
    // MARK: Public

    public let bundleId, releaseDate: String
    public let trackId: Int
    public let currentVersionReleaseDate, releaseNotes, version: String
    public let trackViewUrl: String

    public var isNewerThanCurrentVersion: Bool {
        guard Pizza.isAppStoreRelease else { return false }
        let bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        guard let bundleVersion else { return false }
        return Self.compareVersions(bundleVersion, version) == .orderedAscending
    }

    // MARK: Private

    /// Compares two semantic version strings.
    /// - Parameters:
    ///   - version1: The first version string.
    ///   - version2: The second version string.
    /// - Returns: A `ComparisonResult` indicating the comparison result.
    private static func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        let version1Components = version1.split(separator: ".").compactMap { Int($0) }
        let version2Components = version2.split(separator: ".").compactMap { Int($0) }
        for (v1, v2) in zip(version1Components, version2Components) {
            if v1 < v2 { return .orderedAscending }
            if v1 > v2 { return .orderedDescending }
        }
        if version1Components.count < version2Components.count { return .orderedAscending }
        if version1Components.count > version2Components.count { return .orderedDescending }
        return .orderedSame
    }
}
