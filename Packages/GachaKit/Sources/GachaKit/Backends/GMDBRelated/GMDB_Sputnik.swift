// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Defaults
import EnkaKit
import Foundation
import GachaMetaDB
import GachaMetaGeneratorModule
import PZAccountKit
import PZBaseKit

// MARK: - GachaMeta.Sputnik

extension GachaMeta {
    public enum Sputnik {}

    /// 拿传入的简体中文翻译「是否在库」来检查资料库是否过期。（原神专用。）
    public func checkIfExpired(againstTranslation names: Set<String>) -> Bool {
        !names.subtracting(Set<String>(GachaMeta.sharedDB.reversedDB4GI.keys)).isEmpty
    }
}

// MARK: - GachaMeta.DBSet

/// 备注：此处不宜将 GachaMetaDB 继续用作 Root Namespace，
/// 否则 Observable Macro 生成的内容在这个代码文脉下会产生冲突性质的 cmopile-time error。
extension GachaMeta {
    public static let sharedDB = GachaMeta.DBSet()

    @Observable
    public final class DBSet: ObservableObject, @unchecked Sendable {
        // MARK: Lifecycle

        public init() {
            /// These domestic properties are `@ObservationTracked` by the `@Observable` macro
            /// applied to this class, hence no worries.
            Task {
                for await newDB in Defaults.updates(.localGachaMetaDBReversed4GI) {
                    self.reversedDB4GI = newDB
                }
            }
            Task {
                for await newDB in Defaults.updates(.localGachaMetaDB4GI) {
                    self.mainDB4GI = newDB
                }
            }
            Task {
                for await newDB in Defaults.updates(.localGachaMetaDB4HSR) {
                    self.mainDB4HSR = newDB
                }
            }
        }

        // MARK: Public

        public var reversedDB4GI = Defaults[.localGachaMetaDBReversed4GI]
        public var mainDB4GI = Defaults[.localGachaMetaDB4GI]
        public var mainDB4HSR = Defaults[.localGachaMetaDB4HSR]

        public func reverseQuery4GI(for name: String) -> Int? {
            reversedDB4GI[name]
        }
    }
}

extension GachaMeta.Sputnik {
    @MainActor
    public static func updateLocalGachaMetaDB(for game: Pizza.SupportedGame) async throws {
        do {
            switch game {
            case .genshinImpact:
                let newDB = try await fetchPreCompiledData(from: .miyoushe(game))
                Defaults[.localGachaMetaDB4GI] = newDB
                Defaults[.localGachaMetaDBReversed4GI] = newDB.generateHotReverseQueryDict(for: "zh-cn") ?? [:]
            case .starRail:
                let newDB = try await fetchPreCompiledData(from: .miyoushe(game))
                Defaults[.localGachaMetaDB4HSR] = newDB
            case .zenlessZone: return // 暂不支持。
            }
        } catch {
            throw GachaMeta.GMDBError.resultFetchFailure(subError: error)
        }
    }

    static func fetchPreCompiledData(
        from serverType: HoYo.AccountRegion
    ) async throws
        -> GachaMeta.MetaDB {
        do {
            return try await AF.request(serverType.gachaMetaDBRemoteURL)
                .serializingDecodable(GachaMeta.MetaDB.self)
                .value
        } catch {
            print(error.localizedDescription)
            print("// [GachaMeta.MetaDB.fetchPreCompiledData] Attempt using alternative JSON server source.")
            do {
                let resultObj = try await AF.request(serverType.gmdbServerViceVersa.gachaMetaDBRemoteURL)
                    .serializingDecodable(GachaMeta.MetaDB.self)
                    .value
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                let successMsg = "// [GachaMeta.MetaDB.fetchPreCompiledData] 2nd attempt succeeded."
                print(successMsg)
                return resultObj
            } catch {
                print("// [GachaMeta.MetaDB.fetchPreCompiledData] Final attempt failed:")
                print(error.localizedDescription)
                throw error
            }
        }
    }
}

// MARK: - GachaMeta.Trie

extension GachaMeta {
    class Trie {
        // MARK: Lifecycle

        public init() {}

        public init(words: [String]) {
            words.forEach(insert)
        }

        // MARK: Internal

        func insert(_ word: String) {
            var currentNode = root
            for char in word {
                if currentNode.children[char] == nil {
                    currentNode.children[char] = Node()
                }
                currentNode = currentNode.children[char]!
            }
            currentNode.isWord = true
        }

        // 在 Trie 中查找接近的词语
        func findSimilarWords(
            against word: String,
            maxDistance: Int
        )
            -> [String] {
            let trie = self
            var matchedWords: [String] = []
            let initialDistance = Array(0 ... word.count) // 初始化编辑距离
            trie.getRoot().InternalSearch(
                target: word,
                currentWord: "",
                maxDistance: Double(maxDistance),
                currentDistance: initialDistance.map(Double.init),
                results: &matchedWords
            )
            return matchedWords
        }

        // MARK: Fileprivate

        fileprivate class Node {
            var children: [Character: Node] = [:]
            var isWord: Bool = false
        }

        fileprivate func getRoot() -> Node {
            root
        }

        // MARK: Private

        private let root = Node()
    }
}

extension GachaMeta.Trie.Node {
    /// key 应该是米哈游官方用字，而 value 是其可能的笔画相似的错别字或非官方用字。
    /// 抽卡记录的原始数据原则上只能使用米哈游官方用字，哪怕米哈游自己用了错别字。
    private static let similarCharacters: [Character: [Character]] = [
        "曚": ["朦"],
    ]

    fileprivate func InternalSearch(
        target: String,
        currentWord: String,
        maxDistance: Double,
        currentDistance: [Double],
        results: inout [String],
        similarCharacters: [Character: [Character]]? = nil
    ) {
        let similarCharacters = similarCharacters ?? Self.similarCharacters
        // 如果当前节点是一个完整单词，并且编辑距离符合条件
        if isWord, let lastDistance = currentDistance.last, lastDistance <= maxDistance {
            results.append(currentWord)
        }

        // 遍历节点的每个子节点
        children.forEach { char, childNode in
            var nextDistance: [Double] = [currentDistance[0] + 1] // 第 0 列: 插入操作
            for (i, targetChar) in target.enumerated() {
                let cost: Double
                if char == targetChar {
                    cost = 0
                } else if similarCharacters[char]?.contains(targetChar) == true {
                    cost = 0.5
                } else {
                    cost = 1
                }
                nextDistance.append(
                    min(
                        currentDistance[i + 1] + 1, // 删除
                        nextDistance[i] + 1, // 插入
                        currentDistance[i] + cost // 替换或相似
                    )
                )
            }

            // 如果最小编辑距离在允许范围内，继续搜寻子节点
            if nextDistance.min()! <= maxDistance {
                childNode.InternalSearch(
                    target: target,
                    currentWord: currentWord + String(char),
                    maxDistance: maxDistance,
                    currentDistance: nextDistance,
                    results: &results,
                    similarCharacters: similarCharacters
                )
            }
        }
    }
}

// MARK: - GachaMeta.GMDBError

extension GachaMeta {
    public enum GMDBError: Error, LocalizedError {
        case emptyFetchResult
        case resultFetchFailure(subError: Error)
        case databaseExpired(game: Pizza.SupportedGame)
        case itemIDInvalid(name: String, game: Pizza.SupportedGame, uid: String?)

        // MARK: Public

        public var errorDescription: String? { localizedDescription }

        public var description: String { localizedDescription }

        public var localizedDescription: String {
            switch self {
            case .emptyFetchResult:
                "gachaKit.GachaMetaDBError.EmptyFetchResult".i18nGachaKit
            case let .resultFetchFailure(subError):
                "gachaKit.GachaMetaDBError.ResultFetchFailed"
                    .i18nGachaKit + " // \(subError.localizedDescription)"
            case .databaseExpired:
                "gachaKit.GachaMetaDBError.DatabaseExpired".i18nGachaKit
            case let .itemIDInvalid(name, game, uid):
                if let uid {
                    "gachaKit.GachaMetaDBError.itemIDInvalid"
                        .i18nGachaKit + " // \(name) @ \(game.localizedShortName) (\(uid))"
                } else {
                    "gachaKit.GachaMetaDBError.itemIDInvalid"
                        .i18nGachaKit + " // \(name) @ \(game.localizedShortName)"
                }
            }
        }
    }
}

extension HoYo.AccountRegion {
    fileprivate var gmdbServerViceVersa: Self {
        switch self {
        case .miyoushe: .hoyoLab(game)
        case .hoyoLab: .miyoushe(game)
        }
    }

    fileprivate var gachaMetaDBRemoteURL: URL {
        switch self {
        case .miyoushe: Enka.HostType.mainlandChina.getRemoteGMDBFileURL(game: game)
        case .hoyoLab: Enka.HostType.enkaGlobal.getRemoteGMDBFileURL(game: game)
        }
    }
}

extension Enka.HostType {
    fileprivate func getRemoteGMDBFileURL(game: Pizza.SupportedGame) -> URL {
        let baseStr: String = switch game {
        case .genshinImpact:
            gmDBSourceURLPrefix + "OUTPUT-GI.json"
        case .starRail:
            gmDBSourceURLPrefix + "OUTPUT-HSR.json"
        case .zenlessZone:
            "/dev/null"
        }
        return baseStr.asURL
    }

    fileprivate var gmDBSourceURLPrefix: String {
        let prefix = switch self {
        case .mainlandChina: "https://raw.gitcode.com/SHIKISUEN/GachaMetaGenerator/raw/main/"
        case .enkaGlobal: "https://raw.githubusercontent.com/pizza-studio/GachaMetaGenerator/main/"
        }
        return prefix + "Sources/GachaMetaDB/Resources/"
    }
}
