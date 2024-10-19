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
        self._delegate = .init(
            wrappedValue: .init(uid: pzProfile.uid, theDB: theDB)
        )
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
            if let error = delegate.currentError {
                Button {
                    triggerUpdateTask()
                } label: {
                    Text(verbatim: "\(error)").font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            appendedContent()
        }
        .onChange(of: broadcaster.eventForStoppingRootTabTasks) { _, _ in
            delegate.forceStopTheTask()
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
                let levelTag = if let rawInfo {
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
    @StateObject private var delegate: CaseProfileVM<QueryDB>
    @StateObject private var broadcaster = Broadcaster.shared

    private var isUIDValid: Bool {
        guard let givenUIDInt = Int(pzProfile.uid) else { return false }
        return (100_000_000 ... 9_999_999_999).contains(givenUIDInt)
    }

    private var guardedEnkaProfile: QueryDB.QueriedProfile? {
        delegate.currentInfo
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
