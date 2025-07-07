// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - SDStringEnumCodec

/// SwiftData CloudKit 喜欢把 String-based Enum 保存成 NSKeyedArchiver 处理过的 Plist。
/// 这里准备一套 Codec 方便 CoreData 针对 SwiftData CloudKit 处理数据。
public enum SDStringEnumCodec {
    // MARK: Public

    /// 从 CloudKit NSData（NSKeyedArchiver Plist）解码出 rawValue 字符串
    public static func decodeRawValue(from data: Data) throws -> String {
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)
        // 解析 Plist 结构，找到 rawValue（以 "HSR" 或 "GI" 形式出现）
        guard let dict = plist as? [String: Any],
              let objects = dict["$objects"] as? [Any] else {
            throw NSError(
                domain: "SwiftDataStringEnumCodec",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Plist structure error"]
            )
        }
        // 查找第一个 String 类型且不是 "$null" 或 "__empty_slot_token..." 的字符串
        let stringCandidates = objects.compactMap { $0 as? String }
        // 排除特殊字符串，通常就是 HSR、GI
        let value = stringCandidates.first { $0 != "$null" && !$0.hasPrefix("__empty_slot_token") && $0 != "game" }
        guard let rawValue = value else {
            throw NSError(
                domain: "SwiftDataStringEnumCodec",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "RawValue string not found"]
            )
        }
        return rawValue
    }

    // MARK: Internal

    // 把 rawValue 字符串编码成 CloudKit 需要的 NSData（NSKeyedArchiver Plist 格式）
    // 编码 rawValue 字符串为 CloudKit 兼容 Data（NSKnownKeysDictionary1 格式）
    static func encodeRawValue(_ rawValue: String, forKey key: String) throws -> Data {
        // 必须用 NSDictionary，否则结构和 CloudKit 不兼容
        let dict = NSDictionary(object: rawValue, forKey: key as NSString)
        let data = try NSKeyedArchiver.archivedData(withRootObject: dict, requiringSecureCoding: false)
        return data
    }
}
