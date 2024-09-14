// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

extension GITodayMaterial {
    @MainActor public static let bundledData: [Self] = {
        let bundledRawData = NSDataAsset(name: "BundledGIDailyMaterialsData", bundle: .module)!
        return try! JSONDecoder().decode([Self].self, from: bundledRawData.data)
    }()
}

extension String {
    public var i18nTodayMaterials: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }

    public var i18nTodayMaterialNames: String {
        String(localized: .init(stringLiteral: self), table: "MaterialNames", bundle: .module)
    }
}

extension String.LocalizationValue {
    public var i18nTodayMaterials: String {
        String(localized: self, bundle: .module)
    }

    public var i18nTodayMaterialNames: String {
        String(localized: self, table: "MaterialNames", bundle: .module)
    }
}
