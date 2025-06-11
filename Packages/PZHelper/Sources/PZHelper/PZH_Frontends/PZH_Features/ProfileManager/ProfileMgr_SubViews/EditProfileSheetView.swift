// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileManagerPageContent.EditProfileSheetView

extension ProfileManagerPageContent {
    struct EditProfileSheetView: View {
        // MARK: Lifecycle

        init(profile: PZProfileMO, sheetType: Binding<SheetType?>) {
            self._sheetType = sheetType
            self._profile = State(wrappedValue: profile)
        }

        // MARK: Internal

        var body: some View {
            NavigationStack {
                Form {
                    ProfileConfigViewContents(profile: profile)
                }
                .disabled(theVM.taskState == .busy)
                .saturation(theVM.taskState == .busy ? 0 : 1)
                .formStyle(.grouped)
                .navigationTitle("profileMgr.edit.title".i18nPZHelper)
                .navBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("sys.done".i18nBaseKit) {
                            saveButtonDidTap()
                        }
                        .disabled(theVM.taskState == .busy)
                        .saturation(theVM.taskState == .busy ? 0 : 1)
                    }
                    ToolbarItem(placement: .cancellationAction) {
                        Button("sys.cancel".i18nBaseKit) {
                            theVM.discardUncommittedChanges()
                            sheetType = nil
                        }
                    }
                }
            }
        }

        // MARK: Private

        @Binding private var sheetType: SheetType?
        @State private var profile: PZProfileMO
        @State private var isSaveProfileFailAlertShown: Bool = false
        @State private var saveProfileError: SaveProfileError?
        @StateObject private var theVM: ProfileManagerVM = .shared
        @Environment(AlertToastEventStatus.self) private var alertToastEventStatus

        private func saveButtonDidTap() {
            if theVM.hasUncommittedChanges {
                theVM.updateProfile(
                    profile.asSendable,
                    trailingTasks: {
                        PZNotificationCenter.bleachNotificationsIfDisabled(for: profile.asSendable)
                        sheetType = nil
                        Broadcaster.shared.requireOSNotificationCenterAuthorization()
                        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                        alertToastEventStatus.isProfileTaskSucceeded.toggle()
                    },
                    errorHandler: { error in
                        saveProfileError = .saveDataError(error)
                        isSaveProfileFailAlertShown.toggle()
                    }
                )
            } else {
                sheetType = nil
                alertToastEventStatus.isProfileTaskSucceeded.toggle()
            }
        }
    }
}
