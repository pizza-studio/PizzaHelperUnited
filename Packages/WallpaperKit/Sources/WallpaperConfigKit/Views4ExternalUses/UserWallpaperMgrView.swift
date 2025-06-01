// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import Defaults
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit

#if !os(watchOS)

public struct UserWallpaperMgrViewContent: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = "userWallpaperMgr.navTitle".i18nWPConfKit
    public static let navDescription: String = "userWallpaperMgr.navDescription".i18nWPConfKit
    public static let navTitleTiny: String = "userWallpaperMgr.navTitle.tiny".i18nWPConfKit

    public var body: some View {
        NavigationStack {
            coreBody
                .navigationTitle(Self.navTitleTiny)
                .navBarTitleDisplayMode(.large)
                .navigationDestination(item: $currentSheet, destination: handleSheetNavigation)
                .toolbar {
                    #if os(iOS) || targetEnvironment(macCatalyst)
                    if !userWallpapers.isEmpty {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(isEditMode.isEditing ? "sys.done".i18nBaseKit : "sys.edit".i18nBaseKit) {
                                withAnimation {
                                    isEditMode = (isEditMode.isEditing) ? .inactive : .active
                                }
                            }
                        }
                    }
                    #endif

                    ToolbarItem(placement: .confirmationAction) {
                        UserWallpaperExchangeMenu { importFileResult in
                            switch importFileResult {
                            case .failure:
                                alertToastEventStatus.isWallpaperTaskFailed.toggle()
                            case let .success(url):
                                defer {
                                    url.stopAccessingSecurityScopedResource()
                                }
                                guard url.startAccessingSecurityScopedResource() else {
                                    alertToastEventStatus.isWallpaperTaskFailed.toggle()
                                    return
                                }
                                do {
                                    try UserWallpaperPack.loadAndParse(url)
                                } catch {
                                    alertToastEventStatus.isWallpaperTaskFailed.toggle()
                                    return
                                }
                                alertToastEventStatus.isWallpaperTaskSucceeded.toggle()
                            }
                        } extraItem: {
                            Button {
                                currentSheet = .isAddingWallpaper
                            } label: {
                                Label {
                                    Text("userWallpaperMgr.menu.addNewWallpaper", bundle: .module)
                                } icon: {
                                    Image(systemSymbol: .photoBadgePlus)
                                }
                            }
                            .disabled(userWallpapers.count >= Self.maxEntriesAmount)
                        }
                        .disabled(isEditing)
                    }
                }
                .toast(isPresenting: $alertToastEventStatus.isWallpaperTaskSucceeded) {
                    AlertToast(
                        displayMode: .alert,
                        type: .complete(.green),
                        title: "userWallpaperMgr.toast.taskSucceeded".i18nWPConfKit
                    )
                }
                .toast(isPresenting: $alertToastEventStatus.isWallpaperTaskFailed) {
                    AlertToast(
                        displayMode: .alert,
                        type: .error(.red),
                        title: "userWallpaperMgr.toast.taskFailed".i18nWPConfKit
                    )
                }
            #if os(iOS) || targetEnvironment(macCatalyst)
                .environment(\.editMode, $isEditMode)
            #endif
        }
    }

    // MARK: Internal

    @Observable
    final class AlertToastEventStatus: ObservableObject {
        public var isWallpaperTaskSucceeded = false
        public var isWallpaperTaskFailed = false
    }

    enum SheetType: String, Identifiable, Hashable {
        case isAddingWallpaper

        // MARK: Public

        public var id: String { rawValue }
    }

    // MARK: Private

    private static let maxEntriesAmount = 10

    #if os(iOS) || targetEnvironment(macCatalyst)
    @State private var isEditMode: EditMode = .inactive
    #endif

    @State private var currentSheet: SheetType?
    @State private var isCropperSheetPresented: Bool = false
    @StateObject private var alertToastEventStatus: AlertToastEventStatus = .init()
    @State private var isNameEditorVisible: Bool = false
    @State private var currentEditingWallpaper: UserWallpaper?

    @Default(.userWallpapers) private var userWallpapers: Set<UserWallpaper>

    private var nameEditingBuffer: Binding<String> {
        .init {
            currentEditingWallpaper?.name ?? ""
        } set: { newValue in
            currentEditingWallpaper?.name = newValue
        }
    }

    private var userWallpapersSorted: [UserWallpaper] {
        userWallpapers.sorted {
            $0.timestamp > $1.timestamp
        }
    }

    private var isEditing: Bool {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return isEditMode.isEditing
        #else
        return false
        #endif
    }
}

extension UserWallpaperMgrViewContent {
    @ViewBuilder var coreBody: some View {
        List {
            Section {
                ForEach(userWallpapersSorted, content: drawRow)
                    .onDelete(perform: deleteItems)
            } header: {
                if userWallpapers.count >= Self.maxEntriesAmount {
                    Text("userWallpaperMgr.footerNotice.maximumEntryAmountReached", bundle: .module)
                        .textCase(.none)
                        .foregroundStyle(
                            userWallpapers.count < Self.maxEntriesAmount
                                ? Color.secondary
                                : .orange
                        )
                }
            } footer: {
                Text("userWallpaperMgr.navDescription", bundle: .module)
            }
            if userWallpapers.isEmpty {
                Section {
                    Text("userWallpaperMgr.emptyContentsNotice", bundle: .module)
                    Button {
                        currentSheet = .isAddingWallpaper
                    } label: {
                        Text("userWallpaperMgr.clickToAddYourFirstWallpaper", bundle: .module)
                            .fontWeight(.bold)
                            .fontWidth(.condensed)
                            .padding(.vertical, 4)
                            .frame(maxWidth: .infinity)
                            .background {
                                Color.accentColor.opacity(0.2)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func drawRow(_ userWallpaper: UserWallpaper) -> some View {
        let cgImage = userWallpaper.imageSquared
        let iconImage: Image = {
            if let cgImage { return Image(decorative: cgImage, scale: 1, orientation: .up) }
            return Image(systemSymbol: .trashSlashFill)
        }()
        /// LabeledContent 与 iPadOS 18 的某些版本不相容，使得此处需要改用 HStack 应对处理。
        HStack {
            iconImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .frame(width: 48).padding(.trailing, 4)
            VStack(alignment: .leading, spacing: 3) {
                Text(userWallpaper.name)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text(userWallpaper.dateString).fontDesign(.monospaced)
                }
                .font(.caption2)
                .fontWidth(.condensed)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            if isEditing || (OS.type == .macOS && !OS.isCatalyst) {
                Button {
                    currentEditingWallpaper = userWallpaper
                    isNameEditorVisible = true
                } label: {
                    Image(systemSymbol: .squareAndPencil)
                }
            }
        }
        .contextMenu {
            Button {
                currentEditingWallpaper = userWallpaper
                isNameEditorVisible = true
            } label: {
                Text("userWallpaperMgr.contextMenu.renameWallpaperEntry", bundle: .module)
            }
            Divider()
            Button(role: .destructive) {
                withAnimation {
                    userWallpapers = userWallpapers.filter {
                        $0.id != userWallpaper.id
                    }
                    #if os(iOS) || targetEnvironment(macCatalyst)
                    if userWallpapers.isEmpty {
                        isEditMode = .inactive
                    }
                    #endif
                    Task { @MainActor in
                        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                    }
                }
            } label: {
                Text("userWallpaperMgr.contextMenu.removeWallpaperEntry", bundle: .module)
            }
        }
        .alert(
            Text("userWallpaperMgr.editingWallpaperName.prompt", bundle: .module),
            isPresented: $isNameEditorVisible,
            actions: {
                TextField(
                    text: nameEditingBuffer
                ) {
                    Text("userWallpaperMgr.editingWallpaperName.fieldLabel", bundle: .module)
                }.onChange(of: currentEditingWallpaper) { oldValue, newValue in
                    guard oldValue != newValue else { return }
                    limitText(30)
                }
                Button {
                    if let currentEditingWallpaper {
                        var newWallpapers = userWallpapers.filter {
                            $0.id != currentEditingWallpaper.id
                        }
                        newWallpapers.insert(currentEditingWallpaper)
                        withAnimation {
                            userWallpapers = newWallpapers
                            alertToastEventStatus.isWallpaperTaskSucceeded.toggle()
                            Task { @MainActor in
                                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                            }
                        }
                    }
                    isNameEditorVisible = false
                } label: {
                    Text("sys.done".i18nBaseKit)
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.return)
                Button {
                    currentEditingWallpaper = nil
                    isNameEditorVisible = false
                } label: {
                    Text("sys.cancel".i18nBaseKit)
                }
                .keyboardShortcut(.escape)
            }
        )
    }

    @ViewBuilder
    private func handleSheetNavigation(_ sheetType: SheetType) -> some View {
        switch sheetType {
        case .isAddingWallpaper:
            UserWallpaperMakerView { finishedWallpaper in
                withAnimation {
                    alertToastEventStatus.isWallpaperTaskSucceeded.toggle()
                    currentEditingWallpaper = finishedWallpaper
                    var allUserWallpapers = userWallpapersSorted
                    allUserWallpapers.insert(finishedWallpaper, at: 0)
                    userWallpapers = .init(allUserWallpapers)
                    isNameEditorVisible = true
                    Task { @MainActor in
                        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                    }
                }
            } failureHandler: {
                alertToastEventStatus.isWallpaperTaskFailed.toggle()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("sys.cancel".i18nBaseKit) {
                        currentSheet = nil
                    }
                }
            }
            // 逼着用户改用自订的后退按钮。
            // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
            // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
            .navigationBarBackButtonHidden(true)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            var wallpapersTemp = userWallpapersSorted
            wallpapersTemp.remove(atOffsets: offsets)
            userWallpapers = .init(wallpapersTemp)
            #if os(iOS) || targetEnvironment(macCatalyst)
            if userWallpapers.isEmpty {
                isEditMode = .inactive
            }
            #endif
            Task { @MainActor in
                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
            }
        }
    }

    // Function to keep text length in limits
    private func limitText(_ upper: Int) {
        guard upper > 0 else { return }
        if (currentEditingWallpaper?.name.count ?? -1) > upper {
            currentEditingWallpaper?.name = String(nameEditingBuffer.wrappedValue.prefix(upper))
        }
    }
}

#if DEBUG

#Preview {
    NavigationStack {
        UserWallpaperMgrViewContent()
    }
}

#endif

#endif
