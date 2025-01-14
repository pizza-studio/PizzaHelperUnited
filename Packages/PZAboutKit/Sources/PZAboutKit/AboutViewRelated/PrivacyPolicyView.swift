// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SwiftUI

// MARK: - PrivacyPolicyView

public struct PrivacyPolicyView: View {
    // MARK: Lifecycle

    public init(isOOBE: Bool = false) {
        self.isOOBE = isOOBE
    }

    // MARK: Public

    public static let navTitle: String = {
        let key: String.LocalizationValue = "aboutKit.PrivacyPolicy.title"
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
                                        Defaults[.isPrivacyPolicyConfirmed] = true
                                        UserDefaults.baseSuite.synchronize()
                                        presentationMode.wrappedValue.dismiss()
                                    }
                                }
                            }
                    }
                }
        }
    }

    // MARK: Private

    private static let urlString: String = {
        let fileURL = Bundle.module.url(forResource: "PRIVACY_POLICY", withExtension: "html")
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

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    private let isOOBE: Bool
}

extension Defaults.Keys {
    public static let isPrivacyPolicyConfirmed = Key<Bool>(
        "isPrivacyPolicyConfirmed",
        default: false,
        suite: .baseSuite
    )
}
