#!/usr/bin/env swift

import AppKit
import AVFoundation
import Foundation

// 该脚本专门用来整理星穹铁道的手机壁纸、以及原神的名片。
// 出于某些原因，现阶段仅自动处理原神的名片素材。
/// 1. 从 Enka 的仓库拿到正式服的素材的所有角色 ID 阵列与名片 ID 阵列、
/// 以及每个名片对应的素材名称和 NameTextMapHash。
/// 这个先导步骤可以有效避免从迫真资料库获取到测试服的内鬼资料。
/// 2. 拿着 NameTextMapHash 前往 Dimbreath 的仓库取得翻译资料。
/// 3. 以上述 Enka 资料反查迫真资料库，取得所有角色 ID 对应的名片资料。
/// 4. 将要下载的内容整理成 `[String: NSImage]` 辞典，然后下载且处理素材。
/// 5. 处理过的名片素材尺寸为 210x100 的 JPEG。实际上的 Widget 会联网下载素材。

let path4GILang = "./Packages/WallpaperKit/Sources/WallpaperKit/Resources/GIWallpapers_Lang.json"
let path4GIMeta = "./Packages/WallpaperKit/Sources/WallpaperKit/Resources/GIWallpapers_Meta.json"

let encoder = JSONEncoder()
encoder.outputFormatting = [.sortedKeys, .prettyPrinted, .withoutEscapingSlashes]

// MARK: - ImageProcessingError

enum ImageProcessingError: Error {
    case imageInitializationFailed
    case bitmapCreationFailed
    case jpegConversionFailed
}

func resizeImageToJPEGData(from imageData: Data) throws -> Data {
    guard let image = NSImage(data: imageData) else {
        throw ImageProcessingError.imageInitializationFailed
    }

    // Create a new size for the image
    let newSize = NSSize(width: 210, height: 100)

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
    guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.82]) else {
        throw ImageProcessingError.jpegConversionFailed
    }

    return jpegData
}

// MARK: - Extract Filename Stem

extension String {
    public var asURL: URL {
        // swiftlint:disable force_unwrapping
        URL(string: self)!
        // swiftlint:enable force_unwrapping
    }
}

// MARK: - GenshinLang

public enum GenshinLang: String, CaseIterable, Sendable, Identifiable {
    case langCHS
    case langCHT
    case langDE
    case langEN
    case langES
    case langFR
    case langID
    case langIT
    case langJP
    case langKR
    case langPT
    case langRU
    case langTH
    case langTR
    case langVI

    // MARK: Public

    public var id: String { langID }

    public var langID: String {
        switch self {
        case .langCHS: "zh-cn"
        case .langCHT: "zh-tw"
        case .langDE: "de"
        case .langEN: "en"
        case .langES: "es"
        case .langFR: "fr"
        case .langID: "id"
        case .langIT: "it"
        case .langJP: "ja"
        case .langKR: "ko"
        case .langPT: "pt"
        case .langRU: "ru"
        case .langTH: "th"
        case .langTR: "tr"
        case .langVI: "vi"
        }
    }

    public var filename: String {
        rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending(".json")
    }

    public var urls: [URL] {
        filenamesForChunks.compactMap { currentFileName in
            URL(string: """
            https://raw.githubusercontent.com/DimbreathBot/AnimeGameData/refs/heads/master/TextMap/\(currentFileName)
            """)
        }
    }

    // MARK: Internal

    var filenamesForChunks: [String] {
        switch self {
        case .langTH: [
                rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending("_0.json"),
                rawValue.replacingOccurrences(of: "lang", with: "TextMap").appending("_1.json"),
            ]
        default: [filename]
        }
    }
}

// MARK: - WallpaperAsset

public final class WallpaperAsset: Identifiable, Encodable {
    // MARK: Lifecycle

    public init(
        id: String,
        nameTextMapHash: String,
        assetName: String,
        officialFileNameStem: String,
        assetName4LiveActivity: String,
        bindedCharID: String? = nil
    ) {
        self.id = id
        self.nameTextMapHash = nameTextMapHash
        self.assetName = assetName
        self.officialFileNameStem = officialFileNameStem
        self.assetName4LiveActivity = assetName4LiveActivity
        self.bindedCharID = bindedCharID
    }

    // MARK: Public

    public let game: String = "GI"
    public let id: String
    public let nameTextMapHash: String
    public let officialFileNameStem: String
    public let assetName: String
    public let assetName4LiveActivity: String
    public var bindedCharID: String? // 原神专用

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(game, forKey: .game)
        try container.encode(id, forKey: .id)
        try container.encode(officialFileNameStem, forKey: .officialFileNameStem)
        // try container.encode(nameTextMapHash, forKey: .nameTextMapHash)
        // try container.encode(assetName, forKey: .assetName)
        // try container.encode(assetName4LiveActivity, forKey: .assetName4LiveActivity)
        if bindedCharID != nil {
            try container.encode(bindedCharID, forKey: .bindedCharID)
        }
    }

    // MARK: Private

    private enum CodingKeys: CodingKey {
        case game
        case id
        case nameTextMapHash
        case assetName
        case officialFileNameStem
        case assetName4LiveActivity
        case bindedCharID
    }
}

// MARK: - EnkaCharacterDictValueType

struct EnkaCharacterDictValueType: Decodable {
    // MARK: Public

    public let NameTextMapHash: Int

    // MARK: Internal

    static let urlPath = """
    https://raw.githubusercontent.com/pizza-studio/EnkaDBGenerator/main/Sources/EnkaDBFiles/Resources/Specimen/GI/characters.json
    """

    static func getRemoteMap() async throws -> [String: EnkaCharacterDictValueType] {
        let (data, _) = try await URLSession.shared.data(from: urlPath.asURL)
        return try JSONDecoder().decode([String: EnkaCharacterDictValueType].self, from: data)
    }
}

var allCharIDs: [String] = []

try await EnkaCharacterDictValueType.getRemoteMap().forEach { key, _ in
    guard key.count == 8, !key.hasPrefix("10000007"), !key.hasPrefix("10000005") else { return } // 主角没有名片。
    // TODO: 此处增加检查。如果连 Hakushin 都没列出当前迭代的 characterID 的话，
    // 那么这个 characterID 对应的就是测试角色、得排除。
    allCharIDs.append(key)
}

// MARK: - MaterialExcelConfigData

/// This struct is only for extrcting NameCards.
struct MaterialExcelConfigData: Decodable {
    // MARK: Lifecycle

    init(from decoder: any Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.picPath = try container.decode([String].self, forKey: .picPath)
        self.materialType = try container.decodeIfPresent(String.self, forKey: .materialType)
        self.nameTextMapHash = try container.decode(Int.self, forKey: .nameTextMapHash)
        self.rankLevel = (try container.decodeIfPresent(Int.self, forKey: .rankLevel)) ?? 4
    }

    // MARK: Internal

    static let urlPath = """
    https://gitlab.com/Dimbreath/AnimeGameData/-/raw/master/ExcelBinOutput/MaterialExcelConfigData.json
    """

    let id: Int
    let icon: String
    let picPath: [String]
    let materialType: String?
    let nameTextMapHash: Int
    let rankLevel: Int // All NameCards are ranked at level 4.

    var isValid: Bool {
        materialType == "MATERIAL_NAMECARD"
    }

    var guardedIconName: String {
        picPath.first { $0.hasSuffix("_P") } ?? "\(icon)_P"
    }

    static func getRemoteMap() async throws -> [MaterialExcelConfigData] {
        let (data, _) = try await URLSession.shared.data(from: urlPath.asURL)
        let valMap = try JSONDecoder().decode([MaterialExcelConfigData].self, from: data)
        var newValues = [MaterialExcelConfigData]()
        valMap.forEach { value in
            if value.isValid { newValues.append(value) }
        }
        return newValues
    }

    // MARK: Private

    private enum CodingKeys: CodingKey {
        case id
        case icon
        case picPath
        case materialType
        case nameTextMapHash
        case rankLevel
    }
}

var allNameTextMapHashesNeeded = Set<String>()
var mapHashToID = [String: String]()

let assetObjects: [WallpaperAsset] = try await MaterialExcelConfigData.getRemoteMap().map { rawValue in
    let nameHash = rawValue.nameTextMapHash.description
    let id = rawValue.id.description
    mapHashToID[nameHash] = id
    allNameTextMapHashesNeeded.insert(nameHash)
    return WallpaperAsset(
        id: id,
        nameTextMapHash: nameHash,
        assetName: rawValue.guardedIconName,
        officialFileNameStem: "\(rawValue.guardedIconName)",
        assetName4LiveActivity: rawValue.guardedIconName
    )
}

// MARK: - HakushinChar

struct HakushinChar: Decodable {
    struct CharaInfo: Decodable {
        struct Namecard: Decodable {
            let Id: Int
            let Name: String
            let Icon: String
        }

        let Namecard: Namecard
    }

    let CharaInfo: CharaInfo
}

for charID in allCharIDs {
    let url = "https://api.hakush.in/gi/data/zh/character/\(charID).json".asURL
    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let hakushinObj = try JSONDecoder().decode(HakushinChar.self, from: data)
        let nameCardID = hakushinObj.CharaInfo.Namecard.Id
        let matched = assetObjects.first { $0.id == nameCardID.description }
        matched?.bindedCharID = charID
    } catch {
        // 這裡暫時假設 charID 不會高於 10000800。
        guard let intCharID = Int(charID), intCharID < 10000800 else { continue }
        print("------------------------")
        print("FAILED FROM HANDLING SOURCE URL: \(url.absoluteString)")
        print("------------------------")
        print(error)
        print("------------------------")
        continue
    }
}

// MARK: - Add supplemental charIDs for chars with costumes.

let bindedCostumeIDMap: [String: String] = [
    "210021": "10000003_200301",
    "210074": "10000014_201401",
    "210091": "10000027_202701",
    "210117": "10000042_204201",
    "210028": "10000016_201601",
    "210042": "10000031_203101",
    "210098": "10000002_200201",
    "210127": "10000006_200601",
    "210065": "10000029_202901",
    "210132": "10000015_201501",
    "210150": "10000063_206301",
    "210191": "10000025_202501",
    "210192": "10000037_203701",
    "210183": "10000070_207001",
    "210206": "10000061_206101",
    "210149": "10000023_202301",
    "210232": "10000046_204601",
    "210249": "10000032_203201",
    "210121": "10000060_206001",
]

assetObjects.forEach { obj in
    let matched = bindedCostumeIDMap.first { $0.key == obj.id }
    if let matched {
        obj.bindedCharID = matched.value
    }
}

// MARK: - Write Meta.

try encoder.encode(assetObjects).write(to: URL(fileURLWithPath: path4GIMeta), options: .atomic)

// MARK: - Handle Asset Downloads.

var assetIDURLMap: [String: URL] = [:]

assetObjects.forEach { currentObj in
    let assetURL = "https://gi.yatta.moe/assets/UI/namecard/\(currentObj.assetName).png".asURL
    assetIDURLMap[currentObj.id] = assetURL
}

let assetDataMap: [String: Data] = try await withThrowingTaskGroup(
    of: (String, Data).self,
    returning: [String: Data].self
) { taskGroup in
    assetIDURLMap.forEach { id, url in
        taskGroup.addTask {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let newData = try resizeImageToJPEGData(from: data)
                return (id, newData)
            } catch {
                print("Error handing: \(url.absoluteString)")
                throw error
            }
        }
    }
    var results = [String: Data]()
    for try await result in taskGroup {
        results[result.0] = result.1
    }
    return results
}

// MARK: - Asset Compilation

let assetTempPath = "./Assets/AssetTemp"

do {
    try? FileManager.default.removeItem(atPath: assetTempPath)
    try FileManager.default.createDirectory(
        atPath: assetTempPath,
        withIntermediateDirectories: true,
        attributes: nil
    )

    for (fileNameStem, data) in assetDataMap {
        let newURL = URL(fileURLWithPath: assetTempPath + "/NC\(fileNameStem).jpg")
        try data.write(to: newURL, options: .atomic)
    }

    print("\n// RAW Name Cards Pulled Succesfully.\n")
} catch {
    assertionFailure(error.localizedDescription)
    exit(1)
}

// MARK: - Handle translation table.

@MainActor
func makeLanguageMeta() async throws {
    let dictAll = try await withThrowingTaskGroup(
        of: (subDict: [String: String], lang: GenshinLang).self,
        returning: [String: [String: String]].self
    ) { taskGroup in
        GenshinLang.allCases.forEach { locale in
            taskGroup.addTask {
                var finalDict = [String: String]()
                for url in locale.urls {
                    print("// Fetching: \(url.absoluteString)")
                    let (data, _) = try await URLSession.shared.data(from: url)
                    let dict = try JSONDecoder().decode([String: String].self, from: data)
                    dict.forEach { key, value in
                        finalDict[key] = value
                    }
                }
                let keysToRemove = await Set<String>(finalDict.keys).subtracting(allNameTextMapHashesNeeded)
                keysToRemove.forEach { finalDict.removeValue(forKey: $0) }
                return (subDict: finalDict, lang: locale)
            }
        }
        var results = [String: [String: String]]()
        for try await result in taskGroup {
            result.subDict.forEach { hash, translatedText in
                guard let id = mapHashToID[hash] else { return }
                results[result.lang.langID, default: [:]][id] = translatedText
            }
        }
        return results
    }

    try encoder.encode(dictAll).write(to: URL(fileURLWithPath: path4GILang), options: .atomic)
}

// MARK: - Make Wallpaper Assets

let workSpaceDirPath = "./Packages/WallpaperKit/Sources/WallpaperKit/Resources/Assets.xcassets/GILiveActivityBGs"

// MARK: JSON 档案范本内容。

let folderJSONContents = #"""
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

"""#

let sampleJSONForFile = #"""
{
  "images" : [
    {
      "filename" : "FILENAMEPLACEHOLDER",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "idiom" : "universal",
      "scale" : "2x"
    },
    {
      "idiom" : "universal",
      "scale" : "3x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}

"""#

func generateJSON(fileName: String? = nil) -> String {
    guard let fileName = fileName, !fileName.isEmpty else {
        return folderJSONContents
    }
    return sampleJSONForFile.replacingOccurrences(of: "FILENAMEPLACEHOLDER", with: fileName)
}

// swiftlint:disable:next large_tuple
func generateNewPath(newFileName: String) -> (filePath: String, jsonPath: String, setPath: String) {
    let newFileNameStem = newFileName.split(separator: ".").dropLast().joined(separator: ".")
    let setPath = "\(workSpaceDirPath)/\(newFileNameStem).imageset"
    let filePath = "\(setPath)/\(newFileName)"
    let jsonPath = "\(setPath)/Contents.json"
    return (filePath, jsonPath, setPath)
}

// MARK: - AssetFile

struct AssetFile: Codable, CustomStringConvertible {
    // MARK: Lifecycle

    public init(oldPath: String) {
        self.oldPath = oldPath
        let oldPathCells = oldPath.split(separator: "/").split(separator: #"\"#).reduce([], +).map(\.description)
        let newFileName = oldPathCells.suffix(1).joined(separator: "_")
        self.fileName = newFileName
        let newPaths = generateNewPath(newFileName: newFileName)
        self.newPath = newPaths.filePath
        self.setPath = newPaths.setPath
        self.jsonPath = newPaths.jsonPath
        self.jsonText = generateJSON(fileName: fileName)
        print(description)
    }

    // MARK: Internal

    let oldPath: String
    let newPath: String
    let fileName: String
    let jsonText: String
    let jsonPath: String
    let setPath: String

    var description: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys]
        // swiftlint:disable:next force_try
        let data = try! encoder.encode(self)
        return String(data: data, encoding: .utf8)!
    }

    func deploy() throws {
        try FileManager.default.createDirectory(atPath: setPath, withIntermediateDirectories: true)
        try FileManager.default.moveItem(atPath: oldPath, toPath: newPath)
        try jsonText.write(to: URL(fileURLWithPath: jsonPath), atomically: true, encoding: .utf8)
    }
}

// MARK: - 初始化新的工作资料夹。

func initNewWorkspace() {
    do {
        try? FileManager.default.removeItem(atPath: workSpaceDirPath)
        try FileManager.default.createDirectory(
            atPath: workSpaceDirPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        let contentsJSONURL = URL(fileURLWithPath: workSpaceDirPath + "/Contents.json")
        try folderJSONContents.write(to: contentsJSONURL, atomically: true, encoding: .utf8)
    } catch {
        assertionFailure(error.localizedDescription)
    }
}

func cleanWorkspace() {
    do {
        try FileManager.default.removeItem(atPath: "./Assets/AssetTemp")
    } catch {
        assertionFailure(error.localizedDescription)
    }
}

// MARK: - 列出所有要弄的档案。

func handleAllFiles() {
    let fileMgr = FileManager.default
    let allPaths: [String] = (fileMgr.subpaths(atPath: "./Assets/") ?? []).filter {
        $0.contains("AssetTemp") && $0.suffix(4).lowercased() == ".jpg"
    }
    let assets: [AssetFile] = allPaths.map { AssetFile(oldPath: "./Assets/" + $0) }
    assets.forEach {
        do {
            try $0.deploy()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }
}

initNewWorkspace()
handleAllFiles()
cleanWorkspace()

// Finally, compile the language data.

try await makeLanguageMeta()
