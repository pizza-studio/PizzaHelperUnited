// (c) 2024 and onwards Pizza Studio (MIT License).
// ====================
// This code is released under the SPDX-License-Identifier: `MIT License`.

import Foundation
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileShowCaseSections

@available(iOS 17.0, macCatalyst 17.0, *)
public struct ProfileShowCaseSections<AppendedContent: View, QueryDB: EnkaDBProtocol>: View
    where QueryDB.QueriedProfile.DBType == QueryDB {
    // MARK: Lifecycle

    @MainActor
    public init(
        theDB: QueryDB,
        pzProfile: any ProfileProtocol,
        appendedContent: @escaping (() -> AppendedContent) = { AnyView(EmptyView()) },
        onTapGestureAction: (() -> Void)? = nil
    ) {
        self.appendedContent = appendedContent
        self.theDB = theDB
        self.pzProfile = pzProfile
        self.onTapGestureAction = onTapGestureAction
        self._delegate = .init(
            wrappedValue: .init(uid: pzProfile.uid, theDB: theDB)
        )
    }

    @MainActor
    public init(
        theDB4GI: Enka.EnkaDB4GI,
        pzProfile: any ProfileProtocol,
        appendedContent: @escaping (() -> AppendedContent) = { AnyView(EmptyView()) },
        onTapGestureAction: (() -> Void)? = nil
    ) where QueryDB == Enka.EnkaDB4GI {
        self.appendedContent = appendedContent
        self.theDB = theDB4GI
        self.pzProfile = pzProfile
        self.onTapGestureAction = onTapGestureAction
        let indexKey4VM = pzProfile.uidWithGame
        let vm = CaseProfileVM<Enka.EnkaDB4GI>.singletonForPersonalProfile[
            indexKey4VM, default: .init(uid: pzProfile.uid, theDB: theDB)
        ]
        CaseProfileVM<Enka.EnkaDB4GI>.singletonForPersonalProfile[
            indexKey4VM
        ] = vm
        self._delegate = .init(wrappedValue: vm)
    }

    @MainActor
    public init(
        theDB4HSR: Enka.EnkaDB4HSR,
        pzProfile: any ProfileProtocol,
        appendedContent: @escaping (() -> AppendedContent) = { AnyView(EmptyView()) },
        onTapGestureAction: (() -> Void)? = nil
    ) where QueryDB == Enka.EnkaDB4HSR {
        self.appendedContent = appendedContent
        self.theDB = theDB4HSR
        self.pzProfile = pzProfile
        self.onTapGestureAction = onTapGestureAction
        let indexKey4VM = pzProfile.uidWithGame
        let vm = CaseProfileVM<Enka.EnkaDB4HSR>.singletonForPersonalProfile[
            indexKey4VM, default: .init(uid: pzProfile.uid, theDB: theDB)
        ]
        CaseProfileVM<Enka.EnkaDB4HSR>.singletonForPersonalProfile[
            indexKey4VM
        ] = vm
        self._delegate = .init(wrappedValue: vm)
    }

    // MARK: Public

    public var body: some View {
        listHeader
        Section {
            Group {
                profileShowCaseList
            }
            .onTapGesture {
                onTapGestureAction?()
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
        // .react(to: broadcaster.eventForStoppingRootTabTasks) { _, _ in
        //     delegate.forceStopTheTask()
        // }
        .react(to: broadcaster.eventForRefreshingCurrentPage) { _, _ in
            triggerUpdateTask()
        }
    }

    // MARK: Internal

    @State var pzProfile: any ProfileProtocol

    @ViewBuilder var listHeader: some View {
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
                    .contextMenu {
                        if OS.type == .macOS {
                            Button("↺".description) {
                                triggerUpdateTask()
                            }
                        }
                    }
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
            .headerFooterTextVisibilityEnhanced()
        }
    }

    func triggerUpdateTask() {
        if delegate.taskState == .standby {
            delegate.update()
        }
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @State private var delegate: CaseProfileVM<QueryDB>
    @StateObject private var broadcaster = Broadcaster.shared

    private let appendedContent: () -> AppendedContent
    private let onTapGestureAction: (() -> Void)?
    private var theDB: QueryDB

    private var isUIDValid: Bool {
        guard let givenUIDInt = Int(pzProfile.uid) else { return false }
        return (100_000_000 ... 9_999_999_999).contains(givenUIDInt)
    }

    private var guardedEnkaProfile: QueryDB.QueriedProfile? {
        delegate.currentInfo
    }

    @ViewBuilder private var profileShowCaseList: some View {
        if let result = guardedEnkaProfile {
            ShowCaseListView(
                profile: result,
                enkaDB: theDB,
                asCardIcons: true,
                appendHoYoLABResults: false
            )
            .id(result.hashValue)
            .disabled(delegate.taskState == .busy)
            .saturation(delegate.taskState == .busy ? 0 : 1)
            .padding(.bottom, delegate.taskState == .busy ? 8 : 0)
            .overlay(alignment: .bottom) {
                if delegate.taskState == .busy {
                    InfiniteProgressBar().id(UUID())
                }
            }
        } else {
            if delegate.taskState == .busy {
                InfiniteProgressBar().id(UUID())
            }
        }
    }
}

#if DEBUG

// swiftlint:disable force_try
// swiftlint:disable force_unwrapping
@available(iOS 17.0, macCatalyst 17.0, *) private let enkaDatabaseGI = try! Enka.EnkaDB4GI(locTag: "zh-tw")
// swiftlint:enable force_try
// swiftlint:enable force_unwrapping

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    NavigationStack {
        Form {
            if let testAccountMO = PZProfileSendable.makeInheritedInstance(
                game: .genshinImpact,
                uid: "114514810"
            ) {
                ProfileShowCaseSections(theDB: enkaDatabaseGI, pzProfile: testAccountMO)
            }
        }
        .formStyle(.grouped).disableFocusable()
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
