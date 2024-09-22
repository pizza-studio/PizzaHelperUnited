// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import GachaKit
import PZAccountKit
import SwiftData

public enum PZHelper {
    public static let sharedContainer: ModelContainer = {
        let result = try! ModelContainer(
            for: PZProfileMO.self, PZGachaEntryMO.self, PZGachaProfileMO.self,
            configurations: PZProfileActor.modelConfig, GachaActor.modelConfig4Profiles, GachaActor.modelConfig4Entries
        )
        return result
    }()
}
