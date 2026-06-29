#!/usr/bin/env swift

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
    "talentMoonlight",
    "talentElysium",
    "talentVagrancy",
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
    "weaponArtfulDevice",
    "weaponLongNightFlint",
    "weaponFarNorthScions",
    // 此处插入原神今后大版本的新的武器突破材料的命名。
]

// MARK: - DimbreathMaterialRAW

public enum DimbreathMaterialRAW {
    // MARK: Public

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

        /// 负责解码任何结构的每日副本资料。
        /// - 先尝试用可读栏位名称（旧版 Dimbreath 资料）。
        /// - 若失败则用 DynamicCodingKeys 遍历所有混淆栏位，依据值特征（长度 ≥ 3 的 [Int] 阵列）自动判定当天的副本清单。
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
                // 混淆栏位备援：使用 DynamicCodingKeys 遍历所有 key。
                // 选其中最长的 array（3+ 元素）作为当天的副本群组。
                let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
                var idFound: Int?
                var largestArray: [Int] = []
                var loops = 0
                for key in container.allKeys {
                    loops += 1
                    precondition(
                        loops < 200,
                        "DailyDungeonConfigDatum decoding exceeded 200 key iterations; possible infinite loop."
                    )
                    if key.stringValue == "id" {
                        idFound = try container.decode(Int.self, forKey: key)
                        continue
                    }
                    // 只尝试解 [Int]，跳过非阵列栏位。
                    // 阈值设为 1：6.7+ 部分条目只有单一 dungeon（如周日副本）。
                    guard let candidate = try? container.decode([Int].self, forKey: key),
                          !candidate.isEmpty
                    else { continue }
                    if candidate.count > largestArray.count {
                        largestArray = candidate
                    }
                }
                guard let id = idFound, !largestArray.isEmpty else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Cannot decode DailyDungeonConfig: no readable keys nor valid array fields found."
                    ))
                }
                self.id = id
                self.monday = largestArray
                self.tuesday = largestArray
                self.wednesday = largestArray
                self.thursday = largestArray
                self.friday = largestArray
                self.saturday = largestArray
            }
        }

        // MARK: Public

        public enum CodingKeys: String, CodingKey {
            case id
            case monday
            case tuesday
            case wednesday
        }

        public var id: Int
        public var monday, tuesday, wednesday: [Int]
        public var thursday, friday, saturday: [Int]

        // MARK: Private

        /// 接受任意 string value 的 CodingKey，用于遍历混淆栏位。
        private struct DynamicCodingKeys: CodingKey {
            // MARK: Lifecycle

            init?(stringValue: String) { self.stringValue = stringValue }
            init?(intValue: Int) { nil }

            // MARK: Internal

            var stringValue: String

            var intValue: Int? { nil }
        }
    }

    public typealias DailyDungeonConfigData = [DailyDungeonConfigDatum]

    public static let urlPrefix = "https://raw.githubusercontent.com/DimbreathBot/AnimeGameData/refs/heads/master/"
    public static var localPath: String?

    // MARK: Fileprivate

    /// 统一从本机路径或线上 URL 读取资料。relativePath 即 ExcelBinOutput/xxx.json。
    fileprivate static func fetchData(relativePath: String) async throws -> Data {
        if let localPath {
            let url = URL(fileURLWithPath: localPath).appendingPathComponent(relativePath)
            return try Data(contentsOf: url)
        }
        let url = URL(string: urlPrefix + relativePath)!
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

extension DimbreathMaterialRAW.MaterialSourceDataExcelConfigData {
    public static let urlSuffix = "ExcelBinOutput/MaterialSourceDataExcelConfigData.json"
}

extension DimbreathMaterialRAW.DailyDungeonConfigData {
    public static let urlSuffix = "ExcelBinOutput/DailyDungeonConfigData.json"
}

extension DimbreathMaterialRAW {
    public static func assembleMaterialWeekdayDB() async throws -> [Int: Int] {
        fputs("// [1/3] Fetching MaterialSource + DailyDungeon...\n", stderr); fflush(stderr)
        let data4Materials = try await fetchData(relativePath: MaterialSourceDataExcelConfigData.urlSuffix)
        let data4Dungeons = try await fetchData(relativePath: DailyDungeonConfigData.urlSuffix)
        fputs("// [2/3] Decoding...\n", stderr); fflush(stderr)

        let obj4Materials: MaterialSourceDataExcelConfigData
        do {
            obj4Materials = try JSONDecoder().decode(MaterialSourceDataExcelConfigData.self, from: data4Materials)
                .compactMap(\.validSelf)
        } catch {
            print("❌ JSON Decoding Error for MaterialSourceData")
            print("Error details: \(error)")
            throw error
        }

        let obj4Dungeons: DailyDungeonConfigData
        do {
            obj4Dungeons = try JSONDecoder().decode(DailyDungeonConfigData.self, from: data4Dungeons)
        } catch {
            print("❌ JSON Decoding Error for DailyDungeonConfig")
            print("Error details: \(error)")
            throw error
        }

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
        // 6.7+ 每日副本资料已改为按天分条目的格式。
        // 多元素条目（≥3 dungeon）按出现顺序轮转星期（0=MR, 1=TF, 2=WS）。
        // 单元素条目紧跟在多元素条目之后，继承前一组轮转的星期，不推进轮转计数。
        let dayNames = ["MR", "TF", "WS"]
        var rotationIndex = 0
        for dungeon in obj4Dungeons {
            let isMultiDay = dungeon.monday.count >= 3
            let weekday: Int
            if isMultiDay {
                weekday = rotationIndex % dayNames.count
                rotationIndex += 1
            } else {
                // 单元素条目沿用前一组轮转的星期（代表周四/周五/周六与周一/周二/周三对应）。
                weekday = (rotationIndex - 1) % dayNames.count
            }
            dungeon.monday.forEach { dungeonID in
                guard dungeonID != 0, allValidDungeons.contains(dungeonID) else { return }
                if dungeonWeekdayMap[dungeonID] == nil {
                    dungeonWeekdayMap[dungeonID] = weekday
                    print("\(dungeonID) is set on \(dayNames[weekday])")
                }
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
        /// 从 `ExcelBinOutput/AvatarExcelConfigData.json` 取得所有角色 ID。
        /// 过滤掉主角 ID 和超出有效区间的 ID。
        struct AvatarEntry: Decodable { let id: Int }
        let data = try await DimbreathMaterialRAW.fetchData(relativePath: "ExcelBinOutput/AvatarExcelConfigData.json")
        let entries: [AvatarEntry]
        do {
            entries = try JSONDecoder().decode([AvatarEntry].self, from: data)
        } catch {
            print("❌ JSON Decoding Error for AvatarExcelConfigData")
            print("Error details: \(error)")
            throw error
        }
        let excludedIDs: Set<Int> = [10000005, 10000007, 10000117, 10000118]
        let validRange = 10000000 ... 10000800
        return entries.map(\.id)
            .filter { validRange.contains($0) && !excludedIDs.contains($0) }
            .sorted()
    }

    public static func getAllWeaponIDs() async throws -> [Int] {
        /// 从 `ExcelBinOutput/WeaponExcelConfigData.json` 取得所有武器 ID。
        /// 对 3 星以上武器通过 `skillAffix[0] != 0` 过滤掉测试武器与剧情武器。
        /// 1-2 星武器全部保留（它们的 skillAffix[0] 本身就为 0，属于正常情况）。
        struct WeaponEntry: Decodable {
            let id: Int
            let rankLevel: Int?
            let skillAffix: [Int]?
            var isValid: Bool {
                let rank = rankLevel ?? 0
                if rank <= 2 { return true }
                return (skillAffix?.first ?? 0) != 0
            }
        }
        let data = try await DimbreathMaterialRAW.fetchData(relativePath: "ExcelBinOutput/WeaponExcelConfigData.json")
        let entries: [WeaponEntry]
        do {
            entries = try JSONDecoder().decode([WeaponEntry].self, from: data)
        } catch {
            print("❌ JSON Decoding Error for WeaponExcelConfigData")
            print("Error details: \(error)")
            throw error
        }
        // 有效武器 ID 区间：[11100, 20000)。
        // 3 星以上武器额外要求 skillAffix 首个元素不为 0（排除测试/剧情武器）。
        let validRange = 11100 ..< 20000
        return entries
            .filter { validRange.contains($0.id) && $0.isValid }
            .map(\.id)
            .sorted()
    }

    /// 批量构建实体 ID（角色/武器）→ 素材 ID 集合的映射。从 ExcelBinOutput 批量读取。
    /// - 角色: AvatarExcel → SkillDepot → Skill → ProudSkill(costItems)
    /// - 武器: WeaponExcel → WeaponPromote(costItems)
    public static func buildBulkUserMaterialMap(
        charIDs: [Int],
        weaponIDs: [Int]
    ) async throws
        -> [String: Set<Int>] {
        struct AvatarEntry: Decodable { let id: Int; let skillDepotId: Int }
        struct SkillDepotEntry: Decodable { let id: Int; let skills: [Int]?; let energySkill: Int? }
        struct SkillEntry: Decodable { let id: Int; let proudSkillGroupId: Int? }
        struct CostItem: Decodable { let id: Int; let count: Int }
        struct ProudSkillEntry: Decodable {
            let proudSkillGroupId: Int; let level: Int; let costItems: [CostItem]?

            private enum CodingKeys: String, CodingKey {
                case proudSkillGroupId, level, costItems
            }

            private enum CodingKeysAlt: String, CodingKey {
                case costItems = "NJMNABKGKIJ"
            }

            init(from decoder: any Decoder) throws {
                let c = try decoder.container(keyedBy: CodingKeys.self)
                self.proudSkillGroupId = try c.decode(Int.self, forKey: .proudSkillGroupId)
                self.level = try c.decode(Int.self, forKey: .level)
                if c.contains(.costItems) {
                    self.costItems = try c.decodeIfPresent([CostItem].self, forKey: .costItems)
                } else {
                    let cAlt = try decoder.container(keyedBy: CodingKeysAlt.self)
                    self.costItems = try cAlt.decodeIfPresent([CostItem].self, forKey: .costItems)
                }
            }
        }
        struct WeaponExcelEntry: Decodable { let id: Int; let weaponPromoteId: Int? }
        struct WeaponPromoteEntry: Decodable {
            let weaponPromoteId: Int; let costItems: [CostItem]?

            private enum CodingKeys: String, CodingKey {
                case weaponPromoteId, costItems
            }

            private enum CodingKeysAlt: String, CodingKey {
                case costItems = "NJMNABKGKIJ"
            }

            init(from decoder: any Decoder) throws {
                let c = try decoder.container(keyedBy: CodingKeys.self)
                self.weaponPromoteId = try c.decode(Int.self, forKey: .weaponPromoteId)
                if c.contains(.costItems) {
                    self.costItems = try c.decodeIfPresent([CostItem].self, forKey: .costItems)
                } else {
                    let cAlt = try decoder.container(keyedBy: CodingKeysAlt.self)
                    self.costItems = try cAlt.decodeIfPresent([CostItem].self, forKey: .costItems)
                }
            }
        }

        let urlBase = "ExcelBinOutput/"
        // 顺序加载所有 ExcelBinOutput 资料。
        let avatarData = try await DimbreathMaterialRAW
            .fetchData(relativePath: "ExcelBinOutput/AvatarExcelConfigData.json")
        let depotData = try await DimbreathMaterialRAW
            .fetchData(relativePath: "ExcelBinOutput/AvatarSkillDepotExcelConfigData.json")
        let skillData = try await DimbreathMaterialRAW
            .fetchData(relativePath: "ExcelBinOutput/AvatarSkillExcelConfigData.json")
        let proudData = try await DimbreathMaterialRAW
            .fetchData(relativePath: "ExcelBinOutput/ProudSkillExcelConfigData.json")
        let wpnExcelData = try await DimbreathMaterialRAW
            .fetchData(relativePath: "ExcelBinOutput/WeaponExcelConfigData.json")
        let wpnPromData = try await DimbreathMaterialRAW
            .fetchData(relativePath: "ExcelBinOutput/WeaponPromoteExcelConfigData.json")

        let avatarEntries: [AvatarEntry]
        do {
            avatarEntries = try JSONDecoder().decode([AvatarEntry].self, from: try await avatarData)
        } catch {
            print("❌ JSON Decoding Error for URL: \(urlBase)AvatarExcelConfigData.json")
            print("Error details: \(error)")
            throw error
        }

        let depotEntries: [SkillDepotEntry]
        do {
            depotEntries = try JSONDecoder().decode([SkillDepotEntry].self, from: try await depotData)
        } catch {
            print("❌ JSON Decoding Error for URL: \(urlBase)AvatarSkillDepotExcelConfigData.json")
            print("Error details: \(error)")
            throw error
        }

        let skillEntries: [SkillEntry]
        do {
            skillEntries = try JSONDecoder().decode([SkillEntry].self, from: try await skillData)
        } catch {
            print("❌ JSON Decoding Error for URL: \(urlBase)AvatarSkillExcelConfigData.json")
            print("Error details: \(error)")
            throw error
        }

        let proudEntries: [ProudSkillEntry]
        do {
            proudEntries = try JSONDecoder().decode([ProudSkillEntry].self, from: try await proudData)
        } catch {
            print("❌ JSON Decoding Error for URL: \(urlBase)ProudSkillExcelConfigData.json")
            print("Error details: \(error)")
            throw error
        }

        let wpnExcelEntries: [WeaponExcelEntry]
        do {
            wpnExcelEntries = try JSONDecoder().decode(
                [WeaponExcelEntry].self, from: try await wpnExcelData
            )
        } catch {
            print("❌ JSON Decoding Error for URL: \(urlBase)WeaponExcelConfigData.json")
            print("Error details: \(error)")
            throw error
        }

        let wpnPromEntries: [WeaponPromoteEntry]
        do {
            wpnPromEntries = try JSONDecoder().decode(
                [WeaponPromoteEntry].self, from: try await wpnPromData
            )
        } catch {
            print("❌ JSON Decoding Error for URL: \(urlBase)WeaponPromoteExcelConfigData.json")
            print("Error details: \(error)")
            throw error
        }

        // 构建查找表。
        let avatarToDepot = Dictionary(
            avatarEntries.map { ($0.id, $0.skillDepotId) },
            uniquingKeysWith: { a, _ in a }
        )
        let depotMap = Dictionary(
            depotEntries.map { ($0.id, $0) },
            uniquingKeysWith: { a, _ in a }
        )
        let skillToProudGroup = Dictionary(
            skillEntries.compactMap { s in s.proudSkillGroupId.map { (s.id, $0) } },
            uniquingKeysWith: { a, _ in a }
        )

        // proudSkillGroupId → 所有等级的素材 ID 集合。
        var proudGroupMaterials = [Int: Set<Int>]()
        for entry in proudEntries where entry.level >= 2 {
            guard let items = entry.costItems else { continue }
            let ids = Set(items.map(\.id).filter { $0 > 0 })
            proudGroupMaterials[entry.proudSkillGroupId, default: []].formUnion(ids)
        }

        // weaponPromoteId → 所有突破等级的素材 ID 集合。
        var wpnPromoteMaterials = [Int: Set<Int>]()
        for entry in wpnPromEntries {
            guard let items = entry.costItems else { continue }
            let ids = Set(items.map(\.id).filter { $0 > 0 })
            wpnPromoteMaterials[entry.weaponPromoteId, default: []].formUnion(ids)
        }

        let wpnToPromoteId = Dictionary(
            wpnExcelEntries.compactMap { w in w.weaponPromoteId.map { (w.id, $0) } },
            uniquingKeysWith: { a, _ in a }
        )

        // 构建结果映射。
        var result = [String: Set<Int>]()

        for charID in charIDs {
            guard let depotId = avatarToDepot[charID] else { continue }
            guard let depot = depotMap[depotId] else { continue }
            var materialIDs = Set<Int>()
            let allSkillIDs = (depot.skills ?? []) + [depot.energySkill].compactMap { $0 }
            for skillID in allSkillIDs where skillID > 0 {
                guard let groupId = skillToProudGroup[skillID] else { continue }
                if let mats = proudGroupMaterials[groupId] {
                    materialIDs.formUnion(mats)
                }
            }
            if !materialIDs.isEmpty {
                result[charID.description] = materialIDs
            }
        }

        for weaponID in weaponIDs {
            guard let promoteId = wpnToPromoteId[weaponID] else { continue }
            if let mats = wpnPromoteMaterials[promoteId] {
                result[weaponID.description] = mats
            }
        }

        return result
    }

    public static func compileMaterialDB() async throws -> [GITodayMaterialEncoded] {
        let allCharIDs = try await getAllCharIDsExceptProtagonists()
        let allWeaponIDs = try await getAllWeaponIDs()

        let userMaterialMap = try await buildBulkUserMaterialMap(
            charIDs: allCharIDs, weaponIDs: allWeaponIDs
        )

        func findUsers(itemID: Int) -> [String] {
            var results = [String]()
            userMaterialMap.forEach { userID, itemIDSet in
                guard itemIDSet.contains(itemID) else { return }
                results.append(userID)
            }
            return results.sorted()
        }

        let materialWeekdayDB = try await DimbreathMaterialRAW.assembleMaterialWeekdayDB()
        // 如果线上资料缺了某些材料（比如 dungeons 4233, 4333 等还没有 weekday），
        // 则只产出有 weekday 的材料，不再严格要求数量匹配。
        let sortedMaterials = materialWeekdayDB.sorted { $0.key < $1.key }
        guard sortedMaterials.count >= materialNameTags.count - 2 else {
            print(materialWeekdayDB)
            print("!!! ERROR: Too many missing materials; check materialNameTags.")
            exit(1)
        }

        var allObjs = [GITodayMaterialEncoded]()
        var enumID = 0
        sortedMaterials.forEach { itemID, _ in
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

var targetJSONPath =
    "./Packages/GITodayMaterialsKit/Sources/GITodayMaterialsKit/Resources/BundledGIDailyMaterialsData.json"

// Parse optional -localPath argument.
if let idx = CommandLine.arguments.firstIndex(of: "-localPath"), CommandLine.arguments.count > idx + 1 {
    DimbreathMaterialRAW.localPath = CommandLine.arguments[idx + 1]
    fputs("// Using local data: \(CommandLine.arguments[idx + 1])\n", stderr)
}

// Parse optional -output arg.
if let idx = CommandLine.arguments.firstIndex(of: "-output"), CommandLine.arguments.count > idx + 1 {
    targetJSONPath = CommandLine.arguments[idx + 1]
}

print("// Compiling GI Material DB...")
let encoded = try await GIMaterialDBGenerator.compileMaterialDB().printEncoded()
try encoded.write(to: URL(fileURLWithPath: targetJSONPath), options: .atomic)
print("// Done. Written to \(targetJSONPath)")
