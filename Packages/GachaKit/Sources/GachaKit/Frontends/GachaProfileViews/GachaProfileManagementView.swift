// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
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
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        } label: {
                            Text("gachaKit.management.gachaPullerToPurge", bundle: .currentSPM)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        if theVM.taskState == .busy {
                            InfiniteProgressBar().id(UUID())
                        }
                    } header: {
                        if let gpid = theVM.currentGPID {
                            HStack {
                                Text("gachaKit.management.currentGame", bundle: .currentSPM)
                                Spacer()
                                Text(verbatim: gpid.game.localizedDescription)
                            }
                            .textCase(.none)
                        }
                    } footer: {
                        if let gpid = theVM.currentGPID {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Image(systemSymbol: .tray2Fill)
                                    .foregroundStyle(.secondary)
                                Text(totalEntriesSummary(for: gpid))
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.leading)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    if theVM.taskState != .busy {
                        Button(role: .destructive) {
                            isRemovalConfirmationAlertShown = true
                        } label: {
                            Text("gachaKit.management.clickHereToDeleteAllRecordsOfThisGPID", bundle: .currentSPM)
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
                    Text("gachaKit.prompt.noGachaProfileFound", bundle: .currentSPM)
                }
            }
            .formStyle(.grouped).disableFocusable()
            .navigationTitle(Self.navTitle)
            .saturation(theVM.taskState == .busy ? 0 : 1)
            .disabled(theVM.taskState == .busy)
            .navigationBarBackButtonHidden(theVM.taskState == .busy)
            .animation(.default, value: theVM.taskState)
            .react(to: theVM.hasGPID.wrappedValue) { _, newValue in
                if !newValue {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .toolbar {
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .primaryAction) {
                        WinUI3ProgressRing()
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
    @State private var theVM: GachaVM = .shared
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>

    private var totalEntriesCount: Int {
        theVM.mappedEntriesByPools.values.reduce(into: 0) { partialResult, entries in
            partialResult += entries.count
        }
    }

    private func totalEntriesSummary(for gpid: GachaProfileID) -> String {
        let format = "gachaKit.management.totalLocalEntriesFootnote".i18nGachaKit
        return String(
            format: format,
            locale: Locale.current,
            gpid.uid,
            gpid.game.localizedShortName,
            totalEntriesCount
        )
    }
}
