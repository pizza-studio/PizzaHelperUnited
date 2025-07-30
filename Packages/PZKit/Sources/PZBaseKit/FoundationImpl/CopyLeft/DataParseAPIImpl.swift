// This implementation is considered as copyleft from public domain.

import Foundation

// MARK: - Data Implementation

extension Data {
    public func parseAs<T: Decodable>(
        _ type: T.Type, config: ((JSONDecoder) -> Void)? = nil
    ) throws
        -> T {
        let decoder = JSONDecoder()
        config?(decoder)
        return try decoder.decode(T.self, from: self)
    }
}

extension Data? {
    public func parseAs<T: Decodable>(
        _ type: T.Type, config: ((JSONDecoder) -> Void)? = nil
    ) throws
        -> T? {
        guard let this = self else { return nil }
        let decoder = JSONDecoder()
        config?(decoder)
        return try decoder.decode(T.self, from: this)
    }

    public func assertedParseAs<T: Decodable>(
        _ type: T.Type,
        config: ((JSONDecoder) -> Void)? = nil
    ) throws
        -> T {
        let decoder = JSONDecoder()
        config?(decoder)
        return try decoder.decode(T.self, from: self ?? .init([]))
    }
}
