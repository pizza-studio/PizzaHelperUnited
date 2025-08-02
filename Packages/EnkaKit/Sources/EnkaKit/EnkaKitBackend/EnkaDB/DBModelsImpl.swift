// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import EnkaDBModels

@available(iOS 17.0, macCatalyst 17.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, *)
extension EnkaDBModelsHSR.Meta.RawRelicDB.SubAffix {
    var propertyType: Enka.PropertyType? {
        .init(rawValue: property)
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension EnkaDBModelsHSR.Meta.RawRelicDB.MainAffix {
    var propertyType: Enka.PropertyType? {
        .init(rawValue: property)
    }
}
