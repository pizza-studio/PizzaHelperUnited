// This implementation is considered as copyleft from public domain.

import CryptoKit
import Foundation

/// This combination has been used too frequent
public typealias AbleToCodeSendHash = Codable & Sendable & Hashable

// MARK: - UserDefaults + Sendable

extension UserDefaults: @unchecked @retroactive Sendable {}

// MARK: - Debug Message Printer

extension String {
    public static func printDebug(
        _ items: Any..., separator: String = " ", terminator: String = "\n"
    ) {
        #if DEBUG
        print(items, separator: separator, terminator: terminator)
        #endif
    }

    public static func printNSLog4Debug(
        _ format: String,
        _ args: any CVarArg...
    ) {
        #if DEBUG
        NSLog(format, args)
        #endif
    }
}

// MARK: - Ask Bundle to tell App Build Number.

extension Bundle {
    public static func getAppVersionAndBuild() throws -> (version: String, build: String) {
        guard let infoDictionary = Bundle.main.infoDictionary else {
            throw NSError(
                domain: "AppInfoError",
                code: 213,
                userInfo: [NSLocalizedDescriptionKey: "Failed to get the app's Info.plist."]
            )
        }

        guard let version = infoDictionary["CFBundleShortVersionString"] as? String,
              let build = infoDictionary["CFBundleVersion"] as? String else {
            throw NSError(
                domain: "AppInfoError",
                code: 233,
                userInfo: [NSLocalizedDescriptionKey: "Version or build number is missing."]
            )
        }

        return (version, build)
    }
}

// MARK: - Swift Extension to round doubles.

extension Double {
    /// Rounds the double to decimal places value
    public func roundToPlaces(places: Int = 1, round: FloatingPointRoundingRule? = nil) -> Double {
        guard places > 0 else { return self }
        var precision = 1.0
        for _ in 0 ..< places {
            precision *= 10
        }
        var amped = precision * self
        if let round {
            amped.round(round)
        } else {
            amped = amped.rounded()
        }

        return Double(amped / precision)
    }
}

// MARK: - String Implementations.

extension String {
    public var asURL: URL {
        // swiftlint:disable force_unwrapping
        URL(string: self)!
        // swiftlint:enable force_unwrapping
    }
}

extension String {
    public var i18nBaseKit: String {
        if #available(iOS 15.0, macCatalyst 15.0, *) {
            String(localized: .init(stringLiteral: self), bundle: .module)
        } else {
            NSLocalizedString(self, bundle: .module, comment: "")
        }
    }
}

@available(iOS 15.0, macCatalyst 15.0, *)
extension String.LocalizationValue {
    public var i18nBaseKit: String {
        String(localized: self, bundle: .module)
    }
}

extension String {
    /// - returns: the String, as an MD5 hash.
    public var md5: String {
        Insecure.MD5.hash(data: Data(utf8)).map {
            String(format: "%02hhx", $0)
        }.joined()
    }

    public var sha256: String {
        let digest = SHA256.hash(data: Data(utf8))
        return digest.map {
            String(format: "%02hhx", $0)
        }.joined()
    }
}

extension String {
    public func convertPercentedSelfToDouble() -> Double? {
        var allChars = map { $0 }
        var shouldDivideBy100 = false
        if allChars.last == "%" {
            allChars = allChars.dropLast()
            shouldDivideBy100 = true
        }
        guard let numberResult = Double(String(allChars)) else { return nil }
        return shouldDivideBy100 ? (numberResult / 100) : numberResult
    }
}

// MARK: - AnyLocalizedError

public enum AnyLocalizedError: LocalizedError {
    case localizedError(LocalizedError)
    case otherError(Error)

    // MARK: Lifecycle

    public init(_ error: Error) {
        if let error = error as? LocalizedError {
            self = .localizedError(error)
        } else {
            self = .otherError(error)
        }
    }

    // MARK: Public

    public var errorDescription: String? {
        switch self {
        case let .localizedError(localizedError):
            localizedError.errorDescription
        case let .otherError(error):
            error.localizedDescription
        }
    }
}

// MARK: - UUID Impl.

extension UUID {
    /// Converts an MD5 hash string into a UUID.
    /// - Parameter md5: A 32-character hexadecimal MD5 hash string.
    /// - Throws: An error if the MD5 string is invalid.
    /// - Returns: A UUID generated from the MD5 hash.
    public static func fromMD5(_ md5: String) throws -> UUID {
        // Ensure the MD5 string is valid (32 characters, hexadecimal)
        guard md5.count == 32, md5.range(of: "^[a-fA-F0-9]{32}$", options: .regularExpression) != nil else {
            throw NSError(domain: "InvalidMD5", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid MD5 string."])
        }

        // Convert the MD5 string into raw bytes
        var bytes = [UInt8]()
        var index = md5.startIndex
        for _ in 0 ..< 16 {
            let nextIndex = md5.index(index, offsetBy: 2)
            if let byte = UInt8(md5[index ..< nextIndex], radix: 16) {
                bytes.append(byte)
            }
            index = nextIndex
        }

        // Convert the raw bytes into a UUID
        let uuid = UUID(uuid: (
            bytes[0],
            bytes[1],
            bytes[2],
            bytes[3],
            bytes[4],
            bytes[5],
            bytes[6],
            bytes[7],
            bytes[8],
            bytes[9],
            bytes[10],
            bytes[11],
            bytes[12],
            bytes[13],
            bytes[14],
            bytes[15]
        ))
        return uuid
    }
}

// MARK: - Collection Extensions.

extension Collection {
    public func chunked(into size: Int) -> [[Self.Element]] where Self.Index == Int {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, self.count)])
        }
    }

    public func indicesMeeting(condition: (Element) throws -> Bool) rethrows -> [Index]? {
        let indices = try indices.filter { try condition(self[$0]) }
        return indices.isEmpty ? nil : indices
    }
}
