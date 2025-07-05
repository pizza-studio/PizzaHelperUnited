// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZAccountKit

// MARK: - GachaClient

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
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
            let data = try await request.serializingData().value
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
        -> DataRequest {
        let langRawValue: String = switch gachaType.game {
        case .genshinImpact: GachaLanguage.langCHS.rawValue
        default: GachaLanguage.current.rawValue
        }

        let host = URLRequestConfig.domain4PublicOps(region: basicParam.server.region)
        let path = URLRequestConfig.gachaRecordAPIPath(game: gachaType.game)
        let baseURL = "https://\(host)\(path)"

        // 改用明确的字典型别，避免 Any 型别问题
        var parameters = [String: String]()
        parameters["authkey_ver"] = basicParam.authenticationKeyVersion
        parameters["sign_type"] = basicParam.signType
        parameters["auth_appid"] = "webview_gacha"
        parameters["win_mode"] = "fullscreen"
        parameters["timestamp"] = "\(Int(Date().timeIntervalSince1970))"
        parameters["region"] = basicParam.server.rawValue
        parameters["default_gacha_type"] = GachaType.knownCases[0].rawValue
        parameters["lang"] = langRawValue
        parameters["game_biz"] = basicParam.server.region.rawValue
        parameters["os_system"] = "iOS 16.6"
        parameters["device_model"] = "iPhone15.2"
        parameters["plat_type"] = "ios"
        parameters["page"] = "\(page)"
        parameters["size"] = "\(size)"
        parameters["gacha_type"] = gachaType.rawValue
        parameters["real_gacha_type"] = gachaType.rawValue
        parameters["end_id"] = endID
        parameters["authkey"] = basicParam.authenticationKey // Alamofire 似乎不会损毁这个参数值。

        // 使用 interceptor 确保请求可靠性
        let interceptor = RetryPolicy()

        return AF.request(
            baseURL,
            method: .get,
            parameters: parameters,
            headers: nil,
            interceptor: interceptor
        )
        .cURLDescription { description in
            // 仅在侦错时输出，避免敏感信息泄漏
            #if DEBUG
            print(description)
            #endif
        }
    }
}
