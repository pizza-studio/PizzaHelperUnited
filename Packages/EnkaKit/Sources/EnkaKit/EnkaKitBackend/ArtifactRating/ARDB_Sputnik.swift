// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import ArtifactRatingDB
import Foundation
import Observation
import PZBaseKit

// MARK: - ArtifactRating.ARSputnik

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating {
    @Observable
    public final class ARSputnik: Sendable {
        // MARK: Lifecycle

        private init() {
            // Cleanup old UserDefaults keys that have been moved to filesystem
            UserDefaults.enkaSuite.removeObject(forKey: "artifactRatingDB")
            UserDefaults.enkaSuite.removeObject(forKey: "artifactCountDB4GI")
            Task {
                do {
                    await self.artifactRatingDBMonitor.saveData()
                    await self.artifactCountDBMonitor4GI.saveData()
                    try await self.artifactRatingDBMonitor.startMonitoring()
                    try await self.artifactCountDBMonitor4GI.startMonitoring()
                } catch {
                    print("[ArtifactRating.ARSputnik] Init error: \(error)")
                }
            }
        }

        // MARK: Public

        public static let shared = ARSputnik()

        public fileprivate(set) var arDB: ArtifactRating.ModelDB {
            get { artifactRatingDBMonitor.data }
            set {
                artifactRatingDBMonitor.data = newValue
                Enka.Sputnik.shared.tellViewsToResummarizeEnkaProfiles()
                Enka.Sputnik.shared.tellViewsToResummarizeHoYoLABProfiles()
            }
        }

        public fileprivate(set) var countDB4GI: [String: Enka.PropertyType] {
            get { artifactCountDBMonitor4GI.data }
            set {
                artifactCountDBMonitor4GI.data = newValue
                Enka.Sputnik.shared.tellViewsToResummarizeEnkaProfiles()
                Enka.Sputnik.shared.tellViewsToResummarizeHoYoLABProfiles()
            }
        }

        // MARK: Private

        /// Artifact rating database stored in filesystem instead of UserDefaults
        private let artifactRatingDBMonitor = PlistCodableFileMonitor(
            fileURL: FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]
                .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                .appending(component: "ARDBCache")
                .appending(component: "artifactRatingDB.plist"),
            defaultValue: ArtifactRating.ModelDB.makeBundledDB()
        )

        /// Artifact count database for Genshin Impact stored in filesystem instead of UserDefaults
        private let artifactCountDBMonitor4GI = PlistCodableFileMonitor(
            fileURL: FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            )[0]
                .appendingPathComponent(sharedBundleIDHeader, isDirectory: true)
                .appending(component: "ARDBCache")
                .appending(component: "artifactCountDB4GI.plist"),
            defaultValue: ArtifactRating.initBundledCountDB()
        )
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating.ARSputnik {
    public func resetFactoryScoreModel() {
        arDB = ArtifactRating.ModelDB.makeBundledDB()
    }

    @MainActor
    public func onlineUpdate() async throws {
        var newDB = try await Self.fetchARDBData(type: .arDB4GI, decodingTo: ArtifactRating.ModelDB.self)
        let hsrDB = try await Self.fetchARDBData(type: .arDB4HSR, decodingTo: ArtifactRating.ModelDB.self)
        hsrDB.forEach { key, value in
            newDB[key] = value
        }
        arDB = newDB
        countDB4GI = try await Self.fetchARDBData(type: .countDB4GI, decodingTo: [String: Enka.PropertyType].self)
    }

    func calculateCounts4GI(
        against appendPropIdList: [Int]
    )
        -> [Enka.PropertyType: Int] {
        ArtifactRating.calculateCounts(against: appendPropIdList, using: countDB4GI) {
            Task { @MainActor in
                try? await self.onlineUpdate()
            }
        }
    }

    enum RemoteSourceFile: String {
        case arDB4GI = "ARDB4GI.json"
        case arDB4HSR = "ARDB4HSR.json"
        case countDB4GI = "CountDB4GI.json"
    }

    static func fetchARDBData<T: AbleToCodeSendHash>(
        from serverType: Enka.HostType? = nil,
        type dataType: RemoteSourceFile,
        decodingTo: T.Type
    ) async throws
        -> T {
        let serverType = serverType ?? Defaults[.defaultDBQueryHost]
        let debugMsg = "// DEBUG: [ARDBSputnik.fetchARDBData] Data Fetch / Parse Failed: \(dataType.rawValue).json"
        do {
            let requestURL = serverType.getRemoteARDBFileURL(type: dataType)
            return try await AF.request(requestURL).serializingDecodable(T.self).value
        } catch {
            print(debugMsg)
            print(error)
            print(error.localizedDescription)
            print("// [ARDBSputnik.fetchARDBData] Attempting to use alternative JSON server source.")
            do {
                let requestURL = serverType.viceVersa.getRemoteARDBFileURL(type: dataType)
                let resultObj = try await AF.request(requestURL).serializingDecodable(T.self).value
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                var successMsg = "// [ARDBSputnik.fetchARDBData] 2nd attempt succeeded."
                successMsg += " Will use this JSON server source from now on."
                print(successMsg)
                Enka.HostType.toggleEnkaDBQueryHost()
                return resultObj
            } catch {
                print("// [ARDBSputnik.fetchARDBData] Final attempt failed:")
                print(debugMsg)
                print(error)
                print(error.localizedDescription)
                throw error
            }
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.HostType {
    fileprivate func getRemoteARDBFileURL(type: ArtifactRating.ARSputnik.RemoteSourceFile) -> URL {
        let baseStr = arDBSourceURLPrefix + type.rawValue
        return baseStr.asURL
    }

    fileprivate var arDBSourceURLPrefix: String {
        let prefix =
            switch self {
            case .mainlandChina: "https://raw.gitcode.com/SHIKISUEN/ArtifactRatingDB/raw/main/"
            case .enkaGlobal: "https://raw.githubusercontent.com/pizza-studio/ArtifactRatingDB/main/"
            }
        return prefix + "Sources/ArtifactRatingDB/Resources/"
    }
}
