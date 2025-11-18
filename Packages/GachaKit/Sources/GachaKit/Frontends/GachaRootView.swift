// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AlertToast
import EnkaKit
import PZAccountKit
import PZBaseKit
import SwiftUI

// MARK: - GachaRootView

@available(iOS 17.0, macCatalyst 17.0, *)
public struct GachaRootView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    public static let navTitle: String = "gachaKit.GachaRootView.navTitle".i18nGachaKit
    public static let navDescription: String = "gachaKit.GachaRootView.navDescription".i18nGachaKit

    @MainActor public static var getFAQView: (() -> AnyView)?

    public static var navIcon: Image { Image("GachaRecordMgr_NavIcon", bundle: .module) }

    public var body: some View {
        coreBody
            .navigationTitle(theVM.currentGPIDTitle ?? Self.navTitle)
            .navBarTitleDisplayMode(.large)
            // 保证用户只能在结束编辑、关掉该画面之后才能切到别的 Tab。
            .appTabBarVisibility(.hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    GachaProfileSwitcherView()
                        .environment(theVM)
                }
                if theVM.taskState == .busy {
                    ToolbarItem(placement: .primaryAction) {
                        ProgressView()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    GachaExportToolbarButton(gpid: theVM.currentGPID)?
                        .environment(theVM)
                        .disabled(theVM.taskState == .busy)
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Menu {
                            ForEach(Pizza.SupportedGame.allCases) { game in
                                NavigationLink(game.localizedDescription) {
                                    GachaFetchView(for: game)
                                }.disabled(game == .zenlessZone)
                            }
                        } label: {
                            Label(
                                GachaFetchView.navTitle,
                                systemSymbol: .squareAndArrowDownOnSquare
                            )
                        }
                        NavigationLink {
                            GachaProfileManagementView()
                                .environment(theVM)
                        } label: {
                            Label(
                                GachaProfileManagementView.navTitle,
                                systemSymbol: .tray2
                            )
                        }
                        NavigationLink {
                            GachaExchangeView()
                                .environment(theVM)
                        } label: {
                            Label(
                                "gachaKit.menu.exchangeGachaRecords".i18nGachaKit,
                                systemSymbol: .externaldriveFillBadgeWifi
                            )
                        }
                        Divider()
                        if FileManager.default.ubiquityIdentityToken != nil {
                            NavigationLink {
                                CDGachaMODebugView()
                            } label: {
                                Label(
                                    "gachaKit.menu.listCloudDataFromPreviousVersions".i18nGachaKit,
                                    systemSymbol: .externaldriveBadgeIcloud
                                )
                            }
                            if theVM.hasInheritableGachaEntries {
                                Button {
                                    theVM.migrateOldGachasIntoProfiles()
                                } label: {
                                    Label(
                                        "gachaKit.menu.inheritCloudDataFromPreviousVersions".i18nGachaKit,
                                        systemSymbol: .icloudAndArrowDown
                                    )
                                }
                            }
                        }
                        Divider()
                        Button {
                            let backendChangesAvailable = theVM.backendChangesAvailable
                            theVM.rebuildGachaUIDList()
                            if backendChangesAvailable {
                                theVM.updateMappedEntriesByPools(immediately: false)
                            }
                        } label: {
                            Label(
                                "gachaKit.menu.reloadData".i18nGachaKit,
                                systemSymbol: .gearshapeArrowTriangle2Circlepath
                            )
                        }
                    } label: {
                        Image(systemSymbol: .filemenuAndSelection)
                            .overlay(alignment: .topLeading) {
                                if theVM.backendChangesAvailable {
                                    Circle().fill(.red).frame(width: 4, height: 4)
                                }
                            }
                    }
                    .disabled(theVM.taskState == .busy)
                }
            }
            .task {
                if let task = theVM.task { await task.value }
                if !theVM.hasInheritableGachaEntries {
                    theVM.checkWhetherInheritableDataExists()
                }
            }
            .environment(theVM)
            .apply { mainContent in
                @Bindable var theVM = theVM
                mainContent
                    .toast(isPresenting: $theVM.showSucceededAlertToast) {
                        AlertToast(
                            displayMode: .alert,
                            type: .complete(.green),
                            title: "gachaKit.alertToast.succeeded".i18nGachaKit
                        )
                    }
            }
    }

    // MARK: Private

    @Environment(GachaVM.self) private var theVM
}

@available(iOS 17.0, macCatalyst 17.0, *)
extension GachaRootView {
    @ViewBuilder public var coreBody: some View {
        Form {
            if theVM.backendChangesAvailable {
                Text(
                    "gachaKit.prompt.remoteChangesDetected.withRecommendedAction",
                    bundle: .module
                )
                .font(.caption)
                .fontWeight(.medium)
                .fontWidth(.condensed)
            }
            if theVM.currentGPID != nil {
                GachaProfileView()
            } else if !theVM.hasGPID.wrappedValue {
                Text("gachaKit.prompt.pleaseChooseGachaPuller", bundle: .module)
            } else {
                Text("gachaKit.prompt.noGachaProfileFound", bundle: .module)
            }
        }
        .formStyle(.grouped).disableFocusable()
    }
}
