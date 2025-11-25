# 統一披薩引擎 (Unified Pizza Engine) — 維護者指南

> 最後更新：2025年11月26日

本文件旨在為接手維護「披薩小助手」專案的開發者提供全面的技術指南。披薩小助手是一款支援米哈遊旗下多款遊戲（原神、崩壞：星穹鐵道、絕區零）的第三方工具應用程式，並非 miHoYo 官方軟體。

---

## 目錄

1. [專案概述](#專案概述)
2. [Local Swift Package 詳解](#local-swift-package-詳解)
3. [Package 依賴關係](#package-依賴關係)
4. [Widgets 組態詳解](#widgets-組態詳解)
5. [iOS 16 與 iOS 17+ 相容性策略](#ios-16-與-ios-17-相容性策略)
6. [跨平台顯示架構 (PZHelper)](#跨平台顯示架構-pzhelper)
7. [iPhone 與 Apple Watch 資料互通](#iphone-與-apple-watch-資料互通)
8. [EnkaKit 詳解](#enkakit-詳解)
9. [GachaKit 詳解](#gachakit-詳解)
10. [PZAccountKit 與 HoYoLab API 互動](#pzaccountkit-與-hoyolab-api-互動)
11. [其他維護注意事項](#其他維護注意事項)

---

## 專案概述

### 支援平台

- **iOS / iPadOS**: iOS 14.0+（完整功能需 iOS 17+; 小工具對 iOS 16.2+ 暫時開放使用）
- **macOS (Catalyst)**: macOS 14.0+
- **watchOS**: watchOS 9.2+
- **visionOS**: 不支援。

### 支援的遊戲

- 原神 (Genshin Impact)
- 崩壞：星穹鐵道 (Houkai: Star Rail) *
- 絕區零 (Zenless Zone Zero) - 部分功能

> `*:` **Honkai** 是官方故意使用的錯誤拼寫，旨在方便英語母語者不把這個詞唸成「薅開」。但「崩壞」的日語羅馬音只對應「Houkai」。

### 核心技術棧

- **Swift 6.0** 與 Swift Concurrency
- **SwiftUI** 作為主要 UI 框架
- **SwiftData** (iOS 17+) / **CoreData** (iOS 16 向下相容)
- **WidgetKit** 用於桌面小工具與鎖屏小工具
- **ActivityKit** 用於 Live Activity（實時活動）
- **WatchConnectivity** 用於 iPhone ↔ Apple Watch 通訊

---

## Local Swift Package 詳解

專案採用模組化架構，所有核心程式碼均以 Local Swift Package 形式組織於 `Packages/` 目錄下。以下按重要性列出主要套件與內含 Target／模組，並給出檔案路徑以利索引。

### 1. PZKit (核心基礎套件)

**位置**: `Packages/PZKit/`

PZKit 是整個專案的基礎套件，提供兩個主要模組：

#### PZBaseKit

最底層的基礎模組，主要檔案分布：

| 子目錄/檔案 | 說明 |
|------------|------|
| `AppUtils/` | 應用程式通用工具類 |
| `BaseTypes/` | 基礎資料型別定義 |
| `FoundationImpl/` | Foundation 框架擴展（如 `DateFormatter+Extensions`）|
| `OSImpl/` | 跨平台 OS 層抽象（含 `ScreenVM`、`OS` 判斷工具、`TaskManagedVM`）|
| `AppUtils/ScreenTimeLimiter.swift` | App 啟動限制、背景任務輔助 |
| `BundleGroupIDs.swift` | App Group 識別碼定義 |
| `UserDefaultsKeys_Base.swift` | UserDefaults 鍵值定義 |
| `ReexportedModules.swift` | 重新匯出的第三方模組（Defaults, Alamofire, SFSafeSymbols 等）|

**主要第三方依賴**：
- `Defaults`: 型別安全的 UserDefaults 封裝
- `Alamofire`: 網路請求框架
- `SFSafeSymbols`: SF Symbols 型別安全存取
- `CodableFileMonitor`: 檔案監控工具

#### PZAccountKit

帳號管理與 API 互動模組，包含：

| 子目錄/檔案 | 說明 |
|------------|------|
| `PZProfileRelated/` | 使用者檔案（Profile）相關。`PZProfileMO.swift` 為 SwiftData Model、`PZProfileManagerVM.swift` 為前端管理器、`DBActors/` 內有 `PZProfileActor`/`CDProfileMOActor`。|
| ├─ `PZProfileMO.swift` | SwiftData Model Object |
| ├─ `PZProfileSendable.swift` | Sendable 資料傳輸物件 |
| ├─ `PZProfileRef.swift` | Profile 參照指標 |
| ├─ `PZProfileManagerVM.swift` | Profile 管理 ViewModel |
| └─ `DBActors/` | SwiftData Actor 實作 |
| `HoYoAPIs/` | HoYoLab/米遊社 API 實作，`HoYo` enum、`URLRequestConfig`、`URLRequestHelper` 為核心；子目錄 `DailyNoteRelated/`、`LoginRelated/`、`HoYo_BasicTypes/` 內含各遊戲模型與 API 封裝。|
| `NotificationRelated/` | 推播通知管理 |
| `WatchSputnik.swift` | `AppleWatchSputnik` 單例，封裝 WatchConnectivity 雙向同步 |

> **Target Summary**：`PZKit` 內含 `PZBaseKit`、`PZAccountKit` 兩個 targets，前者不需資源，後者附帶 `Resources/`（語系字串、模板）。

---

### 2. PZCoreDataKit (資料持久化套件)

**位置**: `Packages/PZCoreDataKit/`

專門處理 CoreData/SwiftData 資料持久化，分為四個 targets：

| 模組名稱 | 說明 |
|---------|------|
| `PZCoreDataKitShared` | 共用型別與協定，包含 `PersistentIdentifier`、`CDAccountMOActor`、`BackgroundTaskAsserter` 等工具 |
| `PZCoreDataKit4LocalAccounts` | CoreData `AccountMO4GI` 模型與 Actor，支援舊版帳號檔案匯入 |
| `PZCoreDataKit4GachaEntries` | CoreData `CDGachaMO4GI/HSR` 模型，提供舊抽卡資料解析 |
| `PZProfileCDMOBackports` | iOS 16 專用的 Profile CoreData 實作，與 SwiftData 接面透過 `PZProfileSendable` |

**資料遷移說明**：
- 舊版披薩助手使用 CoreData 儲存資料
- 新版統一披薩引擎使用 SwiftData（iOS 17+）
- `PZProfileCDMOBackports` 提供 iOS 16 的 CoreData 實作
- 啟動時會自動偵測並遷移舊版資料

---

### 3. WallpaperKit (桌布/背景套件)

**位置**: `Packages/WallpaperKit/`

管理應用程式視覺背景，包含兩個模組：

| 模組名稱 | 說明 |
|---------|------|
| `WallpaperKit` | 提供 `WallpaperAsset`, `WallpaperTheme`, `UserWallpaperFileHandler` 等型別，自帶 Assets 目錄 |
| `WallpaperConfigKit` | SwiftUI 前端與設定邏輯，依賴 `WallpaperKit` + `AlertToast` + `PZBaseKit` |

**功能**：
- 定義 App 視圖背景、Widget 背景、LiveActivity 背景
- 支援使用者自訂桌布
- 提供遊戲角色立繪背景

---

### 4. EnkaKit (Enka Networks 整合套件)

**位置**: `Packages/EnkaKit/`

與 [Enka.Network](https://enka.network/) 服務整合，提供角色展櫃查詢與顯示功能，並封裝本地化資料庫、資料摘要、前端展示。

#### Backend 模組 (`EnkaKitBackend/`)

| 子目錄 | 說明 |
|--------|------|
| `EnkaDB/` | Enka 資料庫封裝，`EnkaDBProtocol`、`EnkaDB4GI.swift`、`EnkaDB4HSR.swift`、`DBModelsImpl.swift` 負責在本地維持 JSON DB。|
| `QueriedModels_Enka/` | Enka API 查詢結果模型 |
| `QueriedModels_HoYoLab/` | HoYoLab 角色資料模型（補充 Enka 不提供的欄位）|
| `ArtifactRating/` | 聖遺物評分系統（`ARDB_Models`, `AR_Options`, `AR_SummaryImpl`）|
| `SummarySupport/` | 角色資料摘要生成（`AvatarSummarized_*` 初始化器、`ProfileSummarized`）|
| `SharedTypes/` | 共用型別（`GameElement`, `LifePath`, `PropertyType` 等）|
| `HakushinQuery/` | Hakushin API 查詢（主要供名片展示使用）|
| `Utils/` | 共用工具（快取處理、URL 生成、資料校驗）|

#### Frontend 模組 (`EnkaKitFrontend/`)

| 檔案/目錄 | 說明 |
|-----------|------|
| `EnkaShowCaseView.swift` | 展櫃主視圖 |
| `EachAvatarStatView.swift` | 單角色詳細面板 |
| `AvatarStatCollectionTabView.swift` | 角色集合分頁視圖 |
| `CharacterIconViews/` | 角色圖示元件 |
| `CaseProfileVM.swift` | 展櫃 ViewModel |

**第三方依賴**：
- `EnkaDBGenerator`: Enka 資料庫生成器
- `ArtifactRatingDB`: 聖遺物評分資料庫

---

### 5. GachaKit (抽卡記錄管理套件)

**位置**: `Packages/GachaKit/`

完整的抽卡記錄管理系統。

#### Backend 模組 (`Backends/`)

| 子目錄 | 說明 |
|--------|------|
| `GachaFetch/` | 抽卡記錄抓取：`GachaClient`, `GachaFetch_HoYoAPIImpl` (HoYo API), `GachaURLGenerator`, `GachaFetch_Enums`. |
| `GachaExchange/` | 資料匯入匯出：`GachaDocument`, `GachaExchange_Enums`, `UIGFModels/`（含 `UIGFv4`, `SRGFv1`, `GIGF` 模型）。|
| `GachaPersistence/` | SwiftData `GachaActor`, `PZGachaEntryMO`, `PZGachaProfileMO`, 以及 `PZGachaEntrySendableDocument`. |
| `CDGachaMO/` | CoreData 相容層，用於舊版資料遷移與「難民檔」匯入。|
| `GMDBRelated/` | Gacha Meta Database 交握 (`GachaMeta.Sputnik`). |

#### Frontend 模組 (`Frontends/`)

| 子目錄/檔案 | 說明 |
|-------------|------|
| `GachaRootView.swift` | 抽卡功能根視圖（整合 `GachaProfileSwitcher`, `GachaExchange` 流程）。|
| `GachaVM.swift` | 主要 ViewModel，結合 `GachaActor` 與 UI。|
| `GachaProfileViews/` | 檔案管理（`GachaProfileView`, `GachaProfileDetailedListView`, `GPV_Components`）。|
| `GachaFetchViews/` | 抓取流程 UI（輸入 URL、選擇卡池、顯示進度）。|
| `GachaExchangeViews/` | 匯入匯出 Wizard+
| `CommonComponents/` | 共用 UI 元件與 Toast。|

**支援的資料格式**：

| 格式 | 匯入 | 匯出 | 說明 |
|------|------|------|------|
| UIGF v4.1 | ✅ | ✅ | 統一可互換抽卡格式（全遊戲）|
| SRGF v1.0 | ✅ | ✅ | 星穹鐵道專用格式 |
| GIGF (JSON) | ✅ | ❌ | UIGF v2.2~v3.0 舊格式 |
| GIGF (Excel) | ✅ | ❌ | UIGF v2.0~v2.2 Excel 格式 |
| 胡桃難民檔 | ✅ | ❌ | SQLite 資料庫格式 |
| 舊披薩難民檔 | ✅ | ❌ | PropertyList 格式 |

**第三方依賴**：
- `GachaMetaGenerator`: 抽卡元資料生成器
- `CoreXLSX`: Excel 檔案解析

---

### 6. PZWidgetsKit (小工具共用套件)

**位置**: `Packages/PZWidgetsKit/`

Widget 共用程式碼，可由 Swift Package Manager 管理。

| 子目錄/檔案 | 說明 |
|-------------|------|
| `BasicTypesAndConfigs/` | 基礎型別與設定 |
| `IntentTimelineProviderImpl.swift` | Timeline Provider 協定實作 |
| `LiveActivityRelated/` | 實時活動相關 |
| `SPMManagableIntents/` | SPM 可管理的 Intent |
| `ViewsForDesktopWidgets/` | 桌面 Widget 視圖 |
| `ViewsForEmbeddedWidgets/` | 鎖屏 Widget 視圖 |
| `ViewsPlatformIndependent/` | 平台無關視圖 |

---

### 7. PZHoYoLabKit (HoYoLab 進階功能套件)

**位置**: `Packages/PZHoYoLabKit/`

HoYoLab/米遊社的進階功能模組。

| 功能模組 | 說明 |
|---------|------|
| `BattleReport/` | 深淵/忘卻之庭戰報 |
| `CharacterInventory/` | 角色庫存清單 |
| `Ledger/` | 原石/星瓊帳簿 |

每個功能模組包含：
- `HoYoAPIImpl/`: API 實作
- `Models/`: 資料模型
- `Views/`: UI 視圖

---

### 8. 其他套件

| 套件名稱 | 說明 |
|---------|------|
| `PZAboutKit` | 關於頁面 |
| `PZInGameEventKit` | 遊戲內活動資訊（事件排程、素材整合）|
| `GITodayMaterialsKit` | 原神每日素材（`TodayMaterialModel`, `MaterialProvider`, UI 視圖）|
| `PZHelper` | iOS/macOS 主程式套件（詳見 [跨平台顯示架構](#跨平台顯示架構-pzhelper)）|
| `PZHelper-Watch` | watchOS 主程式套件（`WatchApp` 的 SwiftUI 入口、簡化 UI）|

> **PZHelper 子目錄快速索引**：
> - `PZH_Backends/`：`InternalOSImpls/`（`ScreenVM`, `Broadcaster` hook）、`ViewPeripherals/`（Modifier）、`StructImplsAsView/`（公用視圖結構）。
> - `PZH_Frontends/`：`ContentViewRoot/`, `RootTabViews/`, `PZH_Features/`（`TodayDashboard`, `ProfileManager`, `HoyoMap` 等模組化 Feature）。
> - `PZH_iOS14/`：iOS 14~16 的降級 UI 入口（`ContentView4iOS14`, `RefugeeVM4iOS14`）。
> - `Resources/`：多語系字串與圖資。

---

## Package 依賴關係

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                 PZHelper                                 │
│   (iOS/macOS 主 App，整合 Enka、Gacha、HoYoLab、Widgets、Wallpaper 等模組)    │
└──────────────┬─────────────────────────────┬────────────────────────────┘
           │                             │
     ┌─────▼─────┐                 ┌─────▼─────┐
     │  EnkaKit  │                 │ GachaKit  │
     │ (展櫃)     │                 │ (抽卡)     │
     └─────┬─────┘                 └─────┬─────┘
           │                             │
      ┌────────▼────────┐          ┌─────────▼─────────┐
      │   WallpaperKit   │          │  PZHoYoLabKit      │
      │ (背景/資產)       │          │ (戰報/帳簿/角色庫) │
      └────────┬────────┘          └─────────┬─────────┘
           │                             │
           ├──────────────┬──────────────┤
           ▼              ▼              ▼
    ┌────────────┐ ┌────────────┐ ┌────────────┐
    │PZInGameEvent│ │GITodayMed. │ │PZWidgetsKit │
    └────────────┘ └────────────┘ └─────┬──────┘
                        │
               ┌────────────────▼────────────────┐
               │             PZKit               │
               │  ┌───────────────────────────┐  │
               │  │        PZAccountKit       │  │
               │  │ (HoYo API / Profile 管理) │  │
               │  └─────────────┬─────────────┘  │
               │                │                │
               │        ┌───────▼───────┐        │
               │        │   PZBaseKit   │        │
               │        │ (OS/Fnd Utils)│        │
               │        └───────┬───────┘        │
               └────────────────┼────────────────┘
                        │
                 ┌──────────────▼──────────────┐
                 │          PZCoreDataKit       │
                 │  (CoreData/SwiftData 遷移)   │
                 └──────────────────────────────┘
```

**依賴表**：

| 來源 Package | 依賴 | 目的 |
|--------------|------|------|
| `PZHelper` | `EnkaKit`, `GachaKit`, `PZHoYoLabKit`, `WallpaperKit`, `GITodayMaterialsKit`, `PZWidgetsKit`, `PZInGameEventKit`, `PZAboutKit`, `PZHoYoLabKit`, `PZKit`, `AlertToast` | 組成 App 全功能 |
| `GachaKit` | `PZKit`, `EnkaKit`, `PZCoreDataKit`, `GachaMetaGenerator`, `CoreXLSX`, `AlertToast` | 抽卡資料處理、匯入匯出 |
| `EnkaKit` | `PZKit`, `WallpaperKit`, `EnkaDBGenerator`, `ArtifactRatingDB` | Enka 展櫃與評分 |
| `PZWidgetsKit` | `PZKit`, `GITodayMaterialsKit`, `PZInGameEventKit`, `WallpaperKit` | Widget 可共享邏輯 |
| `PZHoYoLabKit` | `PZKit`, `EnkaKit`, `WallpaperKit` | 進階 HoYoLab 功能 |
| `PZHelper-Watch` | `PZKit` | Watch 端只取 Profile/Account 能力 |

> 若新增 Package，應檢查 `Package.swift` 中的 `sharedSwiftSettings`，保持統一的警告與實驗特性設定；同時確認 `PZHelper`、`WidgetExtension`、`WatchApp` Target 是否需要連帶引用。

**特殊依賴說明**：
- `PZHelper-Watch` 僅依賴 `PZKit`，無法使用 `EnkaKit`、`GachaKit` 等進階功能
- `PZWidgetsKit` 可被 `PZHelper` 和 `WidgetExtension` 共同依賴
- 外部 Package（如 `EnkaDBGenerator`、`GachaMetaGenerator`）由 Pizza Studio 維護

---

## Widgets 組態詳解

### 架構分層

Widget 實作分為兩層：

#### 1. SPM 管理層 (`PZWidgetsKit`)

可由 Swift Package Manager 管理的共用程式碼，目標是讓 Widget 相關的邏輯可在 App 與 Extension 之間重複使用：

- **視圖元件**：所有 Widget 的 SwiftUI 視圖
- **Timeline Provider 協定**：跨 iOS 版本的 Provider 抽象
- **Live Activity**：實時活動視圖與後端
- **共用設定**：Widget 設定項
- **Intent/Configuration**：`SPMManagableIntents/WidgetRefreshIntent.swift`, `BasicTypesAndConfigs/WidgetSharedSettings.swift`
- **資源**：`Resources/Localized` 字串可由 SPM 供 App/UI 預覽使用

#### 2. Xcode Target 層 (`WidgetExtension/`)

必須通過 Xcode 直接 build 的內容：

```
WidgetExtension/
├── Modules/
│   ├── Widgets/
│   │   ├── Widgets4Desktop/          # 桌面 Widget
│   │   │   ├── SingleProfileWidget.swift
│   │   │   ├── DualProfileWidget.swift
│   │   │   ├── OfficialFeedWidget.swift
│   │   │   └── MaterialWidget.swift
│   │   ├── Widgets4Embedded/         # 鎖屏 Widget & watchOS 複雜功能
│   │   │   └── (多個鎖屏小工具)
│   │   └── LiveActivityWidget/       # 實時活動 Widget
│   ├── BackendModules/               # Widget 後端邏輯
│   ├── OSImpl.swift                  # Extension 專屬 OS 配置
│   ├── PizzaImpl.swift               # App Group / Defaults 初始化
│   └── WidgetsBoundle.swift          # Widget Bundle 入口
├── Info.plist                        # iOS Widget 設定
└── Info-Watch.plist                  # watchOS Widget 設定
```

### 必須通過 Xcode Target 的原因

1. **Widget Bundle 入口**：`@main` 標記的 `WidgetBundle` 必須在 Target 內才能連到 Extension life-cycle。
2. **Intent 定義/匯出**：`PZWidgetsKit` 只能定義 `AppIntent` 型別，真正的 `.intentdefinition`、`INIntent` wrapper 仍需在 Target 註冊，並於 `Info.plist` 聲明。
3. **Extension 生命週期**：Widget Extension 需要獨立的 `UIApplicationDelegateAdaptor` 與 `AppGroup` 初始化碼（位於 `BackendModules/PizzaImpl.swift`）。
4. **Entitlements**：Widget Extension 使用的 App Group、`com.apple.developer.usernotifications.filtering` 等權限必須在目標層級設定，並保持與主 App 相同。
5. **敏感資料隔離**：只有經 App Group 允許的資料（如 `Defaults[.pzProfiles]`）能被 Extension 讀取，其他資料（如 SwiftData）必須透過 Widget Timeline Provider 轉譯為快取。

---

## iOS 16 與 iOS 17+ 相容性策略

### 核心策略：雙軌制

專案同時維護兩套實作：

| 功能 | iOS 16 | iOS 17+ |
|------|--------|---------|
| 資料持久化 | CoreData | SwiftData |
| Widget Intent | IntentConfiguration | AppIntentConfiguration |
| Profile Actor | `CDProfileMOActor` | `PZProfileActor` |
| Gacha Actor | `CDGachaMOActor` | `GachaActor` |

### Widget 相容性實作

```swift
// WidgetsBoundle.swift 中的雙軌實作

@available(iOS 17.0, macCatalyst 17.0, *)
struct SingleProfileWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(...)  // iOS 17+ 使用 AppIntent
    }
}

@available(iOS 16.2, macCatalyst 16.2, *)
struct INSingleProfileWidget: Widget {
    let kind: String = "WidgetView".asBackportedWidgetKindName
    
    var body: some WidgetConfiguration {
        IntentConfiguration(...)  // iOS 16 使用 Intent
    }
}
```

### Timeline Provider 協定橋接

```swift
// IntentTimelineProviderImpl.swift

// iOS 16 使用的協定
public protocol INThreadSafeTimelineProvider: IntentTimelineProvider, Sendable 
    where Intent: AppIntentUpgradable {
    associatedtype NextGenTLProvider: CrossGenServiceableTimelineProvider
    var asyncTLProvider: NextGenTLProvider { get }
}

// 跨版本共用的 Provider 協定
public protocol CrossGenServiceableTimelineProvider: Sendable {
    func placeholder() -> Self.Entry
    func snapshot(for configuration: Self.Intent) async -> Entry
    func timeline(for configuration: Self.Intent) async -> Timeline<Entry>
}
```

### 自動隱藏機制

當系統版本為 iOS 17+ 時，舊版 Widget 會自動隱藏：

```swift
extension Array where Element == WidgetFamily {
    @MainActor var backportsOnly: Self {
        PZWidgets.useBackports ? self : []  // iOS 17+ 返回空陣列
    }
}
```
### 快取同步策略

- **資料來源**：Widget 僅能使用 `Defaults`、`CodableFileMonitor`、`App Group` 內的 JSON 檔案。`GachaKit`、`EnkaKit` 均提供 `Sendable` struct 以供 Timeline 進行序列化。
- **資料刷新**：`PZWidgetsKit.WidgetRefreshIntent` 可由使用者進行手動刷新；`Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()` 會在 Profile 變更、Enka 快取更新時自動觸發。
- **iOS 16 Backport**：`IN*WidgetProvider` 需要保證 Thread-Safe，故 `INThreadSafeTimelineProvider` 使用 `asyncTLProvider` 於背景 Task 中執行，避免在 Objective-C Intent handler 中直接觸碰 Swift Concurrency 物件。

---

## 跨平台顯示架構 (PZHelper)

### ScreenVM：統一的畫面狀態管理

`ScreenVM` 是跨平台顯示的核心，位於 `PZBaseKit/OSImpl/PizzaMIT/_SUI_ScreenVM.swift`：

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

#### macOS (Catalyst)
- 固定使用 `.landscape` 方向
- 預設顯示側邊欄 (`.all`)
- 最小視窗尺寸限制

#### iPadOS
- 支援螢幕旋轉偵測
- 橫向時顯示側邊欄
- 直向時隱藏側邊欄

#### iPhoneOS
- 根據 `horizontalSizeClass` 判斷佈局
- 緊湊模式下使用單欄佈局
- 支援極端緊湊模式（SE3 放大）

### NavigationSplitView 佈局

```swift
// ContentView.swift

NavigationSplitView(
    columnVisibility: $screenVM.splitViewVisibility,
    preferredCompactColumn: $viewColumn
) {
    // 側邊欄：Today 頁面
    NavigationStack {
        TodayTabPage(wrappedByNavStack: false)
    }
} detail: {
    // 主內容區
    AppRootPageViewWrapper(tab: rootNavVM.rootPageNav)
}
```
### UI 模組劃分

- **Root 層 (`ContentViewRoot/`)**：`ContentView`, `RootNavVM`, `AppRootPage`。處理 NavigationSplitView、Tab 切換。
- **Tab 層 (`RootTabViews/`)**：`TodayTabPage`, `DetailPortalTabPage`, `UtilsTabPage`, `AppSettingsTabPage`。每個 Tab 對應一個 Feature 模組。
- **Feature 層 (`PZH_Features/`)**：
    - `TodayDashboard/`：DailyNote、官方公告、活動入口等綜合資訊；
    - `ProfileManager/`：帳號 CRUD、排序、同步；
    - `DetailPortalComponents/`：Enka 展櫃、抽卡記錄捷徑；
    - `HoyoMap/`：即時地圖／外部連結；
    - `StartupModifiers/`：啟動任務、OOBE 等。
- **Backend 層 (`PZH_Backends/`)**：UI 無關的輔助，如 `Broadcaster`, `ScreenVM`, `ViewPeripherals` 各種 Modifier（`trackCanvasSize`, `react(to:)`）。

> **降級支援**：`PZH_iOS14/ContentView4iOS14.swift` 使用 `TabView` + `NavigationView`，並透過 `RefugeeVM4iOS14` 注入最小必要功能。當 `#available(iOS 17.0, *)` 為 false 時由入口 `PZHelper.makeMainScene()` 自動切換。

---

## iPhone 與 Apple Watch 資料互通

### 通訊架構

使用 `WatchConnectivity` 框架實現雙向通訊：

```swift
// WatchSputnik.swift

public final class AppleWatchSputnik: NSObject, ObservableObject, WCSessionDelegate {
    public static let shared = AppleWatchSputnik()
    
    // 發送帳號資料
    public func sendAccounts(_ accounts: [PZProfileSendable], _ message: String)
    
    // 接收帳號資料（watchOS 端）
    public func session(_ session: WCSession, didReceiveMessage message: [String: Any])
}
```

**資料格式**：

```swift
public struct PZProfileSendable: Codable, Hashable, Identifiable, Sendable {
    public var uuid: UUID
    public var uid: String
    public var game: Pizza.SupportedGame
    public var server: HoYo.Server
    public var cookie: String
    public var deviceFingerPrint: String
    public var sTokenV2: String?
    public var deviceID: String
    public var allowNotification: Bool
}
```

**訊息 Key**：

| Key | 說明 |
|-----|------|
| `"message"` (`AppleWatchSputnik.kMessageKey`) | 傳送文字通知（顯示在 Watch App overlay）|
| `uidWithGame` | 例如 `"gi-800123456"`，作為字典 key |

### 資料同步流程

#### iPhone → Apple Watch

1. 使用者在 iPhone 上新增/修改帳號
2. `ProfileManagerVM` 觸發同步
3. `AppleWatchSputnik.sendAccounts()` 發送資料
4. 資料以 JSON 格式透過 `WCSession.sendMessage()` 傳輸

#### Apple Watch 接收處理

```swift
// watchOS 端處理
extension PZProfileActor {
    public func watchSessionHandleIncomingPushedProfiles(
        _ receivedProfileMap: [String: PZProfileSendable]
    ) {
        // 1. 刪除不存在的 Profile
        // 2. 更新已存在的 Profile
        // 3. 插入新的 Profile
        // 4. 同步到 UserDefaults
        // 5. 更新通知設定
    }
}
```
**背景任務**：`BackgroundTaskAsserter`（來自 `PZCoreDataKitShared`）確保在 watchOS 後台執行期間資料寫入不被取消。若 assertion 被系統提前終止，會記錄到 Console 以便除錯。

**差異化邏輯**：

- watchOS 端只保留 `PZProfileMO` 的必要欄位（通知、UID、Cookie），並在合併期間透過 `inherit(from:)` 維持 UUID，避免通知重複。
- iOS 端會於 `ProfileManagerVM.didObserveChangesFromSwiftData()` 中呼叫 `Broadcaster.shared.reloadAllTimeLinesAcrossWidgets()`，進而刷新 Watch Complication/Widget（若已安裝）。

**限制**：

- `WCSession.sendMessage` 需在裝置連線且前景狀態才能執行，必要時回退到 `transferCurrentComplicationUserInfo`（尚未實作）。
- 目前僅同步帳號資訊；未來如需同步抽卡記錄，需新增 `transferFile` 或 `transferUserInfo` 管道。

### 資料格式

使用 `PZProfileSendable` 作為傳輸格式：
- Codable & Sendable
- 包含完整的帳號資訊
- 使用 `uidWithGame` 作為唯一識別碼

---

## EnkaKit 詳解

### 架構概述

EnkaKit 負責與 [Enka.Network](https://enka.network/) 服務整合，提供角色展櫃查詢與顯示功能。

### Backend 元件

#### EnkaDB (資料庫)

```swift
public protocol EnkaDBProtocol: AnyObject, Sendable {
    associatedtype QueriedResult: EKQueryResultProtocol
    associatedtype QueriedProfile: EKQueriedProfileProtocol
    
    var locTable: Enka.LocTable { get set }  // 本地化表
    var isExpired: Bool { get set }
    
    func query(for uid: String) async throws -> QueriedProfile
    func onlineUpdate() async throws -> Self
}
```

實作類：
- `EnkaDB4GI`: 原神資料庫
- `EnkaDB4HSR`: 星穹鐵道資料庫

#### QueriedModels (查詢模型)

| 協定 | 說明 |
|------|------|
| `EKQueryResultProtocol` | API 回應結果 |
| `EKQueriedProfileProtocol` | 玩家資料 |
| `EKQueriedRawAvatarProtocol` | 原始角色資料 |

#### ArtifactRating (聖遺物評分)

```swift
// 評分請求
struct ArtifactRatingRequest {
    var avatar: Enka.AvatarSummarized
    var options: AROptions
}

// 評分結果
struct ArtifactRatingSummary {
    var totalScore: Double
    var rank: String  // S/A/B/C/D
}
```

#### SummarySupport (資料摘要)

將原始 API 資料轉換為統一的展示格式：

```swift
public struct AvatarSummarized {
    var mainInfo: MainInfo          // 基本資訊
    var equippedWeapon: WeaponPanel // 武器資訊
    var artifacts: [ArtifactInfo]   // 聖遺物
    var props: [PropertyPair]       // 屬性面板
}
```

### Frontend 元件

| 元件 | 說明 |
|------|------|
| `EnkaShowCaseView` | 展櫃主視圖容器 |
| `ShowCaseListView` | 角色列表視圖 |
| `EachAvatarStatView` | 單角色詳細面板 |
| `AvatarStatCollectionTabView` | 分頁式角色集合 |
| `CharacterIconViews/` | 角色圖示元件庫 |
| `CaseProfileVM` | 展櫃 ViewModel |

### 快取機制

```swift
extension EKQueriedProfileProtocol {
    // 儲存到本地快取
    public func saveToCache()
    
    // 讀取本地快取
    public static func getCachedProfile(uid: String) -> Self?
    
    // 清除快取
    public static func removeCachedProfile(uid: String)
    
    // 獲取所有快取
    public static func getAllCachedProfiles() -> [String: Self]
}
```

快取位置：`ApplicationSupport/[BundleID]/CachedAvatars/FromEnkaNetworks/`
### 資料流（Backend → Frontend）

1. `Enka.Sputnik.fetchEnkaQueryResultRAW(uid:type:)` 透過 `EnkaDBProtocol` 取得快取或呼叫遠端 API。
2. 回傳的 `EKQueryResultProtocol` 內含 `detailInfo` 與 `message`。若 `message` 為 `nil` 代表成功。
3. `EKQueriedProfileProtocol.inheritAvatars(from:)` 將既有快取和新資料合併，避免 API 未回傳全部角色時資料丟失。
4. `AvatarSummarized` 透過 `SummarizerImpls` 將 `QueriedAvatar` 轉為 UI 友善結構。
5. `CaseProfileVM` 監聽 `Broadcaster.shared.localEnkaAvatarCacheDidUpdate`，更新 SwiftUI 視圖。

### 前後端模組對應

| Backend 模組 | 對應 Frontend 元件 | 說明 |
|---------------|-------------------|------|
| `EnkaDB` | `CaseProfileVM` | 提供本地化名稱、資源定位 |
| `ArtifactRating` | `EachAvatarStatView` | 顯示聖遺物分數、排名、加成來源 |
| `HakushinQuery` | `ProfileIconView` | 取得名片、美術資產 |
| `SharedTypes` | `CharacterIconViews` | 依元素/命途套用配色與圖示 |

### 快取與資料新鮮度

- `Defaults[.lastEnkaDBDataCheckDate]` 控制 DB 更新頻率（預設 2 小時）
- `EnkaDBProtocol.needsUpdate` 判斷語系或時間是否失效
- `Enka.Sputnik.migrateCachedProfilesFromUserDefaultsToFiles()`（iOS 17+）會啟動 SwiftData→檔案轉移
- 若 `EnkaDB` 線上更新失敗，會 fallback 到匯入於 App bundle 的備份 DB

---

## GachaKit 詳解

### 架構概述

GachaKit 是完整的抽卡記錄管理系統，支援多種資料格式的匯入匯出。

### Backend 元件

#### GachaClient (抽卡客戶端)

實作 `AsyncSequence` 協定，支援非同步迭代抓取：

```swift
public struct GachaClient<GachaType: GachaTypeProtocol>: AsyncSequence, AsyncIteratorProtocol {
    public init(gachaURLString: String) throws(ParseGachaURLError)
    
    public mutating func next() async throws(GachaError) 
        -> (gachaType: GachaType, result: GachaResult)?
}

// 使用方式
for try await (poolType, result) in gachaClient {
    // 處理每一頁的抽卡記錄
}
```

#### GachaPersistence (資料持久化)

使用 SwiftData 儲存抽卡記錄：

```swift
// 資料模型
@Model
final class PZGachaEntryMO {
    var id: String           // 抽卡記錄 ID
    var uid: String          // 玩家 UID
    var gachaType: String    // 卡池類型
    var itemId: String       // 物品 ID
    var time: String         // 抽卡時間
    var name: String         // 物品名稱
    var rankType: String     // 稀有度
}

// GachaActor：SwiftData ModelActor
@ModelActor
actor GachaActor {
    static let shared: GachaActor
    
    func insertEntries(_ entries: [PZGachaEntrySendable]) async throws
    func fetchAllGPIDs() async -> [GachaProfileID]
    func prepareUIGFv4Document(...) async throws -> GachaDocument
}
```

#### GachaExchange (資料交換)

**UIGFv4 格式結構**：

```swift
public struct UIGFv4: Codable {
    var info: UIGFInfo
    var giProfiles: [UIGFGachaProfile4GI]?
    var hsrProfiles: [UIGFGachaProfile4HSR]?
    var zzzProfiles: [UIGFGachaProfile4ZZZ]?
}

public struct UIGFGachaItem4GI: Codable {
    var uigfGachaType: String
    var gachaType: String
    var itemId: String
    var time: String
    var id: String
}
```

**格式轉換流程**：

```
GIGF (Excel) ──┐
               │
GIGF (JSON) ───┼──► UIGFv4 ──► PZGachaEntrySendable ──► SwiftData
               │
SRGF v1.0 ─────┤
               │
胡桃難民檔 ─────┘
```

### Frontend 元件

#### GachaVM (主要 ViewModel)

```swift
@Observable
public final class GachaVM: TaskManagedVM {
    public var allGPIDs: [GachaProfileID]        // 所有抽卡檔案
    public var currentGPID: GachaProfileID?      // 當前選中檔案
    public var currentPoolType: GachaPoolExpressible?  // 當前卡池
    public var mappedEntriesByPools: [GachaPoolExpressible: [GachaEntryExpressible]]
    
    // 核心方法
    func updateAllCachedGPIDs() async
    func prepareGachaDocumentForExport(...)
    func prepareGachaDocumentForImport(...)
    func importUIGFv4(...)
}
```

#### 視圖結構

```
GachaRootView
├── GachaProfileSwitcherView     # 檔案切換器
├── GachaProfileView             # 主視圖
│   ├── GachaProfileDetailedListView  # 詳細列表
│   └── GPV_Components/          # 子元件
├── GachaFetchViews/             # 抓取視圖
└── GachaExchangeViews/          # 匯入匯出視圖
```

### 難民資料遷移

支援從舊版應用遷移資料：

```swift
// 舊版披薩難民檔案
public struct PZRefugeeFile: Codable {
    var newProfiles: [PZProfileSendable]
    var oldProfiles4GI: [AccountMO4GI]
    var oldGachaEntries4GI: [CDGachaMO4GI]
}

// 胡桃難民檔案（SQLite）
public struct HutaoRefugeeFile {
    static func fromDatabase(url: URL) throws -> HutaoRefugeeFile
    func toUIGFv4() async throws -> UIGFv4
}
```
### 資料流（抓取 → 儲存 → 匯出）

1. **抓取**：`GachaClient` 解析使用者貼上的 URL，抽取 `authkey`, `region`, `sign_type` 等參數，並依序抓取卡池。
2. **正規化**：`GachaResult.list[i].toGachaEntrySendable()` 轉為 `PZGachaEntrySendable`，同時修正時區、物品 ID。
3. **儲存**：`GachaActor.insertEntries()` 以 SwiftData 寫入，另外對 iOS 16 於 `CDGachaMOActor` 進行遷移。
4. **統計/視圖**：`GachaVM.updateMappedEntriesByPools()` 拉取各卡池資料並分類，以備 UI 顯示。
5. **匯出**：`GachaActor.prepareGachaDocument()` 依指定格式產出 `GachaDocument`，並於前端顯示分享面板。

### Frontend 工作流程

| 流程 | 相關視圖 | 備註 |
|------|----------|------|
| 建立 Profile | `GachaProfileManagementView` | 可從 `EnkaKit` 快取中預填角色名稱 |
| 抓取記錄 | `GachaFetchViews/FetchWizard` | 支援處理多卡池、進度條、錯誤提示 |
| 匯入資料 | `GachaExchangeViews/ImportWizard` | 自動辨識格式、執行資料清洗（`correctedUIGFDateFormat`）|
| 匯出資料 | `GachaExchangeViews/ExportWizard` | 可選擇單檔案、多檔案、全檔案 |
| 查看統計 | `GachaProfileView` | 依卡池分類顯示五星歷史、趨勢圖 |

### 舊資料接收（難民檔）

- `PZRefugeeDocument`：PropertyList，包含舊版披薩帳號與抽卡記錄；讀入後會執行 `genshinDataRAW.fixItemIDs()` 與 `updateLanguage`。
- `HutaoRefugeeFile`：SQLite；透過 `CoreOffice/CoreXLSX` 或 `SQLite` API 解析，再轉為 `UIGFv4`。
- `GachaVM.migrateOldGachasIntoProfiles()`：背景任務會將 `Defaults[.pzProfiles]` 與舊資料合併，並清除 Legacy CoreData 內容。

---

## PZAccountKit 與 HoYoLab API 互動

### API 架構概述

PZAccountKit 封裝了與米遊社（中國）和 HoYoLab（國際）伺服器的互動。

### 伺服器區域

```swift
public enum AccountRegion: String {
    case miyoushe(SupportedGame)   // 中國大陸
    case hoyoLab(SupportedGame)    // 國際服
}
```

### API 請求生成

```swift
// HoyoAPI.swift

extension HoYo {
    // 生成記錄 API 請求
    public static func generateRecordAPIRequest(
        httpMethod: HTTPMethod = .get,
        region: AccountRegion,
        path: String,
        queryItems: [URLQueryItem],
        cookie: String?,
        deviceFingerPrint: String?,
        additionalHeaders: [String: String]?
    ) async throws -> DataRequest
}
```

### 請求配置

```swift
// URLRequestConfig.swift

public enum URLRequestConfig {
    // API 主機
    static func recordURLAPIHost(region: AccountRegion) -> String {
        switch region {
        case .miyoushe: "api-takumi-record.mihoyo.com"
        case .hoyoLab: "bbs-api-os.hoyolab.com"
        }
    }
    
    // 請求標頭
    static func defaultHeaders(region: AccountRegion, ...) async throws -> [String: String]
    
    // DS 簽名（動態密鑰）
    // 透過 URLRequestHelper.getDS() 生成
}
```

### 主要 API 功能

#### 1. 即時便箋 (DailyNote)

```swift
// NoteAPI4GI.swift
public static func note4GI(profile: PZProfileSendable) async throws -> any Note4GI

// 內部會根據 region 選擇 API：
// - miyoushe: /game_record/app/genshin/api/dailyNote (需要驗證)
// - hoyoLab: 同上（較少驗證）

// 如果主 API 失敗且有 sTokenV2，會 fallback 到 Widget API：
// - /game_record/app/genshin/aapi/widget/v2
```

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

#### 3. QR Code 登入流程

```swift
// QRCodeShared.swift
enum QRCodeShared {
    static let appID = "7"  // 崩壞2 的 App ID（用於生成 QR Code）
    static let appTag = "bh2_cn"
    static let url4Query = URL(string: "https://hk4e-sdk.mihoyo.com/bh2_cn/combo/panda/qrcode/query")!
    static let url4Fetch = URL(string: "https://hk4e-sdk.mihoyo.com/bh2_cn/combo/panda/qrcode/fetch")!
}
```

### PZHoYoLabKit 進階功能

#### 深淵/忘卻之庭戰報

```swift
// BattleReport/HoYoAPIImpl/
struct BattleReportAPI {
    static func fetchReport(profile: PZProfileSendable) async throws -> BattleReport
}
```

#### 帳簿查詢

```swift
// Ledger/HoYoAPIImpl/
struct LedgerAPI {
    static func fetchLedger(profile: PZProfileSendable, month: Int) async throws -> Ledger
}
```

#### 角色庫存

```swift
// CharacterInventory/HoYoAPIImpl/
struct CharacterInventoryAPI {
    static func fetchInventory(profile: PZProfileSendable) async throws -> [CharacterDetail]
}
```
### PZAccountKit ↔ PZHoYoLabKit 資料流程

1. `PZAccountKit` 管理登入狀態，並將 `cookie`, `deviceID`, `deviceFingerPrint` 存於 `PZProfileSendable`。
2. `PZHoYoLabKit` 透過 `PZAccountKit` 暴露的 `HoYo` API 與 Profiles，決定 region/game。
3. API 回應會寫入 `Defaults` 或 SwiftData（視功能而定），再由對應視圖（`FeatureModules/*/Views`）呈現。
4. Raised Error（如 `MiHoYoAPIError.retcode`）會透過 `AlertToast` 或 `Broadcaster.shared.showErrorToast` 顯示於 UI。

> **建議**：當 miHoYo 修改 API（例如需要新的 header）時，統一於 `URLRequestConfig`/`URLRequestHelper` 更新，並在 `HoYo` extension 中增加重試／風控處理，避免散布於各模組。

---

## 其他維護注意事項

### 1. 版本相容性

- **最低部署目標**：iOS 14.0 / macOS 14.0 / watchOS 9.0
- **完整功能需求**：iOS 17.0+
- **Swift 版本**：Swift 6.0（啟用 Strict Concurrency）

### 2. App Group 設定

所有資料共享（主 App、Widget、Watch）都依賴 App Group：

```swift
// BundleGroupIDs.swift
public let sharedBundleIDHeader = "group.Canglong.PizzaHelper"
```

### 3. 編譯警告設定

Package.swift 中啟用了編譯時間警告：

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
- 支援語言：中文簡體、中文繁體、日文、韓文、法文、德文、俄文等
- 本地化檔案位於各 Target 的 `Localizable.xcstrings`

### 5. 資料安全

- Cookie 等敏感資料存儲在 App Group 的 UserDefaults 中
- 使用 Keychain 存儲高敏感資訊（可選）
- 網路請求使用 HTTPS

### 6. 測試

- 單元測試位於各 Package 的 `Tests/` 目錄
- 使用 `@testable import` 進行內部測試

### 7. 已知技術債務

1. **iOS 16 相容層**：計畫在未來版本移除
2. **絕區零支援**：部分功能尚未完成
3. **CoreData 遷移**：舊版資料遷移邏輯可在確認無用戶需要後移除

### 8. 外部依賴更新

Pizza Studio 維護的外部 Package：
- `EnkaDBGenerator`: Enka 資料庫
- `GachaMetaGenerator`: 抽卡元資料
- `ArtifactRatingDB`: 聖遺物評分

這些 Package 需要定期更新以跟進遊戲版本。

### 9. API 變更應對

米哈遊的 API 可能隨時變更，需要注意：
- DS 簽名演算法變更
- API 路徑變更
- 請求標頭要求變更
- 驗證碼機制變更

建議關注社群討論（如 UIGF 組織）以獲取最新資訊。

- 建議建立 `DevDocs/APIChangeLog.md` 紀錄每次 header/salt 更新；可透過腳本 `Script/GI_RawAssetsPuller.swift` 類似方式自動化。

### 10. 建置、測試與維運建議

- **建置**：
    1. `BoostBuildVersion.swift` 會根據 `git describe` 更新 Xcode Build Number。
    2. `Makefile archive-ios` / `archive-mac` 集中 Xcodebuild 參數，直接生成可用於 App Store Review 的 Archive。
- **靜態檢查**：
    - `swift test --parallel` 覆蓋所有 Package；若只想檢查某模組，可進入對應資料夾執行。但這些 Swift Package 並沒有撰寫詳實的單元測試（EnkaKit 除外）。
- **資料庫遷移驗證**：
    - iOS 16/17 需雙機測試（模擬器 + 實機），以確認 CoreData/SwiftData 同步正常。
- **故障排除**：
    - Widget 不更新：檢查 `WidgetExtension/Modules/BackendModules/PizzaImpl.startupTask()` 是否成功呼叫 `PZWidgets.startupTask()`。
    - Watch 無法同步：確認 App Group ID 是否與 iPhone 相同，並查看 `Console` 中 `AppleWatchSputnik` log。
    - API 403：檢查 `URLRequestConfig.salt` 是否過期，或是否需要 `x-rpc-device_fp`／`x-rpc-device_id`。

### 11. 交接前檢查清單

- [ ] 更新 `DevDocs/MaintainerGuide.md` 版本日期與重大變更。
- [ ] 確認 `Packages/*/Package.swift` 版本號與第三方依賴是否為最新安全版。
- [ ] 執行 `Script/_assetUpdate4GI.sh`／`_assetUpdate4HSR.sh`，確保資產同步。
- [ ] Widget、Watch、主 App App Group 設定一致。

---

## 附錄：檔案結構速查

```
PizzaHelperUnited/
├── Packages/                    # Swift Packages
│   ├── PZKit/                   # 核心基礎
│   ├── PZCoreDataKit/           # 資料持久化
│   ├── EnkaKit/                 # Enka 整合
│   ├── GachaKit/                # 抽卡管理
│   ├── PZHoYoLabKit/            # HoYoLab 進階功能
│   ├── PZWidgetsKit/            # Widget 共用
│   ├── WallpaperKit/            # 桌布管理
│   ├── PZAboutKit/              # 關於頁面
│   ├── PZInGameEventKit/        # 遊戲活動
│   ├── GITodayMaterialsKit/     # 原神每日素材
│   ├── PZHelper/                # iOS/macOS 主程式
│   └── PZHelper-Watch/          # watchOS 主程式
├── ThePizzaHelper/              # iOS App Target
├── UnitedPizzaHelperEngine/     # macOS App Target
├── WatchApp/                    # watchOS App Target
├── WatchExtension/              # watchOS Extension
├── WidgetExtension/             # Widget Extension
├── INIntents4iOS16/             # iOS 16 Intent Extension
├── DevDocs/                     # 開發文件
├── Script/                      # 建置腳本
└── UnitedPizzaHelper.xcodeproj/ # Xcode 專案
```

---

*本文件由 Pizza Studio 維護團隊藉由 Codex 服務編寫。如有疑問，請聯繫原作者或查閱專案 README。*
