// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import PZAccountKit
import PZBaseKit
import SFSafeSymbols
import SwiftData
import SwiftUI

public struct GachaProfileSwitcherView: View {
    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    @MainActor public var body: some View {
        profileSwitcherMenu()
            .saturation(theVM.taskState == .busy ? 0 : 1)
            .disabled(theVM.taskState == .busy || !theVM.hasGPID.wrappedValue)
            .onAppear {
                // rebuildGachaUIDList() // 需額外評估是否就這樣砍掉這一行。
                if theVM.currentGPID == nil {
                    theVM.resetDefaultProfile()
                } else if let profile = theVM.currentGPID, !sortedGPIDs.contains(profile) {
                    theVM.currentGPID = nil
                }
            }
    }

    // MARK: Internal

    @MainActor @ViewBuilder var profileSwitcherMenuLabel: some View {
        LabeledContent {
            let dimension: CGFloat = 30
            Group {
                if let profile = theVM.currentGPID {
                    profile.photoView.frame(width: dimension)
                } else {
                    Image(systemSymbol: .personCircleFill)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: dimension - 8)
                        .foregroundStyle(Color.accentColor)
                }
            }
            .background {
                // Compiler optimization.
                AnyView(erasing: {
                    Circle()
                        .strokeBorder(Color.accentColor, lineWidth: 8)
                        .frame(width: dimension, height: dimension)
                }())
            }
            .frame(width: dimension, height: dimension)
            .clipShape(.circle)
            .compositingGroup()
        } label: {
            if let profile = theVM.currentGPID {
                Text(profile.uidWithGame).monospacedDigit()
            } else {
                Text("gachaKit.gachaProfileMenu.chooseProfile".i18nGachaKit)
            }
        }
        .padding(4).padding(.leading, 12)
        .blurMaterialBackground()
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @MainActor @ViewBuilder
    func profileSwitcherMenu() -> some View {
        let nameIDMap = theVM.nameIDMap
        if !sortedGPIDs.isEmpty {
            Menu {
                ForEach(sortedGPIDs) { profileIDObj in
                    Button {
                        withAnimation {
                            theVM.currentGPID = profileIDObj
                        }
                    } label: {
                        Label {
                            if let name = nameIDMap[profileIDObj.uidWithGame] {
                                #if targetEnvironment(macCatalyst)
                                Text(name + " // \(profileIDObj.uidWithGame)")
                                #else
                                Text(name + "\n\(profileIDObj.uidWithGame)")
                                #endif
                            } else {
                                Text(profileIDObj.uidWithGame)
                            }
                        } icon: {
                            profileIDObj.photoView
                        }
                        .id(profileIDObj.uidWithGame)
                    }
                }
            } label: {
                profileSwitcherMenuLabel
            }
        }
    }

    // MARK: Fileprivate

    @Query(sort: \PZProfileMO.priority) fileprivate var pzProfiles: [PZProfileMO]
    @Environment(\.modelContext) fileprivate var modelContext
    @Environment(GachaVM.self) fileprivate var theVM

    fileprivate var sortedGPIDs: [GachaProfileID] {
        theVM.allGPIDs.wrappedValue
    }
}
