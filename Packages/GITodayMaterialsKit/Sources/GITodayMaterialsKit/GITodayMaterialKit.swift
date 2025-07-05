// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
@available(watchOS, unavailable)
extension GITodayMaterial {
    public static let bundledData: [Self] = {
        guard let url = Bundle.module.url(
            forResource: "BundledGIDailyMaterialsData", withExtension: "json"
        ) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([Self].self, from: data)
        } catch {
            NSLog("EnkaKit: Cannot access BundledGIDailyMaterialsData.json.")
            return []
        }
    }()

    // MARK: - TodayMaterialsSupplier

    public struct Supplier {
        // MARK: Lifecycle

        public init(weekday: GITodayMaterial.AvailableWeekDay? = nil) {
            self.weekday = weekday
        }

        // MARK: Public

        public var weekday: GITodayMaterial.AvailableWeekDay? = .today()

        public var weaponMaterials: [GITodayMaterial] {
            GITodayMaterial.bundledData.filter {
                $0.availableWeekDay == weekday && $0.isWeapon
            }
        }

        public var talentMaterials: [GITodayMaterial] {
            GITodayMaterial.bundledData.filter {
                $0.availableWeekDay == weekday && !$0.isWeapon
            }
        }
    }
}

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
@available(watchOS, unavailable)
extension String {
    public var i18nTodayMaterials: String {
        String(localized: .init(stringLiteral: self), bundle: .module)
    }

    public var i18nTodayMaterialNames: String {
        String(localized: .init(stringLiteral: self), table: "MaterialNames", bundle: .module)
    }
}

@available(iOS 15.0, macCatalyst 15.0, macOS 12.0, *)
@available(watchOS, unavailable)
extension String.LocalizationValue {
    public var i18nTodayMaterials: String {
        String(localized: self, bundle: .module)
    }

    public var i18nTodayMaterialNames: String {
        String(localized: self, table: "MaterialNames", bundle: .module)
    }
}
