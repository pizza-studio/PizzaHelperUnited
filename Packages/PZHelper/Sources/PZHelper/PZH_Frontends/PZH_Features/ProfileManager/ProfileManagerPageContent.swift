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

struct ProfileManagerPageContent: View {
    // MARK: Public

    public var body: some View {
        coreBody
            .disabled(isBusy)
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
                ForEach(profiles) { profile in
                    Button {
                        #if os(iOS) || targetEnvironment(macCatalyst)
                        if isEditMode != .active {
                            sheetType = .editExistingProfile(profile)
                        }
                        #else
                        sheetType = .editExistingProfile(profile)
                        #endif
                    } label: {
                        drawRow(profile: profile)
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
                if profiles.isEmpty {
                    if lastTimeResetLocalProfileDB != nil {
                        Text("profileMgr.noLocalProfileFound".i18nPZHelper)
                            .font(.footnote)
                    }
                }
            } header: {
                drawDBResetDate()
            }
            if profiles.isEmpty, PZProfileActor.hasOldAccountDataDetected() {
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
    @StateObject private var alertToastEventStatus: AlertToastEventStatus = .init()
    @State private var isBusy = false
    @State private var errorMessage: String?
    @Default(.lastTimeResetLocalProfileDB) private var lastTimeResetLocalProfileDB: Date?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]

    private var isEditing: Bool {
        #if os(iOS) || targetEnvironment(macCatalyst)
        return isEditMode.isEditing
        #else
        return false
        #endif
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
        if PZProfileActor.hasOldAccountDataDetected() {
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
                let uuidToDelete = profile.uuid
                PZNotificationCenter.deleteDailyNoteNotification(for: profile.asSendable)
                modelContext.delete(profile)
                try? modelContext.save()
                Defaults[.pzProfiles].removeValue(forKey: uuidToDelete.uuidString)
                UserDefaults.profileSuite.synchronize()
                #if os(iOS) || targetEnvironment(macCatalyst)
                if profiles.isEmpty {
                    isEditMode = .inactive
                }
                #endif
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
        withAnimation {
            do {
                let uuid = profile.uuid
                PZNotificationCenter.deleteDailyNoteNotification(for: profile.asSendable)
                try modelContext.delete(
                    model: PZProfileMO.self,
                    where: #Predicate { obj in
                        obj.uuid == uuid
                    },
                    includeSubclasses: false
                )
                modelContext.insert(profile)
                try modelContext.save()
                PZNotificationCenter.bleachNotificationsIfDisabled(for: profile.asSendable)
                Defaults[.pzProfiles][profile.uuid.uuidString] = profile.asSendable
                if !inBatchQueue {
                    UserDefaults.profileSuite.synchronize()
                }
            } catch {
                return
            }
        }
    }

    /// 该方法是 SwiftUI 内部 Protocol 规定的方法。
    private func deleteItems(offsets: IndexSet) {
        deleteItems(offsets: offsets, clearEnkaCache: false)
    }

    private func deleteItems(offsets: IndexSet, clearEnkaCache: Bool) {
        withAnimation {
            var uuidsToDrop: [UUID] = []
            var profilesDropped: [PZProfileSendable] = []
            offsets.map {
                let returned = profiles[$0]
                profilesDropped.append(returned.asSendable)
                uuidsToDrop.append(returned.uuid)
                return returned
            }.forEach(modelContext.delete)

            defer {
                let remainingUIDs = Set(profiles.map(\.uidWithGame))
                profilesDropped.forEach { currentProfile in
                    // 特殊处理：当且仅当当前删掉的账号不是重复的本地账号的时候，才清空展柜缓存與通知。
                    guard !remainingUIDs.contains(currentProfile.uidWithGame) else { return }
                    PZNotificationCenter.deleteDailyNoteNotification(for: currentProfile)
                    if clearEnkaCache {
                        switch currentProfile.game {
                        case .genshinImpact: Defaults[.queriedEnkaProfiles4GI].removeValue(forKey: currentProfile.uid)
                        case .starRail: Defaults[.queriedEnkaProfiles4HSR].removeValue(forKey: currentProfile.uid)
                        case .zenlessZone: break // 临时设定。
                        }
                    }
                }
            }

            try? modelContext.save()
            uuidsToDrop.forEach {
                Defaults[.pzProfiles].removeValue(forKey: $0.uuidString)
            }
        }
        #if os(iOS) || targetEnvironment(macCatalyst)
        if profiles.isEmpty {
            isEditMode = .inactive
        }
        #endif
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        withAnimation {
            var revisedProfiles: [PZProfileMO] = profiles.map { $0 }
            revisedProfiles.move(fromOffsets: source, toOffset: destination)

            for (index, profile) in revisedProfiles.enumerated() {
                profile.priority = index
            }
        }
    }

    @MainActor
    private func importLegacyData() {
        withAnimation {
            isBusy = true
            do {
                try PZProfileActor.migrateOldAccountsIntoProfiles()
            } catch {
                errorMessage = error.localizedDescription
            }
            isBusy = false
        }
    }

    private func bleachInvalidProfiles() {
        profiles.filter(\.isInvalid).forEach { profile in
            let uuidToRemove = profile.uuid
            PZNotificationCenter.deleteDailyNoteNotification(for: profile.asSendable)
            modelContext.delete(profile)
            try? modelContext.save()
            Defaults[.pzProfiles].removeValue(forKey: uuidToRemove.uuidString)
            UserDefaults.profileSuite.synchronize()
        }
    }

    private func handleImportProfilePackResult(_ result: Result<URL, any Error>) {
        switch result {
        case .failure:
            alertToastEventStatus.isFailureSituationTriggered.toggle()
        case let .success(url):
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            guard url.startAccessingSecurityScopedResource() else {
                alertToastEventStatus.isFailureSituationTriggered.toggle()
                return
            }
            do {
                let data: Data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode([PZProfileSendable].self, from: data)
                decoded.forEach { profileSendable in
                    addProfile(profileSendable.asMO)
                }
                UserDefaults.profileSuite.synchronize()
                Broadcaster.shared.requireOSNotificationCenterAuthorization()
                Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
            } catch {
                alertToastEventStatus.isFailureSituationTriggered.toggle()
                return
            }
            alertToastEventStatus.isProfileTaskSucceeded.toggle()
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
