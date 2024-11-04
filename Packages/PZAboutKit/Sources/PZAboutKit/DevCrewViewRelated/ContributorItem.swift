// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SFSafeSymbols
import SwiftUI

struct ContributorItem: View {
    // MARK: Lifecycle

    init(
        isExpanded: Bool = false,
        main: Bool,
        icon: String,
        title: String,
        subtitle: String? = nil,
        @ArrayBuilder<Link?> extraLinks: () -> [Link?] = { [] }
    ) {
        self.isExpanded = isExpanded
        self.asMainMember = main
        self.iconName = icon
        self.title = title
        self.subtitle = subtitle ?? ""
        self.extraLinks = extraLinks().compactMap { $0 }
    }

    init(
        isExpanded: Bool = false,
        main: Bool,
        icon: String,
        titleKey: String.LocalizationValue,
        subtitleKey: String.LocalizationValue? = nil,
        @ArrayBuilder<Link?> extraLinks: () -> [Link?] = { [] }
    ) {
        self.isExpanded = isExpanded
        self.asMainMember = main
        self.iconName = icon
        self.title = .init(localized: titleKey)
        if let subtitleKey {
            self.subtitle = .init(localized: subtitleKey)
        } else {
            self.subtitle = ""
        }
        self.extraLinks = extraLinks().compactMap { $0 }
    }

    // MARK: Internal

    typealias Link = LinkLabelItem.ItemType

    var body: some View {
        switch asMainMember {
        case false: drawAsSomethingElse()
        case true: drawAsMainMember()
        }
    }

    // MARK: Private

    private let asMainMember: Bool
    private let iconName: String
    private let title: String
    private let subtitle: String
    private let extraLinks: [Link]
    @State private var isExpanded: Bool

    @ViewBuilder
    private func drawAsMainMember() -> some View {
        HStack {
            Image(iconName, bundle: .module).resizable().clipShape(Circle())
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Group {
                    Text(verbatim: title).fontWidth(.condensed).fontWeight(.heavy)
                    if !subtitle.isEmpty {
                        Text(verbatim: subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 5)
            Spacer()
            if !extraLinks.isEmpty {
                Image(systemSymbol: .chevronRight)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            simpleTaptic(type: .light)
            withAnimation { isExpanded.toggle() }
        }
        if isExpanded, !extraLinks.isEmpty {
            ForEach(extraLinks) { $0.asView }
        }
    }

    @ViewBuilder
    private func drawAsSomethingElse() -> some View {
        let labelContent = Group {
            Label {
                VStack(alignment: .leading) {
                    Text(verbatim: title)
                        .fontWidth(.condensed).fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if !subtitle.isEmpty {
                        Text(verbatim: subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            } icon: {
                Image(iconName, bundle: .module)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
            }
        }
        if !extraLinks.isEmpty {
            Menu {
                ForEach(extraLinks) { $0.asView }
            } label: {
                labelContent
            }
        } else {
            labelContent
        }
    }
}
