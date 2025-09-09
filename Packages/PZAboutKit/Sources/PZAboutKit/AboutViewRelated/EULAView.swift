// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZBaseKit
import SwiftUI

// MARK: - EULAView

@available(iOS 16.0, macCatalyst 16.0, *)
public struct EULAView: View {
    // MARK: Lifecycle

    public init(isVisible: Binding<Bool>? = nil) {
        if let isVisibleGuarded = isVisible {
            self.isOOBE = true
            self._isVisible = isVisibleGuarded
        } else {
            self.isOOBE = false
            self._isVisible = .init(get: { true }, set: { _ in })
        }
    }

    // MARK: Public

    public static let navTitle: String = {
        let key: String.LocalizationValue = "aboutKit.eula.title"
        return .init(localized: key, bundle: .module)
    }()

    public var body: some View {
        NavigationStack {
            WebBrowserView(url: Self.urlString)
                .navigationTitle(Self.navTitle)
                .navBarTitleDisplayMode(.inline)
                .apply { content in
                    if !isOOBE {
                        content
                    } else {
                        content
                            .navigationBarBackButtonHidden()
                            .toolbar {
                                ToolbarItem(placement: .cancellationAction) {
                                    Button("sys.decline".i18nBaseKit) {
                                        exit(1)
                                    }
                                }
                                ToolbarItem(placement: .confirmationAction) {
                                    Button("sys.agree".i18nBaseKit) {
                                        isVisible.toggle()
                                    }
                                }
                            }
                    }
                }
        }
    }

    // MARK: Private

    private static let urlString: String = {
        let fileURL = Bundle.module.url(forResource: "EULA", withExtension: "html")
        let url: String = {
            switch Locale.preferredLanguages.first?.prefix(2) {
            case "zh":
                return "https://hsr.pizzastudio.org/static/policy"
            case "ja":
                return "https://hsr.pizzastudio.org/static/policy_ja"
            default:
                return "https://hsr.pizzastudio.org/static/policy_en"
            }
        }()
        return fileURL?.absoluteString ?? url
    }()

    @Binding private var isVisible: Bool

    private let isOOBE: Bool
}

extension Defaults.Keys {
    public static let isEULAConfirmed = Key<Bool>("isEULAConfirmed", default: false, suite: .baseSuite)
}
