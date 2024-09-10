// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Combine
@preconcurrency import Defaults
import Foundation
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - CaseQuerySection

public struct CaseQuerySection<QueryDB: EnkaDBProtocol>: View {
    // MARK: Lifecycle

    public init(theDB: QueryDB, focus: FocusState<Bool>.Binding? = nil) {
        self.theDB = theDB
        self.focused = focus
    }

    // MARK: Public

    @MainActor public var body: some View {
        Section {
            queryInputSection()
            if let result = delegate.currentInfo {
                NavigationLink(value: result) {
                    HStack {
                        result.localFittingIcon4SUI
                            .background { Color.black.opacity(0.165) }
                            .clipShape(Circle())
                            .contentShape(Circle())
                            .frame(width: ceil(Font.baseFontSize * 3))
                        VStack(alignment: .leading) {
                            Text(result.nickname).font(.headline).fontWeight(.bold)
                            Group {
                                if !result.signature.isEmpty, horizontalSizeClass != .compact {
                                    Text(result.uid.description) + Text(
                                        verbatim: "   \(result.signature)"
                                    ).foregroundStyle(.secondary)
                                } else {
                                    Text(result.uid.description)
                                }
                            }.font(.subheadline)
                        }
                        Spacer()
                    }
                }
            }
            if let errorMsg = delegate.errorMsg {
                Text(errorMsg).font(.caption2)
            }
        } header: {
            sectionHeader()
                .foregroundColor(.primary.opacity(0.75)) // Enhance legibility with background images.
                .onTapGesture {
                    dropFieldFocus()
                }
        } footer: {
            sectionFooterWithExplainTexts()
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.footnote)
                .foregroundColor(.primary.opacity(0.75)) // Enhance legibility with background images.
                .onTapGesture {
                    dropFieldFocus()
                }
        }
    }

    // MARK: Internal

    @State var givenUID: String = {
        #if DEBUG
        switch QueryDB.game {
        case .genshinImpact: return "114514810"
        case .starRail: return "114514810"
        case .zenlessZone: return "114514810"
        }
        #else
        return ""
        #endif
    }()

    var focused: FocusState<Bool>.Binding?
    @FocusState var backupFocus: Bool

    @MainActor @ViewBuilder var textFieldView: some View {
        TextField("UID".description, text: $givenUID)
            .focused(focused ?? $backupFocus)
            .onReceive(Just(givenUID)) { _ in formatText() }
        #if !os(OSX) && !targetEnvironment(macCatalyst)
            .keyboardType(.numberPad)
        #endif
            .onSubmit {
                if isUIDValid {
                    triggerUpdateTask()
                }
            }
            .disabled(delegate.taskState == .busy)
    }

    @MainActor @ViewBuilder
    func sectionHeader() -> some View {
        switch QueryDB.game {
        case .genshinImpact:
            Text("enka.CaseQuery.title.GI", bundle: .module)
        case .starRail:
            Text("enka.CaseQuery.title.HSR", bundle: .module)
        case .zenlessZone:
            EmptyView() // 临时设定。
        }
    }

    @MainActor @ViewBuilder
    func sectionFooterWithExplainTexts() -> some View {
        switch QueryDB.game {
        case .genshinImpact:
            Text("enka.CaseQuery.showCaseAPIServiceProviders.explain.GI", bundle: .module)
        case .starRail:
            Text("enka.CaseQuery.showCaseAPIServiceProviders.explain.HSR", bundle: .module)
        case .zenlessZone:
            EmptyView() // 临时设定。
        }
    }

    @MainActor @ViewBuilder
    func queryInputSection() -> some View {
        HStack {
            textFieldView
                .font(.system(.title))
                .monospaced()
                .fontWidth(.condensed)
            ZStack {
                if delegate.taskState == .busy {
                    ProgressView()
                } else {
                    Button(action: triggerUpdateTask) {
                        Image(systemSymbol: SFSymbol.magnifyingglassCircleFill)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.borderless)
                    .disabled(delegate.taskState == .busy || !isUIDValid)
                }
            }
            .frame(height: ceil(Font.baseFontSize * 2))
        }
    }

    func dropFieldFocus() {
        focused?.wrappedValue = false
        backupFocus = false
    }

    @MainActor
    func triggerUpdateTask() {
        delegate.update(givenUID: Int(givenUID))
    }

    // MARK: Private

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private var theDB: QueryDB
    @State private var delegate: Coordinator<QueryDB> = .init()

    private var isUIDValid: Bool {
        guard let givenUIDInt = Int(givenUID) else { return false }
        return (100_000_000 ... 9_999_999_999).contains(givenUIDInt)
    }

    private func formatText() {
        let maxCharInputLimit = 10
        let pattern = "[^0-9]+"
        var toHandle = givenUID.replacingOccurrences(of: pattern, with: "", options: [.regularExpression])
        if toHandle.count > maxCharInputLimit {
            toHandle = toHandle.prefix(maxCharInputLimit).description
        }
        // 仅当结果相异时，才会写入。
        if givenUID != toHandle { givenUID = toHandle }
    }
}

// MARK: CaseQuerySection.Coordinator

extension CaseQuerySection {
    @Observable
    final class Coordinator<CoordinatedDB: EnkaDBProtocol> {
        // MARK: Lifecycle

        public init() {}

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

        var errorMsg: String?

        @MainActor
        func update(givenUID: Int?) {
            guard let givenUID = givenUID else { return }
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
private let enkaDatabaseHSR = try! Enka.EnkaDB4HSR(locTag: "zh-tw")
private let enkaDatabaseGI = try! Enka.EnkaDB4GI(locTag: "zh-tw")
// swiftlint:enable force_try
// swiftlint:enable force_unwrapping

#Preview {
    /// 注意：请仅用 iOS 或者 MacCatalyst 来预览。AppKit 无法正常处理这个 View。
    NavigationStack {
        List {
            CaseQuerySection(theDB: enkaDatabaseHSR)
            CaseQuerySection(theDB: enkaDatabaseGI)
        }
        .navigationDestination(for: Enka.QueriedProfileGI.self) { result in
            ShowCaseListView(profile: result, enkaDB: enkaDatabaseGI)
        }
        .navigationDestination(for: Enka.QueriedProfileHSR.self) { result in
            ShowCaseListView(profile: result, enkaDB: enkaDatabaseHSR)
        }
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
