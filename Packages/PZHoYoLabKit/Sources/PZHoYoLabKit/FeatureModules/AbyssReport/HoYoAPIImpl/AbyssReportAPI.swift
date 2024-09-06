// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

extension HoYo {
    public static func getAbyssReportSet(for profile: PZProfileMO) async throws -> (any AbyssReportSet)? {
        switch profile.game {
        case .genshinImpact:
            let current = try await abyssReportData4GI(for: profile, isPreviousRound: false)
            let previous = try? await abyssReportData4GI(for: profile, isPreviousRound: true)
            defer {
                Task(priority: .background) {
                    try? await SnapHutao.commitAbyssRecord(profile: profile, abyssData: current)
                }
            }
            return AbyssReportSet4GI(current: current, previous: previous)
        case .starRail:
            let current = try await abyssReportData4HSR(for: profile, isPreviousRound: false)
            let previous = try? await abyssReportData4HSR(for: profile, isPreviousRound: true)
            return AbyssReportSet4HSR(current: current, previous: previous)
        default: return nil
        }
    }
}

extension HoYo {
    fileprivate static func abyssReportData4GI(
        for profile: PZProfileMO, isPreviousRound: Bool = false
    ) async throws
        -> AbyssReport4GI {
        try await abyssReportData4GI(
            isPreviousRound: isPreviousRound,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }

    fileprivate static func abyssReportData4HSR(
        for profile: PZProfileMO, isPreviousRound: Bool = false
    ) async throws
        -> AbyssReport4HSR {
        try await abyssReportData4HSR(
            isPreviousRound: isPreviousRound,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
    }
}

extension HoYo {
    fileprivate static func abyssReportData4GI(
        isPreviousRound: Bool = false,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> AbyssReport4GI {
        #if DEBUG
        print("||| START REQUESTING SPIRAL ABYSS DATA (GI) |||")
        #endif
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "schedule_type", value: isPreviousRound ? "2" : "1"),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                return nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: server.region.abyssReportRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }

    fileprivate static func abyssReportData4HSR(
        isPreviousRound: Bool = false,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> AbyssReport4HSR {
        #if DEBUG
        print("||| START REQUESTING SPIRAL ABYSS DATA (HSR) |||")
        #endif

        let queryItems: [URLQueryItem] = [
            .init(name: "isPrev", value: isPreviousRound ? "true" : "false"),
            .init(name: "need_all", value: "true"),
            .init(name: "role_id", value: uid),
            .init(name: "schedule_type", value: isPreviousRound ? "2" : "1"),
            .init(name: "server", value: server.rawValue),
        ]

        var additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
                return [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                return [:]
            }
        }()

        checkMiyoushe: switch server.region {
        case .miyoushe: additionalHeaders?["x-rpc-language"] = HoYo.APILang.langCHS.rawValue
        default: break checkMiyoushe
        }

        if additionalHeaders?.isEmpty ?? false {
            additionalHeaders = nil
        }

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: server.region.abyssReportRetrievalPath,
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let (data, _) = try await URLSession.shared.data(for: request)

        return try .decodeFromMiHoYoAPIJSONResult(data: data)
    }
}

extension HoYo.AccountRegion {
    /// 除绝区零情况未知以外，原神与星穹铁道搭配 `.recordURLAPIHost()` 使用。
    public var abyssReportRetrievalPath: String {
        switch (self, game) {
        case (.hoyoLab, .genshinImpact): "/game_record/app/genshin/api/spiralAbyss"
        case (.miyoushe, .genshinImpact): "/game_record/app/genshin/api/spiralAbyss"
        case (.hoyoLab, .starRail): "/game_record/app/hkrpg/api/challenge"
        case (.miyoushe, .starRail): "/game_record/app/hkrpg/api/challenge"
        case (.hoyoLab, .zenlessZone): "" // 暂不实作。
        case (.miyoushe, .zenlessZone): "" // 暂不实作。
        }
    }
}

// MARK: - HutaoDB Extensions.

extension SnapHutao.AbyssDataPack {
    public enum InitError: Error {
        case wrongGame
        case insufficientStars
        case avatarMismatch
        case abyssDataNotSupplied
    }

    public init(
        profile: PZProfileMO,
        abyssData: HoYo.AbyssReport4GI? = nil
    ) async throws {
        guard profile.game == .genshinImpact else { throw InitError.wrongGame }
        guard SnapHutao.isCommissionPermittedByUser else {
            throw SnapHutao.SHError.insufficientUserPermission
        }
        self.uid = profile.uid
        self.identity = "GenshinPizzaHelper"
        self.reservedUserName = ""
        var abyssData = abyssData
        if abyssData == nil {
            abyssData = try await HoYo.abyssReportData4GI(for: profile)
        }
        guard let abyssData else { throw InitError.abyssDataNotSupplied }
        guard abyssData.totalStar == 36 else { throw InitError.insufficientStars }
        let rawInventory = try await HoYo.getCharacterInventory(for: profile)
        guard let allAvatarInfo = rawInventory as? HoYo.CharInventory4GI else { throw InitError.wrongGame }
        self.avatars = allAvatarInfo.avatars.map { avatar in
            .init(
                avatarId: avatar.id,
                weaponId: avatar.weapon.id,
                reliquarySetIds: avatar.reliquaries.map(\.set.id),
                activedConstellationNumber: avatar.activedConstellationNum
            )
        }
        self.spiralAbyss = .init(data: abyssData)
    }
}
