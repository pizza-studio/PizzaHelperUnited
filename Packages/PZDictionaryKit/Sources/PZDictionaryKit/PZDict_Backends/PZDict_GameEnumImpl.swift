// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Foundation
import PZBaseKit

extension Pizza.SupportedGame {
    private var dictionaryServerHost: String {
        switch self {
        case .genshinImpact: "gidict-api.pizzastudio.org"
        case .starRail: "hsrdict-api.pizzastudio.org"
        case .zenlessZone: "zzzdict-api.pizzastudio.org"
        }
    }

    var dictURL: URL {
        switch self {
        case .genshinImpact: "https://gidict.pizzastudio.org/".asURL
        case .starRail: "https://hsrdict.pizzastudio.org/".asURL
        case .zenlessZone: "https://zzzdict.pizzastudio.org/".asURL
        }
    }
}

extension Pizza.SupportedGame {
    // This function is Package-Domestic.
    func translate(query: String, page: Int, pageSize: Int) async throws -> TranslationResult {
        var components = URLComponents()
        components.scheme = "https"
        components.host = dictionaryServerHost
        components.path = "/v1/translations/\(query)"
        components.queryItems = [.init(name: "page", value: "\(page)"), .init(name: "page_size", value: "\(pageSize)")]
        guard let url = components.url else {
            throw AFError.invalidURL(url: components)
        }

        return try await AF.request(url)
            .serializingDecodable(TranslationResult.self)
            .value
    }
}
