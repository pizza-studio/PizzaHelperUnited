// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

@available(iOS 16.0, macCatalyst 16.0, *)
struct ContributorItem: View {
    // MARK: Lifecycle

    init(
        isExpanded: Bool = false,
        main: Bool,
        icon: String,
        title: String,
        subtitle: String? = nil,
        retireDate: Date? = nil,
        @ArrayBuilder<Link?> extraLinks: () -> [Link?] = { [] }
    ) {
        self.isExpanded = isExpanded
        self.asMainMember = main
        self.iconName = icon
        self.title = title
        self.subtitle = subtitle ?? ""
        self.retireDate = retireDate
        self.extraLinks = extraLinks().compactMap { $0 }
    }

    init(
        isExpanded: Bool = false,
        main: Bool,
        icon: String,
        titleKey: String.LocalizationValue,
        subtitleKey: String.LocalizationValue? = nil,
        retireDate: Date? = nil,
        @ArrayBuilder<Link?> extraLinks: () -> [Link?] = { [] }
    ) {
        self.isExpanded = isExpanded
        self.asMainMember = main
        self.iconName = icon
        self.title = .init(localized: titleKey, bundle: .currentSPM)
        if let subtitleKey {
            self.subtitle = .init(localized: subtitleKey, bundle: .currentSPM)
        } else {
            self.subtitle = ""
        }
        self.retireDate = retireDate
        self.extraLinks = extraLinks().compactMap { $0 }
    }

    // MARK: Internal

    typealias Link = LinkLabelItem.ItemType

    var body: some View {
        switch asMainMember {
        case false: drawAsSomethingElse()
            .alignmentGuide(.listRowSeparatorLeading) { d in
                d[.leading] + 40
            }
        case true: drawAsMainMember()
        }
    }

    // MARK: Private

    @State private var isExpanded: Bool

    private let asMainMember: Bool
    private let iconName: String
    private let title: String
    private let subtitle: String
    private let retireDate: Date?
    private let extraLinks: [Link]

    private let dateFormatter: DateFormatter = {
        let result = DateFormatter.GregorianPOSIX()
        result.dateFormat = "yyyy-MM-dd"
        result.timeZone = .init(secondsFromGMT: 3600 * 8)
        return result
    }()

    @ViewBuilder
    private func drawAsMainMember() -> some View {
        HStack {
            Image(iconName, bundle: .currentSPM)
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(width: 50, height: 50)
            VStack(alignment: .leading) {
                Group {
                    Text(verbatim: title)
                        .fontWidth(.condensed)
                        .fontWeight(.heavy)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                    if let retireDate {
                        let dateText = dateFormatter.string(from: retireDate)
                        Text("aboutKit.contributor.retiredOn:\(dateText)", bundle: .currentSPM)
                            .font(.caption2)
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                            .fontWidth(.condensed)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                            .saturation(0.5)
                    }
                    if !subtitle.isEmpty {
                        Text(verbatim: subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
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
                        .multilineTextAlignment(.leading)
                    if !subtitle.isEmpty {
                        Text(verbatim: subtitle)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .multilineTextAlignment(.leading)
                    }
                }
            } icon: {
                Image(iconName, bundle: .currentSPM)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        if !extraLinks.isEmpty {
            Menu {
                ForEach(extraLinks) {
                    if OS.type == .macOS {
                        $0.asMenuItem4MacOS
                    } else {
                        $0.asView
                    }
                }
            } label: {
                labelContent
            }
        } else {
            labelContent
        }
    }
}
