// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - ProfileShowCaseSections

@MainActor
public struct ProfileShowCaseSections<QueryDB: EnkaDBProtocol, T: View>: View
    where QueryDB.QueriedProfile.DBType == QueryDB {
    // MARK: Lifecycle

    @MainActor
    public init(
        theDB: QueryDB,
        pzProfile: any ProfileMOProtocol,
        additionalView: @escaping (() -> T) = { EmptyView() }
    ) {
        self.additionalView = additionalView
        self.theDB = theDB
        self.pzProfile = pzProfile
        self.delegate = .init(uid: pzProfile.uid)
    }

    // MARK: Public

    public var body: some View {
        listHeader
        Section {
            switch delegate.taskState {
            case .standBy:
                if let result = guardedEnkaProfile {
                    ShowCaseListView(profile: result, enkaDB: theDB, asCardIcons: true)
                }
            case .busy:
                if let result = guardedEnkaProfile {
                    ShowCaseListView(profile: result, enkaDB: theDB, asCardIcons: true)
                        .disabled(delegate.taskState == .busy)
                        .saturation(delegate.taskState == .busy ? 0 : 1)
                }
                InfiniteProgressBar().id(UUID())
            }
            if let errorMsg = delegate.errorMsg {
                Button {
                    triggerUpdateTask()
                } label: {
                    Text(errorMsg).font(.caption2)
                }
            }
        }
        .onChange(of: refreshSputnik.event) { _, _ in
            triggerUpdateTask()
        }
        .refreshable {
            triggerUpdateTask()
        }
    }

    // MARK: Internal

    @State var pzProfile: any ProfileMOProtocol

    @ViewBuilder var listHeader: some View {
        let extraTerms = Enka.ExtraTerms(lang: theDB.locTag, game: theDB.game)
        let rawInfo = guardedEnkaProfile
        Section {
            HStack(spacing: 0) {
                let levelTag: String = if let rawInfo {
                    "\(extraTerms.levelNameShortened)\(rawInfo.level)"
                } else {
                    ""
                }
                Enka.ProfileIconView(uid: pzProfile.uid, game: pzProfile.game)
                    .frame(width: 74, height: 60, alignment: .leading)
                    .corneredTag(
                        verbatim: levelTag,
                        alignment: .bottomTrailing,
                        textSize: 12
                    )
                    .padding(.trailing, 4)
                #if targetEnvironment(macCatalyst) || os(macOS)
                    .contextMenu {
                        Button("↺".description) {
                            triggerUpdateTask()
                        }
                    }
                #endif
                VStack(alignment: .leading) {
                    HStack(spacing: 10) {
                        VStack(alignment: .leading) {
                            Text(verbatim: rawInfo?.nickname ?? pzProfile.name)
                                .font(.title3)
                                .bold()
                                .padding(.top, 5)
                                .lineLimit(1)
                            if let signature = rawInfo?.signature {
                                Text(verbatim: signature)
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                                    .lineLimit(2)
                                    .fixedSize(
                                        horizontal: false,
                                        vertical: true
                                    )
                            }
                        }
                        Spacer()
                    }
                }
                additionalView()
            }
        } footer: {
            HStack {
                Text(verbatim: "UID: \(pzProfile.uidWithGame)")
                Spacer()
                if let worldLevel = rawInfo?.worldLevel {
                    Text(verbatim: "\(extraTerms.equilibriumLevel): \(worldLevel)")
                }
            }
            .secondaryColorVerseBackground()
        }
    }

    func triggerUpdateTask() {
        Task {
            delegate.update()
        }
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private let additionalView: () -> T
    private var theDB: QueryDB
    @State private var delegate: Coordinator<QueryDB>
    @State private var refreshSputnik = ViewRefreshSputnik.shared

    private var isUIDValid: Bool {
        guard let givenUIDInt = Int(pzProfile.uid) else { return false }
        return (100_000_000 ... 9_999_999_999).contains(givenUIDInt)
    }

    private var guardedEnkaProfile: QueryDB.QueriedProfile? {
        delegate.currentInfo ?? theDB.getCachedProfileRAW(uid: pzProfile.uid)
    }
}

// MARK: ProfileShowCaseSections.Coordinator

extension ProfileShowCaseSections {
    @Observable
    @MainActor
    class Coordinator<CoordinatedDB: EnkaDBProtocol> {
        // MARK: Lifecycle

        public init(uid: String) {
            self.uid = uid
            Task.detached { @MainActor in
                self.update()
            }
        }

        // MARK: Public

        public enum State: String, Sendable, Hashable, Identifiable {
            case busy
            case standBy

            // MARK: Public

            public var id: String { rawValue }
        }

        // MARK: Internal

        var taskState: State = .standBy
        var currentInfo: CoordinatedDB.QueriedProfile?
        var task: Task<CoordinatedDB.QueriedProfile?, Never>?
        var uid: String

        var errorMsg: String?

        @MainActor
        func update() {
            guard let givenUID = Int(uid) else { return }
            task?.cancel()
            withAnimation {
                self.taskState = .busy
                currentInfo = nil
                errorMsg = nil
            }
            task = Task {
                do {
                    let enkaDB = CoordinatedDB.shared
                    let profile = try await enkaDB.query(for: givenUID.description)
                    // 检查本地 EnkaDB 是否过期，过期了的话就尝试更新。
                    if enkaDB.checkIfExpired(against: profile) {
                        let factoryDB = CoordinatedDB(locTag: Enka.currentLangTag)
                        if factoryDB.checkIfExpired(against: profile) {
                            enkaDB.update(new: factoryDB)
                        } else {
                            try await enkaDB.onlineUpdate()
                        }
                    }

                    // 检查本地圣遗物评分模型是否过期，过期了的话就尝试更新。
                    if ArtifactRating.sharedDB.isExpired(against: profile) {
                        ArtifactRating.ARSputnik.shared.resetFactoryScoreModel()
                        if ArtifactRating.sharedDB.isExpired(against: profile) {
                            // 圣遗物评分非刚需体验。
                            // 如果在这个过程内出错的话，顶多就是该当角色没有圣遗物评分可用。
                            try? await ArtifactRating.ARSputnik.shared.onlineUpdate()
                        }
                    }

                    Task.detached { @MainActor in
                        withAnimation {
                            self.currentInfo = profile
                            self.taskState = .standBy
                            self.errorMsg = nil
                        }
                    }
                    return profile
                } catch {
                    Task.detached { @MainActor in
                        withAnimation {
                            self.taskState = .standBy
                            self.errorMsg = error.localizedDescription
                        }
                    }
                    return nil
                }
            }
        }
    }
}

#if DEBUG

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
private let enkaDatabaseGI = try! Enka.EnkaDB4GI(locTag: "zh-tw")
private let testAccountMO = FakePZProfileMO(game: .genshinImpact, uid: "114514810")
// swiftlint:enable force_try
// swiftlint:enable force_unwrapping

#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    NavigationStack {
        List {
            ProfileShowCaseSections(theDB: enkaDatabaseGI, pzProfile: testAccountMO)
        }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
