// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import PZBaseKit
import SwiftUI
import WallpaperKit

// MARK: - EnkaShowCaseView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct EnkaShowCaseView<DBType: EnkaDBProtocol>: View where DBType.QueriedProfile.DBType == DBType {
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

    public var body: some View {
        if profile.summarizedAvatars.isEmpty {
            blankView()
        } else {
            AvatarStatCollectionTabView(
                selectedAvatarID: $showingCharacterIdentifier,
                summarizedAvatars: profile.summarizedAvatars,
                onClose: onClose
            )
            // 下一行是刚需，否则 OS26 无法通过上下文选单正确跳转到对应的角色页面。
            .id(showingCharacterIdentifier)
        }
    }

    // MARK: Internal

    @ViewBuilder
    func blankView() -> some View {
        Text(verbatim: "🗑️")
    }

    // MARK: Private

    @State private var showTabViewIndex = false
    @State private var showingCharacterIdentifier: String
    @State private var profile: Enka.ProfileSummarized<DBType>

    private let onClose: (() -> Void)?
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension Enka.ProfileSummarized where DBType.QueriedProfile.DBType == DBType {
    @MainActor
    public func asView(selectedAvatarID: String? = nil, onClose: (() -> Void)? = nil) -> EnkaShowCaseView<DBType>? {
        .init(selectedAvatarID: selectedAvatarID, profile: self, onClose: onClose)
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *)
@MainActor private let summaryHSR: Enka.ProfileSummarized<Enka.EnkaDB4HSR> = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4HSR(locTag: "zh-tw")
    let profile = try! Enka.QueriedResultHSR.exampleData()
    return profile.detailInfo!.summarize(theDB: enkaDatabase)
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, *)
@MainActor private let summaryGI: Enka.ProfileSummarized<Enka.EnkaDB4GI> = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let enkaDatabase = try! Enka.EnkaDB4GI(locTag: "zh-tw")
    let profile = try! Enka.QueriedResultGI.exampleData()
    return profile.detailInfo!.summarize(theDB: enkaDatabase)
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    TabView {
        summaryGI.asView().clipped().tabItem { Text(verbatim: "GI") }
        summaryHSR.asView().clipped().tabItem { Text(verbatim: "HSR") }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
