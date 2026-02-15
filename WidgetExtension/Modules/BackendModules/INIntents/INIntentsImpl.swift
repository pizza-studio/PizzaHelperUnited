// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if ENABLE_ININTENTS_BACKPORTS

import Foundation
import Intents
import PZWidgetsKit

// MARK: - SelectAccountIntent + AppIntentUpgradable

@available(iOS 16.2, macCatalyst 16.2, *)
extension SelectAccountIntent: AppIntentUpgradable { // SelectAccountIntent
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
        switch trounceBlossomDisplayMethod {
        case .alwaysShow: result.trounceBlossomDisplayMethod = .alwaysShow
        case .disappearAfterCompleted: result.trounceBlossomDisplayMethod = .disappearAfterCompleted
        case .neverShow: result.trounceBlossomDisplayMethod = .neverShow
        default: break
        }
        switch echoOfWarDisplayMethod {
        case .alwaysShow: result.echoOfWarDisplayMethod = .alwaysShow
        case .disappearAfterCompleted: result.echoOfWarDisplayMethod = .disappearAfterCompleted
        case .neverShow: result.echoOfWarDisplayMethod = .neverShow
        default: break
        }
        switch expeditionDisplayPolicy {
        case .neverDisplay: result.expeditionDisplayPolicy = .neverDisplay
        case .displayWhenAvailable: result.expeditionDisplayPolicy = .displayWhenAvailable
        case .displayExclusively: result.expeditionDisplayPolicy = .displayExclusively
        default: break
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

// MARK: - SelectDualProfileIntent + AppIntentUpgradable

@available(iOS 16.2, macCatalyst 16.2, *)
extension SelectDualProfileIntent: AppIntentUpgradable { // SelectDualProfileIntent
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
        switch trounceBlossomDisplayMethod {
        case .alwaysShow: result.trounceBlossomDisplayMethod = .alwaysShow
        case .disappearAfterCompleted: result.trounceBlossomDisplayMethod = .disappearAfterCompleted
        case .neverShow: result.trounceBlossomDisplayMethod = .neverShow
        default: break
        }
        switch echoOfWarDisplayMethod {
        case .alwaysShow: result.echoOfWarDisplayMethod = .alwaysShow
        case .disappearAfterCompleted: result.echoOfWarDisplayMethod = .disappearAfterCompleted
        case .neverShow: result.echoOfWarDisplayMethod = .neverShow
        default: break
        }
        switch expeditionDisplayPolicy {
        case .neverDisplay: result.expeditionDisplayPolicy = .neverDisplay
        case .displayWhenAvailable: result.expeditionDisplayPolicy = .displayWhenAvailable
        case .displayExclusively: result.expeditionDisplayPolicy = .displayExclusively
        default: break
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

// MARK: - SelectOnlyAccountIntent + AppIntentUpgradable

@available(iOS 16.2, macCatalyst 16.2, *)
extension SelectOnlyAccountIntent: AppIntentUpgradable { // SelectOnlyAccountIntent
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

// MARK: - SelectAccountAndShowWhichInfoIntent + AppIntentUpgradable

@available(iOS 16.2, macCatalyst 16.2, *)
extension SelectAccountAndShowWhichInfoIntent: AppIntentUpgradable { // SelectAccountAndShowWhichInfoIntent
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
        switch usingResinStyle {
        case .byDefault: result.usingResinStyle = .byDefault
        case .timer: result.usingResinStyle = .timer
        case .time: result.usingResinStyle = .time
        case .roundMeter: result.usingResinStyle = .roundMeter
        default: break
        }
        return result
    }
}

// MARK: - SelectOnlyGameIntent + AppIntentUpgradable

@available(iOS 16.2, macCatalyst 16.2, *)
extension SelectOnlyGameIntent: AppIntentUpgradable { // SelectOnlyGameIntent
    public typealias AppIntent = PZDesktopIntent4GameOnly

    public var asAppIntent: AppIntent {
        let result = PZDesktopIntent4GameOnly()
        result.game = switch game {
        case .allGames: .allGames
        case .genshinImpact: .genshinImpact
        case .starRail: .starRail
        case .zenlessZone: .zenlessZone
        default: .allGames
        }
        return result
    }
}

#endif
