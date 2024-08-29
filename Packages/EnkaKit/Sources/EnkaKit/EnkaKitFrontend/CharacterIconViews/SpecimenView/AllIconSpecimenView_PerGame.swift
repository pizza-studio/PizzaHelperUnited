// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import EnkaDBModels
import PZBaseKit
import SwiftUI

// MARK: - CharSpecimen

public struct CharSpecimen: Identifiable, Hashable {
    // MARK: Public

    public let id: String

    @ViewBuilder @MainActor
    public static func renderAllSpecimen(
        for game: Enka.GameType?,
        scroll: Bool,
        columns: Int,
        size: Double,
        cutType: IDPhotoView4HSR.IconType = .cutShoulder,
        animation: Namespace.ID,
        supplementalIDs: (() -> [String])? = nil
    )
        -> some View {
        let specimens = Self.allSpecimens(for: game, supplementalIDs: supplementalIDs?())
        let inner = StaggeredGrid(
            columns: columns, outerPadding: false, scroll: scroll, list: specimens
        ) { specimen in
            specimen.render(size: size, cutType: cutType)
                .matchedGeometryEffect(id: specimen.id, in: animation)
        }
        if scroll {
            ScrollView {
                inner.padding()
            }
        } else {
            inner
        }
    }

    @ViewBuilder @MainActor
    public func render(size: Double, cutType: IDPhotoView4HSR.IconType = .cutShoulder) -> some View {
        if id.count == 4 {
            if let first = IDPhotoView4HSR(pid: id, size, cutType, forceRender: true) {
                first
            } else {
                IDPhotoFallbackView4HSR(pid: id, size, cutType)
            }
        } else {
            CharacterIconView(charID: id, size: size)
        }
    }

    // MARK: Internal

    static func allSpecimens(for game: Enka.GameType?, supplementalIDs: [String]? = nil) -> [Self] {
        var ids: [String] = []
        switch game {
        case .genshinImpact:
            let filtered: [[String]] = Enka.Sputnik.shared.db4GI.characters.compactMap { charID, char in
                // Drop duplicated anemo protagonist.
                if Protagonist(rawValue: Int(charID.prefix(8).description) ?? -114_514) != nil {
                    guard charID.count != 8 else { return nil }
                }
                let costume: (String, EnkaDBModelsGI.Costume)? = char.costumes?.first { _, costume in
                    !costume.icon.contains("CostumeWic")
                }
                var returnable = [charID]
                if let costume {
                    returnable.append("\(charID)_\(costume.0)")
                }
                return returnable
            }
            ids = filtered.reduce([], +)
        case .starRail:
            ids = Enka.Sputnik.shared.db4HSR.characters.keys.sorted()
        case .zenlessZone: break // 临时设定。
        case .none: break
        }
        ids += (supplementalIDs ?? [])
        return Set<String>(ids).sorted().map { Self(id: $0) }
    }
}

// MARK: - AllCharacterPhotoSpecimenViewPerGame

public struct AllCharacterPhotoSpecimenViewPerGame: View {
    // MARK: Lifecycle

    public init(
        for game: Enka.GameType,
        scroll: Bool = true,
        supplementalIDs: (() -> [String])? = nil
    ) {
        self.scroll = scroll
        self.supplementalIDs = supplementalIDs?() ?? []
        self.game = game
    }

    // MARK: Public

    @MainActor public var body: some View {
        coreBodyView.overlay {
            GeometryReader { geometry in
                Color.clear.onAppear {
                    containerSize = geometry.size
                }.onChange(of: geometry.size) { _, newSize in
                    containerSize = newSize
                }
            }
        }
    }

    // MARK: Internal

    @Namespace var animation: Namespace.ID

    @State var containerSize: CGSize = .init(width: 320, height: 320)

    @State var scroll: Bool

    var columns: Int {
        max(Int(($containerSize.wrappedValue.width / 120).rounded(.down)), 1)
    }

    var singleSize: Double {
        (($containerSize.wrappedValue.width / Double(columns)) - 8.0).rounded(.down)
    }

    @MainActor @ViewBuilder var coreBodyView: some View {
        CharSpecimen.renderAllSpecimen(
            for: game,
            scroll: scroll,
            columns: columns,
            size: singleSize,
            cutType: .cutShoulder,
            animation: animation
        ) {
            supplementalIDs
        }
        .animation(.easeInOut, value: columns)
        .environment(orientation)
    }

    // MARK: Private

    @State private var game: Enka.GameType
    @State private var supplementalIDs: [String]
    @State private var orientation = DeviceOrientation()
}

#if DEBUG

struct CharacterPhotoSpecimenViewPerGame_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            List {
                TabView {
                    AllCharacterPhotoSpecimenViewPerGame(for: .starRail, scroll: false) {
                        ["1218", "1221", "1224"]
                    }.tabItem { Text(verbatim: "HSR") }
                    AllCharacterPhotoSpecimenViewPerGame(for: .genshinImpact, scroll: false)
                        .tabItem { Text(verbatim: "GI") }
                }
            }
        }
        .frame(height: 600)
    }
}

#endif
