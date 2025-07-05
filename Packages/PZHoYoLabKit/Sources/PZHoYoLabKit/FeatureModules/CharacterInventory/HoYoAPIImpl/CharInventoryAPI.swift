// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Defaults
import EnkaKit
import Foundation
import PZAccountKit

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HoYo {
    public static func getCharacterInventory(for profile: PZProfileSendable) async throws -> (any CharacterInventory)? {
        #if DEBUG
        print("||| START REQUESTING CHARACTER INVENTORY |||")
        #endif
        return switch profile.game {
        case .genshinImpact: try await characterInventory4GI(for: profile)
        case .starRail: try await characterInventory4HSR(for: profile)
        case .zenlessZone: nil
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HoYo {
    static func characterInventory4GI(for profile: PZProfileSendable) async throws -> CharInventory4GI {
        try await characterInventory4GI(
            server: profile.server.withGame(profile.game),
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceId: profile.deviceID
        )
    }

    static func characterInventory4HSR(for profile: PZProfileSendable) async throws -> CharInventory4HSR {
        try await characterInventory4HSR(
            server: profile.server.withGame(profile.game),
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceId: profile.deviceID
        )
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HoYo {
    private static func characterInventory4GI(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceId: String?
    ) async throws
        -> CharInventory4GI {
        await HoYo.waitFor300ms()
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                ]
            } else {
                nil
            }
        }()

        // QUERYING THE LIST.

        let request1 = try await Self.generateRecordAPIRequest(
            httpMethod: .post, // 不是 .get。
            region: server.region,
            path: server.region.characterInventoryRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            deviceID: deviceId,
            additionalHeaders: additionalHeaders
        )
        request1.printDebugIntelIfDebugMode()

        let data1 = try await request1.serializingData().value

        // #if DEBUG
        // print("-----------------------------------")
        // print(String(data: data1, encoding: .utf8)!)
        // print("-----------------------------------")
        // #endif
        var decodedResult = try CharInventory4GI
            .decodeFromMiHoYoAPIJSONResult(data: data1, debugTag: "HoYo.characterInventory4GI().1")

        // QUERYING DETAILS.

        let postBody: NSDictionary = [
            "character_ids": decodedResult.avatars.map(\.id),
            "role_id": uid,
            "server": server.rawValue,
            "sort_type": "1",
        ]

        let request2 = try await Self.generateRecordAPIRequest(
            httpMethod: .post, // 不是 .get。
            region: server.region,
            path: server.region.characterInventoryDetailRetrievalPath,
            queryItems: queryItems,
            body: try? JSONSerialization.data(withJSONObject: postBody, options: []),
            cookie: cookie,
            deviceID: deviceId,
            additionalHeaders: additionalHeaders
        )
        request2.printDebugIntelIfDebugMode()

        let data2 = try await request2.serializingData().value

        // #if DEBUG
        // print("-----------------------------------")
        // print(String(data: data2, encoding: .utf8)!)
        // print("-----------------------------------")
        // #endif
        let decodedDetails = try CharInventory4GI.AvatarDetailPackage4GI
            .decodeFromMiHoYoAPIJSONResult(data: data2, debugTag: "HoYo.characterInventory4GI().2") {
                HYQueriedModels.HYLAvatarDetail4GI.cacheLocalHoYoAvatars(uid: uid, data: data2)
                Enka.Sputnik.shared.tellViewsToResummarizeHoYoLABProfiles()
            }

        // Insert new data.

        let newAvatars: [CharInventory4GI.HYAvatar4GI] = decodedDetails.list.map { avatarDetailObj in
            var newAvatar = avatarDetailObj.base
            newAvatar.costumeIDs = avatarDetailObj.costumes?.map(\.id) ?? []
            newAvatar.relicSetIDs = avatarDetailObj.relics?.map(\.set.id) ?? []
            newAvatar.relicIDs = avatarDetailObj.relics?.map(\.id) ?? []
            newAvatar.relicIconURLs = avatarDetailObj.relics?.map(\.icon) ?? []
            return newAvatar
        }
        decodedResult.list = newAvatars
        return decodedResult
    }

    private static func characterInventory4HSR(
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceId: String?
    ) async throws
        -> CharInventory4HSR {
        await HoYo.waitFor300ms()
        let queryItems: [URLQueryItem] = [
            .init(name: "need_wiki", value: "false"),
            .init(name: "role_id", value: uid),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty {
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                ]
            } else {
                nil
            }
        }()

        // QUERYING DETAILS.

        let request = try await Self.generateRecordAPIRequest(
            httpMethod: .get, // 不是 .post。
            region: server.region,
            path: server.region.characterInventoryDetailRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            deviceID: deviceId,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let data = try await request.serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.characterInventory4HSR()") {
            HYQueriedModels.HYLAvatarDetail4HSR.cacheLocalHoYoAvatars(uid: uid, data: data)
            Enka.Sputnik.shared.tellViewsToResummarizeHoYoLABProfiles()
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension HoYo.AccountRegion {
    public var characterInventoryRetrievalPath: String {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact): "/game_record/app/genshin/api/character/list"
        case (.miyoushe, .genshinImpact): "/game_record/app/genshin/api/character/list"
        case (.hoyoLab, .starRail): "/game_record/app/hkrpg/api/avatar/basic"
        case (.miyoushe, .starRail): "/game_record/app/hkrpg/api/avatar/basic"
        case (.hoyoLab, .zenlessZone): "/event/game_record_zzz/api/zzz/avatar/basic" // 乱填，暂不实作。
        case (.miyoushe, .zenlessZone): "/event/game_record_zzz/api/zzz/avatar/basic" // 乱填，暂不实作。
        }
    }

    public var characterInventoryDetailRetrievalPath: String {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact): "/game_record/app/genshin/api/character/detail"
        case (.miyoushe, .genshinImpact): "/game_record/app/genshin/api/character/detail"
        case (.hoyoLab, .starRail): "/game_record/app/hkrpg/api/avatar/info"
        case (.miyoushe, .starRail): "/game_record/app/hkrpg/api/avatar/info"
        case (.hoyoLab, .zenlessZone): "/event/game_record_zzz/api/zzz/avatar/info" // 乱填，暂不实作。
        case (.miyoushe, .zenlessZone): "/event/game_record_zzz/api/zzz/avatar/info" // 乱填，暂不实作。
        }
    }
}
