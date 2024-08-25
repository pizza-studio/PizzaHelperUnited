// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import Defaults
import EnkaKit
import Observation
import PZAccountKit
import PZBaseKit
import SwiftData
import SwiftUI

// MARK: - ProfileManagerPageContent

@MainActor
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
                        if isEditMode != .active {
                            sheetType = .editExistingProfile(profile)
                        }
                    } label: {
                        drawRow(profile: profile)
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
                if profiles.isEmpty, PersistenceController.hasOldAccountDataDetected() {
                    Button("profileMgr.importLegacyProfiles.title".i18nPZHelper) {
                        importLegacyData()
                    }
                }
            }
        }
        .apply { thisViewUnit in
            if #unavailable(macCatalyst 18.0) {
                thisViewUnit.navigationDestination(item: $sheetType, destination: handleSheetNavigation)
            } else {
                thisViewUnit.sheet(item: $sheetType, content: handleSheetNavigation)
            }
        }
        .navigationTitle("profileMgr.manage.title".i18nPZHelper)
        .navigationBarTitleDisplayMode(.large)
        .onAppear(perform: bleachInvalidProfiles)
        .toolbar { EditButton() }
        .toast(isPresenting: $alertToastEventStatus.isDoneButtonTapped) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "profileMgr.added.succeeded".i18nPZHelper
            )
        }
        .environment(\.editMode, $isEditMode)
    }

    // MARK: Private

    @State private var sheetType: SheetType?
    @State private var alertToastEventStatus = AlertToastEventStatus()
    @State private var isBusy = false
    @State private var errorMessage: String?
    @State var isEditMode: EditMode = .inactive
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]

    private var isSheetShown: Binding<Bool> {
        .init {
            sheetType != nil
        } set: { newValue in
            if !newValue { sheetType = nil }
        }
    }

    @ViewBuilder
    private func handleSheetNavigation(_ sheetType: SheetType) -> some View {
        Group {
            switch sheetType {
            case let .createNewProfile(newProfile):
                CreateProfileSheetView(profile: newProfile, isShown: isSheetShown)
                    .environment(alertToastEventStatus)
            case let .editExistingProfile(profile):
                EditProfileSheetView(profile: profile, isShown: isSheetShown)
                    .environment(alertToastEventStatus)
            }
        }
        // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
        .toolbar(.hidden, for: .tabBar)
        // 仅针对 macOS 使用 NavigationDestination 的情况，让用户改用自订的后退按钮。
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private func drawRow(profile: PZProfileMO) -> some View {
        /// LabeledContent 与 iPadOS 18 的某些版本不相容，使得此处需要改用 HStack 应对处理。
        HStack {
            profile.asIcon4SUI().frame(width: 48).padding(.trailing, 4)
            VStack(alignment: .leading, spacing: 3) {
                Text(profile.name)
                    .foregroundColor(.primary)
                HStack {
                    Text(profile.uidWithGame).fontDesign(.monospaced)
                    if horizontalSizeClass != .compact {
                        Text(profile.game.localizedDescription)
                    }
                    Text(profile.server.localizedDescriptionByGame)
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            Spacer()
            if isEditMode != .active {
                Image(systemSymbol: .sliderHorizontal3)
            }
        }
        .contextMenu {
            Button("profileMgr.edit.title".i18nPZHelper) {
                sheetType = .editExistingProfile(profile)
            }
            Button(role: .destructive) {
                modelContext.delete(profile)
                try? modelContext.save()
            } label: {
                Text("profileMgr.delete.title".i18nPZHelper)
            }
        }
    }

    private func addProfile(_ profile: PZProfileMO) {
        withAnimation {
            modelContext.insert(profile)
        }
    }

    /// 该方法是 SwiftUI 内部 Protocol 规定的方法。
    private func deleteItems(offsets: IndexSet) {
        deleteItems(offsets: offsets, clearEnkaCache: false)
    }

    private func deleteItems(offsets: IndexSet, clearEnkaCache: Bool) {
        withAnimation {
            var idsToDrop: [(String, Pizza.SupportedGame)] = []
            offsets.map {
                let returned = profiles[$0]
                idsToDrop.append((returned.uid, returned.game))
                return returned
            }.forEach(modelContext.delete)

            defer {
                if clearEnkaCache {
                    // 特殊处理：当且仅当当前删掉的帐号不是重复的本地帐号的时候，才清空展柜缓存。
                    let remainingUIDs = profiles.map(\.uid)
                    idsToDrop.forEach { currentUID, currentGame in
                        if !remainingUIDs.contains(currentUID) {
                            switch currentGame {
                            case .genshinImpact: Defaults[.queriedEnkaProfiles4GI].removeValue(forKey: currentUID)
                            case .starRail: Defaults[.queriedEnkaProfiles4HSR].removeValue(forKey: currentUID)
                            }
                        }
                    }
                }
            }

            for index in offsets {
                modelContext.delete(profiles[index])
            }
        }
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

    private func importLegacyData() {
        withAnimation {
            isBusy = true
            do {
                try PersistenceController.migrateOldAccountsIntoProfiles()
            } catch {
                errorMessage = error.localizedDescription
            }
            isBusy = false
        }
    }

    private func bleachInvalidProfiles() {
        profiles.filter(\.isInvalid).forEach { profile in
            modelContext.delete(profile)
            try? modelContext.save()
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
            case let .createNewProfile(profile):
                return profile.uuid
            case let .editExistingProfile(profile):
                return profile.uuid
            }
        }
    }
}
