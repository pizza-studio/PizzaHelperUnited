// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

#if !os(watchOS)
import UIKit

public enum SimpleTapticType {
    case success
    case warning
    case error
    case light
    case medium
    case heavy
    case rigid
    case soft
    case selection
}

// swiftlint:disable:next cyclomatic_complexity
public func simpleTaptic(type: SimpleTapticType) {
    let feedbackGenerator = UINotificationFeedbackGenerator()
    switch type {
    case .success:
        feedbackGenerator.notificationOccurred(.success)
    case .warning:
        feedbackGenerator.notificationOccurred(.warning)
    case .error:
        feedbackGenerator.notificationOccurred(.error)
    case .light:
        let impactGenerator = UIImpactFeedbackGenerator(style: .light)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .medium:
        let impactGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .heavy:
        let impactGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .rigid:
        let impactGenerator = UIImpactFeedbackGenerator(style: .rigid)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .soft:
        let impactGenerator = UIImpactFeedbackGenerator(style: .soft)
        impactGenerator.prepare()
        impactGenerator.impactOccurred()
    case .selection:
        let selectionGenerator = UISelectionFeedbackGenerator()
        selectionGenerator.selectionChanged()
    }
    print("Taptic Success")
}
#endif
