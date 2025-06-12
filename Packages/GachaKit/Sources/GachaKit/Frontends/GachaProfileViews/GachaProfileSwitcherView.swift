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

    public var body: some View {
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

    @ViewBuilder var profileSwitcherMenuLabel: some View {
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
                Text(profile.uidWithGame).fontWidth(.condensed)
            } else {
                Text("gachaKit.gachaProfileMenu.chooseProfile", bundle: .module)
            }
        }
        .padding(4).padding(.leading, 12)
        .blurMaterialBackground(enabled: true) // 在正中心位置时，不是玻璃按钮，所以始终启用。
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    func profileSwitcherMenu() -> some View {
        let allGPIDsNested = sortedGPIDsNested
        if !allGPIDsNested.isEmpty {
            let nameIDMap = theVM.nameIDMap
            Menu {
                ForEach(allGPIDsNested, id: \.offset) { sortedSubGPIDPair in
                    if let sortedSubGPIDs = sortedSubGPIDPair.element {
                        ForEach(sortedSubGPIDs) { profileIDObj in
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
                    } else {
                        Divider()
                    }
                }
            } label: {
                profileSwitcherMenuLabel
            }
        }
    }

    // MARK: Private

    @Environment(GachaVM.self) private var theVM

    private var sortedGPIDsNested: [EnumeratedSequence<[[GachaProfileID]?]>.Element] {
        let allGPIDs = sortedGPIDs
        guard !allGPIDs.isEmpty else { return [] }
        let giGPIDs = allGPIDs.filter { $0.game == .genshinImpact }
        let hsrGPIDs = allGPIDs.filter { $0.game == .starRail }
        let zzzGPIDs = allGPIDs.filter { $0.game == .zenlessZone }
        var allGPIDsNested: [[GachaProfileID]?] = [giGPIDs, nil, hsrGPIDs, nil, zzzGPIDs].filter {
            if let core = $0 {
                return !core.isEmpty
            }
            return true
        }
        if !allGPIDsNested.isEmpty, allGPIDsNested.first == nil { allGPIDsNested.removeFirst() }
        if !allGPIDsNested.isEmpty, allGPIDsNested.last == nil { allGPIDsNested.removeLast() }
        return Array(allGPIDsNested.enumerated())
    }

    private var sortedGPIDs: [GachaProfileID] {
        theVM.allGPIDs
    }
}
