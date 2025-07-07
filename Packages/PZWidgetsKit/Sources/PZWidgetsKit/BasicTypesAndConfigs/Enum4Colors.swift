// (c) 2024 and onwards Pizza Studio (AGPL v3.0 License or later).
// ====================
// This code is released under the SPDX-License-Identifier: `AGPL-3.0-or-later`.

import CoreGraphics

// MARK: - PZWidgetsSPM.Colors

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
extension PZWidgetsSPM {
    /// 用 Xcode Asset Catalog 管理颜色的话会有个风险：一旦颜色名称填写错误的话，就是 Runtime Error。
    /// 用 Enums 管理颜色可以使这种错误变成 Compile-time Error。
    public enum Colors {
        public enum TextColor {
            public static let primaryBlack = CGColor(red: 0.439, green: 0.604, blue: 0.820, alpha: 1.0)
            public static let activityBlueText = CGColor(red: 0.847, green: 0.906, blue: 0.996, alpha: 1.0)
            public static let primaryWhite = CGColor(red: 0.988, green: 0.992, blue: 1.0, alpha: 1.0)
            public static let originResin = CGColor(red: 0.796, green: 0.933, blue: 1.0, alpha: 1.0)
            public static let calendarWeekday = CGColor(red: 0.996, green: 0.329, blue: 0.259, alpha: 1.0)
            public static let appIconLike = CGColor(red: 0.961, green: 0.91, blue: 1.0, alpha: 1.0)
        }

        public enum IconColor {
            public enum Resin {
                public static let accented = CGColor(red: 0.459, green: 0.643, blue: 0.867, alpha: 1.0)
                public static let light = CGColor(red: 0.98, green: 0.988, blue: 0.996, alpha: 1.0)
                public static let middle = CGColor(red: 0.341, green: 0.749, blue: 0.98, alpha: 1.0)
                public static let dark = CGColor(red: 0.353, green: 0.478, blue: 0.792, alpha: 1.0)
            }

            public enum HomeCoin {
                public static let accented = CGColor(red: 0.961, green: 0.761, blue: 0.259, alpha: 1.0)
                public static let darkBlue = CGColor(red: 0.075, green: 0.651, blue: 0.945, alpha: 1.0)
                public static let lightBlue = CGColor(red: 0.416, green: 0.784, blue: 0.996, alpha: 1.0)
            }

            public static let weeklyBosses = CGColor(red: 0.059, green: 0.757, blue: 0.757, alpha: 1.0)
            public static let transformer = CGColor(red: 0.49, green: 0.761, blue: 0.792, alpha: 1.0)
            public static let expedition = CGColor(red: 0.337, green: 0.733, blue: 0.416, alpha: 1.0)
            public static let dailyTask = CGColor(red: 0.714, green: 0.596, blue: 0.98, alpha: 1.0)
        }

        // MARK: - 背景顏色

        public enum Background {
            public enum IntertwinedFate {
                public static let color1 = CGColor(red: 0.843, green: 0.549, blue: 0.753, alpha: 1.0)
                public static let color2 = CGColor(red: 0.753, green: 0.682, blue: 0.894, alpha: 1.0)
                public static let color3 = CGColor(red: 0.376, green: 0.682, blue: 0.957, alpha: 1.0)
            }

            public static let widgetBackground = CGColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
}

#if DEBUG

import SwiftUI

@available(iOS 17.0, macCatalyst 17.0, watchOS 10.0, *)
#Preview {
    VStack(alignment: .leading) {
        Group {
            Label("TextColor.primaryBlack".description, systemImage: "square.fill")
                .tint(Color(cgColor: PZWidgetsSPM.Colors.TextColor.primaryBlack))
            Label("TextColor.activityBlueText".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.TextColor.activityBlueText))
            Label("TextColor.primaryWhite".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.TextColor.primaryWhite))
            Label("TextColor.originResin".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.TextColor.originResin))
            Label("TextColor.calendarWeekday".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.TextColor.calendarWeekday))
            Label("TextColor.appIconLike".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.TextColor.appIconLike))
        }
        Group {
            Label("IconColor.Resin.accented".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.Resin.accented))
            Label("IconColor.Resin.light".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.Resin.light))
            Label("IconColor.Resin.middle".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.Resin.middle))
            Label("IconColor.Resin.dark".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.Resin.dark))
        }
        Group {
            Label("iconColor.HomeCoin.accented".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.HomeCoin.accented))
            Label("IconColor.HomeCoin.darkBlue".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.HomeCoin.darkBlue))
            Label("IconColor.HomeCoin.lightBlue".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.HomeCoin.lightBlue))
        }
        Group {
            Label("IconColor.weeklyBosses".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.weeklyBosses))
            Label("IconColor.transformer".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.transformer))
            Label("IconColor.expedition".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.expedition))
            Label("IconColor.dailyTask".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.IconColor.dailyTask))
        }
        Group {
            Label("Background.IntertwinedFate.color1".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.Background.IntertwinedFate.color1))
            Label("Background.IntertwinedFate.color2".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.Background.IntertwinedFate.color2))
            Label("Background.IntertwinedFate.color3".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.Background.IntertwinedFate.color3))
            Label("Background.widgetBackground".description, systemImage: "square.fill")
                .foregroundStyle(Color(cgColor: PZWidgetsSPM.Colors.Background.widgetBackground))
        }
    }
    .padding()
    .background {
        Color.gray
    }
}
#endif
