// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

@preconcurrency import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileManagerPageContent.EditProfileSheetView

extension ProfileManagerPageContent {
    struct EditProfileSheetView: View {
        // MARK: Lifecycle

        init(profile: PZProfileMO, isShown: Binding<Bool>) {
            self._isShown = isShown
            self.profile = profile
        }

        // MARK: Internal

        var body: some View {
            NavigationStack {
                Form {
                    ProfileConfigViewContents(profile: profile)
                }.formStyle(.grouped)
                    .navigationTitle("profileMgr.edit.title".i18nPZHelper)
                    .navBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("sys.done".i18nBaseKit) {
                                if modelContext.hasChanges {
                                    do {
                                        try modelContext.save()
                                        PZNotificationCenter.bleachNotificationsIfDisabled(for: profile.asSendable)
                                        Defaults[.pzProfiles][profile.uuid.uuidString] = profile.asSendable
                                        UserDefaults.profileSuite.synchronize()
                                        isShown.toggle()
                                        Broadcaster.shared.requireOSNotificationCenterAuthorization()
                                        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                                        alertToastEventStatus.isProfileTaskSucceeded.toggle()
                                    } catch {
                                        saveProfileError = .saveDataError(error)
                                        isSaveProfileFailAlertShown.toggle()
                                    }
                                } else {
                                    isShown.toggle()
                                    alertToastEventStatus.isProfileTaskSucceeded.toggle()
                                }
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("sys.cancel".i18nBaseKit) {
                                modelContext.rollback()
                                isShown.toggle()
                            }
                        }
                    }
            }
        }

        // MARK: Private

        @Binding private var isShown: Bool
        @State private var profile: PZProfileMO
        @State private var isSaveProfileFailAlertShown: Bool = false
        @State private var saveProfileError: SaveProfileError?
        @Environment(\.modelContext) private var modelContext
        @Environment(AlertToastEventStatus.self) private var alertToastEventStatus
    }
}
