// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

@testable import EnkaKit
import Foundation
import Testing

// MARK: - ArtifactRatingTests

struct ArtifactRatingTests {
    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testInitializingBundledArtifactRatingDB() async throws {
        let dictA = ArtifactRating.ModelDB(game: .starRail)
        let dictB = ArtifactRating.ModelDB(game: .genshinImpact)
        #expect(!dictA.isEmpty)
        #expect(!dictB.isEmpty)
        try await ArtifactRating.ARSputnik.shared.onlineUpdate()
        let c = ArtifactRating.ARSputnik.shared.countDB4GI
        print(c)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testFetchingRemoteData() async throws {
        _ = try await ArtifactRating.ARSputnik.fetchARDBData(
            from: .mainlandChina,
            type: .arDB4GI,
            decodingTo: ArtifactRating.ModelDB.self
        )
        _ = try await ArtifactRating.ARSputnik.fetchARDBData(
            from: .mainlandChina,
            type: .arDB4HSR,
            decodingTo: ArtifactRating.ModelDB.self
        )
    }
}

// MARK: - EnkaKitTests

@MainActor
struct EnkaKitTests {
    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testDecodingPropertyAndElement() throws {
        let jsonStr1 = #"{"PropType": "GrassAddedRatio"}"#
        let jsonStr2 = #"{"Element": "Grass"}"#
        let jsonStr3 = #"{"PropType": "20"}"#
        let jsonStr4 = #"{"CriticalChance": 0.533699989318848}"#
        let jsonStr5 = """
        {
        "1":15307.388671875,"2":6871.27978515625,
        "3":1.042799949646,"4":785.791748046875,
        "5":326.559997558594,"6":0.157399997115135,
        "7":695.541687011719,"8":39.3499984741211,
        "9":0.109300002455711,"20":0.533699989318848,
        "21":0,"22":2.22934794425964,"23":1.48570001125336,
        "26":0,"27":0,"28":41.9599990844727,
        "29":0,"30":0,"40":0,"41":0,"42":0,"43":0,"44":0,
        "45":0,"46":0,"50":0,"51":0,"52":0,"53":0,"54":0,
        "55":0,"56":0,"72":60,"1002":33.5768241882324,
        "1010":45488.76171875,"2000":38141.21484375,
        "2001":1236.03540039063,"2002":810.914367675781,
        "2003":0,"2004":0,"2005":0,"3006":0,"3045":0,"3046":1
        }
        """
        let data1 = try #require(jsonStr1.data(using: .utf8), "jsonStr1 is nil")
        let data2 = try #require(jsonStr2.data(using: .utf8), "jsonStr2 is nil")
        let data3 = try #require(jsonStr3.data(using: .utf8), "jsonStr3 is nil")
        let data4 = try #require(jsonStr4.data(using: .utf8), "jsonStr4 is nil")
        let data5 = try #require(jsonStr5.data(using: .utf8), "jsonStr5 is nil")
        let decoded1 = try #require(
            try? JSONDecoder().decode([String: Enka.PropertyType].self, from: data1), "jsonStr1 is not decodable"
        )
        let decoded2 = try #require(
            try? JSONDecoder().decode([String: Enka.GameElement].self, from: data2), "jsonStr2 is not decodable"
        )
        let decoded3 = try #require(
            try? JSONDecoder().decode([String: Enka.PropertyType].self, from: data3), "jsonStr3 is not decodable"
        )
        let decoded4 = try #require(
            try? JSONDecoder().decode([Enka.PropertyType: Double].self, from: data4), "jsonStr4 is not decodable"
        )
        let decoded5 = try #require(
            try? JSONDecoder().decode([Enka.PropertyType: Double].self, from: data5), "jsonStr5 is not decodable"
        )
        #expect(decoded1.values.first == .dendroAddedRatio)
        #expect(decoded2.values.first == .dendro)
        #expect(decoded3.values.first == .criticalChance)
        #expect(decoded4[.criticalChance] == 0.533699989318848)
        #expect(decoded5[.criticalChance] == 0.533699989318848)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaDBInitUsingBundledData() throws {
        let dbGI = try Enka.EnkaDB4GI(locTag: "zh-Hant")
        let dbHSR = try Enka.EnkaDB4HSR(locTag: "zh-Hant")
        #expect(dbGI.locTag == "zh-tw")
        #expect(dbHSR.locTag == "zh-tw")
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaDBOnlineConstruction() async throws {
        let dbGI = try await Enka.EnkaDB4GI(host: .mainlandChina)
        let dbHSR = try await Enka.EnkaDB4HSR(host: .mainlandChina)
        #expect(dbGI.game == .genshinImpact)
        #expect(dbHSR.game == .starRail)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaQueryFileDecoding() throws {
        let hsrDecoded = try Enka.QueriedResultHSR.exampleData()
        let giDecoded = try Enka.QueriedResultGI.exampleData()
        let hsrProfile = try #require(
            hsrDecoded.detailInfo, "No HSR Profile found in decoded results."
        )
        let giProfile = try #require(
            giDecoded.detailInfo, "No GI Profile found in decoded results."
        )
        #expect(hsrProfile.uid == giProfile.uid)
        let giDecodedHYL = try HYQueriedModels.HYLAvatarDetail4GI.exampleData()
        let hsrDecodedHYL = try HYQueriedModels.HYLAvatarDetail4HSR.exampleData()
        #expect(!giDecodedHYL.avatarList.isEmpty)
        #expect(!hsrDecodedHYL.avatarList.isEmpty)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaOnlineProfileQuery() async throws {
        let hsrQueried = try await Enka.QueriedResultHSR.queryProfile(uid: "114514810")
        let giQueried = try await Enka.QueriedResultGI.queryProfile(uid: "114514810")
        #expect(hsrQueried.uid == giQueried.uid)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaHSRProfileSummaryAsText() async throws {
        let englishDB = try Enka.EnkaDB4HSR(locTag: "en")
        Enka.Sputnik.shared.db4HSR = englishDB
        ArtifactRating.ARSputnik.shared.resetFactoryScoreModel()
        let hsrDecoded = try Enka.QueriedResultHSR.exampleData()
        let profile = try #require(hsrDecoded.detailInfo, "HSR detailInfo is nil.")
        let firstAvatar = try #require(
            profile.avatarDetailList.first, "First avatar (Raiden Mei) missing."
        )
        let summarized = try #require(
            firstAvatar.summarize(theDB: englishDB)?.artifactsRated(),
            "Failed in summarizing Raiden Mei's character build."
        )
        print(summarized.asText)
        print(summarized.mainInfo.idExpressable.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.talent.onlineAssetURLStr)
        if let weapon = summarized.equippedWeapon { print(weapon.onlineAssetURLStr) }
        summarized.artifacts.forEach { print($0.onlineAssetURLStr) }
        print(profile.iconAssetName)
        print(profile.onlineAssetURLStr)
        let x = summarized.artifactRatingResult
        print(x ?? "Result Rating Failed.")
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaGIProfileSummaryAsText() async throws {
        let englishDB = try Enka.EnkaDB4GI(locTag: "en")
        ArtifactRating.ARSputnik.shared.resetFactoryScoreModel()
        let giDecoded = try Enka.QueriedResultGI.exampleData()
        let profile = try #require(giDecoded.detailInfo, "GI detailInfo is nil.")
        #expect(profile.avatarDetailList.count == 12, "Expecting 12 avatars in detail list.")
        // Test Manekina.
        let manekinaRAW = try #require(
            profile.avatarDetailList.dropFirst(9).first,
            "Manekina avatar missing (index 9 out of range)."
        )
        let manekina = try #require(
            manekinaRAW.summarize(theDB: englishDB)?.artifactsRated(),
            "Failed in summarizing Manekina."
        )
        #expect(manekina.mainInfo.element == .pyro)
        print(manekina.asText)
        print(manekina.asText)
        print(manekina.mainInfo.idExpressable.onlineAssetURLStr)
        print(manekina.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(manekina.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(manekina.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        if let weapon = manekina.equippedWeapon { print(weapon.onlineAssetURLStr) }
        manekina.artifacts.forEach { print($0.onlineAssetURLStr) }
        print(profile.iconAssetName)
        print(profile.onlineAssetURLStr)
        let x4Manekina = manekina.artifactRatingResult
        print(x4Manekina ?? "Result Rating Failed for Manekina.")
        // Test Hutao with costume.
        let ninthAvatar = try #require(
            profile.avatarDetailList.dropFirst(8).first,
            "Hutao avatar missing (index 8 out of range)."
        )
        let hutao = try #require(
            ninthAvatar.summarize(theDB: englishDB)?.artifactsRated(),
            "Failed in summarizing Hutao character build (with costume)."
        )
        print(hutao.asText)
        print(hutao.mainInfo.idExpressable.onlineAssetURLStr)
        print(hutao.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(hutao.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(hutao.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        if let weapon = hutao.equippedWeapon { print(weapon.onlineAssetURLStr) }
        hutao.artifacts.forEach { print($0.onlineAssetURLStr) }
        print(profile.iconAssetName)
        print(profile.onlineAssetURLStr)
        let x4Hutao = hutao.artifactRatingResult
        print(x4Hutao ?? "Result Rating Failed for Hutao.")
    }
}

// MARK: - EnkaKitWithHoYoQueryResultTests

@MainActor
struct EnkaKitWithHoYoQueryResultTests {
    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testBatchSummary4GI() async throws {
        let chtDB = try Enka.EnkaDB4GI(locTag: "zh-Hant")
        Enka.Sputnik.shared.db4GI = chtDB
        let giDecoded = try HYQueriedModels.HYLAvatarDetail4GI.exampleData()
        let summarized = await Task { @MainActor in
            giDecoded.avatarList.compactMap { $0.summarize(theDB: chtDB) }
        }.value
        #expect(giDecoded.avatarList.count == summarized.count)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testBatchSummary4HSR() async throws {
        let chtDB = try Enka.EnkaDB4HSR(locTag: "zh-Hant")
        Enka.Sputnik.shared.db4HSR = chtDB
        let hsrDecoded = try HYQueriedModels.HYLAvatarDetail4HSR.exampleData()
        var failedCharIDs: [Int] = []
        let summarized = hsrDecoded.avatarList.compactMap {
            let summarizedSingle = $0.summarize(theDB: chtDB)
            if summarizedSingle == nil {
                failedCharIDs.append($0.id)
            }
            return summarizedSingle
        }
        print("failedCharIDs: \(failedCharIDs)")
        #expect(failedCharIDs.isEmpty)
        #expect(hsrDecoded.avatarList.count == summarized.count)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testHoYoGIProfileSummaryAsText() async throws {
        let giDecoded = try HYQueriedModels.HYLAvatarDetail4GI.exampleData()
        let firstAvatar = try #require(giDecoded.avatarList.first, "First avatar (Raiden Ei) missing.")
        let chtDB = try Enka.EnkaDB4GI(locTag: "zh-Hant")
        Enka.Sputnik.shared.db4GI = chtDB
        let summarized = try #require(
            firstAvatar.summarize(theDB: chtDB)?.artifactsRated(),
            "Failed in summarizing Keqing's character build."
        )
        print(summarized.asText)
        print(summarized.mainInfo.idExpressable.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        if let weapon = summarized.equippedWeapon { print(weapon.onlineAssetURLStr) }
        summarized.artifacts.forEach { print($0.onlineAssetURLStr) }
        let x4Keqing = summarized.artifactRatingResult
        print(x4Keqing ?? "Result Rating Failed for Keqing.")
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testHoYoHSRProfileSummaryAsText() async throws {
        let hsrDecoded = try HYQueriedModels.HYLAvatarDetail4HSR.exampleData()
        let firstAvatar = try #require(
            hsrDecoded.avatarList.first, "First HSR avatar (Seele) missing."
        )
        let chtDB = try Enka.EnkaDB4HSR(locTag: "zh-Hant")
        Enka.Sputnik.shared.db4HSR = chtDB
        let summarized = try #require(
            firstAvatar.summarize(theDB: chtDB)?.artifactsRated(),
            "Failed in summarizing Seele's character build."
        )
        print(summarized.asText)
        print(summarized.mainInfo.idExpressable.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        if let weapon = summarized.equippedWeapon { print(weapon.onlineAssetURLStr) }
        summarized.artifacts.forEach { print($0.onlineAssetURLStr) }
        let x4Seele = summarized.artifactRatingResult
        print(x4Seele ?? "Result Rating Failed for Seele.")
    }
}
