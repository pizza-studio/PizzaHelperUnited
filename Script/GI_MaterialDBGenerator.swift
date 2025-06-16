// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - GIMaterialDBGenerator

public enum GIMaterialDBGenerator {}

private let materialNameTags: [String] = [
    "talentFreedom",
    "talentResistance",
    "talentBallad",
    "talentProsperity",
    "talentDiligence",
    "talentGold",
    "talentTransience",
    "talentElegance",
    "talentLight",
    "talentAdmonition",
    "talentIngenuity",
    "talentPraxis",
    "talentEquity",
    "talentJustice",
    "talentOrder",
    "talentContention",
    "talentKindling",
    "talentConflict",
    // 此处插入原神今后大版本的新的天赋突破材料的命名。
    "weaponDecarabian",
    "weaponBorealWolf",
    "weaponGladiator",
    "weaponGuyun",
    "weaponElixir",
    "weaponAerosiderite",
    "weaponDistantSea",
    "weaponNarukami",
    "weaponKijinMask",
    "weaponTalisman",
    "weaponOasisGarden",
    "weaponScorchingMight",
    "weaponAncientChord",
    "weaponDewdrop",
    "weaponPristineSea",
    "weaponSacrificialHeart",
    "weaponSacredLord",
    "weaponNightWind",
    // 此处插入原神今后大版本的新的武器突破材料的命名。
]

// MARK: - GIMaterialMetaQueried

public enum GIMaterialMetaQueried {
    public protocol GIMaterialMetaProtocol: Codable, Hashable, Sendable {
        var allUnits: [MaterialUnit] { get }
    }

    public struct MaterialUnit: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case name = "Name"
            case id = "Id"
            case count = "Count"
            case rank = "Rank"
        }

        public var name: String
        public var id, count, rank: Int

        public var assetURLString: String {
            Self.assetURLString(id: id.description)
        }

        public static func assetURLString(id: String) -> String {
            "https://api.hakush.in/gi/UI/UI_ItemIcon_\(id).webp"
        }
    }

    public struct GICharMaterialMeta: GIMaterialMetaProtocol {
        public enum CodingKeys: String, CodingKey {
            case materials = "Materials"
        }

        public struct Materials: Codable, Hashable, Sendable {
            public enum CodingKeys: String, CodingKey {
                case talents = "Talents"
            }

            public struct Talent: Codable, Hashable, Sendable {
                public enum CodingKeys: String, CodingKey {
                    case mats = "Mats"
                    case cost = "Cost"
                }

                public var mats: [GIMaterialMetaQueried.MaterialUnit]
                public var cost: Int
            }

            public var talents: [[Talent]]
        }

        public var materials: Materials

        public var first: MaterialUnit? { materials.talents.first?.first?.mats.first }

        public var allUnits: [MaterialUnit] {
            materials.talents.map { $0.map(\.mats).reduce([], +) }.reduce([], +)
        }
    }

    public struct GIWeaponMaterialMeta: GIMaterialMetaProtocol {
        public enum CodingKeys: String, CodingKey {
            case materials = "Materials"
        }

        public struct Material: Codable, Hashable, Sendable {
            public enum CodingKeys: String, CodingKey {
                case mats = "Mats"
                case cost = "Cost"
            }

            public var mats: [GIMaterialMetaQueried.MaterialUnit]
            public var cost: Int
        }

        public var materials: [String: Material]

        public var first: MaterialUnit? { materials["1"]?.mats.first }

        public var allUnits: [MaterialUnit] {
            materials.values.map(\.mats).reduce([], +)
        }
    }

    public static func queryMaterials(for id: String) async throws -> [GIMaterialMetaQueried.MaterialUnit] {
        guard let intID = Int(id) else { return [] }
        var isWeapon: Bool
        switch id.count {
        case 8: isWeapon = false // Character
        case 0 ..< 8: isWeapon = true // Weapon
        default: return []
        }
        let urlString = switch isWeapon {
        case false: "https://api.hakush.in/gi/data/zh/character/\(intID).json"
        case true: "https://api.hakush.in/gi/data/zh/weapon/\(intID).json"
        }
        guard let url = URL(string: urlString) else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded: any GIMaterialMetaProtocol
        switch isWeapon {
        case false:
            decoded = try JSONDecoder().decode(GICharMaterialMeta.self, from: data)

        case true:
            decoded = try JSONDecoder().decode(GIWeaponMaterialMeta.self, from: data)
        }
        return decoded.allUnits
    }
}

// MARK: - DimbreathMaterialRAW

public enum DimbreathMaterialRAW {
    public struct MaterialSourceDataExcelConfigDatum: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.id = try container.decode(Int.self, forKey: .id)
            self.dungeonGroup = (try container.decodeIfPresent([Int].self, forKey: .dungeonGroup)) ?? []
            self.dungeonList = (try container.decodeIfPresent([Int].self, forKey: .dungeonList)) ?? []
        }

        // MARK: Public

        public var id: Int
        public var dungeonGroup: [Int]
        public var dungeonList: [Int]

        public var isValid: Bool { !dungeonGroup.isEmpty && dungeonGroup.first == dungeonList.first }

        public var validSelf: Self? { isValid ? self : nil }

        // MARK: Private

        private enum CodingKeys: String, CodingKey {
            case id
            case dungeonGroup
            case dungeonList
        }
    }

    public typealias MaterialSourceDataExcelConfigData = [MaterialSourceDataExcelConfigDatum]

    public struct DailyDungeonConfigDatum: Codable, Hashable, Sendable {
        // MARK: Lifecycle

        public init(from decoder: any Decoder) throws {
            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.id = try container.decode(Int.self, forKey: .id)
                self.monday = try container.decode([Int].self, forKey: .monday)
                self.tuesday = try container.decode([Int].self, forKey: .tuesday)
                self.wednesday = try container.decode([Int].self, forKey: .wednesday)
                self.thursday = monday
                self.friday = tuesday
                self.saturday = wednesday
            } catch {
                let container = try decoder.container(keyedBy: CodingKeysAlt.self)
                self.id = try container.decode(Int.self, forKey: .id)
                self.monday = try container.decode([Int].self, forKey: .monday)
                self.tuesday = try container.decode([Int].self, forKey: .tuesday)
                self.wednesday = try container.decode([Int].self, forKey: .wednesday)
                self.thursday = monday
                self.friday = tuesday
                self.saturday = wednesday
            }
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id
            case monday
            case tuesday
            case wednesday
        }

        public enum CodingKeysAlt: String, CodingKey {
            case id
            case monday = "BEAGFJKPPFP"
            case tuesday = "JKFMKKBLCGP"
            case wednesday = "GCFOIINPCMI"
        }

        public var id: Int
        public var monday, tuesday, wednesday: [Int]
        public var thursday, friday, saturday: [Int]
    }

    public typealias DailyDungeonConfigData = [DailyDungeonConfigDatum]

    public static let urlPrefix = "https://gitlab.com/Dimbreath/AnimeGameData/-/raw/master/"
}

extension DimbreathMaterialRAW.MaterialSourceDataExcelConfigData {
    public static let urlSuffix = "ExcelBinOutput/MaterialSourceDataExcelConfigData.json"
}

extension DimbreathMaterialRAW.DailyDungeonConfigData {
    public static let urlSuffix = "ExcelBinOutput/DailyDungeonConfigData.json"
}

extension DimbreathMaterialRAW {
    public static func assembleMaterialWeekdayDB() async throws -> [Int: Int] {
        let urlAllMaterials = URL(string: urlPrefix + MaterialSourceDataExcelConfigData.urlSuffix)!
        let urlAllDungeons = URL(string: urlPrefix + DailyDungeonConfigData.urlSuffix)!
        let (data4Materials, _) = try await URLSession.shared.data(from: urlAllMaterials)
        let (data4Dungeons, _) = try await URLSession.shared.data(from: urlAllDungeons)
        let obj4Materials = try JSONDecoder().decode(MaterialSourceDataExcelConfigData.self, from: data4Materials)
            .compactMap(\.validSelf)
        let obj4Dungeons = try JSONDecoder().decode(DailyDungeonConfigData.self, from: data4Dungeons)
        assert(!obj4Dungeons.isEmpty)
        // ---------------------
        var itemIDtoDungeonID = [Int: Int]()
        obj4Materials.forEach { material in
            guard let dungeonGroupID = material.dungeonGroup.last else { return }
            itemIDtoDungeonID[material.id] = dungeonGroupID
        }
        assert(!itemIDtoDungeonID.isEmpty)
        // ---------------------
        var dungeonWeekdayMap = [Int: Int]() // 0 = MR, 1 = TF, 2 = WS.
        let allValidDungeons = itemIDtoDungeonID.values
        assert(!allValidDungeons.isEmpty)
        print("AllValidDungeons: \(allValidDungeons)")
        print("Obj4Dungeons: \(obj4Dungeons)")
        obj4Dungeons.forEach { dungeon in
            dungeon.monday.forEach {
                print("Cheking \($0)...")
                guard allValidDungeons.contains($0) else { return }
                dungeonWeekdayMap[$0] = 0
                print("\($0) is set on MR")
            }
            dungeon.tuesday.forEach {
                print("Cheking \($0)...")
                guard allValidDungeons.contains($0) else { return }
                dungeonWeekdayMap[$0] = 1
                print("\($0) is set on TF")
            }
            dungeon.wednesday.forEach {
                print("Cheking \($0)...")
                guard allValidDungeons.contains($0) else { return }
                dungeonWeekdayMap[$0] = 2
                print("\($0) is set on WS")
            }
        }
        assert(!dungeonWeekdayMap.isEmpty)
        // ---------------------
        var itemWeekdayMap = [Int: Int]()
        itemIDtoDungeonID.forEach { itemID, dungeonID in
            guard let weekday = dungeonWeekdayMap[dungeonID] else {
                print("dungeonID \(dungeonID) has no data in dungeonWeekdayMap.")
                return
            }
            itemWeekdayMap[itemID] = weekday
        }
        return itemWeekdayMap
    }
}

extension Encodable {
    @discardableResult
    func printEncoded() -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let encoded = (try? encoder.encode(self)) ?? Data([])
        let encodedStr = String(data: encoded, encoding: .utf8) ?? ""
        print(encodedStr)
        return encoded
    }
}

extension GIMaterialDBGenerator {
    // MARK: - GITodayMaterial

    public struct GITodayMaterialEncoded: Codable, Identifiable, Equatable, Hashable, Sendable {
        public let id: Int
        public let itemID: Int
        public let isWeapon: Bool
        public let nameTag: String
        public var costedBy: [String]
    }

    public static func getAllCharIDsExceptProtagonists() async throws -> [Int] {
        let url = URL(string: "https://api.hakush.in/gi/data/character.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return decoded.keys.compactMap { Int($0) }.sorted()
    }

    public static func getAllWeaponIDs() async throws -> [Int] {
        let url = URL(string: "https://api.hakush.in/gi/data/weapon.json")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return decoded.keys.compactMap { Int($0) }.sorted()
    }

    public static func compileMaterialDB() async throws -> [GITodayMaterialEncoded] {
        let allCharIDs = try await getAllCharIDsExceptProtagonists()
        let allWeaponIDs = try await getAllWeaponIDs()

        var userMaterialMap = [String: Set<Int>]()

        for userID in allWeaponIDs + allCharIDs {
            let queried = try await GIMaterialMetaQueried.queryMaterials(for: userID.description).map(\.id)
            userMaterialMap[userID.description] = Set(queried)
        }

        func findUsers(itemID: Int) -> [String] {
            var results = [String]()
            userMaterialMap.forEach { userID, itemIDSet in
                guard itemIDSet.contains(itemID) else { return }
                results.append(userID)
            }
            return results.sorted()
        }

        let materialWeekdayDB = try await DimbreathMaterialRAW.assembleMaterialWeekdayDB()
        guard materialNameTags.count == materialWeekdayDB.count else {
            print(materialWeekdayDB)
            print("!!! ERROR: materialNameTags needs update!!!!")
            exit(1)
        }

        var allObjs = [GITodayMaterialEncoded]()
        var enumID = 0
        materialWeekdayDB.sorted { $0.key < $1.key }.forEach { itemID, _ in
            defer { enumID += 1 }
            let obj = GITodayMaterialEncoded(
                id: enumID,
                itemID: itemID + (itemID >= 110000 ? 3 : 2),
                isWeapon: itemID >= 110000,
                nameTag: materialNameTags[enumID],
                costedBy: findUsers(itemID: itemID)
            )
            allObjs.append(obj)
        }
        return allObjs
    }
}

// MARK: - Compilation process

let targetJSONPath =
    "./Packages/GITodayMaterialsKit/Sources/GITodayMaterialsKit/Resources/BundledGIDailyMaterialsData.json"
let encoded = try await GIMaterialDBGenerator.compileMaterialDB().printEncoded()
try encoded.write(to: URL(fileURLWithPath: targetJSONPath), options: .atomic)
