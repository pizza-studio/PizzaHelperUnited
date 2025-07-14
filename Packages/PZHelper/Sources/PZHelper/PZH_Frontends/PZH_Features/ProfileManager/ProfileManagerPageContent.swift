// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import Defaults
import EnkaKit
import GachaKit
import Observation
import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftUI

// MARK: - ProfileManagerPageContent

/// MEMO: 此处沿用 PZProfileRef 作为指针格式，但在增删改操作进行的时候一律走 VM。
/// PZProfileActor 与 MainActor 只能有其中一个用来专门管理 SwiftData 的增删改，
/// 所以只能放弃使用与后者有关的 Environment 层面的 SwiftData API。
/// 不然的话，在 iOS 26 / macOS 26 系统下会崩溃。

@available(iOS 16.2, macCatalyst 16.2, *)
struct ProfileManagerPageContent: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public var body: some View {
        NavigationStack {
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
    }

    // MARK: Internal

    #if os(iOS) || targetEnvironment(macCatalyst)
    @State var isEditMode: EditMode = .inactive
    #endif

    @ViewBuilder var coreBody: some View {
        Form {
            Section {
                if Self.isOS24OrNewer {
                    NavigationLink {
                        let newProfile = PZProfileRef.makeDefaultInstance()
                        CreateProfileSheetView(profile: newProfile, isVisible: isSheetVisible)
                            .environmentObject(alertToastEventStatus)
                    } label: {
                        Label("profileMgr.new".i18nPZHelper, systemSymbol: .plusCircle)
                    }
                } else {
                    Button {
                        sheetType = .createNewProfile(PZProfileRef.makeDefaultInstance())
                    } label: {
                        Label("profileMgr.new".i18nPZHelper, systemSymbol: .plusCircle)
                    }
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
                        if let profileRef = theVM.profileRefMap[profile.uuid.uuidString] {
                            let label = drawRow(profile: profileRef)
                            if isAppKitOrNotEditing {
                                if Self.isOS24OrNewer {
                                    NavigationLink {
                                        EditProfileSheetView(profile: profileRef, isVisible: isSheetVisible)
                                            .environmentObject(alertToastEventStatus)
                                    } label: {
                                        label
                                    }
                                } else {
                                    Button {
                                        sheetType = .editExistingProfile(profileRef)
                                    } label: {
                                        label
                                    }
                                }
                            } else {
                                label
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
        .formStyle(.grouped)
        .navigationTitle("profileMgr.manage.title".i18nPZHelper)
        .navBarTitleDisplayMode(.large)
        .onAppear(perform: bleachInvalidProfiles)
        .apply(hookSheet)
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

    private static var isOS24OrNewer: Bool {
        if #available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *) { return true }
        return false
    }

    @StateObject private var theVM: ProfileManagerVM = .shared
    @StateObject private var alertToastEventStatus: AlertToastEventStatus = .init()
    @State private var errorMessage: String?
    @State private var sheetType: SheetType?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?

    @Default(.lastTimeResetLocalProfileDB) private var lastTimeResetLocalProfileDB: Date?

    private var isSheetVisible: Binding<Bool> {
        .init {
            if Self.isOS24OrNewer {
                theVM.sheetType != nil
            } else {
                sheetType != nil
            }
        } set: { newValue in
            if !newValue {
                if Self.isOS24OrNewer {
                    theVM.sheetType = nil
                } else {
                    sheetType = nil
                }
            }
        }
    }

    private var isEditing: Bool {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return isEditMode.isEditing
        #else
        return false
        #endif
    }

    private var isAppKitOrNotEditing: Bool {
        !isEditing || (OS.type == .macOS && !OS.isCatalyst)
    }

    private var isBusy: Bool {
        theVM.taskState == .busy
    }

    @ViewBuilder
    private func hookSheet(_ givenView: some View) -> some View {
        if !Self.isOS24OrNewer {
            givenView.sheet(item: $sheetType) { currentSheetType in
                switch currentSheetType {
                case let .createNewProfile(newProfile):
                    CreateProfileSheetView(profile: newProfile, isVisible: isSheetVisible)
                        .environmentObject(alertToastEventStatus)
                        .interactiveDismissDisabled(true)
                case let .editExistingProfile(existingProfile):
                    EditProfileSheetView(profile: existingProfile, isVisible: isSheetVisible)
                        .environmentObject(alertToastEventStatus)
                        .interactiveDismissDisabled(true)
                }
            }
        } else {
            givenView
        }
    }

    @ViewBuilder
    private func drawRow(profile: PZProfileRef) -> some View {
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
            if isAppKitOrNotEditing {
                Image(systemSymbol: .sliderHorizontal3)
            }
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
                await theVM.profileActor?.syncAllDataToUserDefaults()
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
                .environmentObject(alertToastEventStatus)
        } label: {
            Label {
                Text(verbatim: PFMgrAdvancedOptionsView.navTitle)
            } icon: {
                Image(systemSymbol: .pc)
            }
        }
    }

    private func addProfile(_ profile: PZProfileRef, inBatchQueue: Bool = true) {
        theVM.fireTask(
            cancelPreviousTask: false,
            givenTask: {
                PZNotificationCenter.deleteDailyNoteNotification(for: profile.asSendable)
                try await theVM.profileActor?.addOrUpdateProfiles([profile.asSendable])
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
                    if #available(iOS 17.0, macCatalyst 17.0, *) {
                        if clearEnkaCache {
                            switch currentProfile.game {
                            case .genshinImpact:
                                Enka.Sputnik.shared.db4GI.removeCachedProfileRAW(uid: currentProfile.uid)
                            case .starRail:
                                Enka.Sputnik.shared.db4HSR.removeCachedProfileRAW(uid: currentProfile.uid)
                            case .zenlessZone: break // 临时设定。
                            }
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
                try await theVM.profileActor?.migrateOldAccountsIntoProfiles()
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
                let removedSet = try await theVM.profileActor?.bleachInvalidProfiles()
                // 注：PZProfileActor 会自动将 SwiftData 内容变更同步到 UserDefaults。
                PZNotificationCenter.batchDeleteDailyNoteNotification(
                    profiles: removedSet ?? [],
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
                    var decodedProfileSet: Set<PZProfileSendable> = []
                    let data: Data = try Data(contentsOf: url)
                    do {
                        // 此时可以假设要处理的档案是披萨难民资料包，里面只有原神的本机帐号资料。
                        let decoded = try PropertyListDecoder().decode(RefugeeFile.self, from: data)
                        var insertedUUIDs = Set<UUID>()
                        for newProfileSendable in decoded.newProfiles {
                            decodedProfileSet.insert(newProfileSendable)
                            insertedUUIDs.insert(newProfileSendable.uuid)
                        }
                        for oldAccountMO in decoded.oldProfiles4GI {
                            let newProfileSendable = PZProfileSendable.makeInheritedInstance(
                                game: .genshinImpact, uid: oldAccountMO.uid, configuration: oldAccountMO
                            )
                            guard let newProfileSendable else { continue }
                            guard !insertedUUIDs.contains(newProfileSendable.uuid) else { continue }
                            decodedProfileSet.insert(newProfileSendable)
                        }
                    } catch {
                        // 难民资料包的解码出错可以忽略不管，因为用户不该手动修改难民资料包的内容。
                        // 接下来处理正常的本地帐号资料备份交换包。
                        let decoded = try JSONDecoder().decode([PZProfileSendable].self, from: data)
                        decodedProfileSet = Set(decoded)
                    }
                    let assertion = BackgroundTaskAsserter(name: UUID().uuidString)
                    do {
                        if await !assertion.state.isReleased {
                            try await theVM.profileActor?.addOrUpdateProfiles(decodedProfileSet)
                        }
                        await assertion.release()
                    } catch {
                        await assertion.release()
                        throw error
                    }
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

@available(iOS 16.2, macCatalyst 16.2, *)
extension ProfileManagerPageContent {
    typealias SheetType = ProfileManagerVM.SheetType
}
