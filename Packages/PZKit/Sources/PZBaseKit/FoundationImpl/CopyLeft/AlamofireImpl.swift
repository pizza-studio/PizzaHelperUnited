// This implementation is considered as copyleft from public domain.

import Alamofire
import Foundation
import OSLog

extension Alamofire.DataRequest {
    public func printDebugIntelIfDebugMode() {
        convertible.urlRequest?.printDebugIntelIfDebugMode()
    }
}

// MARK: - Debug Intel Dumper for URLRequest.

extension URLRequest {
    public func printDebugIntelIfDebugMode() {
        #if DEBUG
        PZLog.debug("---------------------------------------------")
        PZLog.debug(debugDescription)
        if let headerEX = allHTTPHeaderFields {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            PZLog.debug(
                "\(String(data: try! encoder.encode(headerEX), encoding: .utf8) ?? "NOT_A_STRING")"
            )
        }
        PZLog.debug("---------------------------------------------")
        #endif
    }
}
