// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import PZBaseKit

// MARK: - EnkaDBProtocol

@available(iOS 17.0, macCatalyst 17.0, *)
public protocol EnkaDBProtocol: AnyObject, Sendable {
    associatedtype QueriedResult: EKQueryResultProtocol where QueriedResult.DBType == Self
    associatedtype QueriedProfile: EKQueriedProfileProtocol where QueriedProfile.DBType == Self
    associatedtype HYLAvatarDetailType: HYQueriedAvatarProtocol where HYLAvatarDetailType.DBType == Self
    static var game: Enka.GameType { get }
    var locTable: Enka.LocTable { get set }
    var locTag: String { get }
    var isExpired: Bool { get set }

    @MainActor static var shared: Self { get }

    init(host: Enka.HostType) async throws
    init(locTag: String?) throws

    func getNameTextMapHash(id: String) -> String?
    func checkIfExpired(against givenProfile: QueriedProfile) -> Bool

    @MainActor
    func saveSelfToUserDefaults()

    @MainActor
    func update(new: Self)
}

// MARK: - Online Update & Query.

@available(iOS 17.0, macCatalyst 17.0, *)
extension EnkaDBProtocol {
    public typealias QueriedAvatar = QueriedProfile.QueriedAvatar
    public typealias SummarizedType = Enka.ProfileSummarized<Self>

    public var game: Enka.GameType { Self.game }

    /// 这个 Symbol 目前还没派上用场，回头得另议与此有关的处置方案。
    public var needsUpdate: Bool {
        let previousDate = Defaults[.lastEnkaDBDataCheckDate]
        let expired = Calendar.gregorian.date(byAdding: .hour, value: 2, to: previousDate)! < Date()
        return expired || Enka.currentLangTag != locTag
    }

    @MainActor
    @discardableResult
    public func reinit() throws -> Self {
        let newDB = try Self(locTag: Enka.currentLangTag)
        newDB.saveSelfToUserDefaults()
        update(new: newDB)
        return self
    }

    @MainActor
    @discardableResult
    public func reinitOnlyIfBundledDBIsNewer() throws -> Self {
        let bundledDB = try Self(locTag: Enka.currentLangTag)
        guard bundledDB.locTable.count > locTable.count else { return self }
        bundledDB.saveSelfToUserDefaults()
        update(new: bundledDB)
        return self
    }

    @MainActor
    @discardableResult
    public func onlineUpdate() async throws -> Self {
        let newDB = try await Self(host: Defaults[.defaultDBQueryHost])
        newDB.saveSelfToUserDefaults()
        Defaults[.lastEnkaDBDataCheckDate] = Date()
        update(new: newDB)
        return self
    }

    public func getCachedProfileRAW(uid: String) -> QueriedProfile? {
        QueriedProfile.getCachedProfile(uid: uid)
    }

    public func removeCachedProfileRAW(uid: String) {
        QueriedProfile.removeCachedProfile(uid: uid)
    }

    public func getAllCachedProfiles() -> [String: QueriedProfile] {
        QueriedProfile.getAllCachedProfiles()
    }

    @MainActor
    public func query(
        for uid: String,
        dateWhenNextRefreshable nextAvailableDate: Date? = nil
    ) async throws
        -> Self.QueriedProfile {
        let existingData = QueriedProfile.getCachedProfile(uid: uid)
        do {
            let detailInfo = try await QueriedResult.queryProfile(uid: uid, dateWhenNextRefreshable: nextAvailableDate)
            let newMerged = detailInfo.inheritAvatars(from: existingData)
            newMerged.saveToCache()
            return newMerged
        } catch {
            let msg = error.localizedDescription + "\n-------\n// \(error)"
            print(msg)
            switch error {
            case Enka.EKError.queryFailure: throw error
            default: throw Enka.EKError.queryFailure(uid: uid, game: QueriedResult.game, message: msg)
            }
        }
    }
}

// MARK: - Translation APIs.

@available(iOS 17.0, macCatalyst 17.0, *)
extension EnkaDBProtocol {
    public var locTagMismatchingTheSystem: Bool {
        Enka.currentLangTag != locTag
    }

    public func reinitIfLocMismatches() async throws {
        guard locTagMismatchingTheSystem else { return }
        try await reinit()
    }

    public func getFailableTranslationFor(id: String, realName: Bool = true) -> String? {
        var id = id
        if game == .genshinImpact {
            id = id.split(separator: "_").first?.description ?? id
        }
        // 处理雷电国崩的自订姓名。
        if realName, let matchedRealName = Enka.JSONType.bundledRealNameTable[locTag]?[id] {
            return matchedRealName
        } else if ["10000075", "3230559562"].contains(id), !Defaults[.customizedNameForWanderer].isEmpty {
            return Defaults[.customizedNameForWanderer]
        }
        // 正常处理。
        let result: String? = {
            if let hash = getNameTextMapHash(id: id) {
                return locTable[hash]
            } else if game == .genshinImpact, let intHashID = Int(id),
                      let hash = hashMigrationTable4Genshin65[intHashID] {
                // 原神 6.5 更换了新的 NameTextMapHash，但没全部更换。此处使用转换表翻译之。
                // 不然的话，设备缓存的面板可能无法正常解读。
                // 此处的转换表保留一年。
                return locTable[hash.description]
            } else {
                return locTable[id]
            }
        }()
        guard Defaults[.forceCharacterWeaponNameFixed] else { return result }
        guard let result else { return nil }
        if Locale.isUILanguageSimplifiedChinese {
            return Enka.kanjiFixTableCHS[result] ?? result
        } else if Locale.isUILanguageTraditionalChinese {
            return Enka.kanjiFixTableCHT[result] ?? result
        }
        return result
    }

    func getTranslationFor(id: String, realName: Bool = true) -> String {
        let missingTranslation = "i18nMissing(id:\(id))"
        return getFailableTranslationFor(id: id, realName: realName) ?? missingTranslation
    }

    func getTranslationFor(property: Enka.PropertyType) -> String? {
        if let realNameMap = Enka.JSONType.bundledRealNameTable[locTag],
           let matchedRealName = realNameMap[property.rawValue] {
            return matchedRealName
        }
        return locTable[property.rawValue]
    }

    var additionalLocTable: [String: String] {
        Enka.JSONType.bundledExtraLangTable[locTag] ?? [:]
    }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka {
    fileprivate static let kanjiFixTableCHS: [String: String] = [
        "钟离": "锺离",
        "芙宁娜": "芙黎娜", // 得分清ㄋㄌ。
        "希诺宁": "希洛宁", // 得分清ㄋㄌ。
        "艾尔海森": "阿尔海森",
    ]

    fileprivate static let kanjiFixTableCHT: [String: String] = [
        "雲堇": "雲菫",
        "風堇": "風菫",
        "霧切之回光": "霧切之迴光",
        "芙寧娜": "芙黎娜", // 得分清ㄋㄌ。
        "希諾寧": "希洛寧", // 得分清ㄋㄌ。
        "茜特菈莉": "菥特菈莉", // 「茜」在港澳台不是多音字，没有「西」音。
        "艾爾海森": "阿爾海森",
    ]
}

/// 原神 6.5 更换了新的 NameTextMapHash，但没全部更换。此处使用转换表翻译之。
/// 不然的话，设备缓存的面板可能无法正常解读。
/// 此处的转换表保留一年。
private let hashMigrationTable4Genshin65: [Int: Int] = [
    37147251: 37146739,
    102656986: 102656474,
    123009691: 123009179,
    123650890: 123650378,
    160493219: 160492707,
    167199474: 167198962,
    168956722: 168956210,
    283438874: 283438362,
    310247243: 310246731,
    316078811: 316078299,
    334242634: 334242122,
    342097547: 342097035,
    357888539: 357888027,
    370151050: 370150538,
    426363739: 426363227,
    449192923: 449192411,
    452357939: 452357427,
    486513155: 486512643,
    565052971: 565052459,
    578575283: 578574771,
    618786571: 618786059,
    646032090: 646031578,
    655825874: 655825362,
    680510411: 680509899,
    693354267: 693353755,
    712501082: 712500570,
    724881171: 724880659,
    735056795: 735056283,
    781488962: 781488450,
    882305891: 882305379,
    902184579: 902184067,
    933442195: 933441683,
    937533090: 937532578,
    968893378: 968892866,
    1021898539: 1021898027,
    1021947690: 1021947178,
    1055195035: 1055194523,
    1075647299: 1075646787,
    1089950259: 1089949747,
    1130996346: 1130995834,
    1148024603: 1148024091,
    1182966603: 1182966091,
    1183454019: 1183453507,
    1197975042: 1197974530,
    1200948859: 1200948347,
    1201790667: 1201790155,
    1235521427: 1235520915,
    1257396043: 1257395531,
    1321135667: 1321135155,
    1363661611: 1363661099,
    1388004931: 1388004419,
    1431322346: 1431321834,
    1438964522: 1438964010,
    1441327747: 1441327235,
    1455107995: 1455107483,
    1456643042: 1456642530,
    1468367538: 1468367026,
    1473399443: 1473398931,
    1479741275: 1479740763,
    1479961579: 1479961067,
    1533656818: 1533656306,
    1573692171: 1573691659,
    1600275315: 1600274803,
    1608953539: 1608953027,
    1705786122: 1705785610,
    1732418482: 1732417970,
    1773425155: 1773424643,
    1776874018: 1776873506,
    1790067483: 1790066971,
    1804674810: 1804674298,
    1888371618: 1888371106,
    1890163363: 1890162851,
    1901973075: 1901972563,
    1921418842: 1921418330,
    1940821986: 1940821474,
    1940919994: 1940919482,
    1965515667: 1965515155,
    2077869763: 2077869251,
    2125206395: 2125205883,
    2195665683: 2195665171,
    2275710883: 2275710371,
    2332664426: 2332663914,
    2340970067: 2340969555,
    2359799475: 2359798963,
    2387711994: 2387711482,
    2400012995: 2400012483,
    2481464075: 2481463563,
    2491797315: 2491796803,
    2515292882: 2515292370,
    2539208459: 2539207947,
    2556914683: 2556914171,
    2614170427: 2614169915,
    2664629131: 2664628619,
    2666951267: 2666950755,
    2679781122: 2679780610,
    2713453234: 2713452722,
    2745369298: 2745368786,
    2745786202: 2745785690,
    2753539619: 2753539107,
    2832648187: 2832647675,
    2846112523: 2846112011,
    2848374378: 2848373866,
    2918525947: 2918525435,
    2935286715: 2935286203,
    2944936683: 2944936171,
    2948362178: 2948361666,
    2949448555: 2949448043,
    3016493955: 3016493443,
    3024507506: 3024506994,
    3073454867: 3073454355,
    3097441915: 3097441403,
    3112679155: 3112678643,
    3120492514: 3120492002,
    3156385731: 3156385219,
    3176599083: 3176598571,
    3221566250: 3221565738,
    3235324891: 3235324379,
    3273999011: 3273998499,
    3380505211: 3380504699,
    3398665018: 3398664506,
    3400133546: 3400133034,
    3421967235: 3421966723,
    3439749859: 3439749347,
    3447737235: 3447736723,
    3456986819: 3456986307,
    3497155131: 3497154619,
    3500935003: 3500934491,
    3555115602: 3555115090,
    3573591875: 3573591363,
    3608180322: 3608179810,
    3625393819: 3625393307,
    3648220770: 3648220258,
    3673792067: 3673791555,
    3689108098: 3689107586,
    3717667418: 3717666906,
    3719372715: 3719372203,
    3775299170: 3775298658,
    3784387538: 3784387026,
    3790622667: 3790622155,
    3796905611: 3796905099,
    3827789435: 3827788923,
    3847143266: 3847142754,
    3887688410: 3887687898,
    3949653579: 3949653067,
    3995710363: 3995709851,
    4002157418: 4002156906,
    4038676067: 4038675555,
    4049410651: 4049410139,
    4103022435: 4103021923,
    4108620722: 4108620210,
    4119663210: 4119662698,
    4122509083: 4122508571,
    4127888970: 4127888458,
    4139294531: 4139294019,
    4158505619: 4158505107,
    4160147242: 4160146730,
    4172712634: 4172712122,
    4176923379: 4176922867,
    4197635682: 4197635170,
    4201964354: 4201963842,
]
