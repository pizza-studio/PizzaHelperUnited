// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
@preconcurrency import Defaults
import Foundation
import GachaMetaDB
import GachaMetaGeneratorModule
import PZAccountKit
import PZBaseKit

public typealias GachaMetaDBExposed = GachaMetaDB

// MARK: - GachaMetaDB.Sputnik

extension GachaMetaDB {
    public enum Sputnik {}

    /// 拿传入的简体中文翻译「是否在库」来检查资料库是否过期。（原神专用。）
    public func checkIfExpired(againstTranslation names: Set<String>) -> Bool {
        !names.subtracting(Set<String>(GachaMetaDBExposed.shared.reversedDB4GI.keys)).isEmpty
    }
}

extension GachaMetaDB {
    public static let shared = SharedDBSet()

    public class SharedDBSet: ObservableObject, @unchecked Sendable {
        // MARK: Lifecycle

        public init() {
            cancellables.append(
                Defaults.publisher(.localGachaMetaDBReversed4GI).sink { _ in
                    Task.detached { @MainActor in
                        self.reversedDB4GI = Defaults[.localGachaMetaDBReversed4GI]
                    }
                }
            )
            cancellables.append(
                Defaults.publisher(.localGachaMetaDB4GI).sink { _ in
                    Task.detached { @MainActor in
                        self.mainDB4GI = Defaults[.localGachaMetaDB4GI]
                    }
                }
            )
            cancellables.append(
                Defaults.publisher(.localGachaMetaDB4HSR).sink { _ in
                    Task.detached { @MainActor in
                        self.mainDB4HSR = Defaults[.localGachaMetaDB4HSR]
                    }
                }
            )
        }

        // MARK: Public

        @Published public var reversedDB4GI = Defaults[.localGachaMetaDBReversed4GI]
        @Published public var mainDB4GI = Defaults[.localGachaMetaDB4GI]
        @Published public var mainDB4HSR = Defaults[.localGachaMetaDB4HSR]

        public func reverseQuery4GI(for name: String) -> Int? {
            reversedDB4GI[name]
        }

        // MARK: Private

        private var cancellables: [AnyCancellable] = []
    }
}

extension GachaMetaDB.Sputnik {
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
            throw GachaMetaDB.GMDBError.resultFetchFailure(subError: error)
        }
    }

    static func fetchPreCompiledData(
        from serverType: HoYo.AccountRegion
    ) async throws
        -> GachaMetaDB {
        var dataToParse = Data([])
        do {
            let (data, _) = try await URLSession.shared.data(
                for: URLRequest(url: serverType.gachaMetaDBRemoteURL)
            )
            dataToParse = data
        } catch {
            print(error.localizedDescription)
            print("// [GachaMetaDB.fetchPreCompiledData] Attempt using alternative JSON server source.")
            do {
                let (data, _) = try await URLSession.shared.data(
                    for: URLRequest(url: serverType.gmdbServerViceVersa.gachaMetaDBRemoteURL)
                )
                dataToParse = data
                // 如果这次成功的话，就自动修改偏好设定、今后就用这个资料源。
                let successMsg = "// [GachaMetaDB.fetchPreCompiledData] 2nd attempt succeeded."
                print(successMsg)
            } catch {
                print("// [GachaMetaDB.fetchPreCompiledData] Final attempt failed:")
                print(error.localizedDescription)
                throw error
            }
        }
        let requestResult = try JSONDecoder().decode(GachaMetaDB.self, from: dataToParse)
        return requestResult
    }
}

// MARK: - GachaMetaDB.GMDBError

extension GachaMetaDB {
    public enum GMDBError: Error, LocalizedError {
        case emptyFetchResult
        case resultFetchFailure(subError: Error)
        case databaseExpired

        // MARK: Public

        public var errorDescription: String? { localizedDescription }

        public var localizedDescription: String {
            switch self {
            case .emptyFetchResult:
                return "gachaKit.GachaMetaDBError.EmptyFetchResult".i18nGachaKit
            case let .resultFetchFailure(subError):
                return "gachaKit.GachaMetaDBError.ResultFetchFailed"
                    .i18nGachaKit + " // \(subError.localizedDescription)"
            case .databaseExpired:
                return "gachaKit.GachaMetaDBError.DatabaseExpired".i18nGachaKit
            }
        }
    }
}

extension HoYo.AccountRegion {
    fileprivate var gmdbServerViceVersa: Self {
        switch self {
        case .miyoushe: return .hoyoLab(game)
        case .hoyoLab: return .miyoushe(game)
        }
    }

    public var gachaMetaDBRemoteURL: URL {
        var urlStr = ""
        switch (self, game) {
        case (.miyoushe, .genshinImpact):
            urlStr += #"https://gitlink.org.cn/attachments/entries/get_file?download_url="#
            urlStr += #"https://www.gitlink.org.cn/api/ShikiSuen/GachaMetaGenerator/raw/"#
            urlStr += #"Sources%2FGachaMetaDB%2FResources%2FOUTPUT-GI.json?ref=main"#
        case (.hoyoLab, .genshinImpact):
            urlStr += #"https://raw.githubusercontent.com/pizza-studio/"#
            urlStr += #"GachaMetaGenerator/main/Sources/GachaMetaDB/Resources/OUTPUT-GI.json"#
        case (.miyoushe, .starRail):
            urlStr += #"https://gitlink.org.cn/attachments/entries/get_file?download_url="#
            urlStr += #"https://www.gitlink.org.cn/api/ShikiSuen/GachaMetaGenerator/raw/"#
            urlStr += #"Sources%2FGachaMetaDB%2FResources%2FOUTPUT-GI.json?ref=main"#
        case (.hoyoLab, .starRail):
            urlStr += #"https://raw.githubusercontent.com/pizza-studio/"#
            urlStr += #"GachaMetaGenerator/main/Sources/GachaMetaDB/Resources/OUTPUT-GI.json"#
        case (_, .zenlessZone): // 暂不支持，乱填。
            urlStr += "/dev/null"
        }
        return URL(string: urlStr)!
    }
}
