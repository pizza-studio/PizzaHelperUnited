// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SwiftUI

extension ProfileManagerPageContent {
    struct CreateProfileSheetView: View {
        // MARK: Lifecycle

        init(profile: PZProfileMO, isShown: Binding<Bool>) {
            self._isShown = isShown
            self.profile = profile
        }

        // MARK: Internal

        var body: some View {
            // TODO: 现在这个 View 只是临时用的，回头整个 View 都要重写。
            NavigationStack {
                Form {
                    ProfileConfigViewContents(profile: profile)
                }.formStyle(.grouped)
                    .navigationTitle("profileMgr.new".i18nPZHelper)
                    .navigationBarTitleDisplayMode(.large)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("sys.done".i18nBaseKit) {
                                do {
                                    withAnimation {
                                        modelContext.insert(profile)
                                    }
                                    try modelContext.save()
                                    isShown.toggle()
                                    // try await HSRNotificationCenter.requestAuthorization() // TODO:
                                    // WidgetCenter.shared.reloadAllTimelines() // TODO:
                                    // globalDailyNoteCardRefreshSubject.send(()) // TODO:
                                    alertToastEventStatus.isDoneButtonTapped.toggle()
                                } catch {
                                    saveProfileError = .saveDataError(error)
                                    isSaveProfileFailAlertShown.toggle()
                                }
                            }.disabled(profile.isInvalid)
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
