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
                        sheetType = .editExistingProfile(profile)
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(profile.name)
                                    .foregroundColor(.primary)
                                HStack {
                                    Text(profile.uidWithGame).fontDesign(.monospaced)
                                    Text(profile.serverRawValue) // TODO: Needs fix later.
                                }
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemSymbol: .sliderHorizontal3)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
                if profiles.isEmpty {
                    Button("profileMgr.importLegacyProfiles.title".i18nPZHelper) {
                        importLegacyData()
                    }
                }
            }
        }
        .navigationTitle("profileMgr.manage.title".i18nPZHelper)
        .navigationBarTitleDisplayMode(.large)
        .sheet(item: $sheetType, content: { type in
            switch type {
            case let .createNewProfile(newProfile):
                CreateProfileSheetView(profile: newProfile, isShown: isSheetShown)
            case let .editExistingProfile(profile):
                EditProfileSheetView(profile: profile, isShown: isSheetShown)
            }
        })
        .onAppear {
            profiles.filter(\.isInvalid).forEach { profile in
                modelContext.delete(profile)
                try? modelContext.save()
            }
        }
        .toolbar {
            EditButton()
        }
        .toast(isPresenting: $alertToastEventStatus.isDoneButtonTapped) {
            AlertToast(
                displayMode: .alert,
                type: .complete(.green),
                title: "profileMgr.added.succeeded".i18nPZHelper
            )
        }
        .environment(alertToastEventStatus)
    }

    // MARK: Private

    @State private var sheetType: SheetType?
    @State private var alertToastEventStatus = AlertToastEventStatus()
    @State private var isBusy = false
    @State private var errorMessage: String?
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \PZProfileMO.priority) private var profiles: [PZProfileMO]

    private var isSheetShown: Binding<Bool> {
        .init {
            sheetType != nil
        } set: { newValue in
            if !newValue { sheetType = nil }
        }
    }

    private func addProfile(_ profile: PZProfileMO) {
        withAnimation {
            modelContext.insert(profile)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            var idsToDrop: [(String, Pizza.SupportedGame)] = []
            offsets.map {
                let returned = profiles[$0]
                idsToDrop.append((returned.uid, returned.game))
                return returned
            }.forEach(modelContext.delete)

            defer {
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
}

extension ProfileManagerPageContent {
    @Observable
    fileprivate class AlertToastEventStatus {
        var isDoneButtonTapped = false
        var isLoginSucceeded = false
    }

    enum SheetType: Identifiable {
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
