// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Defaults
import EnkaDBModels
import Foundation
import Observation

// MARK: - Enka.Sputnik

// 注意：针对展柜的查询 API 并未放在该档案内，而是针对 EnkaDBProtocol 直接实作了。

extension Enka {
    @Observable
    public final class Sputnik {
        // MARK: Lifecycle

        private init() {
            /// Both db4GI and db4HSR are `@ObservationTracked` by the `@Observable` macro
            /// applied to this class, hence no worries.
            Defaults.publisher(.enkaDBData4GI).sink { newDB in
                Task.detached { @MainActor in
                    self.db4GI.update(new: newDB.newValue)
                }
            }.store(in: &cancellables)
            Defaults.publisher(.enkaDBData4HSR).sink { newDB in
                Task.detached { @MainActor in
                    self.db4HSR.update(new: newDB.newValue)
                }
            }.store(in: &cancellables)

            Defaults.publisher(.artifactRatingRules).sink { _ in
                Task.detached { @MainActor in
                    self.tellViewsToResummarizeEnkaProfiles() // 选项有变更时，给圣遗物重新评分。
                }
            }.store(in: &cancellables)
            Defaults.publisher(.useRealCharacterNames).sink { _ in
                Task.detached { @MainActor in
                    self.tellViewsToResummarizeEnkaProfiles()
                }
            }.store(in: &cancellables)
            Defaults.publisher(.forceCharacterWeaponNameFixed).sink { _ in
                Task.detached { @MainActor in
                    self.tellViewsToResummarizeEnkaProfiles()
                }
            }.store(in: &cancellables)
            Defaults.publisher(.customizedNameForWanderer).sink { _ in
                Task.detached { @MainActor in
                    self.tellViewsToResummarizeEnkaProfiles()
                }
            }.store(in: &cancellables)
        }

        // MARK: Public

        public enum EnkaDBResult {
            case genshinImpact(Enka.EnkaDB4GI)
            case starRail(Enka.EnkaDB4HSR)
            case failure(Error)
        }

        public static let shared = Sputnik()

        public fileprivate(set) var db4GI: Enka.EnkaDB4GI = Defaults[.enkaDBData4GI]
        public fileprivate(set) var db4HSR: Enka.EnkaDB4HSR = Defaults[.enkaDBData4HSR]
        public fileprivate(set) var eventForResummarizingEnkaProfiles: UUID = .init()

        public func tellViewsToResummarizeEnkaProfiles() {
            eventForResummarizingEnkaProfiles = .init()
        }

        // MARK: Private

        private var cancellables: Set<AnyCancellable> = []
    }
}

// MARK: - EnkaDB Getters.

extension Enka.Sputnik {
    @MainActor
    public static func getEnkaDB(for game: Enka.GameType) async -> EnkaDBResult {
        do {
            switch game {
            case .genshinImpact: return try await .genshinImpact(getEnkaDB4GI())
            case .starRail: return try await .starRail(getEnkaDB4HSR())
            }
        } catch {
            return .failure(error)
        }
    }

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
    static func fetchEnkaDBData<T: Codable>(
        from serverType: Enka.HostType = .enkaGlobal,
        type dataType: Enka.JSONType,
        decodingTo: T.Type
    ) async throws
        -> T {
        var dataToParse = Data([])
        do {
            let (data, _) = try await URLSession.shared.data(
                for: URLRequest(url: serverType.enkaDBSourceURL(type: dataType))
            )
            dataToParse = data
        } catch {
            print(error.localizedDescription)
            print("// [Enka.Sputnik.fetchEnkaDBData] Attempting to use alternative JSON server source.")
            do {
                let (data, _) = try await URLSession.shared.data(
                    for: URLRequest(url: serverType.viceVersa.enkaDBSourceURL(type: dataType))
                )
                dataToParse = data
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                var successMsg = "// [Enka.Sputnik.fetchEnkaDBData] 2nd attempt succeeded."
                successMsg += " Will use this JSON server source from now on."
                print(successMsg)
                Enka.HostType.toggleEnkaDBQueryHost()
            } catch {
                print("// [Enka.Sputnik.fetchEnkaDBData] Final attempt failed:")
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
                print("// DEBUG: [Enka.Sputnik.fetchEnkaDBData] Data Fetch Failed: \(dataType.rawValue).json")
            } else {
                print("// DEBUG: [Enka.Sputnik.fetchEnkaDBData] Data Parse Failed: \(dataType.rawValue).json")
            }
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
}

// MARK: - Fetching Enka Query Profile.

extension Enka.Sputnik {
    public func queryAndSave(uid: String, game: Enka.GameType) async throws {
        switch game {
        case .genshinImpact:
            let fetched = try await Enka.Sputnik.fetchEnkaQueryResultRAW(uid, type: Enka.QueriedResultGI.self)
            fetched.detailInfo?.saveToCache()
        case .starRail:
            let fetched = try await Enka.Sputnik.fetchEnkaQueryResultRAW(uid, type: Enka.QueriedResultHSR.self)
            fetched.detailInfo?.saveToCache()
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
        -> T {
        if let date = dateWhenNextRefreshable, date > Date() {
            print("PLAYER DETAIL FETCH 刷新太快了，请在\(date.coolingDownTimeRemaining)秒后刷新")
            throw Enka.EKError.queryTooFrequent(dateWhenRefreshable: date)
        } else {
            var server = Enka.HostType(uid: uid)
            var dataToParse = Data([])
            do {
                let (data, _) = try await URLSession.shared.data(
                    for: URLRequest(url: server.enkaProfileQueryURL(uid: uid, game: T.game))
                )
                dataToParse = data
            } catch {
                print(error.localizedDescription)
                print(
                    "// [Enka.Sputnik.fetchEnkaQueryResultRAW] Attempt using alternative profile query server source."
                )
                do {
                    server = server.viceVersa
                    let (data, _) = try await URLSession.shared.data(
                        for: URLRequest(url: server.enkaProfileQueryURL(uid: uid, game: T.game))
                    )
                    dataToParse = data
                    // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                    let successMsg = "// [Enka.Sputnik.fetchEnkaQueryResultRAW] 2nd attempt succeeded."
                    print(successMsg)
                } catch {
                    print("// [Enka.Sputnik.fetchEnkaQueryResultRAW] Final attempt failed:")
                    print(error.localizedDescription)
                    throw error
                }
            }
            do {
                var requestResult = try JSONDecoder()
                    .decode(T.self, from: dataToParse)
                // MicroGG Genshin Results might have lack of the UID.
                if T.game == .genshinImpact, requestResult.uid == nil {
                    requestResult.uid = uid
                }
                return requestResult
            } catch {
                if dataToParse.isEmpty {
                    print("// DEBUG: [Enka.Sputnik.fetchEnkaQueryResultRAW] Profile Query Failed. UID: \(uid) .")
                } else {
                    print(
                        "// DEBUG: [Enka.Sputnik.fetchEnkaQueryResultRAW] Profile Query Data Parse Failed. UID: \(uid) ."
                    )
                }
                print(error.localizedDescription)
                throw error
            }
        }
    }
}
