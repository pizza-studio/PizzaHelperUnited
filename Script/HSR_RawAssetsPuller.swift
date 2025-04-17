#!/usr/bin/env swift

import AppKit
import AVFoundation
import Foundation

// MARK: - ImageProcessingError

// 该脚本为星穹铁道专用。

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

// MARK: - Extract Filename Stem

extension String {
    func extractFileNameStem() -> String {
        split(separator: "/").last?.split(separator: ".").dropLast().joined(separator: ".").description ?? self
    }
}

// MARK: - BasicSRSStruct

struct BasicSRSStruct: Codable {
    typealias Dict = [String: Self]

    enum CodingKeys: String, CodingKey {
        case id
        case icon
    }

    var icon: String
    var id: String
}

// MARK: - SRDCharacter

struct SRDCharacter: Codable {
    // MARK: Lifecycle

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id).description
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id = "AvatarID"
    }

    var id: String
}

// MARK: - SRDSkillTree

struct SRDSkillTree: Codable {
    // MARK: Lifecycle

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id).description
        self.icon = try container.decode(String.self, forKey: .icon)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id = "AvatarID"
        case icon = "IconPath"
    }

    var icon: String
    var id: String
}

// MARK: - SRDLightCone

struct SRDLightCone: Codable {
    // MARK: Lifecycle

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.icon = try container.decode(String.self, forKey: .icon)
        self.id = try container.decode(Int.self, forKey: .id).description
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case id = "EquipmentID"
        case icon = "ThumbnailPath"
    }

    var icon: String
    var id: String
}

// MARK: - SRDArtifact

struct SRDArtifact: Codable {
    // MARK: Lifecycle

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(ArtifactType.self, forKey: .type)
        self.setID = try container.decode(Int.self, forKey: .setID).description
        self.icon = try container.decode(String.self, forKey: .icon)
    }

    // MARK: Internal

    enum CodingKeys: String, CodingKey {
        case setID = "SetID"
        case icon = "IconPath"
        case type = "Type"
    }

    enum ArtifactType: String, Codable {
        case head = "HEAD"
        case hand = "HAND"
        case body = "BODY"
        case foot = "FOOT"
        case ball = "NECK" // 没写错，是官方写反了。
        case neck = "OBJECT" // 没写错，是官方写反了。

        // MARK: Internal

        var subID: Int {
            switch self {
            case .ball, .head: 0
            case .hand, .neck: 1
            case .body: 2
            case .foot: 3
            }
        }
    }

    var icon: String
    var setID: String
    var type: ArtifactType

    var mar7Tag: String { "\(setID)_\(type.subID)" }
}

// MARK: - DataType

public enum DataType: String, CaseIterable {
    case profileAvatar
    case character
    case lightCone
    case artifact
    case skillTree

    // MARK: Public

    public func generateLinkDataDict() async throws -> [String: String] {
        var dict = [String: String]()
        guard let sourceURL = sourceURL else { return [:] }
        let (data, _) = try await URLSession.shared.data(from: sourceURL)

        do {
            switch self {
            case .profileAvatar:
                let buffer = try JSONDecoder().decode(BasicSRSStruct.Dict.self, from: data).values
                buffer.forEach { obj in
                    guard obj.id.count >= 4, obj.id != "8000" else { return }
                    guard !obj.icon.isEmpty else { return }
                    let sourceFileName = obj.icon.extractFileNameStem()
                    writeKeyValuePair(id: sourceFileName, dict: &dict, sourceFileName: sourceFileName)
                }
            case .skillTree:
                let buffer = try JSONDecoder().decode([SRDSkillTree].self, from: data)
                buffer.forEach { obj in
                    guard !obj.icon.isEmpty else { return }
                    let sourceFileName = obj.icon.extractFileNameStem()
                    guard sourceFileName.contains("_") else { return }
                    let allowedSuffixes = ["Normal", "BP", "Ultra", "Passive"]
                    var allowed = false
                    for suffix in allowedSuffixes {
                        if sourceFileName.hasSuffix(suffix) { allowed = true }
                    }
                    guard allowed else { return }
                    let newID = sourceFileName.replacingOccurrences(of: "SkillIcon_", with: "")
                    writeKeyValuePair(id: newID, dict: &dict, sourceFileName: sourceFileName)
                }
            case .character:
                let buffer = try JSONDecoder().decode([SRDCharacter].self, from: data)
                buffer.forEach { obj in
                    writeKeyValuePair(id: obj.id, dict: &dict, sourceFileName: String?.none)
                }
            case .lightCone:
                let buffer = try JSONDecoder().decode([SRDLightCone].self, from: data)
                buffer.forEach { obj in
                    writeKeyValuePair(id: obj.id, dict: &dict, sourceFileName: String?.none)
                }
            case .artifact:
                let buffer = try JSONDecoder().decode([SRDArtifact].self, from: data)
                buffer.forEach { obj in
                    let sourceFileName = obj.icon.extractFileNameStem()
                    writeKeyValuePair(id: obj.mar7Tag, dict: &dict, sourceFileName: sourceFileName)
                }
            }
        } catch {
            print(String(data: data, encoding: .utf8)!)
            throw error
        }

        return dict
    }

    // MARK: Internal

    static let srdBasePath = "https://gitlab.com/Dimbreath/TurnBasedGameData/-/raw/main/ExcelOutput/"
    static let mar7BasePath = "https://raw.githubusercontent.com/Mar-7th/StarRailRes/master/index_new/en/"
    static let hksResHeader = "https://api.hakush.in/hsr/UI/"
    static let mar7ResHeader = "https://raw.githubusercontent.com/Mar-7th/StarRailRes/master/"
    static let yattaResHeader = "https://sr.yatta.moe/hsr/assets/"

    // MARK: Private

    private var jsonURLString: String {
        switch self {
        case .profileAvatar: Self.mar7BasePath + "avatars.json"
        case .skillTree: Self.srdBasePath + "AvatarSkillTreeConfig.json"
        case .character: Self.srdBasePath + "AvatarConfig.json"
        case .lightCone: Self.srdBasePath + "EquipmentConfig.json"
        case .artifact: Self.srdBasePath + "RelicDataInfo.json"
        }
    }

    private var isMar7th: Bool {
        jsonURLString.hasPrefix(Self.mar7BasePath)
    }

    private var sourceURL: URL? {
        URL(string: jsonURLString)
    }

    private func writeKeyValuePair(id: String, dict: inout [String: String], sourceFileName: String? = nil) {
        switch self {
        case .profileAvatar:
            let fileName = sourceFileName ?? "\(id)"
            var newID = id            
            newID = newID.replacingOccurrences(of: "S1_8001", with: "200105")
            newID = newID.replacingOccurrences(of: "S1_8002", with: "200106")
            newID = newID.replacingOccurrences(of: "IconHeadS1_100", with: "IconHead_20010")
            newID = newID.replacingOccurrences(of: "_IconHead_", with: "_")
            dict["hsr_avatar_\(newID).png"] = Self.mar7ResHeader + "icon/avatar/\(fileName).png"
        case .skillTree:
            let fileName = sourceFileName ?? "\(id)"
            dict["hsr_skill_\(id).png"] = Self.yattaResHeader + "UI/skill/\(fileName).png"
        case .character:
            dict["hsr_character_\(id).webp"] = Self.hksResHeader + "avatarshopicon/\(id).webp"
        case .lightCone:
            dict["hsr_light_cone_\(id).webp"] = Self.hksResHeader + "lightconemediumicon/\(id).webp"
        case .artifact:
            let fileName = sourceFileName ?? "\(id)"
            dict["hsr_relic_\(id).webp"] = Self.hksResHeader + "relicfigures/\(fileName).webp"
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
print(String(data: try! encoder.encode(urlDict), encoding: .utf8)!)

// MARK: - Image Data Download

let dataDict = try await withThrowingTaskGroup(
    of: (String, Data)?.self, returning: [String: Data].self
) { taskGroup in
    urlDict.forEach { fileNameStem, urlString in
        taskGroup.addTask {
            await URLAsyncTaskStack.waitFor200ms()
            let (data, _) = try await URLSession.shared.data(from: URL(string: urlString)!)
            return (fileNameStem, data)
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
    assertionFailure(error.localizedDescription)
    exit(1)
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
