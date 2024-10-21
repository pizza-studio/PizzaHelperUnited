// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import AppIntents
import SwiftUI
import WidgetKit

// MARK: - WidgetExtensionControl

struct WidgetExtensionControl: ControlWidget {
    static let kind: String = "Canglong.GenshinPizzaHepler.ResinStatusWidget"

    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: Self.kind,
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value.isRunning,
                action: StartTimerIntent(value.name)
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension WidgetExtensionControl {
    struct Value {
        var isRunning: Bool
        var name: String
    }

    struct Provider: AppIntentControlValueProvider {
        func previewValue(configuration: TimerConfiguration) -> Value {
            WidgetExtensionControl.Value(isRunning: false, name: configuration.timerName)
        }

        func currentValue(configuration: TimerConfiguration) async throws -> Value {
            let isRunning = true // Check if the timer is running
            return WidgetExtensionControl.Value(isRunning: isRunning, name: configuration.timerName)
        }
    }
}

// MARK: - TimerConfiguration

struct TimerConfiguration: ControlConfigurationIntent {
    static let title: LocalizedStringResource = "Timer Name Configuration"

    @Parameter(title: "Timer Name", default: "Timer") var timerName: String
}

// MARK: - StartTimerIntent

struct StartTimerIntent: SetValueIntent {
    // MARK: Lifecycle

    init() {}

    init(_ name: String) {
        self.name = name
    }

    // MARK: Internal

    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer Name") var name: String

    @Parameter(title: "Timer is running") var value: Bool

    func perform() async throws -> some IntentResult {
        // Start the timer…
        .result()
    }
}
