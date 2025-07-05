// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ShowCaseListView

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
public struct ShowCaseListView<DBType: EnkaDBProtocol>: View where DBType.QueriedProfile.DBType == DBType {
    // MARK: Lifecycle

    public init(
        profile givenProfile: DBType.QueriedProfile,
        enkaDB: DBType,
        asCardIcons: Bool = false,
        appendHoYoLABResults: Bool = false
    ) {
        self.profile = givenProfile.summarize(
            theDB: enkaDB,
            appendHoYoLABResults: appendHoYoLABResults
        )
        self.extraTerms = .init(lang: enkaDB.locTag, game: DBType.game)
        self.asCardIcons = asCardIcons
    }

    // MARK: Public

    public typealias DBType = DBType

    public enum NavMsgPack<DB: EnkaDBProtocol>: Hashable {
        case avatarProfilePair(String, DB.SummarizedType)
    }

    public var body: some View {
        Group {
            if asCardIcons {
                showAsCardIcons
            } else {
                showAsList
            }
        }
        .onChange(of: dbSet.eventForResummarizingEnkaProfiles) { _, _ in
            triggerCaseContentUpdate()
        }
        .onChange(of: dbSet.eventForResummarizingHoYoLABProfiles) { _, _ in
            triggerCaseContentUpdate()
        }
    }

    @ViewBuilder public var showAsCardIcons: some View {
        if profile.summarizedAvatars.isEmpty {
            ShowCaseEmptyInfoView(game: profile.game)
        } else {
            VStack(alignment: .leading) {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(profile.summarizedAvatars) { avatar in
                            NavigationLink {
                                EnkaShowCaseView<DBType>(
                                    selectedAvatarID: avatar.id,
                                    profile: profile
                                )
                                .task {
                                    simpleTaptic(type: .medium)
                                }
                            } label: {
                                avatar.asCardIcon(75)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.vertical, 4)
                HelpTextForScrollingOnDesktopComputer(.horizontal)
            }
        }
    }

    // MARK: Internal

    @ViewBuilder var showAsList: some View {
        Form {
            listHeader
                .listRowMaterialBackground()
            if profile.summarizedAvatars.isEmpty {
                ShowCaseEmptyInfoView(game: profile.game)
                    .listRowMaterialBackground()
            } else {
                Section {
                    ForEach(profile.summarizedAvatars) { avatar in
                        NavigationLink {
                            EnkaShowCaseView<DBType>(
                                selectedAvatarID: avatar.id,
                                profile: profile
                            )
                            .task {
                                simpleTaptic(type: .medium)
                            }
                        } label: {
                            makeLabelForNavLink(avatar: avatar)
                        }
                    }
                }
                .listRowMaterialBackground()
            }
        }
        .formStyle(.grouped)
        .navigationTitle(Text(verbatim: "\(profile.rawInfo.nickname) (\(profile.uid.description))"))
        .navBarTitleDisplayMode(.inline)
    }

    @ViewBuilder var listHeader: some View {
        Section {
            HStack(spacing: 0) {
                let levelTag = "\(extraTerms.levelNameShortened)\(profile.rawInfo.level)"
                profile.rawInfo.localFittingIcon4SUI
                    .frame(width: 74, height: 60, alignment: .leading)
                    .corneredTag(
                        verbatim: levelTag,
                        alignment: .bottomTrailing,
                        textSize: 12
                    )
                    .padding(.trailing, 4)
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(verbatim: profile.rawInfo.nickname)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                            Text(verbatim: profile.rawInfo.signature)
                                .foregroundColor(.secondary)
                                .font(.footnote)
                                .lineLimit(2)
                                .fixedSize(
                                    horizontal: false,
                                    vertical: true
                                )
                        }
                        Spacer()
                    }
                }
            }
        } footer: {
            HStack {
                Text(verbatim: "UID: \(profile.uid)")
                Spacer()
                Text(verbatim: "\(extraTerms.equilibriumLevel): \(profile.rawInfo.worldLevel)")
            }
            .secondaryColorVerseBackground()
        }
    }

    @ViewBuilder
    func makeLabelForNavLink(avatar: Enka.AvatarSummarized) -> some View {
        HStack(alignment: .center) {
            let intel = avatar.mainInfo
            let strLevel = "\(intel.terms.levelName): \(intel.avatarLevel)"
            let strEL = "\(intel.terms.constellationName): \(intel.constellation)"
            intel.idExpressable.avatarPhoto(
                size: ceil(Font.baseFontSize * 3),
                circleClipped: true,
                clipToHead: true
            )
            VStack(alignment: .leading) {
                Text(verbatim: intel.name).font(.headline).fontWeight(.bold)
                HStack {
                    Text(verbatim: strLevel)
                    Spacer()
                    Text(verbatim: strEL)
                }
                .monospacedDigit()
                .font(.subheadline)
            }
        }
        .foregroundStyle(.primary)
    }

    // MARK: Private

    @State private var dbSet = Enka.Sputnik.shared
    @State private var profile: DBType.SummarizedType
    @State private var extraTerms: Enka.ExtraTerms

    private let asCardIcons: Bool

    private func triggerCaseContentUpdate() {
        Task { @MainActor in
            withAnimation {
                profile.update(
                    newRawInfo: profile.rawInfo
                )
            }
        }
    }
}

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension EKQueriedProfileProtocol {
    @MainActor
    public func asView(
        theDB: DBType,
        expanded: Bool = false
    )
        -> ShowCaseListView<DBType> {
        .init(profile: self, enkaDB: theDB, asCardIcons: !expanded)
    }
}

// MARK: - EachAvatarStatView_Previews

#if DEBUG

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) private let enkaDatabaseHSR = try! Enka
    .EnkaDB4HSR(locTag: "zh-tw")
@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) private let enkaDatabaseGI = try! Enka.EnkaDB4GI(locTag: "zh-tw")
// swiftlint:enable force_try
// swiftlint:enable force_unwrapping

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) private let summaryHSR: Enka.QueriedProfileHSR = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileHSR.json"
    let dataURL = URL(fileURLWithPath: filePath)
    return try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultHSR.self).detailInfo!
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) private let summaryGI: Enka.QueriedProfileGI = {
    // swiftlint:disable force_try
    // swiftlint:disable force_unwrapping
    // Note: Do not use #Preview macro. Otherwise, the preview won't be able to access the assets.
    let packageRootPath = URL(fileURLWithPath: #file).pathComponents.prefix(while: { $0 != "Sources" }).joined(
        separator: "/"
    ).dropFirst()
    let testDataPath: String = packageRootPath + "/Tests/EnkaKitTests/TestAssets/"
    let filePath = testDataPath + "testProfileGI.json"
    let dataURL = URL(fileURLWithPath: filePath)
    return try! Data(contentsOf: dataURL).parseAs(Enka.QueriedResultGI.self).detailInfo!
    // swiftlint:enable force_try
    // swiftlint:enable force_unwrapping
}()

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    TabView {
        NavigationStack {
            summaryGI
                .asView(theDB: enkaDatabaseGI, expanded: false)
        }
        .tabItem { Text(verbatim: "GI") }
        NavigationStack {
            summaryHSR
                .asView(theDB: enkaDatabaseHSR, expanded: false)
        }
        .tabItem { Text(verbatim: "HSR") }
        NavigationStack {
            summaryGI
                .asView(theDB: enkaDatabaseGI, expanded: true)
        }
        .tabItem { Text(verbatim: "GIEX") }
        NavigationStack {
            summaryHSR
                .asView(theDB: enkaDatabaseHSR, expanded: true)
        }
        .tabItem { Text(verbatim: "HSREX") }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
