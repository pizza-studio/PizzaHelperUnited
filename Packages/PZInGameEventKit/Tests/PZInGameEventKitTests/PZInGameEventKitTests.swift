// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Alamofire
import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
@testable import PZInGameEventKit
import Testing

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Test
func testDecodingOnlineFetchedOfficialFeeds() async throws {
    for game in Pizza.SupportedGame.allCases {
        // Test EventContent
        let urlDataC = game.getOfficialEventFeedURL(.asia(game), lang: .langJP, isContent: true)
        let resultC = try await AF.request(urlDataC).serializingData().value
        let objContent = try HoYoEventPack.HoYoEventContent.decodeFromMiHoYoAPIJSONResult(data: resultC, debugTag: "")
        print(objContent.total)
        // Test EventMeta
        let urlDataM = game.getOfficialEventFeedURL(.asia(game), lang: .langJP, isContent: false)
        let resultM = try await AF.request(urlDataM).serializingData().value
        let objMeta = try HoYoEventPack.HoYoEventMeta.decodeFromMiHoYoAPIJSONResult(data: resultM, debugTag: "")
        print(objMeta.list.count)
    }
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
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

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Test
func testGetAllOfficialFeedEventsOnline() async throws {
    let allData = await OfficialFeed.getAllFeedEventsOnline(bypassCache: true)
    let allZZZResults = allData.filter { $0.game == .zenlessZone }
    #expect(!allZZZResults.isEmpty)
    print(allZZZResults.count)
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Test
func testGetAllOfficialFeedEventsOffline() async throws {
    let allData = OfficialFeed.getAllBundledFeedEvents()
    let allZZZResults = allData.filter { $0.game == .zenlessZone }
    #expect(!allZZZResults.isEmpty)
    print(allZZZResults.count)
}

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
@Test
func testGetAllOfficialFeedEventsCache() async throws {
    _ = await OfficialFeed.getAllFeedEventsOnline(bypassCache: false)
    let cachedGIEvents = OfficialFeed.getCachedEventsIfValid(for: .genshinImpact) ?? []
    #expect(!cachedGIEvents.isEmpty)
    Defaults[.officialFeedCache].removeAll()
    Defaults[.officialFeedMostRecentFetchDate].removeAll()
}
