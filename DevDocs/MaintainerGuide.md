# 統一披薩引擎 (Unified Pizza Engine) — 維護者指南

> 最後更新：2026 年 9 月 28 日（依程式碼事實全面核對）

本文件旨在為接手維護「披薩小助手」專案的開發者提供全面的技術指南。披薩小助手是一款支援米哈遊旗下多款遊戲（原神、崩壞：星穹鐵道、絕區零）的第三方工具應用程式，並非 miHoYo 官方軟體。

> **核對聲明**：本次更新逐條對照 `Packages/`、各 `Package.swift`、`UnitedPizzaHelper.xcodeproj/project.pbxproj` 與實際原始碼。凡查證後與舊敘述不符者已更正；凡無法查證者已標註，不再保留未經查證的斷言。
> **相關文件**：`DevDocs/ProjectStructure.md`（SPM 元件與 Xcode target 清單）、倉庫根目錄 `AGENTS.md`（發版 SOP）。

---

## 目錄

1. [專案概述](#專案概述)
2. [Local Swift Package 詳解](#local-swift-package-詳解)
3. [Package 依賴關係](#package-依賴關係)
4. [Widgets 組態詳解](#widgets-組態詳解)
5. [iOS 相容性策略](#ios-相容性策略)
6. [跨平台顯示架構 (PZHelper)](#跨平台顯示架構-pzhelper)
7. [iPhone 與 Apple Watch 資料互通](#iphone-與-apple-watch-資料互通)
8. [EnkaKit 詳解](#enkakit-詳解)
9. [GachaKit 詳解](#gachakit-詳解)
10. [PZAccountKit 與 HoYoLab API 互動](#pzaccountkit-與-hoyolab-api-互動)
11. [其他維護注意事項](#其他維護注意事項)

---

## 專案概述

### 支援平台

實際最低部署目標以 Xcode 專案設定為準（非本文宣稱值）：

| 平台 | 專案內實際設定值 | 備註 |
|---|---|---|
| iOS / iPadOS | `IPHONEOS_DEPLOYMENT_TARGET` = 15 / 16.0 / 17.0 / 17.1（各 target 不一） | iOS 16 及更舊：**可安裝，但只有資料匯出介面**，其餘功能不提供（見第 5 節）|
| watchOS | `WATCHOS_DEPLOYMENT_TARGET` = 10.0 / 10.6 | |
| visionOS | `XROS_DEPLOYMENT_TARGET` = 2.0 | |
| macOS | 本專案以 Mac Catalyst 形式提供，未設獨立 macOS target | |

- **Swift 版本**：Swift 6.2（各 `Package.swift` 的 `swift-tools-version: 6.2`）。
- **完整功能需求**：iOS 17.0+。
- **絕區零 (ZZZ) 支援範圍**：目前僅 Daily Note（限 Widget、Live Activity、Today 頁）。見 `README.md`。

> iOS 16 的總體支援是為了與 **Xcode 27 Beta 1** 相容而犧牲的：App 可安裝、可匯出資料，其餘功能不提供。相關細節與程式碼依據見第 5 節。

### 支援的遊戲

本專案**各 App 一律同時支援**下列三款遊戲，沒有「A 助手隱藏 B 遊戲內容」的機制：

- 原神 (Genshin Impact) —— 完整支援
- 崩壞：星穹鐵道 (Houkai: Star Rail) —— 完整支援
- 絕區零 (Zenless Zone Zero) —— 目前僅 Daily Note

> `*:` **Honkai** 是官方故意使用的錯誤拼寫，旨在方便英語母語者不把這個詞唸成「薅開」。但「崩壞」的日語羅馬音只對應「Houkai」。

> **Bundle Identifier 的用途**：只用於區分 App 身分與資料容器（App Group、iCloud Container、App 標題、App Store 連結），**不用於決定支援哪些遊戲**。見 `PZBaseKit/BundleGroupIDs.swift` 的 `appGame: Pizza.SupportedGame? = .none`。

### 核心技術棧

- **Swift 6.2** 與 Swift Concurrency
- **SwiftUI** 作為主要 UI 框架
- **SwiftData**（iOS 17+）／**CoreData**（舊版本機資料與向下相容）
- **WidgetKit** 用於桌面小工具與鎖屏小工具
- **ActivityKit** 用於 Live Activity（實時活動）
- **WatchConnectivity** 用於 iPhone ↔ Apple Watch 通訊

---

## Local Swift Package 詳解

專案採用模組化架構，所有核心程式碼均以 Local Swift Package 形式組織於 `Packages/` 目錄下。**完整且經核對的套件／target 清單見 `DevDocs/ProjectStructure.md`**，本節僅就維護時較常觸及的套件詳述。

目前 `Packages/` 內共有 12 個套件：

`EnkaKit`、`GITodayMaterialsKit`、`GachaKit`、`PZAboutKit`、`PZCoreDataKit`、`PZHelper`、`PZHelper-Watch`、`PZHoYoLabKit`、`PZInGameEventKit`、`PZKit`、`PZWidgetsKit`、`WallpaperKit`。

> ⚠️ `PZDictionaryKit`（披薩辭典）與 `AbyssRankKit`（深淵榜單）**已不存在**。深淵戰報、帳簿、角色庫存三者現為 `PZHoYoLabKit/FeatureModules/` 下的子目錄。

### 1. PZKit (核心基礎套件)

**位置**: `Packages/PZKit/`

PZKit 是整個專案的基礎套件，提供兩個 target：

#### PZBaseKit

最底層的基礎模組，主要檔案分布：

| 子目錄/檔案 | 說明 |
|------------|------|
| `AppUtils/` | 應用程式通用工具類（含 `Broadcaster`、`ScreenTimeLimiter`）|
| `BaseTypes/` | 基礎資料型別定義（含 `SupportedGame`）|
| `FoundationImpl/` | Foundation 框架擴展（如 `DateFormatter+Extensions`）|
| `OSImpl/` | 跨平台 OS 層抽象（含 `PizzaMIT/_SUI_ScreenVM.swift` 的 `ScreenVM`）|
| `BundleGroupIDs.swift` | App Group / iCloud Container / App 標題等識別碼 |
| `UserDefaultsKeys_Base.swift` | UserDefaults 鍵值定義 |
| `ReexportedModules.swift` | 重新匯出的第三方模組（Alamofire, CodableFileMonitor, Defaults, SFSafeSymbols）|

**主要第三方依賴**：`Defaults`、`Alamofire`、`SFSafeSymbols`、`CodableFileMonitor`、`Sworm`。

#### PZAccountKit

帳號管理與 API 互動模組：

| 子目錄/檔案 | 說明 |
|------------|------|
| `PZProfileRelated/` | 使用者檔案（Profile）相關。`PZProfileMO.swift` 為 SwiftData Model、`PZProfileManagerVM.swift` 為前端管理器，`DBActors/` 內有 `PZProfileActor` / `CDProfileMOActor` |
| `HoYoAPIs/` | 米遊社 / HoYoLab API 實作（見第 10 節）|
| `NotificationRelated/` | 推播通知管理 |
| `WatchSputnik.swift` | `AppleWatchSputnik` 單例，封裝 WatchConnectivity 雙向同步 |
| `DependencyImpls/` | 對外部依賴的實作層 |

### 2. PZCoreDataKit (資料持久化套件)

**位置**: `Packages/PZCoreDataKit/`，四個 target：

| 模組名稱 | 說明 |
|---------|------|
| `PZCoreDataKitShared` | 共用型別與協定 |
| `PZCoreDataKit4LocalAccounts` | CoreData `AccountMO4GI` 模型與 Actor，支援舊版帳號檔案匯入 |
| `PZCoreDataKit4GachaEntries` | CoreData `CDGachaMO4GI/HSR` 模型，提供舊抽卡資料解析 |
| `PZProfileCDMOBackports` | 舊系統專用的 Profile CoreData 實作，與 SwiftData 接面透過 `PZProfileSendable` |

- 外部依賴：`Sworm`、`Defaults`。
- **無本地 SPM 依賴**，故為依賴圖的最底層。

### 3. WallpaperKit (桌布／背景套件)

**位置**: `Packages/WallpaperKit/`，兩個 target：`WallpaperKit`（`WallpaperAsset`、`WallpaperTheme`、`UserWallpaperFileHandler`）與 `WallpaperConfigKit`（前端設定邏輯）。外部依賴 `AlertToast`。

### 4. EnkaKit

**位置**: `Packages/EnkaKit/`，詳見第 8 節。外部依賴 `EnkaDBGenerator`、`ArtifactRatingDB`。

### 5. GachaKit

**位置**: `Packages/GachaKit/`，詳見第 9 節。外部依賴 `GachaMetaGenerator`、`CoreXLSX`、`AlertToast`。

### 6. PZWidgetsKit (小工具共用套件)

**位置**: `Packages/PZWidgetsKit/`

| 子目錄/檔案 | 說明 |
|------------|------|
| `BasicTypesAndConfigs/` | 基礎型別與設定 |
| `IntentTimelineProviderImpl.swift` | Timeline Provider 協定實作 |
| `LiveActivityRelated/` | 實時活動相關 |
| `SPMManagableIntents/` | SPM 可管理的 Intent |
| `ViewsForDesktopWidgets/` | 桌面 Widget 視圖 |
| `ViewsForEmbeddedWidgets/` | 鎖屏 Widget 視圖 |
| `ViewsPlatformIndependent/` | 平台無關視圖 |

### 7. PZHoYoLabKit (HoYoLab 進階功能套件)

**位置**: `Packages/PZHoYoLabKit/`，`FeatureModules/` 內含：

| 功能模組 | 說明 |
|---------|------|
| `BattleReport/` | 深淵／忘卻之庭戰報 |
| `Ledger/` | 原石／星瓊帳簿 |
| `CharacterInventory/` | 角色庫存清單 |

### 8. 其他套件

| 套件名稱 | 說明 |
|---------|------|
| `PZAboutKit` | 關於頁面（含 `AppStoreRelated`）|
| `PZInGameEventKit` | 遊戲內活動資訊（事件排程、素材整合）|
| `GITodayMaterialsKit` | 原神每日素材 |
| `PZHelper` | iOS/macOS 主程式套件（見第 6 節）|
| `PZHelper-Watch` | watchOS 主程式套件（依賴 `PZKit`，**不依賴 WallpaperKit**）|

#### PZHelper 子目錄快速索引

- `PZH_Backends/`：`InternalOSImpls/`、`ViewPeripherals/`（Modifier）、`StructImplsAsView/`。
- `PZH_Frontends/`：`ContentViewRoot/`、`RootTabViews/`、`PZH_Features/`（`TodayDashboard`、`ProfileManager`、`HoyoMap` 等）。
- `PZH_iOS14/`：舊系統的降級 UI 入口（`ContentView4iOS14`、`RefugeeVM4iOS14`）。
- `Resources/`：多語系字串與圖資。

---

## Package 依賴關係

```
┌──────────────────────────────────────────────────────────────┐
│                            PZHelper                          │
│        (iOS/macOS 主 App，整合下列所有功能套件)                 │
└───┬───────────┬───────────┬───────────┬───────────┬──────────┘
    │           │           │           │           │
┌───▼───┐  ┌────▼────┐  ┌───▼────┐  ┌───▼─────┐  ┌──▼────────┐
│EnkaKit│  │GachaKit │  │PZHoYo  │  │PZInGame │  │GIToday    │
│(展櫃)  │  │(抽卡)   │  │LabKit  │  │EventKit │  │Materials  │
└───┬───┘  └────┬────┘  └───┬────┘  └───┬─────┘  └──┬────────┘
    │           │           │           │           │
    │      ┌────▼────┐      │           │           │
    │      │PZCore   │      │           │           │
    │      │DataKit  │      │           │           │
    │      └────┬────┘      │           │           │
    └───────────┴───────────┴───────────┴───────────┘
                            │
                 ┌──────────▼──────────┐
                 │   WallpaperKit      │
                 └──────────┬──────────┘
                            │
                 ┌──────────▼──────────┐
                 │       PZKit         │
                 │ ┌─────────────────┐ │
                 │ │   PZAccountKit  │ │
                 │ └────────┬────────┘ │
                 │ ┌────────▼────────┐ │
                 │ │    PZBaseKit    │ │
                 │ └─────────────────┘ │
                 └─────────────────────┘
```

**實際依賴表**（依各 `Package.swift` 抽出，2026-09-28 核對）：

| 來源 Package | 本地依賴 | 外部依賴 |
|--------------|----------|----------|
| `PZKit` | `PZCoreDataKit` | Alamofire, Defaults, SFSafeSymbols, CodableFileMonitor, Sworm |
| `PZCoreDataKit` | （無） | Sworm, Defaults |
| `WallpaperKit` | `PZKit` | AlertToast |
| `EnkaKit` | `PZKit`, `WallpaperKit` | EnkaDBGenerator, ArtifactRatingDB |
| `GachaKit` | `PZKit`, `EnkaKit`, `PZCoreDataKit` | GachaMetaGenerator, CoreXLSX, AlertToast |
| `PZHoYoLabKit` | `PZKit`, `EnkaKit`, `WallpaperKit` | （無） |
| `PZInGameEventKit` | `PZKit`, `WallpaperKit` | （無） |
| `GITodayMaterialsKit` | `PZKit`, `WallpaperKit` | （無） |
| `PZAboutKit` | `PZKit` | （無） |
| `PZWidgetsKit` | `PZKit`, `GITodayMaterialsKit`, `PZInGameEventKit`, `WallpaperKit` | （無） |
| `PZHelper` | 上列全部 + `PZAboutKit`, `PZCoreDataKit` | AlertToast |
| `PZHelper-Watch` | `PZKit` | （無） |

> 若新增 Package，應檢查 `Package.swift` 中的 `sharedSwiftSettings`，保持統一的警告與實驗特性設定；同時確認 `PZHelper`、`WidgetExtension`、`WatchApp` Target 是否需要連帶引用。

---

## Widgets 組態詳解

### 架構分層

#### 1. SPM 管理層 (`PZWidgetsKit`)

可由 Swift Package Manager 管理的共用程式碼：視圖元件、Timeline Provider 協定、Live Activity 視圖與後端、共用設定、Intent/Configuration、資源。

- `SPMManagableIntents/WidgetRefreshIntent.swift`
- `BasicTypesAndConfigs/WidgetSharedSettings.swift`

#### 2. Xcode Target 層 (`WidgetExtension/`)

必須通過 Xcode 直接 build 的內容：

```
WidgetExtension/
├── Modules/
│   ├── Widgets/
│   │   ├── Widgets4Desktop/          # 桌面 Widget（SingleProfile / DualProfile / OfficialFeed / Material）
│   │   ├── Widgets4Embedded/         # 鎖屏 Widget（AllWidgets4Embedded.swift）
│   │   └── LiveActivityWidget/       # 實時活動 Widget
│   ├── BackendModules/
│   │   ├── TimelineProviders/        # Providers4Desktop/ 與 Providers4Embedded/
│   │   ├── Intents/                  # AppIntents_* 與 AppEntities / AppEnums
│   │   └── ...
│   ├── OSImpl.swift
│   ├── PizzaImpl.swift               # App Group / Defaults 初始化
│   └── WidgetsBoundle.swift          # Widget Bundle 入口
├── Info.plist                        # Widget 設定
└── Info-TheLatteWidgetExtension.plist
```

### 必須通過 Xcode Target 的原因

1. **Widget Bundle 入口**：`@main` 標記的 `WidgetBundle` 必須在 Target 內才能連到 Extension life-cycle。
2. **Intent 定義/匯出**：`PZWidgetsKit` 只能定義 `AppIntent` 型別，真正的 `.intentdefinition`、`INIntent` wrapper 仍需在 Target 註冊，並於 `Info.plist` 聲明。
3. **Extension 生命週期**：Widget Extension 需要獨立的 `UIApplicationDelegateAdaptor` 與 App Group 初始化碼（位於 `BackendModules/PizzaImpl.swift`）。
4. **Entitlements**：Widget Extension 使用的 App Group、`com.apple.developer.usernotifications.filtering` 等權限必須在目標層級設定，並保持與主 App 相同。
5. **敏感資料隔離**：只有經 App Group 允許的資料（如 `Defaults[.pzProfiles]`）能被 Extension 讀取，其他資料（如 SwiftData）必須透過 Widget Timeline Provider 轉譯為快取。

### 快取同步策略

- **資料來源**：Widget 僅能使用 `Defaults`、`CodableFileMonitor`、App Group 內的 JSON 檔案。`GachaKit`、`EnkaKit` 均提供 `Sendable` struct 以供 Timeline 進行序列化。
- **資料刷新**：`PZWidgetsKit.WidgetRefreshIntent` 可由使用者手動刷新；`Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()` 會在 Profile 變更、Enka 快取更新時自動觸發。

---

## iOS 相容性策略

### 舊系統與 EOL 的降級介面

`ContentView4iOS14`（`PZH_iOS14/`）**就是資料匯出介面**。其原始碼註解即為規格：

```swift
/// 業務邏輯：
/// iOS 16 僅允許匯出資料。
/// iOS 17+：披薩小助手僅允許匯出資料，但該畫面允許關閉。
///         使用者關閉該畫面之後可繼續照常使用 App，只是所有功能全部放棄維護。
```

它在 `PZHelper.MainApp` 內服務**兩種情境**：

| 情境 | 觸發條件 | 行為 |
|---|---|---|
| iOS 16 及更舊 | `if #available(iOS 17.0, macCatalyst 17.0, *)` 為 false | **整個 App 就是此匯出介面**（無法關閉，因無其他畫面） |
| iOS 17+ 且為披薩小助手 | `Pizza.isAppStoreReleaseAsPizzaHelper` → `isEOLNoticeDisplayed` | 以 `.sheet` 彈出此介面，`.interactiveDismissDisabled()`；`snoozeAction` 讓使用者關閉後繼續使用（功能不再維護） |

（拿鐵小助手不受第二種情境影響。）

**背景**：為了與 Xcode 27 Beta 1 相容，iOS 16 的總體支援已被犧牲——**可安裝、可匯出資料，其餘功能不提供**。相關的 Widget 雙軌 backport 架構亦已一併移除：

- 全倉庫搜尋 `IN*` 前綴型別：**無命中**。
- `WidgetExtension/` 內所有 Widget 一律使用 `AppIntentConfiguration`，**無任何 `IntentConfiguration`**。
- `useBackports` / `backportsOnly`：**無命中**。

因此 Widget 不再有雙軌實作，皆為單一 `AppIntentConfiguration` 路徑。

> 命名提醒：`ContentView4iOS14` 與 `PZH_iOS14/` 的「iOS14」是**歷史命名**，它現行處理的是「iOS 16 的匯出降級」與「披薩小助手的 EOL 匯出」，與當前最低部署目標無關。

---

## 跨平台顯示架構 (PZHelper)

### ScreenVM：統一的畫面狀態管理

`ScreenVM` 位於 `PZBaseKit/OSImpl/PizzaMIT/_SUI_ScreenVM.swift`：

```swift
@Observable
public final class ScreenVM {
    public var orientation: Orientation           // 螢幕方向
    public var isHorizontallyCompact: Bool       // 水平緊湊模式
    public var windowSizeObserved: CGSize        // 視窗尺寸
    public var splitViewVisibility: NavigationSplitViewVisibility
    public var mainColumnCanvasSizeObserved: CGSize  // 主欄位畫布尺寸

    public var isPhonePortraitSituation: Bool    // iPhone 直立情境
    public var isExtremeCompact: Bool            // 極端緊湊（如 iPhone SE3 放大模式）
    public var isSidebarVisible: Bool            // 側邊欄可見性
}
```

### 平台適配策略

- **macOS (Catalyst)**：固定使用 `.landscape` 方向；預設顯示側邊欄 (`.all`)；最小視窗尺寸限制。
- **iPadOS**：支援螢幕旋轉偵測；橫向時顯示側邊欄、直向時隱藏。
- **iPhoneOS**：依 `horizontalSizeClass` 判斷佈局；緊湊模式下使用單欄；支援極端緊湊模式。

### UI 模組劃分

- **Root 層 (`ContentViewRoot/`)**：`ContentView`、`RootNavVM`、`AppRootPage`。處理 NavigationSplitView、Tab 切換。
- **Tab 層 (`RootTabViews/`)**：`TodayTabPage`、`DetailPortalTabPage`、`UtilsTabPage`、`0_AppSettingsTabPage`。
- **Feature 層 (`PZH_Features/`)**：`TodayDashboard/`、`ProfileManager/`、`DetailPortalComponents/`、`HoyoMap/`、`StartupModifiers/`。
- **Backend 層 (`PZH_Backends/`)**：`Broadcaster`、`ScreenVM`、`ViewPeripherals` 各種 Modifier。

### App 入口

三個 App target 的 `main.swift` 皆為單行：

```swift
PZHelper.MainApp.main()
```

（`TheLatteHelper/main.swift`、`ThePizzaHelper/main.swift`、`UnitedPizzaHelperEngine/main.swift`）

啟動流程：`PZHelper.MainApp.body` → `.initializeApp()`（`PZHelper.swift`）→ `startupTasks()`。
Widget 端另有 `WidgetExtension/Modules/PZWidgets.swift` 的 `PZWidgets.startupTask()`。

---

## iPhone 與 Apple Watch 資料互通

使用 `WatchConnectivity` 框架實現雙向通訊：

```swift
// PZAccountKit/WatchSputnik.swift
public final class AppleWatchSputnik: NSObject, ObservableObject, WCSessionDelegate {
    public static let shared: AppleWatchSputnik
    public func sendAccounts(_ accounts: [PZProfileSendable], _ message: String)
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any])
}
```

**訊息 Key**：

| Key | 說明 |
|-----|------|
| `"message"` (`AppleWatchSputnik.kMessageKey`) | 傳送文字通知（顯示在 Watch App overlay）|
| `uidWithGame` | 例如 `"gi-800123456"`，作為字典 key |

**資料同步流程（iPhone → Apple Watch）**：

1. 使用者在 iPhone 上新增/修改帳號。
2. `ProfileManagerVM` 觸發同步。
3. `AppleWatchSputnik.sendAccounts()` 發送資料。
4. 資料以 JSON 格式透過 `WCSession.sendMessage()` 傳輸。

Watch 端由 `PZProfileActor.watchSessionHandleIncomingPushedProfiles(_:)` 處理：刪除不存在的 Profile、更新已存在者、插入新者、同步到 UserDefaults、更新通知設定。

**背景任務**：`BackgroundTaskAsserter`（來自 `PZCoreDataKitShared`）確保在 watchOS 後台執行期間資料寫入不被取消。

**差異化邏輯**：

- watchOS 端只保留 `PZProfileMO` 的必要欄位（通知、UID、Cookie），並在合併期間透過 `inherit(from:)` 維持 UUID，避免通知重複。
- iOS 端會於 `ProfileManagerVM.didObserveChangesFromSwiftData()` 中呼叫 `Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()`。

**限制**：`WCSession.sendMessage` 需在裝置連線且前景狀態才能執行；目前僅同步帳號資訊。

---

## EnkaKit 詳解

### 架構概述

EnkaKit 負責與 [Enka.Network](https://enka.network/) 服務整合，提供角色展櫃查詢與顯示功能。

### Backend 元件 (`EnkaKitBackend/`)

| 子目錄 | 說明 |
|--------|------|
| `EnkaDB/` | Enka 資料庫封裝（`EnkaDBProtocol`、`EnkaDB4GI`、`EnkaDB4HSR`、`DBModelsImpl`）|
| `ArtifactRating/` | 聖遺物評分系統（`ARDB_Models`、`AR_Options`、`AR_SummaryImpl`、`ARDB_Sputnik`）|
| `AssetSuppliable/` | **素材來源機制**（見下）|
| `QueriedModels_Enka/` | Enka API 查詢結果模型 |
| `QueriedModels_HoYoLab/` | HoYoLab 角色資料模型（補充 Enka 不提供的欄位）|
| `SummarySupport/` | 角色資料摘要生成（`AvatarSummarized_*`、`ProfileSummarized`）|
| `SharedTypes/` | 共用型別（`GameElement`、`LifePath`、`PropertyType` 等）|
| `GICostume/` | 原神角色服裝相關 |
| `Utils/` | 共用工具（快取處理、URL 生成、資料校驗）|

> ⚠️ 過往本表列有 `HakushinQuery/`（Hakushin API 查詢），**該模組已不存在於程式中**，全倉庫無 `Hakushin` 命中。名片圖示現由 `ProfileIconView` 透過 `AssetSuppliable` 取得。此欄已移除。

#### 素材來源 (`AssetSuppliable/`)

兩套並行的素材來源，由呼叫端各自選用：

| 協定 | 說明 |
|------|------|
| `LocalAssetSuppliable` | `iconAssetName` / `localIcon4SUI`，由 `Enka.queryImageAssetSUI(for:)` 自 `.currentSPM` bundle 的 `Resources/Assets.xcassets` 取圖 |
| `OnlineAssetSuppliable` | `onlineAssetURLStr` 提供網址、以 `AsyncImage` 載入，目前指向 `gi.yatta.moe` / `sr.yatta.moe`（ZZZ 尚未接）|

- 角色圖示（`CharacterIconView`）：只取本地，取不到顯示空白問號。
- 名片圖示（`ProfileIconView.localFittingIcon4SUI`）：**本地優先，取不到才 fallback 到線上**。

### Frontend 元件 (`EnkaKitFrontend/`)

| 元件 | 說明 |
|------|------|
| `EnkaShowCaseView` | 展櫃主視圖容器 |
| `ShowCaseListView` | 角色列表視圖 |
| `EachAvatarStatView` | 單角色詳細面板 |
| `AvatarStatCollectionTabView` | 分頁式角色集合 |
| `CaseQuerySection` | 查詢區塊 |
| `CaseProfileVM` | 展櫃 ViewModel |
| `ProfileIconView` / `ProfileNameView` | 名片圖示／名稱 |
| `ProfileShowCaseSections` | 展櫃分區 |
| `CharacterIconViews/` | 角色圖示元件庫 |

### 快取機制

`EKQueriedProfileProtocol` 提供 `saveToCache()` / `getCachedProfile(uid:)` / `removeCachedProfile(uid:)` / `getAllCachedProfiles()`。

**快取路徑**（核對 `EKQueryProtocols.swift`）：

```
<Application Support>/<sharedBundleIDHeader>/CachedAvatars/FromEnkaNetworks/
```

> 過往本文件寫為 `ApplicationSupport/[BundleID]/CachedAvatars/FromEnkaNetworks/`。實際路徑中的該層目錄名為 `sharedBundleIDHeader` 的值（拿鐵版為 `org.pizzastudio.TheLatteHelper`），不是任意 Bundle ID。

### 快取與資料新鮮度

- `Defaults[.lastEnkaDBDataCheckDate]` 控制 DB 更新頻率（預設 2 小時）。
- `EnkaDBProtocol.needsUpdate` 判斷語系或時間是否失效。
- 若 `EnkaDB` 線上更新失敗，會 fallback 到匯入於 App bundle 的備份 DB。

---

## GachaKit 詳解

### 架構概述

GachaKit 是完整的抽卡記錄管理系統，支援多種資料格式的匯入匯出。

### Backend 元件 (`Backends/`)

| 子目錄 | 說明 |
|--------|------|
| `GachaFetch/` | 抽卡記錄抓取：`GachaClient`、`GachaURLGenerator`、`GachaFetch_Enums` |
| `GachaExchange/` | 資料匯入匯出：`GachaDocument`、`GachaExchange_Enums`、`UIGFModels/`（`UIGFv4/` 與 `OldModels/`）|
| `GachaPersistence/` | SwiftData `GachaActor`、`PZGachaEntryMO`、`PZGachaProfileMO` |
| `CDGachaMO/` | CoreData 相容層，用於舊版資料遷移與「難民檔」匯入 |
| `GMDBRelated/` | Gacha Meta Database 交握（`GachaMeta.Sputnik`）|
| `Expressibles/` | 抽卡項目的表達型別 |
| `Common/` | 共用工具 |

### GachaClient (抽卡客戶端)

實作 `AsyncSequence`，支援非同步迭代抓取：

```swift
public struct GachaClient<GachaType: GachaTypeProtocol>: AsyncSequence, AsyncIteratorProtocol {
    public init(gachaURLString: String) throws(ParseGachaURLError)
    public mutating func next() async throws(GachaError)
        -> (gachaType: GachaType, result: GachaResult)?
}
```

### GachaExchange (資料交換)

**UIGFv4 格式結構**：

```swift
public struct UIGFv4: Codable {
    var info: UIGFInfo
    var giProfiles: [UIGFGachaProfile4GI]?
    var hsrProfiles: [UIGFGachaProfile4HSR]?
    var zzzProfiles: [UIGFGachaProfile4ZZZ]?
}
```

**支援的資料格式**：

| 格式 | 匯入 | 匯出 | 說明 |
|------|------|------|------|
| UIGF v4.1 | ✅ | ✅ | 統一可互換抽卡格式（全遊戲）|
| SRGF v1.0 | ✅ | ✅ | 星穹鐵道專用格式 |
| GIGF (JSON) | ✅ | ❌ | UIGF v2.2~v3.0 舊格式 |
| GIGF (Excel) | ✅ | ❌ | UIGF v2.0~v2.2 Excel 格式 |
| 胡桃難民檔 | ✅ | ❌ | SQLite 資料庫格式 |
| 舊披薩難民檔 | ✅ | ❌ | PropertyList 格式 |

> 核對：模型實作位於 `GachaExchange/UIGFModels/`（`UIGFv4/` 為現行、`OldModels/` 收 `GIGF` 與 `SRGFv1`）。

### 資料流（抓取 → 儲存 → 匯出）

1. **抓取**：`GachaClient` 解析使用者貼上的 URL，抽取 `authkey`、`region`、`sign_type` 等參數。
2. **正規化**：`GachaResult.list[i].toGachaEntrySendable()` 轉為 `PZGachaEntrySendable`。
3. **儲存**：`GachaActor.insertEntries()` 以 SwiftData 寫入；舊系統另有 CoreData 遷移路徑。
4. **統計/視圖**：`GachaVM.updateMappedEntriesByPools()`。
5. **匯出**：`GachaActor.prepareGachaDocument()` 依指定格式產出 `GachaDocument`。

### 舊資料接收（難民檔）

- `PZRefugeeDocument`：PropertyList，含舊版披薩帳號與抽卡記錄。
- `HutaoRefugeeFile`：SQLite；解析後轉為 `UIGFv4`。
- `GachaVM.migrateOldGachasIntoProfiles()`：背景任務合併 `Defaults[.pzProfiles]` 與舊資料。
- **iCloud 繼承**：`GachaPersistence/GachaActor` 使用 CloudKit 私有資料庫（`cloudKitDatabase: .private(iCloudContainerName)`）承接舊版抽卡記錄；偵錯時可用 `cloudKitDatabase: .none`。

---

## PZAccountKit 與 HoYoLab API 互動

### 伺服器區域

```swift
public enum AccountRegion: String {
    case miyoushe(SupportedGame)   // 中國大陸
    case hoyoLab(SupportedGame)    // 國際服
}
```

### API 請求生成

```swift
public static func generateRecordAPIRequest(
    httpMethod: HTTPMethod = .get,
    region: AccountRegion,
    path: String,
    queryItems: [URLQueryItem],
    cookie: String?,
    deviceFingerPrint: String?,
    additionalHeaders: [String: String]?
) async throws -> DataRequest
```

### 請求配置 (`HoYo_URLReq/URLRequestConfig.swift`)

```swift
public static func recordURLAPIHost(region: HoYo.AccountRegion) -> String {
    switch region {
    case .miyoushe: "api-takumi-record.mihoyo.com"
    case .hoyoLab: "bbs-api-os.hoyolab.com"
    }
}
```

其他主機（核對原始碼）：

| 用途 | miyoushe | hoyoLab |
|---|---|---|
| 記錄 API | `api-takumi-record.mihoyo.com` | `bbs-api-os.hoyolab.com` |
| 帳號 API | `api-takumi.mihoyo.com` | `api-account-os.hoyolab.com` |
| 原神（特定路徑） | — | `sg-hk4e-api.hoyolab.com` |
| 星穹鐵道（特定路徑） | `api-takumi.mihoyo.com` | `sg-public-api.hoyolab.com` |

### 主要 API 功能

#### 1. 即時便箋 (DailyNote)

- `DailyNoteRelated/` 內有 `DailyNoteProtocol` 與各遊戲實作（`note4GI` 等）。
- 若主 API 失敗且有 `sTokenV2`，會 fallback 到 Widget API。

#### 2. 登入相關

| 目錄 | 功能 |
|------|------|
| `QRCodeLoginAPI/` | QR Code 掃碼登入 |
| `GetTokenAPI/` | 獲取登入 Token |
| `GetCookieTokenAPI/` | 獲取 Cookie Token |
| `GameToken2StokenV2/` | GameToken 轉換 SToken |
| `ValidationAPI/` | 驗證碼處理 |
| `UserGameRolesAPI/` | 獲取遊戲角色列表 |
| `GenerateDeviceFingerPrintAPI/` | 設備指紋生成 |

#### 3. QR Code 登入流程（**已改版**）

核對 `QRCodeLoginAPI/GenerateQRCode/GenerateQRCodeURLAPI.swift`，現行實作為新版 passport API：

```swift
enum QRCodeShared {
    static let appID = "ddxf5dufpuyo"
    static let clientType = "3"
    static let userAgent = "HYPContainer/1.3.3.182"
    static let url4Create = URL(string: "https://passport-api.mihoyo.com/account/ma-cn-passport/app/createQRLogin")!
    static let url4Query = URL(string: "https://passport-api.mihoyo.com/account/ma-cn-passport/app/queryQRLoginStatus")!
}
```

> ⚠️ 過往本文件記載的是舊版 `hk4e-sdk.mihoyo.com/bh2_cn/combo/panda/qrcode/*` 端點與 `appID = "7"`（崩壞2），**該實作已被取代**。Header 使用 `x-rpc-app_id`、`x-rpc-client_type`、`x-rpc-device_id`。

### PZHoYoLabKit 進階功能

`FeatureModules/` 內三個模組，各自含 `HoYoAPIImpl/`、`Models/`、`Views/`：

- `BattleReport/`：深淵／忘卻之庭戰報
- `Ledger/`：帳簿查詢
- `CharacterInventory/`：角色庫存

### PZAccountKit ↔ PZHoYoLabKit 資料流程

1. `PZAccountKit` 管理登入狀態，並將 `cookie`、`deviceID`、`deviceFingerPrint` 存於 `PZProfileSendable`。
2. `PZHoYoLabKit` 透過 `PZAccountKit` 暴露的 `HoYo` API 與 Profiles，決定 region/game。
3. API 回應會寫入 `Defaults` 或 SwiftData（視功能而定），再由對應視圖呈現。
4. 錯誤（如 `MiHoYoAPIError.retcode`）透過畫面層的 AlertToast 呈現。

> ⚠️ 過往本文件寫「透過 `Broadcaster.shared.showErrorToast` 顯示錯誤」，**`Broadcaster` 並無此成員**。核對 `Broadcaster.swift`，其成員為 `reloadAllTimeLinesAcrossWidgets()`、`localEnkaAvatarCacheDidUpdate(uidWithGame:)`、`localHoYoLABAvatarCacheDidUpdate()`、`refreshPage()`、`refreshTodayTab()`、`stopRootTabTasks()`、`requireOSNotificationCenterAuthorization()`、`userWallpaperEntryChangesDidSave()`。Toast 由 AlertToast 的 `AlertToastEventStatus` 於各視圖內處理。

> **建議**：當 miHoYo 修改 API（例如需要新的 header）時，統一於 `URLRequestConfig` / `URLRequestHelper` 更新，避免散布於各模組。

---

## 其他維護注意事項

### 1. 版本相容性

見「專案概述 → 支援平台」。**實際值以 Xcode 專案設定為準**；Swift 版本為 6.2（`swift-tools-version: 6.2`）。

### 2. App Group 設定

所有資料共享（主 App、Widget、Watch）都依賴 App Group，其值由 Bundle ID 決定（`BundleGroupIDs.swift`）：

| 情境 | App Group ID | iCloud Container |
|---|---|---|
| 拿鐵小助手（現行） | `group.pizzastudio.TheLatteHelper` | `iCloud.com.pizzastudio.TheLatteHelper` |
| 披薩小助手（`Canglong.GenshinPizzaHepler`） | `group.GenshinPizzaHelper` | `iCloud.com.Canglong.GenshinPizzaHelper` |
| 其他 | `group.pizzastudio.UnitedPizzaHelper` | `iCloud.com.Canglong.UnitedPizzaHelper` |

> ⚠️ 過往本文件寫 `sharedBundleIDHeader = "group.Canglong.PizzaHelper"`，**該字串不存在於程式中**，已更正。

### 3. 編譯警告設定

`Package.swift` 中啟用了編譯時間警告：

```swift
let sharedSwiftSettings: [SwiftSetting] = [
    .unsafeFlags([
        "-Xfrontend", "-warn-long-function-bodies=250",
        "-Xfrontend", "-warn-long-expression-type-checking=250",
    ]),
    .enableExperimentalFeature("AccessLevelOnImport"),
]
```

### 4. 本地化

- 預設語言：英文 (`en`)
- 支援語言：中文簡體、中文繁體、日文、俄文等
- 本地化檔案位於各 Target 的 `Localizable.xcstrings`

### 5. 資料安全

- Cookie 等敏感資料存儲在 App Group 的 UserDefaults 中。
- 網路請求使用 HTTPS。

### 6. 測試

- 單元測試位於各 Package 的 `Tests/` 目錄（`EnkaKit`、`GITodayMaterialsKit`、`PZAboutKit`、`PZHelper-Watch`、`PZInGameEventKit`、`PZHoYoLabKit` 等）。
- 執行 Swift Package 測試時，本機環境需加 `--disable-sandbox`（SwiftPM 內層 sandbox 與 harness sandbox 不相容）。

### 7. 已知技術債

1. **絕區零支援**：目前僅 Daily Note。
2. **iOS 16 支援**：為與 Xcode 27 Beta 1 相容而犧牲，現僅剩資料匯出（見第 5 節）。相關的 Widget 雙軌 backport 架構已完全移除。
3. **CoreData 遷移**：舊版資料遷移邏輯可在確認無使用者需要後移除。
4. **`PZH_iOS14` 命名**：目錄與型別名稱沿用舊系統代號，實際職責是「iOS 16 匯出降級」與「披薩小助手 EOL 匯出」。

### 8. 外部依賴更新

Pizza Studio 維護的外部 Package（上游倉庫位於本倉庫同級目錄）：

- `EnkaDBGenerator`：Enka 資料庫
- `GachaMetaGenerator`：抽卡元資料
- `ArtifactRatingDB`：聖遺物評分

更新流程見倉庫根目錄 `AGENTS.md` 步驟 A（**務必以 Xcode 重新解析**，勿手改 `Package.resolved`）。

### 9. API 變更應對

米哈遊的 API 可能隨時變更，需要注意：DS 簽名演算法、API 路徑、請求標頭要求、驗證碼機制。

建議關注社群討論（如 UIGF 組織）以獲取最新資訊。可考慮建立 `DevDocs/APIChangeLog.md` 紀錄每次 header/salt 更新。

### 10. 建置、測試與維運建議

- **建置**：
    1. `BoostBuildVersion.swift <MARKETING_VERSION>` 依 **`git rev-list --count main` + 3067** 更新 Xcode Build Number（**非** `git describe`）。必須在版本 bump commit **之前**執行。
    2. `make archive`（互動式選單）或 `make archiveLatte-iOS` 等目標集中 xcodebuild 參數，生成可用於 App Store 的 Archive。
- **靜態檢查**：`make lint`（swiftlint，含 `--fix`）、`make format`（swiftformat）。注意 `make lint` 會自動改檔。
- **故障排除**：
    - Widget 不更新：檢查 `WidgetExtension/Modules/PZWidgets.swift` 的 `PZWidgets.startupTask()` 是否被 `BackendModules/PizzaImpl.swift` 成功呼叫。
    - Watch 無法同步：確認 App Group ID 與 iPhone 一致，並查看 Console 中 `AppleWatchSputnik` log。
    - API 403：檢查 `URLRequestConfig` 的 salt 是否過期，或是否需要 `x-rpc-device_fp`／`x-rpc-device_id`。

### 11. 交接前檢查清單

- [ ] 更新 `DevDocs/MaintainerGuide.md` 版本日期與重大變更。
- [ ] 確認 `Packages/*/Package.swift` 的依賴版本與 `UnitedPizzaHelper.xcodeproj/.../Package.resolved` 一致（以 Xcode 重新解析）。
- [ ] 執行 `Script/_assetUpdate4GI.sh`／`_assetUpdate4HSR.sh`，確保資產同步。
- [ ] Widget、Watch、主 App App Group 設定一致。
- [ ] 若新增／移除 SPM 套件或 Xcode target，同步更新 `DevDocs/ProjectStructure.md`。

---

## 附錄：檔案結構速查

```
PizzaHelperUnited/
├── Packages/                    # Swift Packages（12 個）
│   ├── PZKit/                   # 核心基礎（PZBaseKit + PZAccountKit）
│   ├── PZCoreDataKit/           # 資料持久化
│   ├── WallpaperKit/            # 桌布／背景
│   ├── EnkaKit/                 # Enka 整合
│   ├── GachaKit/                # 抽卡管理
│   ├── PZHoYoLabKit/            # HoYoLab 進階功能
│   ├── PZInGameEventKit/        # 遊戲內活動
│   ├── GITodayMaterialsKit/     # 原神每日素材
│   ├── PZAboutKit/              # 關於頁面
│   ├── PZWidgetsKit/            # Widget 共用
│   ├── PZHelper/                # iOS/macOS 主程式
│   └── PZHelper-Watch/          # watchOS 主程式
├── TheLatteHelper/              # 拿鐵小助手 App Target（現行）
├── ThePizzaHelper/              # 披薩小助手 App Target（前作）
├── UnitedPizzaHelperEngine/     # macOS 引擎 App Target
├── WatchApp/                    # watchOS App Target
├── WatchExtension/              # watchOS Extension
├── WidgetExtension/             # Widget Extension
├── SharedBundles/               # 共用資源
├── DevDocs/                     # 開發文件
├── EndUserPublicDocs/           # 使用者文件與發行說明存檔
├── Script/                      # 建置與資料腳本
├── _i18n_xliff/                 # 在地化交換檔
└── UnitedPizzaHelper.xcodeproj/ # Xcode 專案（9 個 native target）
```

---

*本文件由 Pizza Studio 維護團隊維護。如有疑問，請聯繫原作者或查閱專案 `README.md`。*
