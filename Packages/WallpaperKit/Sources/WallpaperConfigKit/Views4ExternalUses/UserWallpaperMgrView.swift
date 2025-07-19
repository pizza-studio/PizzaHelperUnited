// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)

import AlertToast
import Defaults
import PZBaseKit
import SFSafeSymbols
import SwiftUI
import WallpaperKit

@available(iOS 17.0, macCatalyst 17.0, *)
public struct UserWallpaperMgrViewContent: View {
    // MARK: Lifecycle

    public init() {
        self.userWallpapers = UserWallpaperFileHandler.getAllUserWallpapers()
    }

    // MARK: Public

    public static let navTitle: String = "userWallpaperMgr.navTitle".i18nWPConfKit
    public static let navDescription: String = "userWallpaperMgr.navDescription".i18nWPConfKit
    public static let navTitleTiny: String = "userWallpaperMgr.navTitle.tiny".i18nWPConfKit

    public var body: some View {
        NavigationStack {
            coreBody
                .navigationTitle(Self.navTitleTiny)
                .navBarTitleDisplayMode(.large)
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
                                alertToastEventStatus4WPMgr.isWallpaperTaskFailed.toggle()
                            case let .success(url):
                                defer {
                                    url.stopAccessingSecurityScopedResource()
                                }
                                guard url.startAccessingSecurityScopedResource() else {
                                    alertToastEventStatus4WPMgr.isWallpaperTaskFailed.toggle()
                                    return
                                }
                                do {
                                    try UserWallpaperPack.loadAndParse(url)
                                } catch {
                                    alertToastEventStatus4WPMgr.isWallpaperTaskFailed.toggle()
                                    return
                                }
                                alertToastEventStatus4WPMgr.isWallpaperTaskSucceeded.toggle()
                            }
                        } extraItem: {
                            NavigationLink(destination: callUserWallpaperMakerView) {
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
                .toast(isPresenting: $alertToastEventStatus4WPMgr.isWallpaperTaskSucceeded) {
                    AlertToast(
                        displayMode: .alert,
                        type: .complete(.green),
                        title: "userWallpaperMgr.toast.taskSucceeded".i18nWPConfKit
                    )
                }
                .toast(isPresenting: $alertToastEventStatus4WPMgr.isWallpaperTaskFailed) {
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
    final class AlertToastEventStatus4WPMgr {
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

    @State private var isCropperSheetPresented: Bool = false
    @State private var alertToastEventStatus4WPMgr: AlertToastEventStatus4WPMgr = .init()
    @StateObject private var broadcaster = Broadcaster.shared
    @StateObject private var folderMonitor = UserWallpaperFileHandler.folderMonitor
    @State private var isNameEditorVisible: Bool = false
    @State private var currentEditingWallpaper: UserWallpaper?

    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    @State private var userWallpapers: Set<UserWallpaper>

    @Default(.liveActivityWallpaperIDs) private var liveActivityWallpaperIDs: Set<String>
    @Default(.appWallpaperID) private var appWallpaperID: String

    private var viewRefreshHash: Int {
        Set(
            [
                broadcaster.eventForUserWallpaperDidSave.hashValue,
                folderMonitor.stateHash.hashValue,
            ]
        ).hashValue
    }

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

    private var labvParser: LiveActivityBackgroundValueParser { .init($liveActivityWallpaperIDs) }
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension UserWallpaperMgrViewContent {
    @ViewBuilder var coreBody: some View {
        Form {
            Section {
                ForEach(userWallpapersSorted, id: \.id) { userWallpaper in
                    #if os(iOS) || targetEnvironment(macCatalyst)
                    RowEntryView(
                        userWallpaper: userWallpaper,
                        textLimiter: limitText,
                        isEditMode: $isEditMode,
                        isNameEditorVisible: $isNameEditorVisible,
                        currentEditingWallpaper: $currentEditingWallpaper,
                        userWallpapers: $userWallpapers
                    )
                    .environment(alertToastEventStatus4WPMgr)
                    #else
                    RowEntryView(
                        userWallpaper: userWallpaper,
                        textLimiter: limitText,
                        isNameEditorVisible: $isNameEditorVisible,
                        currentEditingWallpaper: $currentEditingWallpaper,
                        userWallpapers: $userWallpapers
                    )
                    .environment(alertToastEventStatus4WPMgr)
                    #endif
                }
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
                    NavigationLink(destination: callUserWallpaperMakerView) {
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
        .formStyle(.grouped).disableFocusable()
        .react(to: viewRefreshHash) {
            Task { @MainActor in
                withAnimation {
                    userWallpapers = UserWallpaperFileHandler.getAllUserWallpapers()
                }
            }
        }
    }

    @ViewBuilder
    func callUserWallpaperMakerView() -> UserWallpaperMakerView {
        UserWallpaperMakerView { finishedWallpaper in
            withAnimation {
                alertToastEventStatus4WPMgr.isWallpaperTaskSucceeded.toggle()
                currentEditingWallpaper = finishedWallpaper
                UserWallpaperFileHandler.saveUserWallpaperToDisk(finishedWallpaper)
                isNameEditorVisible = true
                Task { @MainActor in
                    Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                }
            }
        } failureHandler: {
            alertToastEventStatus4WPMgr.isWallpaperTaskFailed.toggle()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            let wallpapersTemp = userWallpapersSorted
            guard offsets.subtracting(IndexSet(wallpapersTemp.indices)).isEmpty else { return }
            var uuidsToRemove = Set<UUID>()
            offsets.forEach {
                let wp = userWallpapersSorted[$0]
                uuidsToRemove.insert(wp.id)
            }
            UserWallpaperFileHandler.removeWallpapers(uuids: uuidsToRemove)
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

@available(iOS 17.0, macCatalyst 17.0, *)
extension UserWallpaperMgrViewContent {
    private struct RowEntryView: View {
        // MARK: Lifecycle

        #if os(iOS) || targetEnvironment(macCatalyst)
        public init(
            userWallpaper: UserWallpaper,
            textLimiter: @escaping (Int) -> Void,
            isEditMode: Binding<EditMode>,
            isNameEditorVisible: Binding<Bool>,
            currentEditingWallpaper: Binding<UserWallpaper?>,
            userWallpapers: Binding<Set<UserWallpaper>>
        ) {
            self.userWallpaper = userWallpaper
            self.textLimiter = textLimiter
            self._isEditMode = isEditMode
            self._isNameEditorVisible = isNameEditorVisible
            self._currentEditingWallpaper = currentEditingWallpaper
            self._userWallpapers = userWallpapers
        }
        #else
        public init(
            userWallpaper: UserWallpaper,
            textLimiter: @escaping (Int) -> Void,
            isNameEditorVisible: Binding<Bool>,
            currentEditingWallpaper: Binding<UserWallpaper?>,
            userWallpapers: Binding<Set<UserWallpaper>>
        ) {
            self.userWallpaper = userWallpaper
            self.textLimiter = textLimiter
            self._isNameEditorVisible = isNameEditorVisible
            self._currentEditingWallpaper = currentEditingWallpaper
            self._userWallpapers = userWallpapers
        }
        #endif

        // MARK: Public

        public var body: some View {
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
                Button("wpKit.assign.background4App".i18nWPConfKit) {
                    appWallpaperID = userWallpaper.id.uuidString
                }
                #if canImport(ActivityKit) && !targetEnvironment(macCatalyst) && !os(macOS)
                let alreadyChosenAsLABG: Bool =
                    !labvParser.useRandomBackground.wrappedValue
                        && !labvParser.useEmptyBackground.wrappedValue
                        && liveActivityWallpaperIDs.contains(userWallpaper.id.uuidString)
                Button {
                    if alreadyChosenAsLABG {
                        liveActivityWallpaperIDs.remove(userWallpaper.id.uuidString)
                    } else {
                        labvParser.useEmptyBackground.wrappedValue = false
                        liveActivityWallpaperIDs.insert(userWallpaper.id.uuidString)
                    }
                } label: {
                    Label(
                        "wpKit.assign.backgrounds4LiveActivity".i18nWPConfKit,
                        systemSymbol: alreadyChosenAsLABG ? .checkmark : nil
                    )
                }
                #endif
                Divider()
                Button(role: .destructive) {
                    withAnimation {
                        UserWallpaperFileHandler.removeWallpaper(uuid: userWallpaper.id)
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
                    }.react(to: currentEditingWallpaper) { oldValue, newValue in
                        guard oldValue != newValue else { return }
                        textLimiter(30)
                    }
                    if var currentEditingWallpaper {
                        Button {
                            currentEditingWallpaper.name = nameEditingBuffer.wrappedValue
                            UserWallpaperFileHandler.saveUserWallpaperToDisk(currentEditingWallpaper)
                            alertToastEventStatus4WPMgr.isWallpaperTaskSucceeded.toggle()
                            Task { @MainActor in
                                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                            }
                            isNameEditorVisible = false
                        } label: {
                            Text("sys.done".i18nBaseKit)
                        }
                        .buttonStyle(.borderedProminent)
                        .keyboardShortcut(.return)
                    }
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

        // MARK: Private

        #if os(iOS) || targetEnvironment(macCatalyst)
        @Binding private var isEditMode: EditMode
        #endif
        @Binding private var isNameEditorVisible: Bool
        @Binding private var currentEditingWallpaper: UserWallpaper?
        @Binding private var userWallpapers: Set<UserWallpaper>
        @Environment(AlertToastEventStatus4WPMgr.self) private var alertToastEventStatus4WPMgr

        @Default(.liveActivityWallpaperIDs) private var liveActivityWallpaperIDs: Set<String>
        @Default(.appWallpaperID) private var appWallpaperID: String

        private let userWallpaper: UserWallpaper
        private let textLimiter: (Int) -> Void

        private var labvParser: LiveActivityBackgroundValueParser {
            .init($liveActivityWallpaperIDs)
        }

        private var isEditing: Bool {
            #if os(iOS) || targetEnvironment(macCatalyst)
            return isEditMode.isEditing
            #else
            return false
            #endif
        }

        private var nameEditingBuffer: Binding<String> {
            .init {
                currentEditingWallpaper?.name ?? ""
            } set: { newValue in
                currentEditingWallpaper?.name = newValue
            }
        }
    }
}

#if DEBUG

@available(iOS 17.0, macCatalyst 17.0, *)
#Preview {
    NavigationStack {
        UserWallpaperMgrViewContent()
    }
}

#endif

#endif
