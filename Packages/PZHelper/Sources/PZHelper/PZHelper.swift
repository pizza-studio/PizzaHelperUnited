// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaKit
import GachaKit
import PZAboutKit
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI
import WallpaperKit

// MARK: - PZHelper

public enum PZHelper {}

extension PZHelper {
    @MainActor @SceneBuilder
    public static func makeMainScene(modelContainer: ModelContainer) -> some Scene {
        WindowGroup {
            ContentView()
                .initializeApp()
                // .environment(\.horizontalSizeClass, .compact)
                .defaultAppStorage(.baseSuite)
            #if targetEnvironment(macCatalyst)
                .frame(
                    minWidth: OS.liquidGlassThemeSuspected ? 832 : 800,
                    minHeight: 800
                )
            #elseif os(macOS) && !targetEnvironment(macCatalyst)
                .frame(
                    minWidth: OS.liquidGlassThemeSuspected ? 800 : 768,
                    minHeight: 646
                )
            #endif
                .onAppear {
                    if !isApplicationBooted {
                        startupTasks()
                    }
                    isApplicationBooted = true
                }
                .onAppBecomeActive {
                    Task {
                        await ASMetaSputnik.shared.updateMeta()
                    }
                }
                .trackScreenVMParameters()
        }
        #if os(macOS) && !targetEnvironment(macCatalyst)
        .windowToolbarStyle(.expanded)
        #endif
        .windowResizability(.contentMinSize)
        .modelContainer(modelContainer)
    }

    public static func getSharedModelContainer() -> ModelContainer {
        PZProfileActor.shared.modelContainer
    }

    @MainActor static var isApplicationBooted = false
}

extension PZHelper {
    @MainActor
    static func startupTasks() {
        PZProfileActor.attemptToAutoInheritOldAccountsIntoProfiles(resetNotifications: true)
        Task {
            await PZProfileActor.shared.syncAllDataToUserDefaults()
        }
        PZHelper.setupSpotlightSearch()
        GachaRootView.getFAQView = { AnyView(FAQView()) }
        Enka.Sputnik.migrateCachedProfilesFromUserDefaultsToFiles()
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
    }
}

// MARK: - AppInitializer

private struct AppInitializer: ViewModifier {
    // MARK: Lifecycle

    init() {
        if !PZHelper.isApplicationBooted {
            PZHelper.startupTasks()
        }
        PZHelper.isApplicationBooted = true
    }

    // MARK: Internal

    func body(content: Content) -> some View {
        content
            .syncProfilesToUserDefaults()
            .cleanApplicationIconBadgeNumber()
            .checkAndReloadWidgetTimeline()
            .hookEULACheckerOnOOBE()
            .hookPrivacyPolicyCheckerOnOOBE()
            .performEnkaDBSanityCheck()
            .handleHoYoBackgroundSessions()
    }
}

extension View {
    @ViewBuilder
    func initializeApp() -> some View {
        modifier(AppInitializer())
    }
}
