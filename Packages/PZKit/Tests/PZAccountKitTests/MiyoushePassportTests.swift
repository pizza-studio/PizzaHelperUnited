// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
@testable import PZAccountKit
import PZBaseKit
import Testing

// MARK: - MiyoushePassportTests

@Suite("Miyoushe V2 credentials")
struct MiyoushePassportTests {
    // MARK: Internal

    @Test
    func normalizesLegacyCookieFields() {
        let cookie = HoYo.MiyousheCookie(
            cookieString: "stuid=100000001; stoken=v2_abc%3D; mid=test-mid; "
                + "ltuid=100000001; ltoken=v1-ltoken; cookie_token=v1-cookie-token; account_id=100000001"
        )
        #expect(cookie.accountIDV2 == "100000001")
        #expect(cookie.ltuidV2 == "100000001")
        #expect(cookie.stuid == "100000001")
        #expect(cookie.ltokenV2 == "v1-ltoken")
        #expect(cookie.cookieTokenV2 == "v1-cookie-token")
        #expect(cookie.mid == "test-mid")
        #expect(cookie.stoken == "v2_abc%3D")
        #expect(cookie.hasSTokenCredentials)
    }

    @Test
    func prefersV2FieldsOverLegacyAliases() {
        let cookie = HoYo.MiyousheCookie(
            cookieString: "account_id_v2=200000002;account_id=100000001;"
                + "ltuid_v2=200000002;ltuid=100000001;cookie_token_v2=v2-token;cookie_token=v1-token;"
                + "ltmid_v2=lt-mid;mid=canonical-mid;stoken=v2_stoken;stuid=200000002"
        )
        #expect(cookie.accountIDV2 == "200000002")
        #expect(cookie.ltuidV2 == "200000002")
        #expect(cookie.cookieTokenV2 == "v2-token")
        #expect(cookie.mid == "canonical-mid")
    }

    @Test
    func fillsMissingUIDsFromSiblings() {
        let cookie = HoYo.MiyousheCookie(cookieString: "ltuid_v2=300000003;stoken=v2_stoken;mid=test-mid")
        #expect(cookie.accountIDV2 == "300000003")
        #expect(cookie.stuid == "300000003")
        #expect(cookie.hasSTokenCredentials)
    }

    @Test
    func formatsCookieTextInCanonicalOrder() {
        let cookie = makeCookie()
        #expect(
            cookie.cookieString == "account_id_v2=100000001;account_mid_v2=mid-value;"
                + "cookie_token_v2=cookie-token;ltmid_v2=mid-value;ltoken_v2=ltoken-value;"
                + "ltuid_v2=100000001;mid=mid-value;stoken=stoken-value;stuid=100000001;"
        )
    }

    @Test
    func roundTripsCookieText() {
        let cookie = makeCookie()
        let reparsed = HoYo.MiyousheCookie(cookieString: cookie.cookieString)
        #expect(reparsed == cookie)
        #expect(reparsed.cookieString == cookie.cookieString)
    }

    @Test
    func omitsEmptyFieldsFromCookieText() {
        let cookie = HoYo.MiyousheCookie(mid: "mid-value", stoken: "stoken-value", stuid: "100000001")
        #expect(
            cookie.cookieString == "account_mid_v2=mid-value;ltmid_v2=mid-value;mid=mid-value;"
                + "stoken=stoken-value;stuid=100000001;"
        )
    }

    @Test
    func buildsRequestCookieHeaders() {
        let cookie = makeCookie()
        #expect(cookie.appSigningCookieHeader == "mid=mid-value;stoken=stoken-value;stuid=100000001;")
        #expect(
            cookie.webCookieHeader == "account_id_v2=100000001;account_mid_v2=mid-value;"
                + "cookie_token_v2=cookie-token;ltmid_v2=mid-value;ltoken_v2=ltoken-value;"
                + "ltuid_v2=100000001;"
        )
    }

    @Test
    func reportsMissingSTokenCredentials() {
        #expect(!(HoYo.MiyousheCookie(cookieString: "stoken=v2_stoken;mid=test-mid").hasSTokenCredentials))
        #expect(!(HoYo.MiyousheCookie(cookieString: "stuid=1;stoken=v2_stoken").hasSTokenCredentials))
        #expect(!(HoYo.MiyousheCookie(cookieString: "").hasSTokenCredentials))
    }

    @Test
    func signsAppEndRequestsWithSaltTimeAndNonce() {
        let ds = URLRequestHelper.appSignDS(salt: "salt-value", time: "1700000000", nonce: "abcdef")
        let digest = "salt=salt-value&t=1700000000&r=abcdef".md5
        #expect(ds == "1700000000,abcdef,\(digest)")
    }

    @Test
    func buildsTokenExchangeRequestBody() throws {
        let body = try HoYo.exchangeRequestBody(stoken: "v2_stoken", mid: "test-mid", target: .cookieToken)
        let decoded = try #require(
            try JSONSerialization.jsonObject(with: Data(body.utf8)) as? [String: Any]
        )
        #expect(decoded["dst_token_type"] as? Int == 4)
        #expect(decoded["mid"] as? String == "test-mid")
        let srcToken = try #require(decoded["src_token"] as? [String: Any])
        #expect(srcToken["token"] as? String == "v2_stoken")
        #expect(srcToken["token_type"] as? Int == 1)

        let ds = URLRequestHelper.signedBodyDS(
            salt: "salt-value",
            body: body,
            time: "1700000000",
            nonce: "abcdef"
        )
        let digest = "salt=salt-value&t=1700000000&r=abcdef&b=\(body)&q=".md5
        #expect(ds == "1700000000,abcdef,\(digest)")
    }

    @Test
    func escapesTokenExchangeRequestBody() throws {
        let body = try HoYo.exchangeRequestBody(stoken: "v2_a=b&c", mid: "test-mid", target: .ltoken)
        #expect(body.contains(#"\u003d"#))
        #expect(body.contains(#"\u0026"#))
        // 已转义的正文再转义一次不会变化，因此签名时不会二次转义。
        #expect(HoYo.escapedExchangeBody(body) == body)
    }

    @Test
    func escapesJSONBodyBeforeSigning() {
        let json = "{\"src_token\":{\"token\":\"a=b&c<d>e'f\"},\"mid\":\"\u{2028}\"}"
        let expected = #"{"src_token":{"token":"a\u003db\u0026c\u003cd\u003ee\u0027f"},"mid":"\u2028"}"#
        #expect(HoYo.escapedExchangeBody(json) == expected)
    }

    @Test
    func buildsTokenExchangeHeaders() {
        let headers = HoYo.exchangeHeaders(deviceID: "test-device", deviceFP: "0123456789012")
        #expect(headers["x-rpc-client_type"] == "2")
        #expect(headers["x-rpc-game_biz"] == "bbs_cn")
        #expect(headers["x-rpc-sdk_version"] == "2.44.0")
        #expect(headers["x-rpc-account_version"] == "2.44.0")
        #expect(headers["x-rpc-app_version"] == "2.119.0")
        #expect(headers["x-rpc-device_id"] == "test-device")
        #expect(headers["x-rpc-device_fp"] == "0123456789012")
        #expect(headers["cookie"] == nil)
    }

    @Test
    func decodesTokenExchangeResponseWithStringTypedNumbers() throws {
        // 真实回应里 `expire_in_seconds` 与 `user_info.aid` 都是字符串，`token_type` 是数字。
        let json = """
        {"retcode":0,"message":"OK","data":{"token":{"token_type":2,"token":"v2_fake"},
        "user_info":{"aid":"100000001","mid":"test-mid"},"expire_in_seconds":"31536000"}}
        """
        let result = try decodeTokenExchange(json)
        #expect(result.token == "v2_fake")
        #expect(result.tokenType == 2)
        #expect(result.uid == "100000001")
        #expect(result.expireInSeconds == 31_536_000)
    }

    @Test
    func decodesTokenExchangeResponseWithNumericFields() throws {
        let json = """
        {"retcode":0,"message":"OK","data":{"token":{"token_type":4,"token":"v2_fake"},
        "user_info":{"aid":100000001},"expire_in_seconds":3600}}
        """
        let result = try decodeTokenExchange(json)
        #expect(result.tokenType == 4)
        #expect(result.uid == "100000001")
        #expect(result.expireInSeconds == 3600)
    }

    @Test
    func surfacesTokenExchangeServiceErrors() {
        let json = #"{"retcode":-100,"message":"登录状态失效","data":null}"#
        #expect(throws: MiHoYoAPIError.self) {
            _ = try decodeTokenExchange(json)
        }
    }

    @Test
    func rejectsTokenExchangeResponseWithoutToken() {
        let json = #"{"retcode":0,"message":"OK","data":{"token":{"token":""}}}"#
        #expect(throws: MiHoYoAPIError.self) {
            _ = try decodeTokenExchange(json)
        }
    }

    @Test
    func decodesGameRoleLevelInEitherForm() throws {
        let json = """
        {"retcode":0,"message":"OK","data":{"list":[
        {"game_biz":"hk4e_cn","game_uid":"100000002","is_chosen":true,"is_official":true,
        "level":60,"nickname":"旅行者","region":"cn_gf01","region_name":"天空岛"},
        {"game_biz":"hkrpg_cn","game_uid":"100000003","is_chosen":false,"is_official":true,
        "level":"70","nickname":"开拓者","region":"prod_gf_cn","region_name":"星穹列车"}
        ]}}
        """
        let data = try #require(json.data(using: .utf8))
        let list = try FetchedAccountDecodeHelper.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "MiyoushePassportTests"
        ).list
        #expect(list.map(\.level) == [60, 70])
        #expect(HoYo.AccountRegion.game(forGameBiz: "hk4e_cn") == .genshinImpact)
        #expect(HoYo.AccountRegion.game(forGameBiz: "hkrpg_cn") == .starRail)
        #expect(HoYo.AccountRegion.game(forGameBiz: "nap_cn") == .zenlessZone)
        #expect(HoYo.AccountRegion.game(forGameBiz: "unknown") == nil)
    }

    // MARK: Private

    private func decodeTokenExchange(_ json: String) throws -> HoYo.PassportTokenExchangeResult {
        let data = try #require(json.data(using: .utf8))
        return try HoYo.PassportTokenExchangeResult.decodeFromMiHoYoAPIJSONResult(
            data: data,
            debugTag: "MiyoushePassportTests"
        )
    }

    private func makeCookie() -> HoYo.MiyousheCookie {
        .init(
            accountIDV2: "100000001",
            cookieTokenV2: "cookie-token",
            ltokenV2: "ltoken-value",
            ltuidV2: "100000001",
            mid: "mid-value",
            stoken: "stoken-value",
            stuid: "100000001"
        )
    }
}
