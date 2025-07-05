// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SwiftUI

// MARK: - FAQView

@available(iOS 16.0, macCatalyst 16.0, macOS 13.0, *)
public struct FAQView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = {
        let key: String.LocalizationValue = "aboutKit.FAQ.title"
        return .init(localized: key, bundle: .module)
    }()

    public var body: some View {
        NavigationStack {
            WebBrowserView(url: Self.urlString)
                .navigationTitle(Self.navTitle)
                .navBarTitleDisplayMode(.inline)
        }
    }

    // MARK: Private

    private static let urlString: String = {
        Bundle.module.url(forResource: "FAQ", withExtension: "html")!.absoluteString
    }()

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
}
