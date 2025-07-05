// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension EnkaDBModelsHSR.Meta.NestedPropValueMap {
    public func query(id: some StringProtocol, stage: Int) -> [Enka.PropertyType: Double] {
        let rawResult = self[id.description]?[stage.description]?["props"] ?? [:]
        var results = [Enka.PropertyType: Double]()
        for (key, value) in rawResult {
            let propKey = Enka.PropertyType(rawValue: key)
            guard propKey != .unknownType else { continue }
            results[propKey] = value
        }
        return results
    }

    public func query(id: Int, stage: Int) -> [Enka.PropertyType: Double] {
        query(id: id.description, stage: stage)
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension EnkaDBModelsHSR.Meta.RawRelicDB.SubAffix {
    var propertyType: Enka.PropertyType? {
        .init(rawValue: property)
    }
}

@available(iOS 17.0, *)
@available(macCatalyst 17.0, *)
@available(macOS 14.0, *)
extension EnkaDBModelsHSR.Meta.RawRelicDB.MainAffix {
    var propertyType: Enka.PropertyType? {
        .init(rawValue: property)
    }
}
