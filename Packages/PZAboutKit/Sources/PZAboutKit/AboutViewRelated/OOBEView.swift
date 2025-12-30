// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - OOBEView

@available(iOS 16.0, macCatalyst 16.0, *)
public struct OOBEView: View {
    // MARK: Lifecycle

    public init(completionHandler: (() -> Void)? = nil) {
        self.completionHandler = completionHandler
    }

    // MARK: Public

    public var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Image("icon.product.pzHelper4GI", bundle: .module)
                            .resizable()
                            .frame(width: 70, height: 70, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(verbatim: "+")
                        Image("icon.product.pzHelper4HSR", bundle: .module)
                            .resizable()
                            .frame(width: 70, height: 70, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(verbatim: "=")
                        Image(AboutView.assetName4MainApp, bundle: .module)
                            .resizable()
                            .frame(width: 75, height: 75, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Text(verbatim: Pizza.appTitleLocalizedFull)
                        .font(.title)
                        .bold()
                }
                .padding()
                .padding(.top)
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading, spacing: 15) {
                        NetaBar(
                            icon: Image(
                                systemSymbol: .platter2FilledIphone
                            ),
                            title: Text("oobe.feature.widget.title", bundle: .module),
                            detail: widgetDescription,
                            color: .green
                        )
                        NetaBar(
                            icon: Image(
                                systemSymbol: .bellBadgeCircleFill
                            ),
                            title: "oobe.feature.notification.title",
                            detail: "oobe.feature.notification.detail",
                            color: .orange
                        )
                        NetaBar(
                            icon: Image(
                                systemSymbol: .filemenuAndSelection
                            ),
                            title: "oobe.feature.menuButton.title",
                            detail: "oobe.feature.menuButton.detail",
                            color: .indigo
                        )
                        NetaBar(
                            icon: Image(
                                systemSymbol: .externaldriveFillBadgeTimemachine
                            ),
                            title: "oobe.feature.backupYourData.title",
                            detail: "oobe.feature.backupYourData.detail",
                            color: .red
                        )
                        NetaBar(
                            icon: Image(
                                systemSymbol: .personCropCircleBadgeQuestionmarkFill
                            ),
                            title: "oobe.feature.contactDevs.title",
                            detail: "oobe.feature.contactDevs.detail",
                            color: .blue
                        )
                    }
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                Button {
                    completionHandler?()
                } label: {
                    Text(verbatim: "sys.ok".i18nBaseKit)
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
            .background {
                LinearGradient(
                    colors: [
                        .indigo.opacity(0.5),
                        .clear,
                        .clear,
                        .clear,
                        .clear,
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
            }
        }
    }

    // MARK: Private

    @Environment(\.dismiss) private var dismiss

    private let completionHandler: (() -> Void)?

    private var widgetDescription: Text {
        let urlStr = switch OS.type {
        case .macOS: "https://support.apple.com/108996/"
        default: "https://support.apple.com/118610/"
        }
        let strKey = String(localized: .init(stringLiteral: "oobe.feature.widget.detail:%@"), bundle: .module)
        let str = String(format: strKey, urlStr)
        print(str)
        let attrStr = try? AttributedString(markdown: str)
        if let attrStr {
            return Text(attrStr)
        } else {
            return Text(str)
        }
    }
}

// MARK: OOBEView.NetaBar

@available(iOS 16.0, macCatalyst 16.0, *)
extension OOBEView {
    // MARK: - NetaBar

    private struct NetaBar: View {
        // MARK: Lifecycle

        init(
            icon: Image,
            title: LocalizedStringKey,
            detail: LocalizedStringKey,
            color: Color
        ) {
            self.icon = icon
            self.title = Text(title, bundle: .module)
            self.detail = Text(detail, bundle: .module)
            self.color = color
        }

        init(
            icon: Image,
            title: Text,
            detail: Text,
            color: Color
        ) {
            self.icon = icon
            self.title = title
            self.detail = detail
            self.color = color
        }

        // MARK: Internal

        let icon: Image
        let title: Text
        let detail: Text

        let color: Color

        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(color)
                VStack(alignment: .leading) {
                    mainText
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    let descriptionText =
                        subText
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    descriptionText
                        .foregroundStyle(.primary.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
        }

        // MARK: Private

        private var mainText: Text {
            title
                .fontWeight(.heavy)
        }

        private var subText: Text {
            detail
                .font(.subheadline)
        }
    }
}

extension Defaults.Keys {
    public static let isOOBEViewEverPresented = Key<Bool>(
        "isOOBEViewEverPresented",
        default: false,
        suite: .baseSuite
    )
}

@available(iOS 16.0, macCatalyst 16.0, *)
#Preview {
    OOBEView()
        .environment(\.locale, .init(identifier: "zh-Hans"))
}
