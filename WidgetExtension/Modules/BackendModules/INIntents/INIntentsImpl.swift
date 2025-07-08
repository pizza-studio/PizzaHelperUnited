// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import Foundation
import Intents
import PZWidgetsKit

// MARK: - SelectAccountIntentOLD

@available(iOS 16.2, macCatalyst 16.2, *)
@objc(SelectAccountIntent)
public class SelectAccountIntentOLD: INSelectAccount, AppIntentUpgradable { // SelectAccountIntent
    public typealias AppIntent = PZDesktopIntent4SingleProfile

    public var asAppIntent: AppIntent {
        let result = PZDesktopIntent4SingleProfile()
        if let slot1 = accountIntent, let slotID = slot1.identifier {
            result.accountIntent = .init(
                id: slotID, displayString: slot1.displayString
            )
        }
        // 剩下的都相同
        result.showStaminaOnly = showStaminaOnly?.boolValue ?? result.showStaminaOnly
        result.useTinyGlassDisplayStyle = useTinyGlassDisplayStyle?.boolValue ?? result.useTinyGlassDisplayStyle
        result.showTransformer = showTransformer?.boolValue ?? result.showTransformer
        result.trounceBlossomDisplayMethod = switch trounceBlossomDisplayMethod {
        case .alwaysShow: .alwaysShow
        case .disappearAfterCompleted: .disappearAfterCompleted
        case .neverShow: .neverShow
        }
        result.echoOfWarDisplayMethod = switch echoOfWarDisplayMethod {
        case .alwaysShow: .alwaysShow
        case .disappearAfterCompleted: .disappearAfterCompleted
        case .neverShow: .neverShow
        }
        result.expeditionDisplayPolicy = switch expeditionDisplayPolicy {
        case .neverDisplay: .neverDisplay
        case .displayWhenAvailable: .displayWhenAvailable
        case .displayExclusively: .displayExclusively
        }
        result.randomBackground = randomBackground?.boolValue ?? result.randomBackground
        result.chosenBackgrounds = chosenBackgrounds?.compactMap {
            guard let netaID = $0.identifier else { return .none }
            return .init(id: netaID, displayString: $0.displayString)
        } ?? []
        result.isDarkModeRespected = isDarkModeRespected?.boolValue ?? result.isDarkModeRespected
        result.showMaterialsInLargeSizeWidget = showMaterialsInLargeSizeWidget?.boolValue ?? result
            .showMaterialsInLargeSizeWidget
        return result
    }
}

// MARK: - SelectDualProfileIntentOLD

@available(iOS 16.2, macCatalyst 16.2, *)
@objc(SelectDualProfileIntent)
public class SelectDualProfileIntentOLD: INSelectDualProfile, AppIntentUpgradable { // SelectDualProfileIntent
    public typealias AppIntent = PZDesktopIntent4DualProfiles

    public var asAppIntent: AppIntent {
        let result = PZDesktopIntent4DualProfiles()
        if let profileSlot1, let slotID = profileSlot1.identifier {
            result.profileSlot1 = .init(
                id: slotID, displayString: profileSlot1.displayString
            )
        }
        if let profileSlot2, let slotID = profileSlot2.identifier {
            result.profileSlot2 = .init(
                id: slotID, displayString: profileSlot2.displayString
            )
        }
        // 剩下的都相同
        result.useTinyGlassDisplayStyle = useTinyGlassDisplayStyle?.boolValue ?? result.useTinyGlassDisplayStyle
        result.showTransformer = showTransformer?.boolValue ?? result.showTransformer
        result.trounceBlossomDisplayMethod = switch trounceBlossomDisplayMethod {
        case .alwaysShow: .alwaysShow
        case .disappearAfterCompleted: .disappearAfterCompleted
        case .neverShow: .neverShow
        }
        result.echoOfWarDisplayMethod = switch echoOfWarDisplayMethod {
        case .alwaysShow: .alwaysShow
        case .disappearAfterCompleted: .disappearAfterCompleted
        case .neverShow: .neverShow
        }
        result.expeditionDisplayPolicy = switch expeditionDisplayPolicy {
        case .neverDisplay: .neverDisplay
        case .displayWhenAvailable: .displayWhenAvailable
        case .displayExclusively: .displayExclusively
        }
        result.randomBackground = randomBackground?.boolValue ?? result.randomBackground
        result.chosenBackgrounds = chosenBackgrounds?.compactMap {
            guard let netaID = $0.identifier else { return .none }
            return .init(id: netaID, displayString: $0.displayString)
        } ?? []
        result.isDarkModeRespected = isDarkModeRespected?.boolValue ?? result.isDarkModeRespected
        return result
    }
}

// MARK: - SelectOnlyAccountIntentOLD

@available(iOS 16.2, macCatalyst 16.2, *)
@objc(SelectOnlyAccountIntent)
public class SelectOnlyAccountIntentOLD: INSelectOnlyAccount, AppIntentUpgradable { // SelectOnlyAccountIntent
    public typealias AppIntent = PZEmbeddedIntent4ProfileOnly

    public var asAppIntent: AppIntent {
        let result = PZEmbeddedIntent4ProfileOnly()
        if let slot1 = account, let slotID = slot1.identifier {
            result.account = .init(
                id: slotID, displayString: slot1.displayString
            )
        }
        return result
    }
}

// MARK: - SelectAccountAndShowWhichInfoIntentOLD

@available(iOS 16.2, macCatalyst 16.2, *)
@objc(SelectAccountAndShowWhichInfoIntent)
public class SelectAccountAndShowWhichInfoIntentOLD: INSelectAccountAndShowWhichInfo,
    AppIntentUpgradable { // SelectAccountAndShowWhichInfoIntent
    public typealias AppIntent = PZEmbeddedIntent4ProfileMisc

    public var asAppIntent: AppIntent {
        let result = PZEmbeddedIntent4ProfileMisc()
        if let slot1 = account, let slotID = slot1.identifier {
            result.account = .init(
                id: slotID, displayString: slot1.displayString
            )
        }
        result.showEchoOfWar = showEchoOfWar?.boolValue ?? result.showEchoOfWar
        result.showTrounceBlossom = showTrounceBlossom?.boolValue ?? result.showTrounceBlossom
        result.showTransformer = showTransformer?.boolValue ?? result.showTransformer
        result.usingResinStyle = switch usingResinStyle {
        case .default: .byDefault
        case .timer: .timer
        case .time: .time
        case .circle: .roundMeter
        }
        return result
    }
}

// MARK: - SelectOnlyGameIntentOLD

@available(iOS 16.2, macCatalyst 16.2, *)
@objc(SelectOnlyGameIntent)
public class SelectOnlyGameIntentOLD: INSelectOnlyGame, AppIntentUpgradable { // SelectOnlyGameIntent
    public typealias AppIntent = PZDesktopIntent4GameOnly

    public var asAppIntent: AppIntent {
        let result = PZDesktopIntent4GameOnly()
        result.game = switch game {
        case .allGames: .allGames
        case .genshinImpact: .genshinImpact
        case .starRail: .starRail
        case .zenlessZone: .zenlessZone
        }
        return result
    }
}
