// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZBaseKit
import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaProfileManagementView: View {
    // MARK: Public

    public static let navTitle = "gachaKit.management.navTitle".i18nGachaKit

    public var body: some View {
        NavigationStack {
            Form {
                if theVM.hasGPID.wrappedValue {
                    Section {
                        LabeledContent {
                            GachaProfileSwitcherView()
                                .fixedSize()
                                .environment(theVM)
                        } label: {
                            Text("gachaKit.management.uidAndGameToPurge", bundle: .module)
                        }
                        if theVM.taskState == .busy {
                            InfiniteProgressBar().id(UUID())
                        }
                    } header: {
                        if let gpid = theVM.currentGPID {
                            HStack {
                                Text("gachaKit.management.currentGame", bundle: .module)
                                Spacer()
                                Text(verbatim: gpid.game.localizedDescription)
                            }
                            .textCase(.none)
                        }
                    }
                    if theVM.taskState != .busy {
                        Button(role: .destructive) {
                            isRemovalConfirmationAlertShown = true
                        } label: {
                            Text("gachaKit.management.clickHereToDeleteAllRecordsOfThisGPID", bundle: .module)
                                .fontWidth(.condensed)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        .buttonStyle(.borderedProminent)
                        .buttonBorderShape(.capsule)
                        .tint(.red)
                        .listRowInsets(.init())
                        .listRowBackground(Color.clear)
                    }
                } else {
                    Text("gachaKit.prompt.noGachaProfileFound", bundle: .module)
                }
            }
            .navigationTitle(Self.navTitle)
            .disabled(theVM.taskState == .busy)
            .saturation(theVM.taskState == .busy ? 0 : 1)
            .navigationBarBackButtonHidden(theVM.taskState == .busy)
            .animation(.default, value: theVM.taskState)
            .onChange(of: theVM.hasGPID.wrappedValue) { _, newValue in
                if !newValue {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .toolbar {
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .confirmationAction) {
                        ProgressView()
                    }
                }
            }
            .alert(
                "gachaKit.management.confirmingDeletingAllRecordsOfThisGPID".i18nGachaKit,
                isPresented: $isRemovalConfirmationAlertShown
            ) {
                Button("sys.cancel".i18nBaseKit, role: .cancel) {
                    isRemovalConfirmationAlertShown = false
                }
                Button("sys.proceed".i18nBaseKit, role: .destructive) {
                    if let gpid = theVM.currentGPID {
                        theVM.deleteAllEntriesOfGPID(gpid)
                    }
                    theVM.updateMappedEntriesByPools(immediately: false)
                    theVM.resetDefaultProfile()
                }
            }
        }
    }

    // MARK: Private

    @State private var isRemovalConfirmationAlertShown: Bool = false
    @Environment(GachaVM.self) private var theVM
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
}
