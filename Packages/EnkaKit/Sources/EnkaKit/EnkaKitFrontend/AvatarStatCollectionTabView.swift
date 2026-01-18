// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - AvatarStatCollectionTabView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct AvatarStatCollectionTabView: View {
    // MARK: Lifecycle

    public init(
        selectedAvatarID: Binding<String>,
        summarizedAvatars: [Enka.AvatarSummarized],
        onClose: (() -> Void)? = nil
    ) {
        self._showingCharacterIdentifier = selectedAvatarID
        self.onClose = onClose
        self.isEnka = summarizedAvatars.first?.isEnka ?? true
        if isEnka {
            self.summarizedAvatars = summarizedAvatars
        } else {
            self.summarizedAvatars = summarizedAvatars.sorted {
                $0.mainInfo.element.tourID < $1.mainInfo.element.tourID
            }
        }
        self.allIDs = summarizedAvatars.map(\.id)
        var sortedCharIDMapNew = [Enka.GameElement: [CharNameID]]()
        self.summarizedAvatars.forEach {
            sortedCharIDMapNew[$0.mainInfo.element, default: []].append(
                .init(id: $0.mainInfo.uniqueCharId, name: $0.mainInfo.name)
            )
        }
        self.sortedCharIDMap = sortedCharIDMapNew
    }

    // MARK: Public

    public var body: some View {
        Group {
            if isMainBodyVisible {
                coreBody()
                    .overlay(alignment: .top) {
                        if !OS.isAppKit {
                            // AppKit 的 TabView 不支持走马灯滚动操作。
                            HelpTextForScrollingOnDesktopComputer(.horizontal).padding()
                        } else {
                            Text("enka.ASCV.scrollingGuide.appKit", bundle: .currentSPM)
                                .font(.caption2)
                                .fontWidth(.condensed)
                                .opacity(0.7)
                                .padding()
                        }
                    }
            }
        }
        .environment(\.colorScheme, .dark)
        .navBarTitleDisplayMode(.inline)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .toolbar(isMainBodyVisible ? .hidden : .automatic, for: .navigationBar)
            .appTabBarVisibility(isMainBodyVisible ? .hidden : .automatic)
        #endif
            .toolbar(isMainBodyVisible ? .hidden : .automatic)
    }

    @ViewBuilder
    public func coreBody() -> some View {
        TabView(selection: $showingCharacterIdentifier) {
            // TabView 以 EnkaID 为依据。
            ForEach(summarizedAvatars) { avatar in
                framedCoreView(avatar)
            }
        }
        #if os(iOS) || targetEnvironment(macCatalyst)
        .tabViewStyle(
            .page(indexDisplayMode: showTabViewIndex ? .automatic : .never)
        )
        #endif
        .contextMenu { contextMenuContents }
        .onTapGesture {
            if let onClose {
                onClose()
            } else {
                simpleTaptic(type: .medium)
                presentationMode.wrappedValue.dismiss()
            }
        }
        .react(to: showingCharacterIdentifier, initial: true) {
            simpleTaptic(type: .selection)
            withAnimation(.easeIn(duration: 0.1)) {
                showTabViewIndex = true
                Task {
                    try await Task.sleep(nanoseconds: 1_700_000_000) // Sleep 1.7s
                    withAnimation {
                        showTabViewIndex = false
                    }
                }
            }
        }
        .onAppear {
            showTabViewIndex = true
        }
        .background {
            // 为了兼容 iOS 26 / macOS 26，必须得把背景挪到这个层面来处理。
            ZStack {
                Color(hue: 0, saturation: 0, brightness: 0.1)
                avatar?.asBackground(useNameCardBG: useNameCardBackgrounds)
                    .scaledToFill()
                    .scaleEffect(1.2)
                    .clipped()
                    .frame(width: screenVM.windowSizeObserved.width)
                    .animation(.easeIn(duration: 0.2), value: screenVM.mainColumnCanvasSizeObserved)
            }
            .drawingGroup()
            .ignoresSafeArea(.all, edges: .all)
            .animation(.default, value: showingCharacterIdentifier)
        }
        #if os(iOS) || targetEnvironment(macCatalyst)
        .statusBarHidden(true)
        #endif
    }

    // MARK: Internal

    @ViewBuilder var contextMenuContents: some View {
        if let avatar = avatar {
            Group {
                Button {
                    Clipboard.currentString = avatar.asText
                } label: {
                    Text("enka.ASCV.summarzeToClipboard.asText", bundle: .currentSPM)
                }
                Button {
                    Clipboard.currentString = avatar.asMarkDown
                } label: {
                    Text("enka.ASCV.summarzeToClipboard.asMD", bundle: .currentSPM)
                }
                Divider()
                if isEnka {
                    ForEach(summarizedAvatars) { theAvatar in
                        Button(theAvatar.mainInfo.name) {
                            withAnimation(.easeIn(duration: 0.1)) {
                                showingCharacterIdentifier = theAvatar.mainInfo.uniqueCharId
                            }
                        }
                    }
                } else {
                    let allElements = Enka.GameElement.allCases.sorted { $0.tourID < $1.tourID }
                    ForEach(allElements, id: \.tourID) { currentElement in
                        if let avatarsOfThisElement = sortedCharIDMap[currentElement] {
                            Menu {
                                ForEach(avatarsOfThisElement) { charNameID in
                                    Button(charNameID.name) {
                                        withAnimation(.easeIn(duration: 0.1)) {
                                            showingCharacterIdentifier = charNameID.id
                                        }
                                    }
                                }
                            } label: {
                                Text(verbatim: currentElement.localizedName)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func framedCoreView(_ avatar: Enka.AvatarSummarized) -> some View {
        /// Width is locked inside the EachAvatarStatView.
        EachAvatarStatView(data: avatar, background: false)
            .fixedSize()
            .scaleEffect(scaleRatioCompatible)
            .animation(.easeIn(duration: 0.2), value: screenVM.mainColumnCanvasSizeObserved)
            .padding(.top, OS.isAppKit ? 0 : 10)
            .padding(.bottom, OS.isAppKit ? 0 : bottomSpacerHeight)
            .contentShape(.rect)
    }

    // MARK: Private

    private struct CharNameID: Identifiable, Sendable {
        let id: String
        let name: String
    }

    @State private var showTabViewIndex = false
    @Binding private var showingCharacterIdentifier: String
    @State private var screenVM: ScreenVM = .shared
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @Default(.useNameCardBGWithGICharacters) private var useNameCardBGWithGICharacters: Bool

    private let isEnka: Bool
    private let summarizedAvatars: [Enka.AvatarSummarized]
    private let allIDs: [String]
    private let onClose: (() -> Void)?
    private let bottomSpacerHeight: CGFloat = 20
    private let sortedCharIDMap: [Enka.GameElement: [CharNameID]]

    private var avatar: Enka.AvatarSummarized? {
        summarizedAvatars.first(where: { avatar in
            avatar.mainInfo.uniqueCharId == showingCharacterIdentifier
        })
    }

    private var scaleRatioCompatible: CGFloat {
        let canvasSize = screenVM.mainColumnCanvasSizeObserved
        guard canvasSize.width > 0, canvasSize.height > 0 else {
            return 1.0 // 防止除零或无效输入
        }
        let basicMemberSize: CGSize = basicContentUnitSize4ASCV
        let widthRatio = canvasSize.width / basicMemberSize.width
        let heightRatio = canvasSize.height / basicMemberSize.height
        var result = widthRatio
        let zoomedSize = CGSize(
            width: basicMemberSize.width * result,
            height: basicMemberSize.height * result
        )
        let compatible = CGRect(origin: .zero, size: canvasSize)
            .contains(CGRect(origin: .zero, size: zoomedSize))
        if !compatible {
            result = heightRatio
        }
        return result
    }

    private var basicContentUnitSize4ASCV: CGSize {
        switch OS.type {
        case .iPadOS where screenVM.orientation == .landscape && !screenVM.isExtremeCompact:
            .init(width: 622, height: 900)
        default:
            .init(width: 622, height: 1107)
        }
    }

    private var hasNoAvatars: Bool { summarizedAvatars.isEmpty }

    private var game: Pizza.SupportedGame? {
        summarizedAvatars.first?.game
    }

    private var useNameCardBackgrounds: Bool {
        switch game {
        case .genshinImpact: useNameCardBGWithGICharacters
        case .starRail: false
        case .zenlessZone: false // 临时设定。
        case .none: false
        }
    }

    private var isMainBodyVisible: Bool {
        !hasNoAvatars && allIDs.contains(showingCharacterIdentifier)
    }
}
