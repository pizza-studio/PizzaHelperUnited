// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit
import PZBaseKit

extension HoYo {
    public static func getBattleReportSet(for profile: PZProfileSendable) async throws -> (any BattleReportSet)? {
        switch profile.game {
        case .genshinImpact:
            let current = try await battleReportData4GI(for: profile, isPreviousRound: false)
            let previous = try await battleReportData4GI(for: profile, isPreviousRound: true)
            return BattleReportSet4GI(current: current, previous: previous, profile: profile)
        case .starRail:
            let current = try await battleReportData4HSR(for: profile, isPreviousRound: false)
            let previous = try await battleReportData4HSR(for: profile, isPreviousRound: true)
            return BattleReportSet4HSR(current: current, previous: previous, profile: profile)
        default: return nil
        }
    }
}

extension HoYo {
    static func battleReportData4GI(
        for profile: PZProfileSendable, isPreviousRound: Bool = false
    ) async throws
        -> BattleReport4GI {
        let spiralAbyss = try await battleReportData4GISpiralAbyss(
            isPreviousRound: isPreviousRound,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
        return .init(spiralAbyss: spiralAbyss)
    }

    static func battleReportData4HSR(
        for profile: PZProfileSendable, isPreviousRound: Bool = false
    ) async throws
        -> BattleReport4HSR {
        let dataForgottenHall = try await battleReportData4HSRForgottenHall(
            isPreviousRound: isPreviousRound,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
        let dataApocalypticShadow = try await battleReportData4HSRApoShadow(
            isPreviousRound: isPreviousRound,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
        let dataPureFiction = try await battleReportData4HSRPureFiction(
            isPreviousRound: isPreviousRound,
            server: profile.server,
            uid: profile.uid,
            cookie: profile.cookie,
            deviceFingerPrint: profile.deviceFingerPrint,
            deviceID: profile.deviceID
        )
        let result = HoYo.BattleReport4HSR(
            forgottenHall: dataForgottenHall,
            pureFiction: dataPureFiction,
            apocalypticShadow: dataApocalypticShadow
        )
        return result
    }
}

// MARK: - Private Methods (Genshin Impact).

extension HoYo {
    private static func battleReportData4GISpiralAbyss(
        isPreviousRound: Bool = false,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> BattleReport4GI.SpiralAbyssData {
        let type = HoYo.BattleReport4GI.TreasuresStarwardType.spiralAbyss
        await HoYo.waitFor300ms()
        #if DEBUG
        print("||| START REQUESTING SPIRAL ABYSS DATA (GI - SpiralAbyss) |||")
        #endif
        let queryItems: [URLQueryItem] = [
            .init(name: "role_id", value: uid),
            .init(name: "schedule_type", value: isPreviousRound ? "2" : "1"),
            .init(name: "server", value: server.rawValue),
        ]

        let additionalHeaders: [String: String]? = {
            if let deviceFingerPrint, !deviceFingerPrint.isEmpty, let deviceID {
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                nil
            }
        }()

        let request = try await Self.generateRecordAPIRequest(
            region: server.region,
            path: type.getAPIPath(region: server.region),
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let data = try await request.serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.battleReportData4GISpiralAbyss()")
    }
}

// MARK: - Private Methods (Star Rail).

extension HoYo {
    private static func battleReportData4HSRForgottenHall(
        isPreviousRound: Bool = false,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> BattleReport4HSR.ForgottenHallData {
        let type = HoYo.BattleReport4HSR.TreasuresLightwardType.forgottenHall
        await HoYo.waitFor300ms()
        #if DEBUG
        print("||| START REQUESTING SPIRAL ABYSS DATA (HSR - ForgottenHall) |||")
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
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                [:]
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
            path: type.getAPIPath(region: server.region),
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let data = try await request.serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.battleReportData4HSRForgottenHall()")
    }

    private static func battleReportData4HSRPureFiction(
        isPreviousRound: Bool = false,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> BattleReport4HSR.PureFictionData {
        let type = HoYo.BattleReport4HSR.TreasuresLightwardType.pureFiction
        await HoYo.waitFor300ms()
        #if DEBUG
        print("||| START REQUESTING SPIRAL ABYSS DATA (HSR - Pure Fiction) |||")
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
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                [:]
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
            path: type.getAPIPath(region: server.region),
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let data = try await request.serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.battleReportData4HSRPureFiction()")
    }

    private static func battleReportData4HSRApoShadow(
        isPreviousRound: Bool = false,
        server: Server,
        uid: String,
        cookie: String,
        deviceFingerPrint: String?,
        deviceID: String?
    ) async throws
        -> BattleReport4HSR.ApocalypticShadowData {
        let type = HoYo.BattleReport4HSR.TreasuresLightwardType.apocalypticShadow
        await HoYo.waitFor300ms()
        #if DEBUG
        print("||| START REQUESTING SPIRAL ABYSS DATA (HSR - Pure Fiction) |||")
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
                [
                    "x-rpc-device_fp": deviceFingerPrint,
                    "x-rpc-device_id": deviceID,
                ]
            } else {
                [:]
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
            path: type.getAPIPath(region: server.region),
            queryItems: queryItems,
            cookie: cookie,
            additionalHeaders: additionalHeaders
        )
        request.printDebugIntelIfDebugMode()

        let data = try await request.serializingData().value

        return try .decodeFromMiHoYoAPIJSONResult(data: data, debugTag: "HoYo.battleReportData4HSRApoShadow()")
    }
}

extension HoYo.BattleReport4GI.TreasuresStarwardType {
    /// 搭配 `.recordURLAPIHost()` 使用。
    public func getAPIPath(region: HoYo.AccountRegion) -> String {
        switch (self, region) {
        case (.spiralAbyss, .hoyoLab): "/game_record/app/genshin/api/spiralAbyss"
        case (.spiralAbyss, .miyoushe): "/game_record/app/genshin/api/spiralAbyss"
        }
    }
}

extension HoYo.BattleReport4HSR.TreasuresLightwardType {
    /// 搭配 `.recordURLAPIHost()` 使用。
    public func getAPIPath(region: HoYo.AccountRegion) -> String {
        switch (self, region) {
        case (.forgottenHall, .hoyoLab): "/game_record/app/hkrpg/api/challenge"
        case (.forgottenHall, .miyoushe): "/game_record/app/hkrpg/api/challenge"
        case (.pureFiction, .hoyoLab): "/game_record/app/hkrpg/api/challenge_story"
        case (.pureFiction, .miyoushe): "/game_record/app/hkrpg/api/challenge_story"
        case (.apocalypticShadow, .hoyoLab): "/game_record/app/hkrpg/api/challenge_boss"
        case (.apocalypticShadow, .miyoushe): "/game_record/app/hkrpg/api/challenge_boss"
        }
    }
}
