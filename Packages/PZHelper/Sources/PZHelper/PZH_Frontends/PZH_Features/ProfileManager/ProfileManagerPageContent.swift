// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import Defaults
import EnkaKit
import Observation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

// MARK: - ProfileManagerPageContent

/// MEMO: 此处沿用 PZProfileMO 作为指针格式，但在增删改操作进行的时候一律走 VM。
/// PZProfileActor 与 MainActor 只能有其中一个用来专门管理 SwiftData 的增删改，
/// 所以只能放弃使用与后者有关的 Environment 层面的 SwiftData API。
/// 不然的话，在 iOS 26 / macOS 26 系统下会崩溃。

struct ProfileManagerPageContent: View {
    // MARK: Public

    public var body: some View {
        coreBody
            .disabled(isBusy)
            .saturation(isBusy ? 0 : 1)
            .overlay {
                if isBusy {
                    Color.clear
                        .frame(width: 128, height: 128)
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay { ProgressView().frame(width: 100, height: 100) }
                }
            }
    }

    // MARK: Internal

    #if os(iOS) || targetEnvironment(macCatalyst)
    @State var isEditMode: EditMode = .inactive
    #endif

    @ViewBuilder var coreBody: some View {
        List {
            Section {
                Button {
                    sheetType = .createNewProfile(.init())
                } label: {
                    Label("profileMgr.new".i18nPZHelper, systemSymbol: .plusCircle)
                }
            } footer: {
                NavigationLink {
                    HoYoPassWithdrawView()
                } label: {
                    Text("profileMgr.withdraw.entrylink.title".i18nPZHelper)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                }
            }
            Section {
                ForEach(theVM.profiles) { profile in
                    Group {
                        if let profileMO = theVM.profileMOs[profile.uuid.uuidString] {
                            Button {
                                #if os(iOS) || targetEnvironment(macCatalyst)
                                if isEditMode != .active {
                                    sheetType = .editExistingProfile(profileMO)
                                }
                                #else
                                sheetType = .editExistingProfile(profile)
                                #endif
                            } label: {
                                drawRow(profile: profileMO)
                            }
                        }
                    }
                    .id(profile)
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
                if theVM.profiles.isEmpty {
                    if lastTimeResetLocalProfileDB != nil {
                        Text("profileMgr.noLocalProfileFound".i18nPZHelper)
                            .font(.footnote)
                    }
                }
            } header: {
                drawDBResetDate()
            }
            if theVM.profiles.isEmpty, theVM.hasOldAccountDataDetected {
                Button("profileMgr.importLegacyProfiles.title".i18nPZHelper) {
                    importLegacyData()
                }
            }
        }
        .navigationDestination(item: $sheetType, destination: handleSheetNavigation)
        .navigationTitle("profileMgr.manage.title".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
        .onAppear(perform: bleachInvalidProfiles)
        .apply { content in
            content
                .toolbar {
                    #if os(iOS) || targetEnvironment(macCatalyst)
                    ToolbarItem(placement: .confirmationAction) {
                        Button(isEditMode.isEditing ? "sys.done".i18nBaseKit : "sys.edit".i18nBaseKit) {
                            withAnimation {
                                isEditMode = (isEditMode.isEditing) ? .inactive : .active
                            }
                        }
                    }
                    #endif
                    ToolbarItem(placement: .confirmationAction) {
                        ProfileBackupRestoreMenu(
                            importCompletionHandler: handleImportProfilePackResult,
                            extraItem: extraMenuItems
                        )
                        .disabled(isBusy || isEditing)
                    }
                }
                .toast(isPresenting: $alertToastEventStatus.isProfileTaskSucceeded) {
                    AlertToast(
                        displayMode: .alert,
                        type: .complete(.green),
                        title: "profileMgr.toast.taskSucceeded".i18nPZHelper
                    )
                }
                .toast(isPresenting: $alertToastEventStatus.isFailureSituationTriggered) {
                    AlertToast(
                        displayMode: .alert,
                        type: .error(.red),
                        title: "profileMgr.toast.taskFailed".i18nPZHelper
                    )
                }
            #if os(iOS) || targetEnvironment(macCatalyst)
                .environment(\.editMode, $isEditMode)
            #endif
        }
    }

    // MARK: Private

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter.GregorianPOSIX()
        formatter.timeZone = .autoupdatingCurrent
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    @State private var sheetType: SheetType?
    @StateObject private var theVM: ProfileManagerVM = .shared
    @StateObject private var alertToastEventStatus: AlertToastEventStatus = .init()
    @State private var errorMessage: String?
    @Default(.lastTimeResetLocalProfileDB) private var lastTimeResetLocalProfileDB: Date?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    private var isEditing: Bool {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return isEditMode.isEditing
        #else
        return false
        #endif
    }

    private var isBusy: Bool {
        theVM.taskState == .busy
    }

    @ViewBuilder
    private func handleSheetNavigation(_ sheetType: SheetType) -> some View {
        Group {
            switch sheetType {
            case let .createNewProfile(newProfile):
                CreateProfileSheetView(profile: newProfile, sheetType: $sheetType)
                    .environment(alertToastEventStatus)
            case let .editExistingProfile(profile):
                EditProfileSheetView(profile: profile, sheetType: $sheetType)
                    .environment(alertToastEventStatus)
            }
        }
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        #if os(iOS) || targetEnvironment(macCatalyst)
        .toolbar(.hidden, for: .tabBar)
        #endif
        // 逼着用户改用自订的后退按钮。
        // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
        // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func extraMenuItems() -> (some View)? {
        if theVM.hasOldAccountDataDetected {
            Button {
                importLegacyData()
            } label: {
                Label(
                    "profileMgr.importLegacyProfiles.title".i18nPZHelper,
                    systemSymbol: .tray2Fill
                )
            }
        }
        Divider()
        Button {
            Task { @MainActor in
                await PZProfileActor.shared.syncAllDataToUserDefaults()
            }
        } label: {
            Label(
                "profileMgr.syncAllProfilesToUserDefaults.title".i18nPZHelper,
                systemSymbol: .clockArrow2Circlepath
            )
        }
        Divider()
        NavigationLink {
            PFMgrAdvancedOptionsView()
        } label: {
            Label {
                Text(verbatim: PFMgrAdvancedOptionsView.navTitle)
            } icon: {
                Image(systemSymbol: .pc)
            }
        }
    }

    @ViewBuilder
    private func drawRow(profile: PZProfileMO) -> some View {
        /// LabeledContent 与 iPadOS 18 的某些版本不相容，使得此处需要改用 HStack 应对处理。
        HStack {
            profile.asIcon4SUI().frame(width: 48).padding(.trailing, 4)
            VStack(alignment: .leading, spacing: 3) {
                Text(profile.name)
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                let uidView = Text(profile.uidWithGame).fontDesign(.monospaced)
                VStack(alignment: .leading) {
                    uidView
                    let gameTitleAndServer = """
                    \(profile.game.localizedDescription) \
                    (\(profile.server.withGame(profile.game).localizedDescriptionByGame))
                    """
                    Text(gameTitleAndServer)
                }
                .font(.caption2)
                .fontWidth(.condensed)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            #if os(iOS) || targetEnvironment(macCatalyst)
            if isEditMode != .active {
                Image(systemSymbol: .sliderHorizontal3)
            }
            #else
            Image(systemSymbol: .sliderHorizontal3)
            #endif
        }
        .contextMenu {
            Button("profileMgr.edit.title".i18nPZHelper) {
                sheetType = .editExistingProfile(profile)
            }
            Button(role: .destructive) {
                deleteItems(uuids: [profile.uuid], clearEnkaCache: false)
            } label: {
                Text("profileMgr.delete.title".i18nPZHelper)
            }
        }
    }

    @ViewBuilder
    private func drawDBResetDate() -> some View {
        if let lastTimeResetLocalProfileDB {
            let dateStr = Self.dateTimeFormatter.string(from: lastTimeResetLocalProfileDB)
            // 如果是最近 2 小时内发生的，则以红色显示。
            let isRecent = Swift.abs(lastTimeResetLocalProfileDB.timeIntervalSinceNow) > 7200
            Text(
                "profileMgr.lastTimeResetLocalProfileDB:\(dateStr)",
                bundle: .module
            )
            .foregroundStyle(isRecent ? Color.red : Color.primary)
            .textCase(.none)
        }
    }

    private func addProfile(_ profile: PZProfileMO, inBatchQueue: Bool = true) {
        theVM.fireTask(
            cancelPreviousTask: false,
            givenTask: {
                PZNotificationCenter.deleteDailyNoteNotification(for: profile.asSendable)
                try await PZProfileActor.shared.addProfiles([profile.asSendable])
                Broadcaster.shared.requireOSNotificationCenterAuthorization()
                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                alertToastEventStatus.isProfileTaskSucceeded.toggle()
            },
            completionHandler: { _ in
                autoQuitEditModeIfEmpty()
            },
            errorHandler: { error in
                errorMessage = error.localizedDescription
            }
        )
    }

    /// 该方法是 SwiftUI 内部 Protocol 规定的方法。
    private func deleteItems(offsets: IndexSet) {
        deleteItems(offsets: offsets, clearEnkaCache: false)
    }

    private func autoQuitEditModeIfEmpty() {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if theVM.profiles.isEmpty {
            isEditMode = .inactive
        }
        #endif
    }

    private func deleteItems(offsets: IndexSet, clearEnkaCache: Bool) {
        var uuidsToDrop: Set<UUID> = []
        var profilesToDrop: Set<PZProfileSendable> = []
        offsets.forEach {
            let returned = theVM.profiles[$0]
            profilesToDrop.insert(returned)
            uuidsToDrop.insert(returned.uuid)
        }
        deleteItems(uuids: uuidsToDrop, clearEnkaCache: clearEnkaCache)
    }

    private func deleteItems(uuids uuidsToDrop: Set<UUID>, clearEnkaCache: Bool) {
        let profilesToDrop: Set<PZProfileSendable> = {
            var profilesToDropResult: Set<PZProfileSendable> = []
            theVM.profiles.forEach {
                guard uuidsToDrop.contains($0.uuid) else { return }
                profilesToDropResult.insert($0)
            }
            return profilesToDropResult
        }()
        theVM.deleteProfiles(
            uuids: uuidsToDrop,
            completionHandler: { maybeRemained in
                autoQuitEditModeIfEmpty()
                guard let remainingProfiles = maybeRemained else { return }
                let remainingUIDs = Set(remainingProfiles.map(\.uidWithGame))
                profilesToDrop.forEach { currentProfile in
                    // 特殊处理：当且仅当当前删掉的账号不是重复的本地账号的时候，才清空展柜缓存與通知。
                    guard !remainingUIDs.contains(currentProfile.uidWithGame) else { return }
                    PZNotificationCenter.deleteDailyNoteNotification(for: currentProfile)
                    if clearEnkaCache {
                        switch currentProfile.game {
                        case .genshinImpact: Defaults[.queriedEnkaProfiles4GI]
                            .removeValue(forKey: currentProfile.uid)
                        case .starRail: Defaults[.queriedEnkaProfiles4HSR].removeValue(forKey: currentProfile.uid)
                        case .zenlessZone: break // 临时设定。
                        }
                    }
                }
            },
            errorHandler: { error in
                errorMessage = error.localizedDescription
            }
        )
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        theVM.moveItems(from: source, to: destination) { error in
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func importLegacyData() {
        theVM.fireTask(
            cancelPreviousTask: false,
            givenTask: {
                try PZProfileActor.migrateOldAccountsIntoProfiles()
            },
            errorHandler: { error in
                errorMessage = error.localizedDescription
            }
        )
    }

    private func bleachInvalidProfiles() {
        theVM.fireTask(
            cancelPreviousTask: false,
            givenTask: {
                let removedSet = try await PZProfileActor.shared.bleachInvalidProfiles()
                // 注：PZProfileActor 会自动将 SwiftData 内容变更同步到 UserDefaults。
                PZNotificationCenter.batchDeleteDailyNoteNotification(
                    profiles: removedSet,
                    onlyDeleteIfDisabled: false
                )
            },
            errorHandler: { error in
                errorMessage = error.localizedDescription
            }
        )
    }

    private func handleImportProfilePackResult(_ result: Result<URL, any Error>) {
        switch result {
        case .failure:
            alertToastEventStatus.isFailureSituationTriggered.toggle()
        case let .success(url):
            theVM.fireTask(
                cancelPreviousTask: false,
                givenTask: {
                    defer {
                        url.stopAccessingSecurityScopedResource()
                    }
                    guard url.startAccessingSecurityScopedResource() else {
                        alertToastEventStatus.isFailureSituationTriggered.toggle()
                        return
                    }
                    let data: Data = try Data(contentsOf: url)
                    let decoded = try JSONDecoder().decode([PZProfileSendable].self, from: data)
                    let decodedProfileSet = Set(decoded)
                    try await PZProfileActor.shared.addProfiles(decodedProfileSet)
                    Broadcaster.shared.requireOSNotificationCenterAuthorization()
                    Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                    alertToastEventStatus.isProfileTaskSucceeded.toggle()
                },
                errorHandler: { error in
                    errorMessage = error.localizedDescription
                    alertToastEventStatus.isFailureSituationTriggered.toggle()
                }
            )
        }
    }
}

// MARK: ProfileManagerPageContent.SheetType

extension ProfileManagerPageContent {
    enum SheetType: Identifiable, Hashable {
        case createNewProfile(PZProfileMO)
        case editExistingProfile(PZProfileMO)

        // MARK: Public

        public var id: UUID {
            switch self {
            case let .createNewProfile(profile): profile.uuid
            case let .editExistingProfile(profile): profile.uuid
            }
        }
    }
}
