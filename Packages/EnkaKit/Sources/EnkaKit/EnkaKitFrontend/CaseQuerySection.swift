// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import Foundation
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit

// MARK: - CaseQuerySection

public struct CaseQuerySection<QueryDB: EnkaDBProtocol>: View {
    // MARK: Lifecycle

    public init(theDB: QueryDB, focus: FocusState<Bool>.Binding? = nil) {
        self.theDB = theDB
        self.focused = focus
    }

    // MARK: Public

    public var body: some View {
        Section {
            queryInputSection()
            if let result = delegate.currentInfo {
                NavigationLink {
                    ShowCaseListView<QueryDB>(profile: result, enkaDB: theDB)
                        .scrollContentBackground(.hidden)
                        .listContainerBackground()
                } label: {
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
            if let error = delegate.currentError {
                Text(verbatim: "\(error)").font(.caption2)
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

    @FocusState var backupFocus: Bool

    var focused: FocusState<Bool>.Binding?

    @ViewBuilder var textFieldView: some View {
        TextField("UID".description, text: $givenUID)
            .focused(focused ?? $backupFocus)
            .onChange(of: givenUID) { oldValue, newValue in
                guard oldValue != newValue else { return }
                formatText()
            }
        #if !os(macOS) && !targetEnvironment(macCatalyst)
            .keyboardType(.numberPad)
        #endif
            .onSubmit {
                if isUIDValid {
                    triggerUpdateTask()
                }
            }
            .disabled(delegate.taskState == .busy)
    }

    @ViewBuilder
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

    @ViewBuilder
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

    @ViewBuilder
    func queryInputSection() -> some View {
        HStack {
            textFieldView
                .font(.system(.title))
                .monospaced()
                .fontWidth(.condensed)
            let buttonDimension = ceil(Font.baseFontSize * 2)
            #if os(iOS) && !targetEnvironment(macCatalyst)
            if (focused ?? $backupFocus).wrappedValue {
                ZStack {
                    Button(action: dropFieldFocus) {
                        Image(systemSymbol: SFSymbol.keyboardChevronCompactDown)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    }
                    .buttonStyle(.borderless)
                }
                .frame(width: buttonDimension, height: buttonDimension)
            }
            #endif
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
            .frame(width: buttonDimension, height: buttonDimension)
        }
    }

    @MainActor
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

    @StateObject private var delegate: CaseProfileVM<QueryDB> = .init()

    private var theDB: QueryDB

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
    }
    .environment(\.locale, .init(identifier: "zh-Hant-TW"))
}

#endif
