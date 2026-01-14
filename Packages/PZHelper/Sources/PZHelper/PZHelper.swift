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
    @MainActor
    public struct MainApp: App {
        // MARK: Lifecycle

        public init() {
            self.isEOLNoticeDisplayed = Pizza.isAppStoreReleaseAsPizzaHelper
        }

        // MARK: Public

        public var body: some Scene {
            let windowSize = supposedMinWindowSize
            let windowToReturn = WindowGroup {
                Group {
                    if #available(iOS 17.0, macCatalyst 17.0, *) {
                        ContentView()
                            .trackScreenVMParameters()
                            .sheet(isPresented: $isEOLNoticeDisplayed) {
                                ContentView4iOS14 {
                                    Task.detached { @MainActor in
                                        isEOLNoticeDisplayed = false
                                    }
                                }
                                .interactiveDismissDisabled()
                            }
                    } else {
                        ContentView4iOS14()
                    }
                }
                .navigationTitle(Pizza.appTitleLocalizedFull + appVersionStringOrEmpty)
                .initializeApp()
                // .environment(\.horizontalSizeClass, .compact)
                .defaultAppStorage(.baseSuite)
                // Auto-Correction must be disabled to prevent a memory leak issue on OS24+.
                // Refs: https://kyleye.top/posts/swiftui-textfield-memory-leak/
                .autocorrectionDisabled(true)
                .frame(
                    minWidth: windowSize.w,
                    minHeight: windowSize.h
                )
                .apply { mainContents in
                    if #available(iOS 16.2, macCatalyst 16.2, *) {
                        mainContents
                            .onAppear {
                                startupTasks()
                            }
                            .onAppBecomeActive(debounced: false) {
                                Task {
                                    await ASMetaSputnik.shared.updateMeta()
                                }
                            }
                    } else {
                        mainContents
                    }
                }
            }
            #if os(macOS) && !targetEnvironment(macCatalyst)
            .windowToolbarStyle(.expanded)
            #endif

            if #available(iOS 17.0, macCatalyst 17.0, *) {
                return windowToReturn
                    .windowResizability(.contentMinSize)
            } else {
                return windowToReturn
            }
        }

        // MARK: Private

        @State private var isEOLNoticeDisplayed: Bool

        private var appVersionStringOrEmpty: String {
            Pizza.appVersionStringOrEmpty
        }

        private var supposedMinWindowSize: (w: Double, h: Double) {
            guard OS.type == .macOS else { return (320, 480) }
            if OS.isCatalyst {
                return (OS.liquidGlassThemeSuspected ? 832 : 800, 800)
            } else {
                return (OS.liquidGlassThemeSuspected ? 800 : 768, 646)
            }
        }
    }

    @MainActor static var isApplicationBooted = false
}

@available(iOS 16.2, macCatalyst 16.2, *)
extension PZHelper {
    @MainActor
    static func startupTasks() {
        Task { @MainActor in
            await ProfileManagerVM.shared
                .profileActor?
                .tryAutoInheritOldLocalAccounts(resetNotifications: true)
        }
        PZHelper.setupSpotlightSearch()
        if #available(iOS 17.0, *) {
            GachaRootView.getFAQView = { AnyView(FAQView()) }
            Enka.Sputnik.migrateCachedProfilesFromUserDefaultsToFiles()
        } else {
            // Fallback on earlier versions
        }
        UserWallpaperFileHandler.migrateUserWallpapersFromUserDefaultsToFiles()
    }
}

// MARK: - AppInitializer

@available(iOS 16.2, macCatalyst 16.2, *)
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
            .hookOOBESheet()
            .handleHoYoBackgroundSessions()
            .performEnkaDBSanityCheck()
    }
}

extension View {
    @ViewBuilder
    func initializeApp() -> some View {
        if #available(iOS 16.2, *) {
            modifier(AppInitializer())
        } else {
            self
        }
    }
}
