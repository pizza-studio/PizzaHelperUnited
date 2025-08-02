// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Alamofire
import ArtifactRatingDB
import Defaults
import Foundation
import Observation
import PZBaseKit

// MARK: - ArtifactRating.ARSputnik

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating {
    @Observable @MainActor
    public final class ARSputnik {
        // MARK: Lifecycle

        private init() {
            /// Both db4GI and db4HSR are `@ObservationTracked` by the `@Observable` macro
            /// applied to this class, hence no worries.
            Task {
                for await newDB in Defaults.updates(.artifactRatingDB) {
                    self.arDB = newDB
                }
            }
            Task {
                for await newDB in Defaults.updates(.artifactCountDB4GI) {
                    self.countDB4GI = newDB
                }
            }
        }

        // MARK: Public

        public static let shared = ARSputnik()

        public var arDB: ArtifactRating.ModelDB = Defaults[.artifactRatingDB]
        public var countDB4GI: [String: Enka.PropertyType] = Defaults[.artifactCountDB4GI]
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension ArtifactRating.ARSputnik {
    public func resetFactoryScoreModel() {
        Defaults.reset(.artifactRatingDB)
    }

    @MainActor
    public func onlineUpdate() async throws {
        var newDB = try await Self.fetchARDBData(type: .arDB4GI, decodingTo: ArtifactRating.ModelDB.self)
        let hsrDB = try await Self.fetchARDBData(type: .arDB4HSR, decodingTo: ArtifactRating.ModelDB.self)
        hsrDB.forEach { key, value in
            newDB[key] = value
        }
        arDB = newDB
        Defaults[.artifactRatingDB] = newDB
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
        let prefix = switch self {
        case .mainlandChina: "https://raw.gitcode.com/SHIKISUEN/ArtifactRatingDB/raw/main/"
        case .enkaGlobal: "https://raw.githubusercontent.com/pizza-studio/ArtifactRatingDB/main/"
        }
        return prefix + "Sources/ArtifactRatingDB/Resources/"
    }
}
