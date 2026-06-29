#!/usr/bin/env swift

// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation

// MARK: - GIMaterialDBGenerator

public enum GIMaterialDBGenerator {}

/// 天赋材料 nameTag 以 raw itemID (104301 起、步长 3) 为索引。
/// 104319 是「智識之冕」，無 dungeon，用 nil 占位。
private let talentMaterialTags: [String?] = [
    "talentFreedom", // raw 104301
    "talentResistance", // raw 104304
    "talentBallad", // raw 104307
    "talentProsperity", // raw 104310
    "talentDiligence", // raw 104313
    "talentGold", // raw 104316
    nil, // raw 104319（智識之冕，無 dungeon）
    "talentTransience", // raw 104322
    "talentElegance", // raw 104325
    "talentLight", // raw 104328
    "talentAdmonition", // raw 104331
    "talentIngenuity", // raw 104334
    "talentPraxis", // raw 104337
    "talentEquity", // raw 104340
    "talentJustice", // raw 104343
    "talentOrder", // raw 104346
    "talentContention", // raw 104349
    "talentKindling", // raw 104352
    "talentConflict", // raw 104355
    "talentMoonlight", // raw 104358
    "talentElysium", // raw 104361
    "talentVagrancy", // raw 104364
    // 此处插入原神今后大版本的新的天赋突破材料的命名。
]
/// 武器突破材料 nameTag 以 raw itemID (114001 起、步长 4) 为索引。
private let weaponMaterialTags: [String] = [
    "weaponDecarabian", // raw 114001
    "weaponBorealWolf", // raw 114005
    "weaponGladiator", // raw 114009
    "weaponGuyun", // raw 114013
    "weaponElixir", // raw 114017
    "weaponAerosiderite", // raw 114021
    "weaponDistantSea", // raw 114025
    "weaponNarukami", // raw 114029
    "weaponKijinMask", // raw 114033
    "weaponTalisman", // raw 114037
    "weaponOasisGarden", // raw 114041
    "weaponScorchingMight", // raw 114045
    "weaponAncientChord", // raw 114049
    "weaponDewdrop", // raw 114053
    "weaponPristineSea", // raw 114057
    "weaponSacrificialHeart", // raw 114061
    "weaponSacredLord", // raw 114065
    "weaponNightWind", // raw 114069
    "weaponArtfulDevice", // raw 114073
    "weaponLongNightFlint", // raw 114077
    "weaponFarNorthScions", // raw 114081
    // 此处插入原神今后大版本的新的武器突破材料的命名。
]

/// 天赋材料对应的游戏内 itemID（固定值，不随版本 rawID 变更而变化）。
/// 索引规则同 talentMaterialTags：index = (rawID - 104301) / 3。
private let talentInGameItemIDs: [Int?] = [
    104303, // index 0: talentFreedom
    104306, // index 1: talentResistance
    104309, // index 2: talentBallad
    104312, // index 3: talentProsperity
    104315, // index 4: talentDiligence
    104318, // index 5: talentGold
    nil, // index 6: raw 104319（智識之冕，無 dungeon）
    104322, // index 7: talentTransience
    104325, // index 8: talentElegance
    104328, // index 9: talentLight
    104331, // index10: talentAdmonition
    104334, // index11: talentIngenuity
    104337, // index12: talentPraxis
    104340, // index13: talentEquity
    104343, // index14: talentJustice
    104346, // index15: talentOrder
    104349, // index16: talentContention
    104352, // index17: talentKindling
    104355, // index18: talentConflict
    104358, // index19: talentMoonlight
    104361, // index20: talentElysium
    104364, // index21: talentVagrancy
    // 此处插入原神今后大版本的新的天赋突破材料的游戏内 itemID。
]

/// 根据 raw itemID 推导 nameTag。raw itemID 步长：天赋=3，武器=4。
private func materialNameTag(for rawItemID: Int) -> String {
    if rawItemID >= 110000 {
        let index = (rawItemID - 114001) / 4
        guard index >= 0, index < weaponMaterialTags.count else {
            fatalError("Unknown weapon raw itemID: \(rawItemID)")
        }
        return weaponMaterialTags[index]
    } else {
        let index = (rawItemID - 104301) / 3
        guard index >= 0, index < talentMaterialTags.count,
              let tag = talentMaterialTags[index] else {
            fatalError("Unknown talent raw itemID: \(rawItemID)")
        }
        return tag
    }
}

/// 根据 raw itemID 取得游戏内 itemID（天赋为固定值，武器为 rawID + 3）。
private func inGameItemID(for rawItemID: Int, isWeapon: Bool) -> Int {
    if isWeapon {
        return rawItemID + 3
    } else {
        let index = (rawItemID - 104301) / 3
        guard index >= 0, index < talentInGameItemIDs.count,
              let itemID = talentInGameItemIDs[index] else {
            fatalError("Unknown talent raw itemID: \(rawItemID)")
        }
        return itemID
    }
}

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

        public var isValid: Bool { !dungeonGroup.isEmpty }

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
                // 6.7+ 须并集所有阵列（去重）才能拿到该条目全部副本 ID。
                let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
                var idFound: Int?
                var allDungeonIDs = Set<Int>()
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
                    guard let candidate = try? container.decode([Int].self, forKey: key),
                          !candidate.isEmpty
                    else { continue }
                    allDungeonIDs.formUnion(candidate)
                }
                guard let id = idFound, !allDungeonIDs.isEmpty else {
                    throw DecodingError.dataCorrupted(.init(
                        codingPath: decoder.codingPath,
                        debugDescription: "Cannot decode DailyDungeonConfig: no readable keys nor valid array fields found."
                    ))
                }
                let merged = Array(allDungeonIDs)
                self.id = id
                self.monday = merged
                self.tuesday = merged
                self.wednesday = merged
                self.thursday = merged
                self.friday = merged
                self.saturday = merged
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

    public static var localPath: String?

    // MARK: Fileprivate

    fileprivate static let remoteBaseURL =
        "https://gitlab.com/Dimbreath/AnimeGameData2/-/raw/main/"

    /// 统一从本机路径或线上 URL 读取资料。relativePath 即 ExcelBinOutput/xxx.json。
    fileprivate static func fetchData(relativePath: String) async throws -> Data {
        if let localPath {
            let url = URL(fileURLWithPath: localPath).appendingPathComponent(relativePath)
            return try Data(contentsOf: url)
        }
        let url = URL(string: remoteBaseURL + relativePath)!
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
        // materialWeekdayDB 包含所有稀有度；只取金稀有度（天赋步长=3、武器步长=4）。
        let primaryMaterials: [(Int, Int, Bool)] = materialWeekdayDB.compactMap { itemID, weekday in
            let isWeapon = itemID >= 110000
            let isPrimary: Bool = if isWeapon {
                (itemID - 114001) % 4 == 0
            } else {
                (itemID - 104301) % 3 == 0
            }
            guard isPrimary else { return nil }
            _ = materialNameTag(for: itemID)
            return (itemID, weekday, isWeapon)
        }
        // 按 itemID 升序排列（天赋先、武器后），与旧版输出顺序一致。
        let sortedMaterials = primaryMaterials.sorted { a, b in
            if a.2 != b.2 { return !a.2 }
            return a.0 < b.0
        }

        // 匹配整个素材系列（所有稀有度）而非仅当前 itemID。
        func findUsers4Family(rawItemID: Int, isWeapon: Bool) -> [String] {
            let familyBase: Int
            let familyCount: Int
            if isWeapon {
                familyBase = 114001 + ((rawItemID - 114001) / 4) * 4
                familyCount = 4
            } else {
                let step3base = 104301 + ((rawItemID - 104301) / 3) * 3
                // 6.7: 104319 之前 primary 为家族首元素；之后 primary 为末元素（偏移 -2）。
                familyBase = step3base < 104320 ? step3base : step3base - 2
                familyCount = 3
            }
            let familyItems = Set((0 ..< familyCount).map { familyBase + $0 })
            var results = [String]()
            userMaterialMap.forEach { userID, itemIDSet in
                guard !itemIDSet.isDisjoint(with: familyItems) else { return }
                results.append(userID)
            }
            return results.sorted()
        }

        var allObjs = [GITodayMaterialEncoded]()
        var enumID = 0
        sortedMaterials.forEach { itemID, _, isWeapon in
            defer { enumID += 1 }
            let obj = GITodayMaterialEncoded(
                id: enumID,
                itemID: inGameItemID(for: itemID, isWeapon: isWeapon),
                isWeapon: isWeapon,
                nameTag: materialNameTag(for: itemID),
                costedBy: findUsers4Family(rawItemID: itemID, isWeapon: isWeapon)
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
