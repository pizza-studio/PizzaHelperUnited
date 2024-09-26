// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Foundation
import PZAccountKit

// MARK: - GachaClient

public class GachaClient<GachaType: GachaTypeProtocol>: @unchecked Sendable {
    // MARK: Lifecycle

    public init(gachaURLString: String) throws(ParseGachaURLError) {
        self.authentication = try Self.parseGachaURL(by: gachaURLString)
    }

    // MARK: Public

    public typealias GachaResult = GachaFetchModels.PageFetched

    public let publisher: PassthroughSubject<(gachaType: GachaType, result: GachaResult), GachaError> =
        .init()

    public func start() {
        if task == nil {
            task = Task(priority: .high) {
                while case let .currentPagination(pagination) = status {
                    let rnd = Double.random(in: Self.getGachaDelayRangeRandom)
                    try? await Task.sleep(nanoseconds: UInt64(rnd * 1_000_000_000))
                    do {
                        var result = try await fetchData(pagination: pagination)
                        var convertedItems = [PZGachaEntrySendable]()
                        for fetchedEntryRAW in result.list {
                            let convertedEntry = try await fetchedEntryRAW.toGachaEntrySendable(
                                game: GachaType.game, fixItemIDs: GachaType.game == .genshinImpact
                            )
                            convertedItems.append(convertedEntry)
                        }
                        result.listConverted = convertedItems
                        publisher.send((gachaType: pagination.gachaType, result: result))
                        status.switchToNextPage(endID: result.list.last?.id)
                    } catch {
                        status = .finished
                        publisher.send(
                            completion: .failure(
                                GachaError.fetchDataError(
                                    page: pagination.page,
                                    size: pagination.size,
                                    gachaTypeRaw: pagination.gachaType.rawValue,
                                    error: error
                                )
                            )
                        )
                    }
                }
                status = .finished
                publisher.send(completion: .finished)
            }
        }
    }

    public func cancel() {
        task?.cancel()
        status = .finished
        publisher.send(completion: .finished)
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

    private enum Status {
        case finished
        case currentPagination(Pagination)

        // MARK: Internal

        mutating func switchToNextPage(endID: String?) {
            guard case let .currentPagination(pagination) = self else {
                return
            }

            if let endID {
                self = .currentPagination(
                    Pagination(
                        page: pagination.page + 1,
                        size: pagination.size,
                        endID: endID,
                        gachaType: pagination.gachaType
                    )
                )
            } else {
                if let nextGachaType = pagination.gachaType.next() {
                    self = .currentPagination(.init(gachaType: nextGachaType))
                } else {
                    self = .finished
                }
            }
        }
    }

    private struct Pagination {
        // MARK: Lifecycle

        init() {
            self.page = 1
            self.size = 20
            self.endID = "0"
            self.gachaType = .knownCases[0]
        }

        init(gachaType: GachaType) {
            self.page = 1
            self.size = 20
            self.endID = "0"
            self.gachaType = gachaType
        }

        init(page: Int, size: Int, endID: String, gachaType: GachaType) {
            self.page = page
            self.size = size
            self.endID = endID
            self.gachaType = gachaType
        }

        // MARK: Internal

        var page: Int
        var size: Int
        var endID: String
        var gachaType: GachaType
    }

    private static var getGachaDelayRangeRandom: Range<Double> { 0.8 ..< 1.5 }

    private let authentication: GachaRequestAuthentication
    private var status: Status = .currentPagination(.init())
    private var task: Task<Void, Never>?

    private func fetchData(pagination: Pagination) async throws -> GachaResult {
        let request = Self.generateGachaRequest(
            basicParam: authentication,
            page: pagination.page,
            size: pagination.size,
            gachaType: pagination.gachaType,
            endID: pagination.endID
        )

        let (data, _) = try await URLSession.shared.data(for: request)

        let result = try GachaResult.decodeFromMiHoYoAPIJSONResult(data: data)

        return result
    }
}

extension GachaClient {
    private static func generateGachaRequest(
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

        components.path = "/common/gacha_record/api/getGachaLog"

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
        let urlString = components.url!
            .absoluteString +
            "&authkey=\(basicParam.authenticationKey.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!)"
        return URLRequest(url: URL(string: urlString)!)
    }
}
