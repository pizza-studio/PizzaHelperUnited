// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - DecodableFromMiHoYoAPIJSONResult

/// A protocol that enables decoding from MiHoYoAPI JSON results
public protocol DecodableFromMiHoYoAPIJSONResult: Decodable {}

extension DecodableFromMiHoYoAPIJSONResult {
    /// Decodes data from MiHoYoAPI JSON results
    public static func decodeFromMiHoYoAPIJSONResult(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        let result: MiHoYoAPIJSONResult<Self>
        do {
            result = try decoder.decode(MiHoYoAPIJSONResult<Self>.self, from: data)
        } catch {
            let errorMessage = """
            DECODE ITEM: \(String(data: data, encoding: .utf8)!)
            --------------
            rawError:
            \(error)
            """
            #if DEBUG
            print("-----------------------------------")
            print(errorMessage)
            print("-----------------------------------")
            #endif
            throw MiHoYoAPIError(retcode: -114514, message: errorMessage)
        }
        if result.retcode == 0 {
            // swiftlint:disable:next force_unwrapping
            return result.data!
        } else {
            throw MiHoYoAPIError(retcode: result.retcode, message: result.message)
        }
    }
}

// MARK: - MiHoYoAPIJSONResult

/// A generic structure representing JSON results from MiHoYoAPI
private struct MiHoYoAPIJSONResult<T: DecodableFromMiHoYoAPIJSONResult>: Decodable {
    // MARK: Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.retcode = try container.decode(Int.self, forKey: .retcode)
        self.message = try container.decode(String.self, forKey: .message)
        self.data = try container.decodeIfPresent(T.self, forKey: .data)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case retcode
        case message
        case data
    }

    let retcode: Int
    let message: String
    let data: T?
}
