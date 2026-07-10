// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileManagerPageContent.EditProfileSheetView

@available(iOS 17.0, macCatalyst 17.0, *)
extension ProfileManagerPageContent {
    struct EditProfileSheetView: View {
        // MARK: Lifecycle

        init(profile: PZProfileRef, isVisible: Binding<Bool>) {
            self._profile = .init(wrappedValue: profile)
            self.profileBeforeEdit = profile.asSendable
            self._isVisible = isVisible
            if Self.isOS25OrNewer {
                Task { @MainActor in
                    ProfileManagerVM.shared.sheetType = .editExistingProfile(profile)
                }
            }
        }

        // MARK: Internal

        var body: some View {
            Form {
                ProfileConfigViewContents(profile: profile)
            }
            .formStyle(.grouped).disableFocusable()
            .saturation(theVM.taskState == .busy ? 0 : 1)
            .disabled(theVM.taskState == .busy)
            .navigationTitle("profileMgr.edit.title".i18nPZHelper)
            .appTabBarVisibility(.hidden)
            .navigationBarBackButtonHidden(true)
            .navBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("sys.done".i18nBaseKit) {
                        saveButtonDidTap()
                    }
                    .saturation(theVM.taskState == .busy ? 0 : 1)
                    .disabled(theVM.taskState == .busy)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("sys.cancel".i18nBaseKit) {
                        isVisible.toggle()
                        dismiss()
                    }
                }
            }
            .react(to: isVisible) { _, newValue in
                if Self.isOS25OrNewer, !newValue { dismiss() }
            }
        }

        // MARK: Private

        private static var isOS25OrNewer: Bool {
            if #available(iOS 18.0, macCatalyst 18.0, macOS 15.0, *) { return true }
            return false
        }

        @State private var profile: PZProfileRef
        @State private var isSaveProfileFailAlertShown: Bool = false
        @State private var saveProfileError: SaveProfileError?
        @State private var theVM: ProfileManagerVM = .shared
        @Binding private var isVisible: Bool
        @Environment(AlertToastEventStatus.self) private var alertToastEventStatus: AlertToastEventStatus
        @Environment(\.dismiss) private var dismiss: DismissAction

        private let profileBeforeEdit: PZProfileSendable

        private func saveButtonDidTap() {
            if profileBeforeEdit.hashValue != profile.asSendable.hashValue {
                theVM.updateProfile(
                    profile.asSendable,
                    trailingTasks: {
                        PZNotificationCenter.bleachNotificationsIfDisabled(for: profile.asSendable)
                        isVisible.toggle() // 该行为必须发生在 trailingTasks (completionHandler) 内！！！
                        alertToastEventStatus.isProfileTaskSucceeded.toggle()
                        dismiss()
                    },
                    errorHandler: { error in
                        saveProfileError = .saveDataError(error)
                        isSaveProfileFailAlertShown.toggle()
                    }
                )
            } else {
                isVisible.toggle()
                alertToastEventStatus.isProfileTaskSucceeded.toggle()
                dismiss()
            }
        }
    }
}
