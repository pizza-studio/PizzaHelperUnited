// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import ArtifactRatingDB
import Combine
@preconcurrency import Defaults
import Foundation
import Observation
import PZBaseKit

// MARK: - ArtifactRating.ARSputnik

extension ArtifactRating {
    @Observable @MainActor
    public final class ARSputnik: ObservableObject {
        // MARK: Lifecycle

        private init() {
            /// Both db4GI and db4HSR are `@ObservationTracked` by the `@Observable` macro
            /// applied to this class, hence no worries.
            Defaults.publisher(.artifactRatingDB)
                .sink { newDB in
                    self.arDB = newDB.newValue
                }.store(in: &cancellables)
            Defaults.publisher(.artifactCountDB4GI).sink { newDB in
                self.countDB4GI = newDB.newValue
            }.store(in: &cancellables)
        }

        // MARK: Public

        public static let shared = ARSputnik()

        public var arDB: ArtifactRating.ModelDB = Defaults[.artifactRatingDB]
        public var countDB4GI: [String: Enka.PropertyType] = Defaults[.artifactCountDB4GI]

        // MARK: Private

        @ObservationIgnored private var cancellables: Set<AnyCancellable> = []
    }
}

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

    static func fetchARDBData<T: Codable>(
        from serverType: Enka.HostType? = nil,
        type dataType: RemoteSourceFile,
        decodingTo: T.Type
    ) async throws
        -> T {
        let serverType = serverType ?? Defaults[.defaultDBQueryHost]
        var dataToParse = Data([])
        do {
            let (data, _) = try await URLSession.shared.data(
                for: URLRequest(url: serverType.getRemoteARDBFileURL(type: dataType))
            )
            dataToParse = data
        } catch {
            print(error.localizedDescription)
            print("// [ARDBSputnik.fetchARDBData] Attempting to use alternative JSON server source.")
            do {
                let (data, _) = try await URLSession.shared.data(
                    for: URLRequest(url: serverType.viceVersa.getRemoteARDBFileURL(type: dataType))
                )
                dataToParse = data
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                var successMsg = "// [ARDBSputnik.fetchARDBData] 2nd attempt succeeded."
                successMsg += " Will use this JSON server source from now on."
                print(successMsg)
                Enka.HostType.toggleEnkaDBQueryHost()
            } catch {
                print("// [ARDBSputnik.fetchARDBData] Final attempt failed:")
                print(error)
                print(error.localizedDescription)
                throw error
            }
        }
        do {
            let requestResult = try JSONDecoder().decode(T.self, from: dataToParse)
            return requestResult
        } catch {
            if dataToParse.isEmpty {
                print("// DEBUG: [ARDBSputnik.fetchARDBData] Data Fetch Failed: \(dataType.rawValue).json")
            } else {
                print("// DEBUG: [ARDBSputnik.fetchARDBData] Data Parse Failed: \(dataType.rawValue).json")
            }
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
}

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
