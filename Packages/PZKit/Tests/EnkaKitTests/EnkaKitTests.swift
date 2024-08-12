// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@testable import EnkaKit
import XCTest

// MARK: - ArtifactRatingTests

final class ArtifactRatingTests: XCTestCase {
    func testInitializingBundledArtifactRatingDB() async throws {
        let dictA = ArtifactRating.ModelDB(game: .starRail)
        let dictB = ArtifactRating.ModelDB(game: .genshinImpact)
        XCTAssertFalse(dictA.isEmpty)
        XCTAssertFalse(dictB.isEmpty)
        try await ArtifactRating.ARSputnik.shared.onlineUpdate()
    }
}

// MARK: - EnkaKitTests

final class EnkaKitTests: XCTestCase {
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
            assertionFailure("Data Failure.")
            return
        }
        let decoded1 = try JSONDecoder().decode([String: Enka.PropertyType].self, from: data1)
        let decoded2 = try JSONDecoder().decode([String: Enka.GameElement].self, from: data2)
        let decoded3 = try JSONDecoder().decode([String: Enka.PropertyType].self, from: data3)
        let decoded4 = try JSONDecoder().decode([Enka.PropertyType: Double].self, from: data4)
        let decoded5 = try JSONDecoder().decode([Enka.PropertyType: Double].self, from: data5)
        XCTAssertEqual(decoded1.values.first, .dendroAddedRatio)
        XCTAssertEqual(decoded2.values.first, .dendro)
        XCTAssertEqual(decoded3.values.first, .criticalChance)
        XCTAssertEqual(decoded4[.criticalChance], 0.533699989318848)
        XCTAssertEqual(decoded5[.criticalChance], 0.533699989318848)
    }

    func testEnkaDBInitUsingBundledData() throws {
        let dbGI = try Enka.EnkaDB4GI(locTag: "zh-Hant")
        let dbHSR = try Enka.EnkaDB4HSR(locTag: "zh-Hant")
        XCTAssertEqual(dbGI.locTag, "zh-tw")
        XCTAssertEqual(dbHSR.locTag, "zh-tw")
    }

    func testEnkaDBOnlineConstruction() async throws {
        let dbGI = try await Enka.EnkaDB4GI(host: .mainlandChina)
        let dbHSR = try await Enka.EnkaDB4HSR(host: .mainlandChina)
        XCTAssertEqual(dbGI.game, .genshinImpact)
        XCTAssertEqual(dbHSR.game, .starRail)
    }

    func testEnkaQueryFileDecoding() throws {
        let hsrDecoded = try getUnitTestJSONObject("testProfileHSR", as: Enka.QueriedResultHSR.self)
        let giDecoded = try getUnitTestJSONObject("testProfileGI", as: Enka.QueriedResultGI.self)
        guard let hsrProfile = hsrDecoded.detailInfo, let giProfile = giDecoded.detailInfo else {
            throw TestError.error(msg: "No Profile found in the decoded results.")
        }
        XCTAssertEqual(hsrProfile.uid, giProfile.uid)
    }

    func testEnkaOnlineProfileQueryRAW() async throws {
        let hsrQueried = try await Enka.QueriedResultHSR.queryRAW(uid: "114514810")
        let giQueried = try await Enka.QueriedResultHSR.queryRAW(uid: "114514810")
        XCTAssertEqual(hsrQueried.uid, giQueried.uid)
    }

    func testEnkaHSRProfileSummaryAsText() throws {
        let hsrDecoded = try getUnitTestJSONObject("testProfileHSR", as: Enka.QueriedResultHSR.self)
        guard let profile = hsrDecoded.detailInfo, let firstAvatar = profile.avatarDetailList.first else {
            throw TestError.error(msg: "First avatar (Raiden Mei) missing.")
        }
        let englishDB = try Enka.EnkaDB4HSR(locTag: "en")
        guard let summarized = firstAvatar.summarize(theDB: englishDB) else {
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
    }

    func testEnkaGIProfileSummaryAsText() throws {
        let giDecoded = try getUnitTestJSONObject("testProfileGI", as: Enka.QueriedResultGI.self)
        guard let profile = giDecoded.detailInfo, let firstAvatar = profile.avatarDetailList.first else {
            throw TestError.error(msg: "First avatar (Keqing, with costume) missing.")
        }
        let englishDB = try Enka.EnkaDB4GI(locTag: "en")
        guard let summarized = firstAvatar.summarize(theDB: englishDB) else {
            throw TestError.error(msg: "Failed in summarizing Keqing's character build.")
        }
        print(summarized.asText)
        print(summarized.mainInfo.idExpressable.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.basicAttack.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalSkill.onlineAssetURLStr)
        print(summarized.mainInfo.baseSkills.elementalBurst.onlineAssetURLStr)
        if let weapon = summarized.equippedWeapon { print(weapon.onlineAssetURLStr) }
        summarized.artifacts.forEach { print($0.onlineAssetURLStr) }
        print(profile.iconAssetName)
        print(profile.onlineAssetURLStr)
    }
}

// MARK: - TestError

let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Tests" }).joined(
    separator: "/"
).dropFirst()

let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"

// MARK: - TestError

enum TestError: Error {
    case error(msg: String)
}

func getUnitTestJSONObject<T: Decodable>(
    _ fileNameStem: String,
    as: T.Type,
    decoderConfigurator: ((JSONDecoder) -> Void)? = nil
) throws
    -> T {
    let urlStr = "\(testDataPath)\(fileNameStem).json"
    let url = URL(filePath: urlStr, directoryHint: .notDirectory)
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(T.self, from: data)
}
