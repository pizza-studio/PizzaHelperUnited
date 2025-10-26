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
        guard let data1 = jsonStr1.data(using: .utf8),
              let data2 = jsonStr2.data(using: .utf8),
              let data3 = jsonStr3.data(using: .utf8),
              let data4 = jsonStr4.data(using: .utf8),
              let data5 = jsonStr5.data(using: .utf8)
        else {
            preconditionFailure("Data Failure.")
        }
        let decoded1 = try JSONDecoder().decode([String: Enka.PropertyType].self, from: data1)
        let decoded2 = try JSONDecoder().decode([String: Enka.GameElement].self, from: data2)
        let decoded3 = try JSONDecoder().decode([String: Enka.PropertyType].self, from: data3)
        let decoded4 = try JSONDecoder().decode([Enka.PropertyType: Double].self, from: data4)
        let decoded5 = try JSONDecoder().decode([Enka.PropertyType: Double].self, from: data5)
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
        guard let hsrProfile = hsrDecoded.detailInfo, let giProfile = giDecoded.detailInfo else {
            throw TestError.error(msg: "No Profile found in the decoded results.")
        }
        #expect(hsrProfile.uid == giProfile.uid)
        let giDecodedHYL = try HYQueriedModels.HYLAvatarDetail4GI.exampleData()
        let hsrDecodedHYL = try HYQueriedModels.HYLAvatarDetail4HSR.exampleData()
        #expect(!giDecodedHYL.avatarList.isEmpty)
        #expect(!hsrDecodedHYL.avatarList.isEmpty)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaOnlineProfileQueryRAW() async throws {
        let hsrQueried = try await Enka.QueriedResultHSR.queryRAW(uid: "114514810")
        let giQueried = try await Enka.QueriedResultHSR.queryRAW(uid: "114514810")
        #expect(hsrQueried.uid == giQueried.uid)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testEnkaHSRProfileSummaryAsText() async throws {
        let englishDB = try Enka.EnkaDB4HSR(locTag: "en")
        Enka.Sputnik.shared.db4HSR = englishDB
        ArtifactRating.ARSputnik.shared.resetFactoryScoreModel()
        let hsrDecoded = try Enka.QueriedResultHSR.exampleData()
        guard let profile = hsrDecoded.detailInfo, let firstAvatar = profile.avatarDetailList.first else {
            throw TestError.error(msg: "First avatar (Raiden Mei) missing.")
        }
        guard let summarized = await firstAvatar.summarize(theDB: englishDB)?.artifactsRated() else {
            throw TestError.error(msg: "Failed in summarizing Raiden Mei's character build.")
        }
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
        Enka.Sputnik.shared.db4GI = englishDB
        ArtifactRating.ARSputnik.shared.resetFactoryScoreModel()
        let giDecoded = try Enka.QueriedResultGI.exampleData()
        guard let profile = giDecoded.detailInfo, profile.avatarDetailList.count == 12 else {
            throw TestError.error(msg: "Avatar detail list not completely decoded. Expecting 12 avatars.")
        }
        // Test Manekina.
        let manekinaRAW = profile.avatarDetailList[9]
        guard let manekina = await manekinaRAW.summarize(theDB: englishDB)?.artifactsRated() else {
            throw TestError.error(msg: "Failed in summarizing Manekina.")
        }
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
        let ninthAvatar = profile.avatarDetailList[8]
        guard let hutao = await ninthAvatar.summarize(theDB: englishDB)?.artifactsRated() else {
            throw TestError.error(msg: "Failed in summarizing Hutao character build (with costume).")
        }
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

struct EnkaKitWithHoYoQueryResultTests {
    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testBatchSummary4GI() async throws {
        let chtDB = try Enka.EnkaDB4GI(locTag: "zh-Hant")
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
        let hsrDecoded = try HYQueriedModels.HYLAvatarDetail4HSR.exampleData()
        let summarized = await Task { @MainActor in
            hsrDecoded.avatarList.compactMap { $0.summarize(theDB: chtDB) }
        }.value
        #expect(hsrDecoded.avatarList.count == summarized.count)
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testHoYoGIProfileSummaryAsText() async throws {
        let giDecoded = try HYQueriedModels.HYLAvatarDetail4GI.exampleData()
        guard let firstAvatar = giDecoded.avatarList.first else {
            throw TestError.error(msg: "First avatar (Raiden Ei) missing.")
        }
        let chtDB = try Enka.EnkaDB4GI(locTag: "zh-Hant")
        guard let summarized = await firstAvatar.summarize(theDB: chtDB)?.artifactsRated() else {
            throw TestError.error(msg: "Failed in summarizing Keqing's character build.")
        }
        print(summarized.asText)
        print(summarized.mainInfo.idExpressable.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        if let weapon = summarized.equippedWeapon { print(weapon.onlineAssetURLStr) }
        summarized.artifacts.forEach { print($0.onlineAssetURLStr) }
        let x = summarized.artifactRatingResult
        print(x ?? "Result Rating Failed.")
    }

    @available(iOS 17.0, macCatalyst 17.0, *)
    @Test
    func testHoYoHSRProfileSummaryAsText() async throws {
        let hsrDecoded = try HYQueriedModels.HYLAvatarDetail4HSR.exampleData()
        guard let firstAvatar = hsrDecoded.avatarList.first else {
            throw TestError.error(msg: "First avatar (Raiden Mei) missing.")
        }
        let chtDB = try Enka.EnkaDB4HSR(locTag: "zh-Hant")
        guard let summarized = await firstAvatar.summarize(theDB: chtDB)?.artifactsRated() else {
            throw TestError.error(msg: "Failed in summarizing Keqing's character build.")
        }
        print(summarized.asText)
        print(summarized.mainInfo.idExpressable.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        if let weapon = summarized.equippedWeapon { print(weapon.onlineAssetURLStr) }
        summarized.artifacts.forEach { print($0.onlineAssetURLStr) }
        let x = summarized.artifactRatingResult
        print(x ?? "Result Rating Failed.")
    }
}

// MARK: - TestError

enum TestError: Error {
    case error(msg: String)
}
