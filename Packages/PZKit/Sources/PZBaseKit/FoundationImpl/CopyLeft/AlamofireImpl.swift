// This implementation is considered as copyleft from public domain.

import Alamofire
import Foundation

extension Alamofire.DataRequest {
    public func printDebugIntelIfDebugMode() {
        convertible.urlRequest?.printDebugIntelIfDebugMode()
    }
}

// MARK: - Debug Intel Dumper for URLRequest.

extension URLRequest {
    public func printDebugIntelIfDebugMode() {
        #if DEBUG
        print("---------------------------------------------")
        print(debugDescription)
        if let headerEX = allHTTPHeaderFields {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]
            print(String(data: try! encoder.encode(headerEX), encoding: .utf8)!)
        }
        print("---------------------------------------------")
        #endif
    }
}
