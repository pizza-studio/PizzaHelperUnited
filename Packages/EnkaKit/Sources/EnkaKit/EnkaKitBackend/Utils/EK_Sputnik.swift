// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Defaults
import EnkaDBModels
import Foundation
import Observation
import PZBaseKit

// MARK: - Enka.Sputnik

// 注意：针对展柜的查询 API 并未放在该档案内，而是针对 EnkaDBProtocol 直接实作了。

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    @Observable
    public final class Sputnik: @unchecked Sendable {
        // MARK: Lifecycle

        private init() {
            /// Both db4GI and db4HSR are `@ObservationTracked` by the `@Observable` macro
            /// applied to this class, hence no worries.
            Task {
                for await newDB in Defaults.updates(.enkaDBData4GI) {
                    await self.db4GI.update(new: newDB)
                }
            }
            Task {
                for await newDB in Defaults.updates(.enkaDBData4HSR) {
                    await self.db4HSR.update(new: newDB)
                }
            }
            Task {
                for await _ in Defaults.updates(.artifactRatingRules) {
                    self.tellViewsToResummarizeEnkaProfiles() // 选项有变更时，给圣遗物重新评分。
                }
            }
            Task {
                for await _ in Defaults.updates(.useRealCharacterNames) {
                    self.tellViewsToResummarizeEnkaProfiles()
                }
            }
            Task {
                for await _ in Defaults.updates(.forceCharacterWeaponNameFixed) {
                    self.tellViewsToResummarizeEnkaProfiles()
                }
            }
            Task {
                for await _ in Defaults.updates(.customizedNameForWanderer) {
                    self.tellViewsToResummarizeEnkaProfiles()
                }
            }
        }

        // MARK: Public

        public static let shared = Sputnik()
        public static let commonActor = DBActor()

        public private(set) var db4GI: Enka.EnkaDB4GI = Defaults[.enkaDBData4GI]
        public private(set) var db4HSR: Enka.EnkaDB4HSR = Defaults[.enkaDBData4HSR]
        public private(set) var eventForResummarizingEnkaProfiles: UUID = .init()
        public private(set) var eventForResummarizingHoYoLABProfiles: UUID = .init()

        public func tellViewsToResummarizeEnkaProfiles() {
            Task { @MainActor in
                eventForResummarizingEnkaProfiles = .init()
            }
        }

        public func tellViewsToResummarizeHoYoLABProfiles() {
            Task { @MainActor in
                eventForResummarizingHoYoLABProfiles = .init()
            }
        }
    }
}

// MARK: - Enka.Sputnik.DBActor

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.Sputnik {
    public actor DBActor {
        // MARK: Public

        public func queryAndSave(uid: String, game: Enka.GameType) async throws {
            try await sharedSputnik.queryAndSave(uid: uid, game: game)
        }

        // MARK: Private

        private let sharedSputnik = Enka.Sputnik.shared
    }
}

// MARK: - EnkaDB Getters.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.Sputnik {
    @MainActor
    @discardableResult
    public static func getEnkaDB4GI() async throws -> Enka.EnkaDB4GI {
        try await Self.shared.db4GI.onlineUpdate()
    }

    @MainActor
    @discardableResult
    public static func getEnkaDB4HSR() async throws -> Enka.EnkaDB4HSR {
        try await Self.shared.db4HSR.onlineUpdate()
    }

    /// 从 EnkaNetwork 获取具体单笔 EnkaDB 子类型资料
    /// - Parameters:
    ///     - completion: 资料
    static func fetchEnkaDBData<T: AbleToCodeSendHash>(
        from serverType: Enka.HostType = .enkaGlobal,
        type dataType: Enka.JSONType,
        decodingTo: T.Type
    ) async throws
        -> T {
        var urlFinal4Debug: URL?
        var urlFinalDebugStrLine: String {
            "SOURCE URL: \(urlFinal4Debug?.absoluteString ?? "------")"
        }
        do {
            let url = serverType.enkaDBSourceURL(type: dataType)
            urlFinal4Debug = url
            return try await AF.request(url, method: .get).serializingDecodable(T.self).value
        } catch {
            print(error)
            print(error.localizedDescription)
            print(urlFinalDebugStrLine)
            print("// [Enka.Sputnik.fetchEnkaDBData] Attempting to use alternative JSON server source.")
            do {
                let url2 = serverType.viceVersa.enkaDBSourceURL(type: dataType)
                urlFinal4Debug = url2
                let objParsed = try await AF.request(url2, method: .get).serializingDecodable(T.self).value
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                var successMsg = "// [Enka.Sputnik.fetchEnkaDBData] 2nd attempt succeeded."
                successMsg += " Will use this JSON server source from now on."
                print(successMsg)
                Enka.HostType.toggleEnkaDBQueryHost()
                return objParsed
            } catch {
                print("// [Enka.Sputnik.fetchEnkaDBData] Final attempt failed:")
                print(error)
                print(error.localizedDescription)
                print(urlFinalDebugStrLine)
                throw error
            }
        }
    }
}

// MARK: - Fetching Enka Query Profile.

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.Sputnik {
    public func queryAndSave(uid: String, game: Enka.GameType) async throws {
        switch game {
        case .genshinImpact: try await Enka.QueriedResultGI.queryProfile(uid: uid).saveToCache()
        case .starRail: try await Enka.QueriedResultHSR.queryProfile(uid: uid).saveToCache()
        case .zenlessZone: break // 临时设定。
        }
    }

    /// 从 Enka Networks 获取游戏内玩家展柜资讯的原始查询结果。
    /// - Parameters:
    ///     - uid: 用户UID
    ///     - completion: 资料
    static func fetchEnkaQueryResultRAW<T: EKQueryResultProtocol>(
        _ uid: String,
        type: T.Type,
        dateWhenNextRefreshable: Date? = nil
    ) async throws
        -> (result: T, profile: T.QueriedProfileType) {
        if let date = dateWhenNextRefreshable, date > Date() {
            print("PLAYER DETAIL FETCH 刷新太快了，请在\(date.coolingDownTimeRemaining)秒后刷新")
            throw Enka.EKError.queryTooFrequent(dateWhenRefreshable: date)
        }
        var server: Enka.HostType = Defaults[.defaultDBQueryHost]
        do {
            return try await Self.fetchEnkaQueryResultRAWPerServer(uid, type: type, server: server)
        } catch {
            print(error.localizedDescription)
            print(
                "// [Enka.Sputnik.fetchEnkaQueryResultRAW] Attempt using alternative profile query server source."
            )
            server = server.viceVersa
            do {
                let result = try await Self.fetchEnkaQueryResultRAWPerServer(uid, type: type, server: server)
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                Defaults[.defaultDBQueryHost] = server
                return result
            } catch {
                print("// [Enka.Sputnik.fetchEnkaQueryResultRAW] Final attempt failed:")
                print(error.localizedDescription)
                throw error
            }
        }
    }

    private static func fetchEnkaQueryResultRAWPerServer<T: EKQueryResultProtocol>(
        _ uid: String,
        type: T.Type,
        server: Enka.HostType
    ) async throws
        -> (result: T, profile: T.QueriedProfileType) {
        do {
            let requestURL = server.enkaProfileQueryURL(uid: uid, game: T.game)
            var resultObj = try await AF.request(
                requestURL, method: .get
            ).serializingDecodable(T.self).value
            // MicroGG Genshin Results might have lack of the UID.
            if T.game == .genshinImpact, resultObj.uid == nil {
                resultObj.uid = uid
            }
            guard let detailInfo = resultObj.detailInfo else {
                let errMsgCore = resultObj.message ?? "No Error Message is Given."
                throw Enka.EKError.queryFailure(uid: uid, game: T.game, message: errMsgCore)
            }
            return (resultObj, detailInfo)
        } catch {
            print(
                "// DEBUG: [Enka.Sputnik.fetchEnkaQueryResultRAW] Profile Query / Parse Failed from \(server.textTag). UID: \(uid) ."
            )
            print(error.localizedDescription)
            throw error
        }
    }
}
