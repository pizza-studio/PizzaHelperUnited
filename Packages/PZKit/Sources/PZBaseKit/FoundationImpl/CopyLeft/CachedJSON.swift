// This implementation is considered as copyleft from public domain.

import Defaults
import Foundation

// MARK: - CachedJSON

public struct CachedJSON: AbleToCodeSendHash, Defaults.Serializable {
    // MARK: Lifecycle

    public init(rawJSONString: String, timestamp: TimeInterval? = nil) {
        self.rawJSONString = rawJSONString
        self.timestamp = timestamp ?? Date().timeIntervalSince1970
    }

    // MARK: Public

    public let rawJSONString: String
    public let timestamp: TimeInterval

    public var cachedTime: Date { .init(timeIntervalSince1970: timestamp) }
}
