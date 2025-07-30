// This implementation is considered as copyleft from public domain.

#if os(iOS) && !targetEnvironment(macCatalyst)

import Combine
import UIKit

/// Publisher to read keyboard changes.
public protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

extension KeyboardReadable {
    public var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },

            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
}

#endif
