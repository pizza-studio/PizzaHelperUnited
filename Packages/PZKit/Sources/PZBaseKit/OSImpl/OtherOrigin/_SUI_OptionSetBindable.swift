// Ref: https://gist.github.com/vibrazy/79d407cf2eac2b0e65a61ab07f584105

import SwiftUI

// MARK: - Make OptionsSet Bindable.

extension Binding where Value: OptionSet, Value == Value.Element {
    public func bindedValue(_ options: Value) -> Bool {
        wrappedValue.contains(options)
    }

    @MainActor
    public func bind(
        _ options: Value,
        animate: Bool = false
    )
        -> Binding<Bool> {
        .init { () -> Bool in
            self.wrappedValue.contains(options)
        } set: { newValue in
            let body = {
                if newValue {
                    self.wrappedValue.insert(options)
                } else {
                    self.wrappedValue.remove(options)
                }
            }
            guard animate else {
                body()
                return
            }
            withAnimation {
                body()
            }
        }
    }
}
