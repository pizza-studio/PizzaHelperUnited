// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels

extension EnkaDBModelsHSR.Meta.NestedPropValueMap {
    public func query(id: some StringProtocol, stage: Int) -> [Enka.PropertyType: Double] {
        let rawResult = self[id.description]?[stage.description]?["props"] ?? [:]
        var results = [Enka.PropertyType: Double]()
        for (key, value) in rawResult {
            guard let propKey = Enka.PropertyType(rawValue: key) else { continue }
            results[propKey] = value
        }
        return results
    }

    public func query(id: Int, stage: Int) -> [Enka.PropertyType: Double] {
        query(id: id.description, stage: stage)
    }
}

extension EnkaDBModelsHSR.Meta.RawRelicDB.SubAffix {
    var propertyType: Enka.PropertyType? {
        .init(rawValue: property)
    }
}

extension EnkaDBModelsHSR.Meta.RawRelicDB.MainAffix {
    var propertyType: Enka.PropertyType? {
        .init(rawValue: property)
    }
}
