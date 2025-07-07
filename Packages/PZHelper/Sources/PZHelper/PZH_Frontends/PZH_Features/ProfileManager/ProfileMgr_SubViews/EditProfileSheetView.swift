// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Defaults
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - ProfileManagerPageContent.EditProfileSheetView

@available(iOS 17.0, macCatalyst 17.0, *)
extension ProfileManagerPageContent {
    struct EditProfileSheetView: View {
        // MARK: Lifecycle

        init(profile: PZProfileRef) {
            self._profile = .init(wrappedValue: profile)
            Task { @MainActor in
                ProfileManagerVM.shared.sheetType = .editExistingProfile(profile)
            }
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
                            theVM.discardUncommittedChanges()
                            theVM.sheetType = nil
                        }
                    }
                }
                .onChange(of: theVM.sheetType) { oldValue, newValue in
                    if oldValue != nil, newValue == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }

        // MARK: Private

        @StateObject private var profile: PZProfileRef
        @State private var isSaveProfileFailAlertShown: Bool = false
        @State private var saveProfileError: SaveProfileError?
        @State private var theVM: ProfileManagerVM = .shared
        @Environment(AlertToastEventStatus.self) private var alertToastEventStatus
        @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

        private func saveButtonDidTap() {
            if theVM.hasUncommittedChanges {
                theVM.updateProfile(
                    profile.asSendable,
                    trailingTasks: {
                        PZNotificationCenter.bleachNotificationsIfDisabled(for: profile.asSendable)
                        theVM.sheetType = nil
                        alertToastEventStatus.isProfileTaskSucceeded.toggle()
                    },
                    errorHandler: { error in
                        saveProfileError = .saveDataError(error)
                        isSaveProfileFailAlertShown.toggle()
                    }
                )
            } else {
                theVM.sheetType = nil
                alertToastEventStatus.isProfileTaskSucceeded.toggle()
            }
        }
    }
}
