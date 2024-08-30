// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

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

        @MainActor var body: some View {
            NavigationStack {
                Form {
                    ProfileConfigViewContents(profile: profile)
                }.formStyle(.grouped)
                    .navigationTitle("profileMgr.edit.title".i18nPZHelper)
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("sys.done".i18nBaseKit) {
                                if modelContext.hasChanges {
                                    do {
                                        try modelContext.save()
                                        isShown.toggle()
                                        Broadcaster.shared.requireOSNotificationCenterAuthorization()
                                        Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()
                                        alertToastEventStatus.isDoneButtonTapped.toggle()
                                    } catch {
                                        saveProfileError = .saveDataError(error)
                                        isSaveProfileFailAlertShown.toggle()
                                    }
                                } else {
                                    isShown.toggle()
                                    alertToastEventStatus.isDoneButtonTapped.toggle()
                                }
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
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
