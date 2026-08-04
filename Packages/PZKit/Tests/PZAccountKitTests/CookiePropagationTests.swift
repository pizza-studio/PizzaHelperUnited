// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
@testable import PZAccountKit
import PZBaseKit
import SwiftData
import Testing

/// 这些测试会通过 PZProfileActor 读写全局 UserDefaults（影子表与 pzProfiles），
/// 且每个 actor 的 init Task 也会异步读写同一份资料，
/// 因此必须放在 serialized suite 内互斥执行，并在每个测试开头静待 init Task 落定后重置共享状态。
@Suite(.serialized)
struct PZProfileActorTests {
    // MARK: Internal

    @Test
    func cookieUpdatePropagationChain() async throws {
        guard #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) else { return }
        let actor = await makeActor()

        // 观察 ModelContext.didSave，记录每次解析出的实体名。
        final class Recorder: @unchecked Sendable {
            var parsedEntityNames: [Set<String>] = []
        }
        let recorder = Recorder()
        var observer: (any NSObjectProtocol)?
        if #available(iOS 18.0, macCatalyst 18.0, macOS 15.0, watchOS 11.0, *) {
            observer = NotificationCenter.default.addObserver(
                forName: ModelContext.didSave,
                object: nil,
                queue: nil
            ) { notification in
                let names = PersistentIdentifier.parseObjectNames(
                    notificationResult: notification.userInfo
                )
                recorder.parsedEntityNames.append(names)
            }
        }
        defer {
            if let observer { NotificationCenter.default.removeObserver(observer) }
        }

        var profile = PZProfileSendable.getDummyInstance(for: .genshinImpact)
        profile.cookie = "OLD_COOKIE"
        try await actor.addOrUpdateProfile(profile)

        profile.cookie = "NEW_COOKIE"
        try await actor.addOrUpdateProfile(profile)

        // 验证 1：didSave 通知有触发，且能解析出 PZProfileMO。
        if #available(iOS 18.0, macCatalyst 18.0, macOS 15.0, watchOS 11.0, *) {
            #expect(!recorder.parsedEntityNames.isEmpty)
            #expect(recorder.parsedEntityNames.contains { $0.contains("PZProfileMO") })
        }

        // 验证 2：保存后立即重新 fetch，拿到的 cookie 必须是新的。
        let fetched = await actor.getSendableProfiles()
        let matched = fetched.first { $0.uuid == profile.uuid }
        #expect(matched?.cookie == "NEW_COOKIE")
    }

    /// 过期资料（例如 CloudKit 回滚）应被仲裁机制以 UserDefaults 副本写回。
    @Test
    func staleOverwriteArbitration() async throws {
        guard #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) else { return }
        let actor = await makeActor()
        defer {
            Defaults[.pzProfiles] = [:]
            Defaults[.pzProfilesLastLocalEditTimestamps] = [:]
        }

        // 1. 本地修改：写入新 cookie（会盖章），并同步 UserDefaults 副本。
        var profile = PZProfileSendable.getDummyInstance(for: .genshinImpact)
        profile.cookie = "NEW_COOKIE"
        try await actor.addOrUpdateProfile(profile)
        Defaults[.pzProfiles] = [profile.uuid.uuidString: profile]
        let stampedTS = Defaults[.pzProfilesLastLocalEditTimestamps][profile.uuid.uuidString]
        #expect(stampedTS != nil && (stampedTS ?? 0) > 0)

        // 2. 模拟 CloudKit 回滚：旧 cookie + 旧时间戳，绕过盖章路径。
        var stale = profile
        stale.cookie = "OLD_COOKIE"
        try await actor.debugSimulateStaleOverwrite(stale, timestamp: 1)
        let fetchedStale = await actor.getSendableProfiles().first { $0.uuid == profile.uuid }
        #expect(fetchedStale?.cookie == "OLD_COOKIE")

        // 3. 仲裁：应以 UserDefaults 副本写回新 cookie。
        await actor.arbitrateProfilesAgainstUserDefaults()
        let fetchedRestored = await actor.getSendableProfiles().first { $0.uuid == profile.uuid }
        #expect(fetchedRestored?.cookie == "NEW_COOKIE")

        // 4. 再次仲裁应收敛（幂等，不会反复写回）。
        await actor.arbitrateProfilesAgainstUserDefaults()
        let fetchedAgain = await actor.getSendableProfiles().first { $0.uuid == profile.uuid }
        #expect(fetchedAgain?.cookie == "NEW_COOKIE")
    }

    /// 他端装置的合法修改（时间戳较新）应被接受，且影子表跟进。
    @Test
    func newerRemoteEditAccepted() async throws {
        guard #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) else { return }
        let actor = await makeActor()
        defer {
            Defaults[.pzProfiles] = [:]
            Defaults[.pzProfilesLastLocalEditTimestamps] = [:]
        }

        // 1. 本地先有旧 cookie 的资料。
        var profile = PZProfileSendable.getDummyInstance(for: .genshinImpact)
        profile.cookie = "OLD_COOKIE"
        try await actor.addOrUpdateProfile(profile)
        Defaults[.pzProfiles] = [profile.uuid.uuidString: profile]

        // 2. 模拟他端装置较新的修改进入本地库（时间戳更大）。
        var remote = profile
        remote.cookie = "REMOTE_NEW_COOKIE"
        let futureTS = Int64(Date().timeIntervalSince1970) + 1000
        try await actor.debugSimulateStaleOverwrite(remote, timestamp: futureTS)

        // 3. 仲裁：资料应保留远端新值，影子表跟进该时间戳。
        await actor.arbitrateProfilesAgainstUserDefaults()
        let fetched = await actor.getSendableProfiles().first { $0.uuid == profile.uuid }
        #expect(fetched?.cookie == "REMOTE_NEW_COOKIE")
        #expect(Defaults[.pzProfilesLastLocalEditTimestamps][profile.uuid.uuidString] == futureTS)
    }

    // MARK: Private

    /// 静待 actor 的 init Task 落定，再重置共享的 UserDefaults 状态。
    @available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
    private func makeActor() async -> PZProfileActor {
        let actor = PZProfileActor(unitTests: true)
        try? await Task.sleep(nanoseconds: 500_000_000)
        Defaults[.pzProfiles] = [:]
        Defaults[.pzProfilesLastLocalEditTimestamps] = [:]
        return actor
    }
}
