// This implementation is considered as copyleft from public domain.

import Foundation

// MARK: - Decoding Strategy for Decoding UpperCamelCases

extension JSONDecoder.KeyDecodingStrategy {
    public static var convertFromPascalCase: Self {
        .custom { keys in
            PascalCaseKey(stringValue: keys.last!.stringValue)
        }
    }
}

// MARK: - PascalCaseKey

private struct PascalCaseKey: CodingKey {
    // MARK: Lifecycle

    init(stringValue str: String) {
        let allCapicalized = str.filter(\.isLowercase).isEmpty
        guard !allCapicalized else {
            self.stringValue = str.lowercased()
            self.intValue = nil
            return
        }
        var count = 0
        perCharCheck: for char in str {
            if char.isUppercase {
                count += 1
            } else {
                break perCharCheck
            }
        }
        if count > 1 {
            count -= 1
        }
        self.stringValue = str.prefix(count).lowercased() + str.dropFirst(count)
        self.intValue = nil
    }

    init(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }

    // MARK: Internal

    let stringValue: String
    let intValue: Int?
}
