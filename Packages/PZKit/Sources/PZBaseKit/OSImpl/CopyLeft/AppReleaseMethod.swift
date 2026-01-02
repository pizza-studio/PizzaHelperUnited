// This implementation is considered as copyleft from public domain.

import Foundation

public enum AppReleaseMethod: String, Hashable, Sendable {
    case simulator
    case debug
    case testFlight
    case appStore
    case standaloneRelease

    // MARK: Public

    public static let current: AppReleaseMethod = {
        // 1. 判斷是否為模擬器
        #if targetEnvironment(simulator)
        return .simulator
        #else
        // 2. 判斷是否為 Debug 模式 (經由 Xcode 直接安裝)
        #if DEBUG
        return .debug
        #else
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            // 3. 判斷是否為 TestFlight
            // TestFlight 的收據路徑最後一個組件一定是 "sandboxReceipt"
            if receiptURL.lastPathComponent == "sandboxReceipt" {
                return .testFlight
            }
            // 4. App Store 正式版
            return .appStore
        } else {
            // 5. 其他 Apple App Store 以外的渠道發行的 Release Build
            return .standaloneRelease
        }
        #endif
        #endif
    }()
}
