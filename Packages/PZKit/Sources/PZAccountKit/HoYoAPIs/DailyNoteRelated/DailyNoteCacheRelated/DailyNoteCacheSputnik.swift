// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import CoreGraphics
import Defaults
import Foundation
import PZBaseKit

extension PZProfileSendable {
    public func clearDailyNoteCache() {
        Defaults[.cachedDailyNotes].removeValue(forKey: uidWithGame)
    }
}

extension DailyNoteProtocol {
    typealias CacheSputnik = DailyNoteCacheSputnik<Self>
}

// MARK: - DailyNoteCacheSputnik

public struct DailyNoteCacheSputnik<T: DailyNoteProtocol> {
    public static func cache(_ data: Data, uidWithGame: String) {
        guard let dataStr = String(data: data, encoding: .utf8) else { return }
        Defaults[.cachedDailyNotes][uidWithGame] = .init(rawJSONString: dataStr)
    }

    public static func getCache(uidWithGame: String) -> T? {
        guard let package = Defaults[.cachedDailyNotes][uidWithGame] else { return nil }
        let cachedTimestamp = package.timestamp
        let currentTimestamp = Date.now.timeIntervalSince1970
        guard cachedTimestamp + T.game.eachStaminaRecoveryTime > currentTimestamp else { return nil }
        guard let data = package.rawJSONString.data(using: .utf8) else { return nil }
        let decoded = try? T.decodeFromMiHoYoAPIJSONResult(
            data: data, debugTag: "DailyNoteCacheSputnik.getCache()"
        )
        return decoded
    }
}

extension DailyNoteProtocol {
    public func getExpeditionAssetMap() async -> [URL: SendableImagePtr]? {
        let dailyNote = self
        guard dailyNote.hasExpeditions else { return nil }
        let expeditions = dailyNote.expeditionTasks
        guard !expeditions.isEmpty else { return nil }
        var assetMap = [URL: SendableImagePtr]()
        if dailyNote.hasExpeditions {
            for task in dailyNote.expeditionTasks {
                let urls = [task.iconURL, task.iconURL4Copilot].compactMap { $0 }
                for url in urls {
                    if let image = await ImageMap.shared.assetMap[url] {
                        assetMap[url] = image
                    } else {
                        let data: Data = (try? await AF.request(url).serializingData().value) ?? .init([])
                        if var cgImage = CGImage.instantiate(data: data) {
                            if dailyNote.game == .genshinImpact {
                                let croppedCGImage = cgImage.croppedPilotPhoto4Genshin()
                                guard let croppedCGImage else {
                                    continue
                                }
                                cgImage = croppedCGImage
                            }
                            let image = SendableImagePtr(img: .init(decorative: cgImage, scale: 1.0))
                            await ImageMap.shared.insertValue(url: url, image: image)
                            assetMap[url] = image
                        }
                    }
                }
            }
        }
        return assetMap
    }

    /// [WARNING] This has purple warnings and is only used in Xcode SwiftUI preview tests.
    @MainActor
    public func getExpeditionAssetMapFromMainActor() -> [URL: SendableImagePtr]? {
        let dailyNote = self
        guard dailyNote.hasExpeditions else { return nil }
        let expeditions = dailyNote.expeditionTasks
        guard !expeditions.isEmpty else { return nil }
        var assetMap = [URL: SendableImagePtr]()
        if dailyNote.hasExpeditions {
            for task in dailyNote.expeditionTasks {
                let urls = [task.iconURL, task.iconURL4Copilot].compactMap { $0 }
                for url in urls {
                    if let image = ImageMap.shared.assetMap[url] {
                        assetMap[url] = image
                    } else if var cgImage = CGImage.instantiate(url: url) {
                        if dailyNote.game == .genshinImpact {
                            let croppedCGImage = cgImage.croppedPilotPhoto4Genshin()
                            guard let croppedCGImage else {
                                continue
                            }
                            cgImage = croppedCGImage
                        }
                        let image = SendableImagePtr(img: .init(decorative: cgImage, scale: 1.0))
                        ImageMap.shared.insertValue(url: url, image: image)
                        assetMap[url] = image
                    }
                }
            }
        }
        return assetMap
    }

    /// 这是给 .placeholder() 专用的函式，不会调用 ImageMap 的缓存。
    public func getExpeditionAssetMapImmediately()
        -> [URL: SendableImagePtr]? {
        let dailyNote = self
        guard dailyNote.hasExpeditions else { return nil }
        let expeditions = dailyNote.expeditionTasks
        guard !expeditions.isEmpty else { return nil }
        var assetMap = [URL: SendableImagePtr]()
        if dailyNote.hasExpeditions {
            for task in dailyNote.expeditionTasks {
                let urls = [task.iconURL, task.iconURL4Copilot].compactMap { $0 }
                for url in urls {
                    if var cgImage = CGImage.instantiate(url: url) {
                        if dailyNote.game == .genshinImpact {
                            let croppedCGImage = cgImage.croppedPilotPhoto4Genshin()
                            guard let croppedCGImage else {
                                continue
                            }
                            cgImage = croppedCGImage
                        }
                        let image = SendableImagePtr(img: .init(decorative: cgImage, scale: 1.0))
                        assetMap[url] = image
                    }
                }
            }
        }
        return assetMap
    }
}

extension Array where Element == (any DailyNoteProtocol) {
    public func prepareAssetMap() async -> [URL: SendableImagePtr]? {
        var assetMap: [URL: SendableImagePtr]? = [:]
        for currentDailyNote in self {
            let fetchedMap = await Task(priority: .userInitiated) {
                await currentDailyNote.getExpeditionAssetMap()
            }.value
            guard let fetchedMap else { continue }
            fetchedMap.forEach { theKey, theValue in
                assetMap?[theKey] = theValue
            }
        }
        if assetMap?.isEmpty ?? false {
            assetMap = nil
        }
        return assetMap
    }

    /// 这是给 .placeholder() 专用的函式，不会调用 ImageMap 的缓存。
    public func prepareAssetMapImmediately() -> [URL: SendableImagePtr]? {
        var assetMap: [URL: SendableImagePtr]? = [:]
        for currentDailyNote in self {
            let fetchedMap = currentDailyNote.getExpeditionAssetMapImmediately()
            fetchedMap?.forEach { theKey, theValue in
                assetMap?[theKey] = theValue
            }
        }
        if assetMap?.isEmpty ?? false {
            assetMap = nil
        }
        return assetMap
    }
}
