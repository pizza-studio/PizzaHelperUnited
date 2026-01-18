// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

// MARK: - NetaBarHeightsKey

@available(iOS 16.0, macCatalyst 16.0, *)
private struct NetaBarHeightsKey: PreferenceKey {
    static let defaultValue: [UUID: CGFloat] = [:]

    static func reduce(value: inout [UUID: CGFloat], nextValue: () -> [UUID: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

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
                        Image("icon.product.pzHelper4GI", bundle: .currentSPM)
                            .resizable()
                            .frame(width: 70, height: 70, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(verbatim: "+")
                        Image("icon.product.pzHelper4HSR", bundle: .currentSPM)
                            .resizable()
                            .frame(width: 70, height: 70, alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(verbatim: "=")
                        Image(AboutView.assetName4MainApp, bundle: .currentSPM)
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

                netaContentView
                    .frame(maxWidth: .infinity, alignment: .center)
                    .trackCanvasSize { newSize in
                        canvasSize = newSize
                        recalculatePages()
                    }

                bottomButton
                    .padding(.bottom)
            }
            .background {
                // 隐藏的测量层：测量所有 NetaBar 的实际高度
                measurementLayer
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

    private static let netaBarSpacing: CGFloat = 15

    @Environment(\.dismiss) private var dismiss

    @State private var currentPage: Int = 0
    @State private var canvasSize: CGSize = .init(width: 300, height: 400)
    @State private var measuredHeights: [UUID: CGFloat] = [:]
    @State private var pageBreaks: [Int] = [] // indices where each page starts

    private let completionHandler: (() -> Void)?

    private var totalPages: Int {
        max(1, pageBreaks.count)
    }

    private var currentPageItems: [NetaBar] {
        guard !pageBreaks.isEmpty else { return Self.allNetaBars }
        let startIndex = pageBreaks[currentPage]
        let endIndex = currentPage + 1 < pageBreaks.count
            ? pageBreaks[currentPage + 1]
            : Self.allNetaBars.count
        return Array(Self.allNetaBars[startIndex ..< endIndex])
    }

    /// 隐藏的测量层，用于获取每个 NetaBar 的真实高度
    @ViewBuilder private var measurementLayer: some View {
        VStack(alignment: .leading, spacing: Self.netaBarSpacing) {
            ForEach(Self.allNetaBars) { neta in
                neta.asView
                    .background(
                        // 似乎这里暂时只能用 GeometryReader。
                        GeometryReader { geo in
                            Color.clear.preference(
                                key: NetaBarHeightsKey.self,
                                value: [neta.id: geo.size.height]
                            )
                        }
                    )
            }
        }
        .padding(.horizontal)
        .fixedSize(horizontal: false, vertical: true)
        .hidden()
        .onPreferenceChange(NetaBarHeightsKey.self) { heights in
            measuredHeights = heights
            recalculatePages()
        }
    }

    @ViewBuilder private var netaContentView: some View {
        VStack {
            VStack(alignment: .leading, spacing: Self.netaBarSpacing) {
                ForEach(currentPageItems) { neta in
                    neta.asView
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            // 頁面指示器
            if totalPages > 1 {
                HStack(spacing: 8) {
                    ForEach(0 ..< totalPages, id: \.self) { pageIndex in
                        Circle()
                            .fill(pageIndex == currentPage ? Color.primary : Color.primary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }

    @ViewBuilder private var bottomButton: some View {
        let isLastPage = currentPage >= totalPages - 1

        HStack {
            // Back (上一步) — only visible when we can go back
            if currentPage > 0 {
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentPage = max(0, currentPage - 1)
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("sys.back".i18nBaseKit)
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.bordered)
            } else {
                // keep layout stable on single-page cases
                Spacer().frame(width: 8)
            }

            // Next / OK
            if isLastPage {
                Button {
                    completionHandler?()
                } label: {
                    Text(verbatim: "sys.ok".i18nBaseKit)
                        .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    withAnimation(.spring) {
                        currentPage += 1
                    }
                } label: {
                    HStack {
                        Text("oobe.button.next", bundle: .currentSPM)
                        Image(systemName: "chevron.right")
                    }
                    .padding(.horizontal)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(height: 44)
    }

    /// 根据测量高度和画布大小重新计算分页
    private func recalculatePages() {
        guard !measuredHeights.isEmpty else { return }

        let availableHeight = canvasSize.height - 30 // 留出页面指示器空间
        var breaks = [0]
        var accumulatedHeight: CGFloat = 0

        for (index, neta) in Self.allNetaBars.enumerated() {
            let itemHeight = measuredHeights[neta.id] ?? 80
            let heightWithSpacing = index == breaks.last ? itemHeight : itemHeight + Self.netaBarSpacing

            if accumulatedHeight + heightWithSpacing > availableHeight, index > breaks.last! {
                breaks.append(index)
                accumulatedHeight = itemHeight
            } else {
                accumulatedHeight += heightWithSpacing
            }
        }

        pageBreaks = breaks

        // 确保当前页不越界
        if currentPage >= totalPages {
            currentPage = max(0, totalPages - 1)
        }
    }
}

// MARK: OOBEView.NetaBar

@available(iOS 16.0, macCatalyst 16.0, *)
extension OOBEView {
    private struct NetaBar: Sendable, Identifiable {
        // MARK: Lifecycle

        init(
            icon: Image,
            title: LocalizedStringKey,
            detail: LocalizedStringKey,
            color: Color
        ) {
            self.icon = icon
            self.title = Text(title, bundle: .currentSPM)
            self.detail = Text(detail, bundle: .currentSPM)
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

        let id: UUID = .init()
        let icon: Image
        let title: Text
        let detail: Text
        let color: Color

        @MainActor var asView: NetaBarView {
            NetaBarView(neta: self)
        }
    }
}

// MARK: OOBEView.NetaBarView

@available(iOS 16.0, macCatalyst 16.0, *)
extension OOBEView {
    // MARK: - NetaBarView

    private struct NetaBarView: View {
        // MARK: Lifecycle

        init(neta: NetaBar) {
            self.netaBar = neta
        }

        init(
            icon: Image,
            title: LocalizedStringKey,
            detail: LocalizedStringKey,
            color: Color
        ) {
            self.netaBar = .init(icon: icon, title: title, detail: detail, color: color)
        }

        init(
            icon: Image,
            title: Text,
            detail: Text,
            color: Color
        ) {
            self.netaBar = .init(icon: icon, title: title, detail: detail, color: color)
        }

        // MARK: Internal

        let netaBar: NetaBar

        var body: some View {
            HStack(alignment: .top, spacing: 15) {
                netaBar.icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .foregroundColor(netaBar.color)
                VStack(alignment: .leading) {
                    mainText
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    let descriptionText =
                        subText
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
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
            netaBar.title
                .fontWeight(.heavy)
        }

        private var subText: Text {
            netaBar.detail
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

@available(iOS 16.0, macCatalyst 16.0, *)
extension OOBEView {
    private static var allNetaBars: [OOBEView.NetaBar] {
        var result: [OOBEView.NetaBar] = [
            NetaBar(
                icon: Image(
                    systemSymbol: .platter2FilledIphone
                ),
                title: Text("oobe.feature.widget.title", bundle: .currentSPM),
                detail: widgetDescription,
                color: .green
            ),
            NetaBar(
                icon: Image(
                    systemSymbol: .bellBadgeCircleFill
                ),
                title: "oobe.feature.notification.title",
                detail: "oobe.feature.notification.detail",
                color: .orange
            ),
            NetaBar(
                icon: Image(
                    systemSymbol: .filemenuAndSelection
                ),
                title: "oobe.feature.menuButton.title",
                detail: "oobe.feature.menuButton.detail",
                color: .indigo
            ),
            NetaBar(
                icon: Image(
                    systemSymbol: .externaldriveFillBadgeTimemachine
                ),
                title: "oobe.feature.backupYourData.title",
                detail: "oobe.feature.backupYourData.detail",
                color: .red
            ),
            NetaBar(
                icon: Image(
                    systemSymbol: .personCropCircleBadgeQuestionmarkFill
                ),
                title: "oobe.feature.contactDevs.title",
                detail: "oobe.feature.contactDevs.detail",
                color: .blue
            ),
        ]
        if Pizza.isDebug || Pizza.isAppStoreReleaseAsLatteHelper {
            result.append(
                NetaBar(
                    icon: Image(
                        systemSymbol: .suitcaseCartFill
                    ),
                    title: "oobe.feature.refugeeFromThePizzaHelper.title",
                    detail: "oobe.feature.refugeeFromThePizzaHelper.detail",
                    color: .brown
                )
            )
        }
        return result
    }

    private static var widgetDescription: Text {
        let urlStr = switch OS.type {
        case .macOS: "https://support.apple.com/108996/"
        default: "https://support.apple.com/118610/"
        }
        let strKey = String(localized: .init(stringLiteral: "oobe.feature.widget.detail:%@"), bundle: .currentSPM)
        let str = String(format: strKey, urlStr)
        let attrStr = try? AttributedString(markdown: str)
        if let attrStr {
            return Text(attrStr)
        } else {
            return Text(str)
        }
    }
}
