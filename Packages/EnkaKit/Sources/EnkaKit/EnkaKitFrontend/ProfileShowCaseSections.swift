// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import Foundation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - ProfileShowCaseSections

public struct ProfileShowCaseSections<QueryDB: EnkaDBProtocol, T: View>: View
    where QueryDB.QueriedProfile.DBType == QueryDB {
    // MARK: Lifecycle

    @MainActor
    public init(
        theDB: QueryDB,
        pzProfile: any ProfileMOProtocol,
        appendedContent: @escaping (() -> T) = { EmptyView() }
    ) {
        self.appendedContent = appendedContent
        self.theDB = theDB
        self.pzProfile = pzProfile
        self.delegate = .init(uid: pzProfile.uid, theDB: theDB)
    }

    // MARK: Public

    @MainActor public var body: some View {
        listHeader
        Section {
            switch delegate.taskState {
            case .standBy:
                if let result = guardedEnkaProfile {
                    ShowCaseListView(profile: result, enkaDB: theDB, asCardIcons: true)
                        .id(result.hashValue)
                }
            case .busy:
                if let result = guardedEnkaProfile {
                    ShowCaseListView(profile: result, enkaDB: theDB, asCardIcons: true)
                        .id(result.hashValue)
                        .disabled(delegate.taskState == .busy)
                        .saturation(delegate.taskState == .busy ? 0 : 1)
                }
                InfiniteProgressBar().id(UUID())
            }
            if let errorMsg = delegate.errorMsg {
                Divider()
                Button {
                    triggerUpdateTask()
                } label: {
                    Text(errorMsg).font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            appendedContent()
        }
        .onChange(of: broadcaster.eventForStoppingRootTabTasks) { _, _ in
            delegate.task?.cancel()
            delegate.taskState = .standBy
        }
        .onChange(of: broadcaster.eventForRefreshingCurrentPage) { _, _ in
            triggerUpdateTask()
        }
        .refreshable {
            triggerUpdateTask()
        }
    }

    // MARK: Internal

    @State var pzProfile: any ProfileMOProtocol

    @MainActor @ViewBuilder var listHeader: some View {
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
        if delegate.taskState == .standBy {
            Task.detached { @MainActor in
                delegate.update()
            }
        }
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private let appendedContent: () -> T
    private var theDB: QueryDB
    @State private var delegate: Coordinator<QueryDB>
    @State private var broadcaster = Broadcaster.shared

    private var isUIDValid: Bool {
        guard let givenUIDInt = Int(pzProfile.uid) else { return false }
        return (100_000_000 ... 9_999_999_999).contains(givenUIDInt)
    }

    private var guardedEnkaProfile: QueryDB.QueriedProfile? {
        delegate.currentInfo
    }
}

// MARK: ProfileShowCaseSections.Coordinator

extension ProfileShowCaseSections {
    @Observable
    final class Coordinator<CoordinatedDB: EnkaDBProtocol> {
        // MARK: Lifecycle

        /// 展柜 ViewModel 的建构子。
        ///
        /// - Remark: 注意：该 ViewModel 会在 App Tab 切换时立刻被析构，
        /// 所以严禁任何放在 MainActor 之外的间接脱手操作（哪怕间接也不行）。
        /// - Parameters:
        ///   - uid: UID
        ///   - theDB: EnkaDB（注意直接决定了游戏类型）。
        @MainActor
        public init(uid: String, theDB: CoordinatedDB) {
            self.uid = uid
            self.currentInfo = theDB.getCachedProfileRAW(uid: uid)
            update()
        }

        deinit {
            task?.cancel()
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

extension FakePZProfileMO: @unchecked @retroactive Sendable {}

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
