// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import PZAccountKit

public typealias GachaLanguage = HoYo.APILang

@available(iOS 17.0, macCatalyst 17.0, macOS 14.0, *)
extension Locale {
    /// Get the language code used for gacha API according to current preferred localization.
    public static var gachaLangauge: GachaLanguage { .current }
}
