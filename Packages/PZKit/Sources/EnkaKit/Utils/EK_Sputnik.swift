// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Defaults
import EnkaDBModels
import Foundation
import Observation

// MARK: - Enka.Sputnik

extension Enka {
    @Observable
    public class Sputnik {
        // MARK: Lifecycle

        private init() {
            /// Both db4GI and db4HSR are `@ObservationTracked` by the `@Observable` macro
            /// applied to this class, hence no worries.
            Defaults.publisher(.enkaDBData4GI)
                .sink { newDB in
                    Task.detached { @MainActor in
                        self.db4GI.update(new: newDB.newValue)
                    }
                }.store(in: &cancellables)
            Defaults.publisher(.enkaDBData4HSR).sink { newDB in
                Task.detached { @MainActor in
                    self.db4HSR.update(new: newDB.newValue)
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

        // MARK: Private

        private var cancellables: Set<AnyCancellable> = []
    }
}

// MARK: - Individual EnkaDB Getters.

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
        let sharedDB = Self.shared.db4GI
        let needUpdate = checkWhetherDataNeedsUpdate(against: sharedDB)
        guard needUpdate else { return sharedDB }
        let newDB = try await Enka.EnkaDB4GI(host: Defaults[.defaultDBQueryHost])
        Defaults[.enkaDBData4GI] = newDB
        Self.shared.db4GI.update(new: newDB) // 被监视的对象不宜被整个替换，但把内臟全换了还是可以的。
        Defaults[.lastEnkaDBDataCheckDate] = Date()
        return newDB
    }

    @MainActor
    @discardableResult
    public static func getEnkaDB4HSR() async throws -> Enka.EnkaDB4HSR {
        let sharedDB = Self.shared.db4HSR
        let needUpdate = checkWhetherDataNeedsUpdate(against: sharedDB)
        guard needUpdate else { return sharedDB }
        let newDB = try await Enka.EnkaDB4HSR(host: Defaults[.defaultDBQueryHost])
        Defaults[.enkaDBData4HSR] = newDB
        Self.shared.db4HSR.update(new: newDB) // 被监视的对象不宜被整个替换，但把内臟全换了还是可以的。
        Defaults[.lastEnkaDBDataCheckDate] = Date()
        return newDB
    }

    private static func checkWhetherDataNeedsUpdate(against data: EnkaDBProtocol) -> Bool {
        let previousDate = Defaults[.lastEnkaDBDataCheckDate]
        let expired = Calendar.current.date(byAdding: .hour, value: 2, to: previousDate)! < Date()
        return expired || Locale.langCodeForEnkaAPI != data.locTag
    }
}

extension Enka.Sputnik {
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
