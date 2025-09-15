#!/usr/bin/env swift

import AppKit
import AVFoundation
import Foundation

// 该脚本为原神专用。

// 下述 hash 对应的素材必须排除在抓取范围之外。

let forbiddenNameTextMapHashes: [Int] = [
    1595734083, 2719832059, 2009975571, 4137694339, 500987603, 3762437019, 4162981171,
]

// 下述档案名称对应的全都是无效档案，应全部排除在最终抓取的内容范围之外。

let bannedFinalFileNames: [String] = [
    "gi_relic_10000_2.png",
    "gi_relic_10000_4.png",
    "gi_relic_15000_1.png",
    "gi_relic_15000_2.png",
    "gi_relic_15000_3.png",
    "gi_relic_15000_4.png",
    "gi_relic_15000_5.png",
    "gi_relic_15004_1.png",
    "gi_relic_15004_2.png",
    "gi_relic_15004_3.png",
    "gi_relic_15004_4.png",
    "gi_relic_15004_5.png",
    "gi_relic_15012_3.png",
    "gi_skill_A_DreamExplore.png",
    "gi_skill_A_Dvalin_AirGun.png",
    "gi_skill_Btn_Arana_Exchange.png",
    "gi_skill_Btn_Arana_Shoot.png",
    "gi_skill_Btn_Blocking.png",
    "gi_skill_Btn_Blocking_Burst01.png",
    "gi_skill_Btn_Blocking_Burst02.png",
    "gi_skill_Btn_Blocking_Burst03.png",
    "gi_skill_Btn_BounceConjuring_Bomb_S_01.png",
    "gi_skill_Btn_BounceConjuring_Bomb_S_02.png",
    "gi_skill_Btn_BounceConjuring_Bomb_S_03.png",
    "gi_skill_Btn_BounceConjuring_Hit_A_01.png",
    "gi_skill_Btn_BounceConjuring_Serve_S_01.png",
    "gi_skill_Btn_BrickBreaker_Launch.png",
    "gi_skill_Btn_CatchAnimal_Shoot.png",
    "gi_skill_Btn_FairyBook_OrigamFrog.png",
    "gi_skill_Btn_FairyBook_OrigamiAlpaca.png",
    "gi_skill_Btn_FairyBook_OrigamiSquirrel_01.png",
    "gi_skill_Btn_FairyBook_OrigamiSquirrel_02.png",
    "gi_skill_Btn_FairyBook_ToyBrick.png",
    "gi_skill_Btn_Fishing_Bait.png",
    "gi_skill_Btn_Fishing_Battle.png",
    "gi_skill_Btn_Fishing_Cast.png",
    "gi_skill_Btn_Fishing_Exit.png",
    "gi_skill_Btn_Fishing_Pull.png",
    "gi_skill_Btn_FlightSprint.png",
    "gi_skill_Btn_FungusFighter_Aim.png",
    "gi_skill_Btn_HideAndSeekV4_Hider_A_01.png",
    "gi_skill_Btn_HideAndSeekV4_Hider_A_02.png",
    "gi_skill_Btn_HideAndSeekV4_Hider_E.png",
    "gi_skill_Btn_HideAndSeekV4_Hider_S.png",
    "gi_skill_Btn_HideAndSeekV4_Seeker_A_01.png",
    "gi_skill_Btn_HideAndSeekV4_Seeker_A_02.png",
    "gi_skill_Btn_HideAndSeekV4_Seeker_A_03.png",
    "gi_skill_Btn_HideAndSeekV4_Seeker_E_01.png",
    "gi_skill_Btn_HideAndSeekV4_Seeker_E_02.png",
    "gi_skill_Btn_HideAndSeekV4_Seeker_E_03.png",
    "gi_skill_Btn_HideAndSeekV4_Seeker_S.png",
    "gi_skill_Btn_HideAndSeek_Hider_A_01.png",
    "gi_skill_Btn_HideAndSeek_Hider_A_03.png",
    "gi_skill_Btn_HideAndSeek_Hider_E_01.png",
    "gi_skill_Btn_HideAndSeek_Hider_S_01.png",
    "gi_skill_Btn_HideAndSeek_Hider_S_01_Borbid.png",
    "gi_skill_Btn_HideAndSeek_Hider_S_02.png",
    "gi_skill_Btn_HideAndSeek_Hider_S_02_Borbid.png",
    "gi_skill_Btn_HideAndSeek_Seeker_A_01.png",
    "gi_skill_Btn_HideAndSeek_Seeker_E_01.png",
    "gi_skill_Btn_HideAndSeek_Seeker_E_02.png",
    "gi_skill_Btn_HideAndSeek_Seeker_E_03.png",
    "gi_skill_Btn_HideAndSeek_Seeker_S_01.png",
    "gi_skill_Btn_HideAndSeek_Seeker_S_02.png",
    "gi_skill_Btn_PacMan.png",
    "gi_skill_Btn_Recon_Bait.png",
    "gi_skill_Btn_Recon_Bait_Beans.png",
    "gi_skill_Btn_Rises.png",
    "gi_skill_Btn_SlimeCannon_Fire_01.png",
    "gi_skill_Btn_SlimeCannon_Fire_04.png",
    "gi_skill_Btn_Temari_S_01.png",
    "gi_skill_Btn_Turn.png",
    "gi_skill_Btn_WaterSpirit_Skill.png",
    "gi_skill_Btn_Whale_Interrupt.png",
    "gi_skill_CarpJump_01.png",
    "gi_skill_CarpJump_02.png",
    "gi_skill_C_FairyGadgetSet.png",
    "gi_skill_Diving_Absorb.png",
    "gi_skill_Diving_Echo.png",
    "gi_skill_Diving_Jellyfish.png",
    "gi_skill_Diving_Jellyfish_Trigger.png",
    "gi_skill_Diving_Octopus.png",
    "gi_skill_Diving_Shield.png",
    "gi_skill_Diving_Slash.png",
    "gi_skill_E_BubbleGun_01.png",
    "gi_skill_E_Gagana_AimShoot.png",
    "gi_skill_E_Kate.png",
    "gi_skill_E_Monster_Shougun_EyeStrip.png",
    "gi_skill_E_Olorun_Create.png",
    "gi_skill_E_Qin.png",
    "gi_skill_E_SummerTimeV2Quest_BanSkill.png",
    "gi_skill_FairyTalesCurrent_Charge.png",
    "gi_skill_FairyTalesCurrent_Normal.png",
    "gi_skill_LanV3_Icon05.png",
    "gi_skill_LanV4PartyLion_01.png",
    "gi_skill_Main_AimActive.png",
    "gi_skill_Music.png",
    "gi_skill_PoetryFestival_PitchPot_Icon01.png",
    "gi_skill_QuesteventSkillIcon_01.png",
    "gi_skill_S_Kate_01.png",
    "gi_skill_S_Kinich_06.png",
    "gi_skill_S_Kinich_07.png",
    "gi_skill_S_LunaRiteQuest_BanSkill.png",
    "gi_skill_S_Monster_Shougun_EyeStrip.png",
    "gi_skill_S_Mualani_05.png",
    "gi_skill_S_SummerTimeV2Quest_BanSkill.png",
    "gi_skill_UI_Icon_ColoringSpirit.png",
    "gi_skill_UI_Icon_Hunter_Net.png",
    "gi_skill_UI_Img_MVM_01.png",
    "gi_skill_UI_Img_MVM_02.png",
    "gi_skill_UI_Img_MVM_03.png",
    "gi_skill_UI_Img_MVM_Summon.png",
    "gi_weapon_11419.png",
    "gi_weapon_11420.png",
    "gi_weapon_11421.png",
    "gi_weapon_12304.png",
    "gi_weapon_13304.png",
    "gi_weapon_14306.png",
    "gi_weapon_15306.png",
]

// MARK: - ImageProcessingError

enum ImageProcessingError: Error {
    case imageInitializationFailed
    case bitmapCreationFailed
    case jpegConversionFailed
}

func reencodePNG(from imageData: Data) throws -> Data {
    guard let image = NSImage(data: imageData) else {
        throw ImageProcessingError.imageInitializationFailed
    }

    // Create a new size for the image
    let newSize = image.size

    // Create a new bitmap representation for the resized image
    guard let bitmapRep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: Int(newSize.width),
        pixelsHigh: Int(newSize.height),
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw ImageProcessingError.bitmapCreationFailed
    }

    // Draw the image into the new size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
    image.draw(
        in: NSRect(origin: .zero, size: newSize),
        from: NSRect(origin: .zero, size: image.size),
        operation: .sourceOver,
        fraction: 1.0,
        respectFlipped: false,
        hints: [.interpolation: NSImageInterpolation.high]
    )
    NSGraphicsContext.restoreGraphicsState()

    // Convert the resized image to JPEG data with 82% quality
    guard let jpegData = bitmapRep.representation(using: .png, properties: [.compressionFactor: 0.82]) else {
        throw ImageProcessingError.jpegConversionFailed
    }

    return jpegData
}

// MARK: - Decoding Strategy for Decoding UpperCamelCases

extension JSONDecoder.KeyDecodingStrategy {
    static var convertFromPascalCase: Self {
        .custom { keys in
            PascalCaseKey(stringValue: keys.last!.stringValue)
        }
    }
}

// MARK: - PascalCaseKey

struct PascalCaseKey: CodingKey {
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

// MARK: - Extract Filename Stem

extension String {
    func extractFileNameStem() -> String {
        split(separator: "/").last?.split(separator: ".").dropLast().joined(separator: ".").description ?? self
    }
}

// MARK: - AvatarExcelConfigData

struct AvatarExcelConfigData: Hashable, Codable, Identifiable {
    let id: Int
    let nameTextMapHash: Int
    let iconName: String
    let skillDepotId: Int

    var newFileNameStem: String {
        id.description
    }

    var isValid: Bool {
        guard !forbiddenNameTextMapHashes.contains(nameTextMapHash) else { return false }
        guard skillDepotId != 101 else { return false }
        guard !iconName.hasSuffix("_Kate") else { return false }
        guard id.description.prefix(2) != "11" else { return false }
        // 回头注意检查这句是否在今后的版本需要删掉。
        guard !id.description.hasPrefix("100009") else { return false }
        return true
    }
}

// MARK: - AvatarCostumeExcelConfigData

struct AvatarCostumeExcelConfigData: Hashable, Codable, Identifiable {
    let skinId: Int
    let characterId: Int
    let frontIconName: String
    let nameTextMapHash: Int

    var id: Int { skinId }

    var newFileNameStem: String {
        "\(characterId)_\(skinId)"
    }

    var isValid: Bool {
        guard !forbiddenNameTextMapHashes.contains(nameTextMapHash) else { return false }
        return !frontIconName.isEmpty
    }
}

// MARK: - AvatarSkillExcelConfigData

struct AvatarSkillExcelConfigData: Hashable, Codable, Identifiable {
    let id: Int
    let nameTextMapHash: Int
    let skillIcon: String

    var newFileNameStem: String {
        skillIcon.replacingOccurrences(of: "Skill_", with: "")
    }

    var isValid: Bool {
        guard !forbiddenNameTextMapHashes.contains(nameTextMapHash) else { return false }
        return !skillIcon.isEmpty && !isPurgeable
    }

    var isPurgeable: Bool {
        guard skillIcon.hasPrefix("Skill_S_") else { return false }
        return skillIcon.hasSuffix("_02") && id != 10033 // Jean is a special case.
    }
}

// MARK: - ReliquaryExcelConfigData

struct ReliquaryExcelConfigData: Hashable, Codable, Identifiable {
    let id: Int
    let icon: String
    let nameTextMapHash: Int

    var newFileNameStem: String {
        icon.replacingOccurrences(of: "UI_RelicIcon_", with: "")
    }

    var isValid: Bool {
        !forbiddenNameTextMapHashes.contains(nameTextMapHash)
    }
}

// MARK: - WeaponExcelConfigData

struct WeaponExcelConfigData: Hashable, Codable, Identifiable {
    let id: Int
    let awakenIcon: String
    let nameTextMapHash: Int

    var newFileNameStem: String {
        id.description
    }

    var isValid: Bool {
        !forbiddenNameTextMapHashes.contains(nameTextMapHash)
    }
}

// MARK: - ProfilePictureExcelConfigData

struct ProfilePictureExcelConfigData: Hashable, Codable, Identifiable {
    let id: Int
    let iconPath: String

    var newFileNameStem: String {
        id.description
    }
}

// MARK: - DataType

public enum DataType: String, CaseIterable {
    case profilePicture
    case character
    case characterCostumed
    case weapon
    case artifact
    case skill

    // MARK: Public

    public func generateLinkDataDict() async throws -> [String: String] {
        var dict = [String: String]()
        guard let sourceURL = sourceURL else { return [:] }
        let (data, _) = try await URLSession.shared.data(from: sourceURL)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromPascalCase

        do {
            switch self {
            case .profilePicture:
                let buffer = try decoder.decode([ProfilePictureExcelConfigData].self, from: data)
                buffer.forEach { obj in
                    writeKeyValuePair(id: obj.newFileNameStem, dict: &dict, sourceFileName: obj.iconPath)
                }
            case .skill:
                let buffer = try decoder.decode([AvatarSkillExcelConfigData].self, from: data)
                buffer.filter(\.isValid).forEach { obj in
                    writeKeyValuePair(id: obj.newFileNameStem, dict: &dict, sourceFileName: obj.skillIcon)
                }
            case .character:
                let buffer = try decoder.decode([AvatarExcelConfigData].self, from: data)
                buffer.filter(\.isValid).forEach { obj in
                    writeKeyValuePair(id: obj.newFileNameStem, dict: &dict, sourceFileName: obj.iconName)
                }
            case .characterCostumed:
                let buffer = try decoder.decode([AvatarCostumeExcelConfigData].self, from: data)
                buffer.filter(\.isValid).forEach { obj in
                    writeKeyValuePair(id: obj.newFileNameStem, dict: &dict, sourceFileName: obj.frontIconName)
                }
            case .weapon:
                let buffer = try decoder.decode([WeaponExcelConfigData].self, from: data)
                buffer.filter(\.isValid).forEach { obj in
                    let compatibleSourceFileName = obj.awakenIcon.replacingOccurrences(of: "_Awaken", with: "")
                    writeKeyValuePair(id: obj.newFileNameStem, dict: &dict, sourceFileName: compatibleSourceFileName)
                }
            case .artifact:
                let buffer = try decoder.decode([ReliquaryExcelConfigData].self, from: data)
                buffer.filter(\.isValid).forEach { obj in
                    writeKeyValuePair(id: obj.newFileNameStem, dict: &dict, sourceFileName: obj.icon)
                }
            }
        } catch {
            print(String(data: data, encoding: .utf8) ?? "NOT_A_STRING")
            throw error
        }

        bannedFinalFileNames.forEach { forbiddenFileName in
            dict.removeValue(forKey: forbiddenFileName)
        }
        return dict
    }

    // MARK: Internal

    static let agdBasePath = "https://gitlab.com/Dimbreath/AnimeGameData/-/raw/master/ExcelBinOutput/"
    static let enkaResHeader = "https://enka.network/ui/"
    static let yattaMoeHeader = "https://gi.yatta.moe/assets/UI/"

    // MARK: Private

    private var jsonURLString: String {
        switch self {
        case .profilePicture: Self.agdBasePath + "ProfilePictureExcelConfigData.json"
        case .skill: Self.agdBasePath + "AvatarSkillExcelConfigData.json"
        case .character: Self.agdBasePath + "AvatarExcelConfigData.json"
        case .characterCostumed: Self.agdBasePath + "AvatarCostumeExcelConfigData.json"
        case .weapon: Self.agdBasePath + "WeaponExcelConfigData.json"
        case .artifact: Self.agdBasePath + "ReliquaryExcelConfigData.json"
        }
    }

    private var sourceURL: URL? {
        URL(string: jsonURLString)
    }

    private func writeKeyValuePair(id: String, dict: inout [String: String], sourceFileName: String? = nil) {
        let fileName = sourceFileName ?? "\(id)"
        switch self {
        case .profilePicture:
            dict["gi_avatar_\(id).png"] = Self.enkaResHeader + "\(fileName).png"
        case .skill:
            dict["gi_skill_\(id).png"] = Self.yattaMoeHeader + "\(fileName).png"
        case .character, .characterCostumed:
            dict["gi_character_\(id).png"] = Self.yattaMoeHeader + "\(fileName).png"
        case .weapon:
            dict["gi_weapon_\(id).png"] = Self.yattaMoeHeader + "\(fileName).png"
        case .artifact:
            dict["gi_relic_\(id).png"] = Self.yattaMoeHeader + "reliquary/\(fileName).png"
        }
    }
}

// MARK: - Main

let urlDict = try await withThrowingTaskGroup(
    of: [String: String].self, returning: [String: String].self
) { taskGroup in
    DataType.allCases.forEach { currentType in
        taskGroup.addTask { try await currentType.generateLinkDataDict() }
    }

    var dataDict = [String: String]()
    for try await result in taskGroup {
        result.forEach { key, value in
            dataDict[key] = value
        }
    }
    return dataDict
}

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
print(String(data: try! encoder.encode(urlDict), encoding: .utf8) ?? "NOT_A_STRING")

// MARK: - Image Data Download

let dataDict = try await withThrowingTaskGroup(
    of: (String, Data)?.self, returning: [String: Data].self
) { taskGroup in
    urlDict.forEach { fileNameStem, urlString in
        taskGroup.addTask {
            await URLAsyncTaskStack.waitFor200ms()
            guard let url = URL(string: urlString) else { return nil }
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                    if httpResponse.statusCode == 404 {
                        print("[FETCH FAILURE] 404 Not Found: \(fileNameStem) @ \(urlString)")
                        return nil
                    } else {
                        print("[FETCH FAILURE] HTTP \(httpResponse.statusCode): \(fileNameStem) @ \(urlString)")
                        return nil
                    }
                }
                return (fileNameStem, data)
            } catch {
                print("Failed to fetch: \(urlString) (\(error))")
                return nil
            }
        }
    }

    var newDict = [String: Data]()
    for try await result in taskGroup {
        guard let result = result else { continue }
        newDict[result.0] = result.1
    }
    return newDict
}

// MARK: - Asset Compilation

let workSpaceDirPath = "./Assets/AssetTemp"

do {
    try? FileManager.default.removeItem(atPath: workSpaceDirPath)
    try FileManager.default.createDirectory(
        atPath: workSpaceDirPath,
        withIntermediateDirectories: true,
        attributes: nil
    )

    for (fileNameStem, data) in dataDict {
        let newURL = URL(fileURLWithPath: workSpaceDirPath + "/\(fileNameStem)")
        do {
            if fileNameStem.hasSuffix("png") {
                try reencodePNG(from: data).write(to: newURL, options: .atomic)
            } else {
                try data.write(to: newURL, options: .atomic)
            }
        } catch {
            if !fileNameStem.contains("_avatar_") {
                throw error
            }
        }
    }

    print("\n// RAW Images Pulled Succesfully.\n")
} catch {
    preconditionFailure(error.localizedDescription)
}

// MARK: - URLAsyncTaskStack

private actor URLAsyncTaskStack {
    // MARK: Public

    public static func waitFor200ms() async {
        await Self.taskBuffer.addTask {
            try await Task.sleep(nanoseconds: 200_000_000) // 300ms sleep
        }
    }

    // MARK: Internal

    func addTask(_ task: @escaping () async throws -> Void) async {
        // Add the task to the queue and await its execution in sequence
        tasks.append(task)

        // If this is the only task, start processing the queue
        if tasks.count == 1 {
            await processNextTask()
        }
    }

    func cancelAllTasks() {
        tasks.removeAll()
    }

    // MARK: Private

    private static let taskBuffer: URLAsyncTaskStack = .init()

    private var tasks: [() async throws -> Void] = []

    private func processNextTask() async {
        while !tasks.isEmpty {
            let currentTask = tasks.removeFirst()
            do {
                // Execute the current task
                try await currentTask()
            } catch let error as NSError {
                print("Task failed with error: \(error)")
            }
        }
    }
}
