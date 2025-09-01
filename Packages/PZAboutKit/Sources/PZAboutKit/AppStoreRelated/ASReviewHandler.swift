// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import StoreKit
import SwiftUI
#if os(macOS) && !targetEnvironment(macCatalyst)
import AppKit
#endif

extension Defaults.Keys {
    public static let lastVersionPromptedForReviewKey = Key<String?>(
        "lastVersionPromptedForReviewKey",
        default: nil,
        suite: .baseSuite
    )
}

// MARK: - ASReviewHandler

@available(iOS 16.0, macCatalyst 16.0, *)
public enum ASReviewHandler {
    public static let navTitle = "aboutKit.appStoreReview.navTitle".i18nAboutKit
    public static let asURLString = "https://apps.apple.com/app/id1635319193"

    public static func requestReview() {
        guard Pizza.isAppStoreRelease else { return }
        #if DEBUG
        defer {
            Defaults.reset(.lastVersionPromptedForReviewKey)
        }
        #endif
        Task.detached { @MainActor in
            // Keep track of the most recent app version that prompts the user for a review.
            let lastVersionPromptedForReview = Defaults[.lastVersionPromptedForReviewKey]

            // Get the current bundle version for the app.
            let infoDictionaryKey = kCFBundleVersionKey as String
            guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String
            else { fatalError("Expected to find a bundle version in the info dictionary.") }
            // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
            if currentVersion != lastVersionPromptedForReview {
                #if os(macOS) && !targetEnvironment(macCatalyst)
                guard let viewCtl = NSApplication.shared.keyWindow?.contentViewController else { return }
                AppStore.requestReview(in: viewCtl)
                Defaults[.lastVersionPromptedForReviewKey] = currentVersion
                #elseif os(iOS) || targetEnvironment(macCatalyst)
                if let windowScene = UIApplication.shared.connectedScenes
                    .first(where: { $0.activationState == .foregroundActive
                    }) as? UIWindowScene {
                    AppStore.requestReview(in: windowScene)
                    Defaults[.lastVersionPromptedForReviewKey] = currentVersion
                }
                #endif
            }
        }
    }

    public static func requestReviewIfNotRequestedElseNavigateToAppStore() {
        guard Pizza.isAppStoreRelease else { return }
        let lastVersionPromptedForReview = Defaults[.lastVersionPromptedForReviewKey]
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main
            .object(forInfoDictionaryKey: infoDictionaryKey) as? String
        else { fatalError("Expected to find a bundle version in the info dictionary.") }
        // Verify the user completes the process several times and doesn’t receive a prompt for this app version.
        if currentVersion != lastVersionPromptedForReview {
            ASReviewHandler.requestReview()
        } else {
            guard let writeReviewURL = URL(string: "\(asURLString)?action=write-review") else {
                fatalError("Expected a valid URL")
            }
            Task { @MainActor in
                #if os(iOS) || targetEnvironment(macCatalyst)
                UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                #elseif os(macOS)
                NSWorkspace.shared.open(writeReviewURL)
                #endif
            }
        }
    }

    @ViewBuilder
    public static func makeRatingButton() -> some View {
        Button {
            ASReviewHandler.requestReviewIfNotRequestedElseNavigateToAppStore()
        } label: {
            Label(Self.navTitle, systemSymbol: .arrowUpForwardApp)
        }
    }
}
