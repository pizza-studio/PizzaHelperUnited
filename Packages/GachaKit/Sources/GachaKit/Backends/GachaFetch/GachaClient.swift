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
        self.urlString = gachaURLString
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
    public var urlString: String
    public var fetchRange: GachaFetchRange = .allAvailable
    public var chosenPools: Set<GachaType> = Set(GachaType.knownCases)

    public func makeAsyncIterator() -> Self { self }

    public mutating func next() async throws(GachaError) -> (gachaType: GachaType, result: GachaResult)? {
        guard !chosenPools.isEmpty else { return nil }
        while !chosenPools.contains(pagination.gachaType) {
            if let nextGachaType = pagination.gachaType.next() {
                pagination = .init(gachaType: nextGachaType)
            } else {
                return nil
            }
        }
        let request = Self.generateGachaRequest(
            basicParam: authentication,
            page: pagination.page,
            size: pagination.size,
            gachaType: pagination.gachaType,
            endID: pagination.endID
        )
        let sleepNS = Double.random(in: GachaClient.getGachaDelayRangeRandom)
        do {
            try? await Task.sleep(nanoseconds: UInt64(sleepNS * 1_000_000_000))
            let (data, _) = try await URLSession.shared.data(for: request)
            var result = try GachaResult.decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "GachaClient().next()")
            result.listConverted = []
            var shouldJumpToNextGachaType = false
            conversionProcess: for i in 0 ..< result.list.count {
                let translatedEntry = try await result.list[i].toGachaEntrySendable(
                    game: GachaType.game, fixItemIDs: GachaType.game == .genshinImpact
                )
                let tzDelta = GachaKit.getServerTimeZoneDelta(uid: translatedEntry.uid, game: GachaType.game)
                if !fetchRange.isUnlimited, let timeTag = TimeTag(translatedEntry.time, tzDelta: tzDelta) {
                    guard !fetchRange.verifyWhetherOutOfRange(against: timeTag.time) else {
                        shouldJumpToNextGachaType = true
                        // 这里假设 List 最开始的是最新的。回头有意外的话再排查。
                        result.list = Array(result.list[0 ..< i])
                        break conversionProcess
                    }
                }
                result.listConverted.append(translatedEntry)
            }

            if !shouldJumpToNextGachaType, let endResult = result.list.last {
                pagination = .init(
                    page: pagination.page + 1,
                    size: pagination.size,
                    endID: endResult.id,
                    gachaType: pagination.gachaType
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
        var validDomain = false
        validDomain = validDomain || gachaURLString.contains("api/getGachaLog")
        validDomain = validDomain || gachaURLString.contains(try! Regex(#"/event/e.*?gacha-v.*?/index.html"#))
        guard validDomain, let url = URL(string: gachaURLString),
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
        let langRawValue: String = switch gachaType.game {
        case .genshinImpact: GachaLanguage.langCHS.rawValue
        default: GachaLanguage.current.rawValue
        }

        var components = URLComponents()
        components.scheme = "https"
        components.host = URLRequestConfig.domain4PublicOps(region: basicParam.server.region)
        components.path = URLRequestConfig.gachaRecordAPIPath(game: gachaType.game)
        components.queryItems = [
            .init(name: "authkey_ver", value: basicParam.authenticationKeyVersion),
            .init(name: "sign_type", value: basicParam.signType),
            .init(name: "auth_appid", value: "webview_gacha"),
            .init(name: "win_mode", value: "fullscreen"),
            .init(name: "timestamp", value: "\(Int(Date().timeIntervalSince1970))"),
            .init(name: "region", value: basicParam.server.rawValue),
            .init(name: "default_gacha_type", value: GachaType.knownCases[0].rawValue),
            .init(name: "lang", value: langRawValue),
            .init(name: "game_biz", value: basicParam.server.region.rawValue),
            .init(name: "os_system", value: "iOS 16.6"),
            .init(name: "device_model", value: "iPhone15.2"),
            .init(name: "plat_type", value: "ios"),
            .init(name: "page", value: "\(page)"),
            .init(name: "size", value: "\(size)"),
            .init(name: "gacha_type", value: gachaType.rawValue),
            .init(name: "real_gacha_type", value: gachaType.rawValue),
            .init(name: "end_id", value: endID),
        ]
        let authKeyRaw = basicParam.authenticationKey
        let authKeyPercEncoded = authKeyRaw.addingPercentEncoding(
            withAllowedCharacters: .alphanumerics
        )!
        // 注意：不能直接将 AuthKey 塞入 URLQueryItem，否则会破坏 AuthKey。这里得用手动编码。
        let urlString = components.url!.absoluteString + "&authkey=\(authKeyPercEncoded)"
        return URLRequest(url: URL(string: urlString)!)
    }
}
