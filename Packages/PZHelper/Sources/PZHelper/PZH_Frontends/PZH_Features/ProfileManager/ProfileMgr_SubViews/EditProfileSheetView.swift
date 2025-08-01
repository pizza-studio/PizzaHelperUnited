// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileManagerPageContent.EditProfileSheetView

@available(iOS 16.2, macCatalyst 16.2, *)
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
            NavigationStack {
                Form {
                    ProfileConfigViewContents(profile: profile)
                }
                .formStyle(.grouped).disableFocusable()
                .disabled(theVM.taskState == .busy)
                .saturation(theVM.taskState == .busy ? 0 : 1)
                .navigationTitle("profileMgr.edit.title".i18nPZHelper)
                // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
                .appTabBarVisibility(.hidden)
                // 逼着用户改用自订的后退按钮。
                // 这也防止 iPhone / iPad 用户以横扫手势将当前画面失手关掉。
                // 当且仅当用户点了后退按钮或完成按钮，这个画面才会关闭。
                .navigationBarBackButtonHidden(true)
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
                            isVisible.toggle()
                        }
                    }
                }
                .react(to: isVisible) { _, newValue in
                    if Self.isOS25OrNewer, !newValue { presentationMode.wrappedValue.dismiss() }
                }
            }
        }

        // MARK: Private

        private static var isOS25OrNewer: Bool {
            if #available(iOS 18.0, macCatalyst 18.0, macOS 15.0, *) { return true }
            return false
        }

        @StateObject private var profile: PZProfileRef
        @State private var isSaveProfileFailAlertShown: Bool = false
        @State private var saveProfileError: SaveProfileError?
        @StateObject private var theVM: ProfileManagerVM = .shared
        @Binding private var isVisible: Bool
        @EnvironmentObject private var alertToastEventStatus: AlertToastEventStatus
        @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

        private let profileBeforeEdit: PZProfileSendable

        private func saveButtonDidTap() {
            if profileBeforeEdit.hashValue != profile.asSendable.hashValue {
                theVM.updateProfile(
                    profile.asSendable,
                    trailingTasks: {
                        PZNotificationCenter.bleachNotificationsIfDisabled(for: profile.asSendable)
                        isVisible.toggle() // 该行为必须发生在 trailingTasks (completionHandler) 内！！！
                        alertToastEventStatus.isProfileTaskSucceeded.toggle()
                    },
                    errorHandler: { error in
                        saveProfileError = .saveDataError(error)
                        isSaveProfileFailAlertShown.toggle()
                    }
                )
            } else {
                isVisible.toggle()
                alertToastEventStatus.isProfileTaskSucceeded.toggle()
            }
        }
    }
}
