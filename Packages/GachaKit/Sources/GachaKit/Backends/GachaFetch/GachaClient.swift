// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

// MARK: - GachaClient

public struct GachaClient<GachaType: GachaTypeProtocol>: AsyncSequence, AsyncIteratorProtocol {
    // MARK: Lifecycle

    public init(gachaURLString: String) throws(ParseGachaURLError) {
        self.authentication = try Self.parseGachaURL(by: gachaURLString)
    }

    // MARK: Public

    public typealias GachaResult = GachaFetchModels.PageFetched

    public struct Pagination {
        // MARK: Lifecycle

        public init() {
            self.page = 1
            self.size = 20
            self.endID = "0"
            self.gachaType = .knownCases[0]
        }

        public init(gachaType: GachaType) {
            self.page = 1
            self.size = 20
            self.endID = "0"
            self.gachaType = gachaType
        }

        public init(page: Int, size: Int, endID: String, gachaType: GachaType) {
            self.page = page
            self.size = size
            self.endID = endID
            self.gachaType = gachaType
        }

        // MARK: Public

        public var page: Int
        public var size: Int
        public var endID: String
        public var gachaType: GachaType
    }

    public var pagination: Pagination = .init()

    public func makeAsyncIterator() -> Self { self }

    public mutating func next() async throws(GachaError) -> (gachaType: GachaType, result: GachaResult)? {
        do {
            let request = Self.generateGachaRequest(
                basicParam: authentication,
                page: pagination.page,
                size: pagination.size,
                gachaType: pagination.gachaType,
                endID: pagination.endID
            )

            let sleepNS = Double.random(in: GachaClient.getGachaDelayRangeRandom)
            try? await Task.sleep(nanoseconds: UInt64(sleepNS * 1_000_000_000))
            let (data, _) = try await URLSession.shared.data(for: request)

            var result = try GachaResult.decodeFromMiHoYoAPIJSONResult(data: data)

            result.listConverted = try await withThrowingTaskGroup(
                of: PZGachaEntrySendable.self,
                returning: [PZGachaEntrySendable].self,
                body: { taskGroup in
                    result.list.forEach { entryRaw in
                        taskGroup.addTask {
                            try await entryRaw.toGachaEntrySendable(
                                game: GachaType.game, fixItemIDs: GachaType.game == .genshinImpact
                            )
                        }
                    }

                    return try await taskGroup.reduce(into: []) { partialResult, entry in
                        partialResult.append(entry)
                    }
                }
            )

            if let endResult = result.list.last {
                pagination = .init(
                    page: pagination.page + 1,
                    size: pagination.size,
                    endID: endResult.id,
                    gachaType: .init(rawValue: endResult.gachaType)
                )
            } else if let nextGachaType = pagination.gachaType.next() {
                pagination = .init(gachaType: nextGachaType)
            } else {
                return nil
            }

            return (pagination.gachaType, result)
        } catch is CancellationError {
            return nil
        } catch {
            throw GachaError.fetchDataError(
                page: pagination.page,
                size: pagination.size,
                gachaTypeRaw: pagination.gachaType.rawValue,
                error: error
            )
        }
    }

    public mutating func reset() {
        pagination = .init()
    }

    // MARK: Internal

    static func parseGachaURL(
        by gachaURLString: String
    ) throws(ParseGachaURLError)
        -> GachaRequestAuthentication {
        guard let url = URL(string: gachaURLString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { throw ParseGachaURLError.invalidURL }

        let queryItems = components.queryItems
        guard let authenticationKey = queryItems?.first(where: { $0.name == "authkey" })?.value
        else { throw ParseGachaURLError.noAuthenticationKey }
        guard let authenticationKeyVersion = queryItems?.first(where: { $0.name == "authkey_ver" })?.value
        else { throw ParseGachaURLError.noAuthenticationKeyVersion }
        guard let serverRawValue = queryItems?.first(where: { $0.name == "region" })?.value
        else { throw ParseGachaURLError.noServer }
        guard let server = HoYo.Server(rawValue: serverRawValue) else { throw .invalidServer }
        guard let signType = queryItems?.first(where: { $0.name == "sign_type" })?.value
        else { throw ParseGachaURLError.noSignType }

        return GachaRequestAuthentication(
            authenticationKey: authenticationKey,
            authenticationKeyVersion: authenticationKeyVersion,
            signType: signType,
            server: server
        )
    }

    // MARK: Private

    private static var getGachaDelayRangeRandom: Range<Double> { 0.8 ..< 1.5 }

    private let authentication: GachaRequestAuthentication

    static private func generateGachaRequest(
        basicParam: GachaRequestAuthentication,
        page: Int,
        size: Int,
        gachaType: GachaType,
        endID: String
    )
        -> URLRequest {
        var components = URLComponents()

        components.scheme = "https"
        components.host = URLRequestConfig.domain4PublicOps(region: basicParam.server.region)

        components.path = switch GachaType.game {
        case .starRail: "/common/gacha_record/api/getGachaLog"
        case .genshinImpact: "/gacha_info/api/getGachaLog"
        case .zenlessZone: "/gacha_info/api/getGachaLog"
        }

        let langRawValue: String = switch gachaType.game {
        case .genshinImpact: GachaLanguage.langCHS.rawValue
        default: GachaLanguage.current.rawValue
        }

        components.queryItems = [
            .init(name: "authkey_ver", value: basicParam.authenticationKeyVersion),
            .init(name: "sign_type", value: basicParam.signType),
            .init(name: "auth_appid", value: "webview_gacha"),
            .init(name: "win_mode", value: "fullscreen"),
            .init(name: "gacha_id", value: "37ebc087b75657573e19622da856f9c29524ae"),
            .init(name: "timestamp", value: "\(Int(Date().timeIntervalSince1970))"),
            .init(name: "region", value: basicParam.server.rawValue),
            .init(name: "default_gacha_type", value: "11"),
            .init(name: "lang", value: langRawValue),
            .init(name: "game_biz", value: basicParam.server.region.rawValue),
            .init(name: "os_system", value: "iOS 16.6"),
            .init(name: "device_model", value: "iPhone15.2"),
            .init(name: "plat_type", value: "ios"),
            .init(name: "page", value: "\(page)"),
            .init(name: "size", value: "\(size)"),
            .init(name: "gacha_type", value: gachaType.rawValue),
            .init(name: "end_id", value: endID),
        ]
        let authKeyRaw = basicParam.authenticationKey
        let authKeyPercEncoded = authKeyRaw.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics
        )!
        let urlString = components.url!.absoluteString + "&authkey=\(authKeyPercEncoded)"
        return URLRequest(url: URL(string: urlString)!)
    }
}
