// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - AvatarShowCaseView

public struct AvatarShowCaseView<DBType: EnkaDBProtocol>: View where DBType.QueriedProfile.DBType == DBType {
    // MARK: Lifecycle

    public init?(
        selectedAvatarID: String? = nil,
        profile: Enka.ProfileSummarized<DBType>,
        onClose: (() -> Void)? = nil
    ) {
        guard !profile.summarizedAvatars.isEmpty else { return nil }
        let safeSelection: String = profile.summarizedAvatars.first {
            $0.mainInfo.uniqueCharId == selectedAvatarID
        }?.id ?? profile.summarizedAvatars[0].id
        self.showingCharacterIdentifier = safeSelection
        self.onClose = onClose
        self.profile = profile
    }

    // MARK: Public

    @MainActor public var body: some View {
        Group {
            if hasNoAvatars {
                blankView()
            } else {
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
            .toolbar(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
        #endif
            .toolbar(.hidden)
    }

    @MainActor @ViewBuilder
    public func coreBody() -> some View {
        TabView(selection: $showingCharacterIdentifier.animation()) {
            // TabView 以 EnkaID 为依据。
            ForEach(profile.summarizedAvatars) { avatar in
                framedCoreView(avatar)
            }
        }
        #if !os(OSX)
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
        #if !os(OSX)
        .statusBarHidden(true)
        #endif
    }

    // MARK: Internal

    @MainActor @ViewBuilder var contextMenuContents: some View {
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
                ForEach(profile.summarizedAvatars) { theAvatar in
                    Button(theAvatar.mainInfo.name) {
                        withAnimation {
                            showingCharacterIdentifier = theAvatar.mainInfo.uniqueCharId
                        }
                    }
                }
            }
        }
    }

    @MainActor @ViewBuilder
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

    @MainActor @ViewBuilder
    func blankView() -> some View {
        Text(verbatim: "🗑️")
    }

    // MARK: Private

    private let onClose: (() -> Void)?
    private let bottomSpacerHeight: CGFloat = 20
    @State private var showTabViewIndex = false
    @State private var showingCharacterIdentifier: String
    @State private var profile: Enka.ProfileSummarized<DBType>
    @State private var orientation = DeviceOrientation()
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @Default(.useNameCardBGWithGICharacters) private var useNameCardBGWithGICharacters: Bool

    private var avatar: Enka.AvatarSummarized? {
        profile.summarizedAvatars.first(where: { avatar in
            avatar.mainInfo.uniqueCharId == showingCharacterIdentifier
        })
    }

    private var scaleRatioCompatible: CGFloat { DeviceOrientation.scaleRatioCompatible }

    private var hasNoAvatars: Bool { profile.summarizedAvatars.isEmpty }

    private var useNameCardBackgrounds: Bool {
        switch profile.game {
        case .genshinImpact: useNameCardBGWithGICharacters
        case .starRail: false
        case .zenlessZone: false // 临时设定。
        }
    }
}

extension Enka.ProfileSummarized where DBType.QueriedProfile.DBType == DBType {
    @MainActor
    public func asView() -> AvatarShowCaseView<DBType>? {
        .init(profile: self)
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG

@MainActor private let summaryHSR: Enka.ProfileSummarized<Enka.EnkaDB4HSR> = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4HSR(locTag: "zh-tw")
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileHSR.json"
    let dataURL = URL(fileURLWithPath: filePath)
    let profile = try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultHSR.self)
    return profile.detailInfo!.summarize(theDB: enkaDatabase)
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@MainActor private let summaryGI: Enka.ProfileSummarized<Enka.EnkaDB4GI> = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4GI(locTag: "zh-tw")
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileGI.json"
    let dataURL = URL(fileURLWithPath: filePath)
    let profile = try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultGI.self)
    return profile.detailInfo!.summarize(theDB: enkaDatabase)
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    TabView {
        summaryGI.asView().clipped().tabItem { Text(verbatim: "GI") }
        summaryHSR.asView().clipped().tabItem { Text(verbatim: "HSR") }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
