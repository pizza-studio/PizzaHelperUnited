// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
@testable import PZInGameEventKit
import Testing

@Test
func testDecodingOnlineFetchedOfficialFeeds() async throws {
    for game in Pizza.SupportedGame.allCases {
        // Test EventContent
        let urlDataC = game.getOfficialEventFeedURL(.asia(game), lang: .langJP, isContent: true)
        let dataC = try await URLSession.shared.data(from: urlDataC)
        let objContent = try HoYoEventPack.HoYoEventContent.decodeFromMiHoYoAPIJSONResult(data: dataC.0, debugTag: "")
        print(objContent.total)
        // Test EventMeta
        let urlDataM = game.getOfficialEventFeedURL(.asia(game), lang: .langJP, isContent: false)
        let dataM = try await URLSession.shared.data(from: urlDataM)
        let objMeta = try HoYoEventPack.HoYoEventMeta.decodeFromMiHoYoAPIJSONResult(data: dataM.0, debugTag: "")
        print(objMeta.list.count)
    }
}

@Test
func testDecodingBundledOfficialFeeds() async throws {
    for game in Pizza.SupportedGame.allCases {
        // Test EventContent
        let dataC = game.getTestDataForOfficialEvents(isContent: true)
        let objContent = try HoYoEventPack.HoYoEventContent.decodeFromMiHoYoAPIJSONResult(data: dataC, debugTag: "")
        print(objContent.total)
        // Test EventMeta
        let dataM = game.getTestDataForOfficialEvents(isContent: false)
        let objMeta = try HoYoEventPack.HoYoEventMeta.decodeFromMiHoYoAPIJSONResult(data: dataM, debugTag: "")
        print(objMeta.list.count)
    }
}

@Test
func testGetAllOfficialFeedEventsOnline() async throws {
    let allData = await OfficialFeed.getAllFeedEventsOnline(bypassCache: true)
    print(allData.filter { $0.game == .zenlessZone }.count)
}

@Test
func testGetAllOfficialFeedEventsOffline() async throws {
    let allData = OfficialFeed.getAllBundledFeedEvents()
    print(allData.filter { $0.game == .zenlessZone }.count)
}

@Test
func testGetAllOfficialFeedEventsCache() async throws {
    let allData = await OfficialFeed.getAllFeedEventsOnline(bypassCache: false)
    let cachedGIEvents = OfficialFeed.getCachedEventsIfValid(for: .genshinImpact) ?? []
    #expect(!cachedGIEvents.isEmpty)
    Defaults[.officialFeedCache].removeAll()
    Defaults[.officialFeedMostRecentFetchDate].removeAll()
}
