// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAboutKit
import PZAccountKit
import SwiftData
import SwiftUI

// MARK: - PZHelper

public enum PZHelper {}

extension PZHelper {
    @MainActor @SceneBuilder
    public static func makeMainScene() -> some Scene {
        WindowGroup {
            ContentView()
                .initializeApp()
                .environment(\.horizontalSizeClass, .compact)
                .defaultAppStorage(.baseSuite)
            #if targetEnvironment(macCatalyst)
                .frame(minWidth: 600, minHeight: 800)
            #endif
                .onAppear {
                    if !isApplicationBooted {
                        startupTasks()
                    }
                    isApplicationBooted = true
                }
        }
        .windowResizability(.contentMinSize)
        .modelContainer(PZProfileActor.shared.modelContainer)
    }

    @MainActor
    public static func preInitializeTheSharedProfileActor() {
        // 这个步骤只有一个目的：让 PZProfileActor.shared 立即初期化。
        // 原因：Swift 的所有 static property 全都是 lazy-load。
        let context = PZProfileActor.shared.modelExecutor.modelContext
        _ = try? context.fetchCount(
            FetchDescriptor<PZProfileMO>()
        )
        // 下述步骤理论上会立刻触发 iCloud 同步。
        let fakeProfileMO = PZProfileMO()
        context.insert(fakeProfileMO)
        try? context.save()
        context.delete(fakeProfileMO)
        try? context.save()
    }

    @MainActor public private(set) static var isApplicationBooted = false
}

extension PZHelper {
    @MainActor
    private static func startupTasks() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
        Task {
            await PZProfileActor.shared.syncAllDataToUserDefaults()
        }
        PZHelper.setupSpotlightSearch()
    }
}

// MARK: - AppInitializer

private struct AppInitializer: ViewModifier {
    func body(content: Content) -> some View {
        content
            .syncProfilesToUserDefaults()
            .cleanApplicationIconBadgeNumber()
            .checkAndReloadWidgetTimeline()
            .hookEULACheckerOnOOBE()
            .hookPrivacyPolicyCheckerOnOOBE()
            .performEnkaDBSanityCheck()
    }
}

extension View {
    func initializeApp() -> some View {
        modifier(AppInitializer())
    }
}
