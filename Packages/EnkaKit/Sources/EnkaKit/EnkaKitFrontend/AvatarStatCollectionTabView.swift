// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - AvatarStatCollectionTabView

public struct AvatarStatCollectionTabView: View {
    // MARK: Lifecycle

    public init(
        selectedAvatarID: Binding<String>,
        summarizedAvatars: [Enka.AvatarSummarized],
        onClose: (() -> Void)? = nil
    ) {
        self._showingCharacterIdentifier = selectedAvatarID
        self.onClose = onClose
        self.summarizedAvatars = summarizedAvatars
        self.allIDs = summarizedAvatars.map(\.id)
    }

    // MARK: Public

    public var body: some View {
        Group {
            if isMainBodyVisible {
                GeometryReader { geometry in
                    coreBody()
                        .environment(orientation)
                        .overlay(alignment: .top) {
                            HelpTextForScrollingOnDesktopComputer(.horizontal).padding()
                        }.onChange(of: geometry.size, initial: true) { _, _ in
                            showTabViewIndex = $showTabViewIndex.wrappedValue // 强制重新渲染整个画面。
                        }
                }
            }
        }
        .environment(\.colorScheme, .dark)
        .navBarTitleDisplayMode(.inline)
        #if os(iOS) || targetEnvironment(macCatalyst)
            .toolbar(isMainBodyVisible ? .hidden : .automatic, for: .navigationBar)
            .toolbar(isMainBodyVisible ? .hidden : .automatic, for: .tabBar)
        #endif
            .toolbar(isMainBodyVisible ? .hidden : .automatic)
    }

    @ViewBuilder
    public func coreBody() -> some View {
        TabView(selection: $showingCharacterIdentifier.animation()) {
            // TabView 以 EnkaID 为依据。
            ForEach(summarizedAvatars) { avatar in
                framedCoreView(avatar)
            }
        }
        #if !os(macOS)
        .tabViewStyle(
            .page(indexDisplayMode: showTabViewIndex ? .automatic : .never)
        )
        #endif
        .onTapGesture {
            if let onClose {
                onClose()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .background {
            ZStack {
                Color(hue: 0, saturation: 0, brightness: 0.1)
                avatar?.asBackground(useNameCardBG: useNameCardBackgrounds)
                    .scaledToFill()
                    .scaleEffect(1.2)
                    .clipped()
            }
            .compositingGroup()
            .ignoresSafeArea(.all)
        }
        .contextMenu { contextMenuContents }
        .clipped()
        .compositingGroup()
        .onChange(of: showingCharacterIdentifier) { _, _ in
            simpleTaptic(type: .selection)
            withAnimation(.easeIn(duration: 0.1)) {
                showTabViewIndex = true
            }
        }
        .ignoresSafeArea()
        .onAppear {
            showTabViewIndex = true
        }
        .onChange(of: showTabViewIndex) { _, newValue in
            if newValue == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
                    withAnimation {
                        showTabViewIndex = false
                    }
                }
            }
        }
        #if !os(macOS)
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
                    Text("enka.ASCV.summarzeToClipboard.asText", bundle: .module)
                }
                Button {
                    Clipboard.currentString = avatar.asMarkDown
                } label: {
                    Text("enka.ASCV.summarzeToClipboard.asMD", bundle: .module)
                }
                Divider()
                ForEach(summarizedAvatars) { theAvatar in
                    Button(theAvatar.mainInfo.name) {
                        withAnimation {
                            showingCharacterIdentifier = theAvatar.mainInfo.uniqueCharId
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    func framedCoreView(_ avatar: Enka.AvatarSummarized) -> some View {
        VStack {
            Spacer().frame(width: 25, height: 10)
            /// Width is locked inside the EachAvatarStatView.
            EachAvatarStatView(data: avatar, background: false)
                .fixedSize()
                .scaleEffect(scaleRatioCompatible)
            Spacer().frame(width: 25, height: bottomSpacerHeight)
        }
    }

    // MARK: Private

    @State private var showTabViewIndex = false
    @Binding private var showingCharacterIdentifier: String
    @StateObject private var orientation = DeviceOrientation()
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    private let summarizedAvatars: [Enka.AvatarSummarized]
    private let allIDs: [String]
    private let onClose: (() -> Void)?
    private let bottomSpacerHeight: CGFloat = 20
    @Default(.useNameCardBGWithGICharacters) private var useNameCardBGWithGICharacters: Bool

    private var avatar: Enka.AvatarSummarized? {
        summarizedAvatars.first(where: { avatar in
            avatar.mainInfo.uniqueCharId == showingCharacterIdentifier
        })
    }

    private var scaleRatioCompatible: CGFloat { DeviceOrientation.scaleRatioCompatible }

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
