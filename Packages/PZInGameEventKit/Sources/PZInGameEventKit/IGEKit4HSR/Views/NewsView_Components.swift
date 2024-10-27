// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import SwiftUI

// MARK: - NewsKitHSR.NewsElementView

extension NewsKitHSR {
    public struct NewsElementView: View {
        // MARK: Lifecycle

        public init(_ givenData: some NewsElement) {
            self.data = givenData
        }

        // MARK: Public

        public let data: any NewsElement

        @MainActor public var body: some View {
            coreBody
                .fontWidth(.condensed)
        }

        @ViewBuilder public var coreBody: some View {
            Section {
                Text(verbatim: data.title).bold()
                Text(verbatim: data.description)
                    .font(.footnote)
                    .foregroundStyle(.primary.opacity(0.8))
            } footer: {
                HStack {
                    if let event = data as? NewsKitHSR.EventElement {
                        Text(verbatim: event.dateStartedStr)
                        Spacer()
                        Text(verbatim: "→")
                        Spacer()
                        Text(verbatim: event.dateEndedStr)
                    } else {
                        Text(verbatim: data.dateCreatedStr)
                        Spacer()
                    }
                }.frame(maxWidth: .infinity)
            }
            .compositingGroup()
        }
    }
}

// MARK: - View + View

#if hasFeature(RetroactiveAttribute)
@available(watchOS, unavailable)
extension [any NewsElement]: @retroactive View {}
#else
@available(watchOS, unavailable)
extension [any NewsElement]: View {}
#endif

extension [any NewsElement] {
    @available(watchOS, unavailable)
    @MainActor @ViewBuilder public var body: some View {
        Form {
            ForEach(self, id: \.id) { newsElement in
                NewsKitHSR.NewsElementView(newsElement)
                    .listRowMaterialBackground()
            }
        }
        .scrollContentBackground(.hidden)
        #if !os(watchOS)
            .listContainerBackground()
        #endif
    }
}
