// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import EnkaDBModels
import Foundation

// MARK: - Enka.Sputnik

extension Enka {
    public enum Sputnik {
        public static var sharedDB4GI: Enka.EnkaDB4GI = Defaults[.enkaDBData4GI]
        public static var sharedDB4HSR: Enka.EnkaDB4HSR = Defaults[.enkaDBData4HSR]
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
            print("// [Enka.Sputnik.fetchEnkaDBData] Attempt using alternative JSON server source.")
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
            print(error.localizedDescription)
            throw error
        }
    }
}
