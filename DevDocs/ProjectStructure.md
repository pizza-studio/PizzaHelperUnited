# PZKit

為了方便多人開發維護、解決「非得登入專案主管的 Apple ID 才能正常編譯」的窘境，特此設立 PZKit 這個 SPM。

因為涉及多個平台的編譯，所以 `Package.swift` 的構造有些複雜、且有異於常見的 Swift Package。實際上呢，這個檔案是個 Swift JIT 腳本，不用擔心太多。

> 本文所有「米遊社」一詞均同時代稱米遊社與 HoYoLab，除非有特殊的說明。

> **本文件已完成一次事實核對**（對象：`Packages/` 目錄、各 `Package.swift` 的 `platforms` 與 `dependencies`、以及 `UnitedPizzaHelper.xcodeproj/project.pbxproj` 的 target 清單）。若日後新增／移除 SPM 套件或 Xcode target，請一併更新本文與 `MaintainerGuide.md`。
> 註：`DevDocs/DependencyGraph*.dot`／`.svg` 仍引用已移除的 `AbyssRankKit`、`PZDictionaryKit`，**尚未重新產生**，請勿以該圖為準。

幾個注意點：

1. 針對 SwiftUI 的全平台通用擴充放到 `PZBaseKit` 內。
2. `PZAccountKit` 負責存放與米遊社帳號登入有關的一些內容。
3. 前端內容只要是各 App 共用的，就放到 `PZHelper` 或 `PZHelper-Watch` 這兩個套件當中。
4. 開發時是統一開發，實際發行時會針對不同 App 分別設立不同的 Xcode target、以各自的 Bundle Identifier 區分彼此。
   - ⚠️ **Bundle Identifier 的用途只有「App 身分與資料容器」**：決定 App Group ID、iCloud Container、`sharedBundleIDHeader`、App 標題（拿鐵／披薩）與 App Store 連結。它**不用來決定支援哪些遊戲**——見 `PZBaseKit/BundleGroupIDs.swift` 的 `appGame: Pizza.SupportedGame? = .none`。
   - **各 App 一律同時支援《原神》《星穹鐵道》《絕區零》**，沒有「A 助手隱藏 B 遊戲內容」這種事。
   - 支援程度（見 `README.md`）：
    | 遊戲 | 支援程度 |
    |---|---|
    | 《原神》(GI) | 完整支援 |
    | 《星穹鐵道》(HSR) | 完整支援 |
    | 《絕區零》(ZZZ) | 目前僅 Daily Note（限 Widget、Live Activity、Today 頁）；進階支援暫不在近期規劃內 |
   - **角色素材的來源**（`EnkaKit/EnkaKitBackend/AssetSuppliable/`）：`EnkaKit` 有兩套並行的素材來源——
     - **本地素材**：隨 `EnkaKit` 附帶的 `Resources/Assets.xcassets`（如 `gi_character_*`、`hsr_character_*`、`idp*`）。`LocalAssetSuppliable` 提供 `iconAssetName` / `localIcon4SUI`，`Enka.queryImageAssetSUI(for:)` 自 `.currentSPM` bundle 取圖。
     - **線上素材**：`OnlineAssetSuppliable.onlineAssetURLStr` 提供網址、以 `AsyncImage` 載入，目前指向 `gi.yatta.moe` / `sr.yatta.moe`（ZZZ 尚未接）。
     - 角色圖示（`CharacterIconView`）只取本地，取不到就顯示空白問號 `blankQuestionedView`；名片圖示（`ProfileIconView.localFittingIcon4SUI`）則**本地優先、取不到才 fallback 到線上**。
   - DailyNote 的角色肖像素材、以及玩家遊戲進度統計畫面的圖示素材……這些內容是直接從米遊社伺服器載入的，不屬於上述素材機制的管轄範圍。

---

## Xcode Target 清單（實際專案）

`UnitedPizzaHelper.xcodeproj` 內含 9 個 native target：

| 類別 | Target | 備註 |
|---|---|---|
| 主 App | `TheLatteHelper` | **現行**發行對象；Xcode Cloud 建置目標 |
| 主 App | `ThePizzaHelper` | 前作，已停止維護 |
| 引擎 App | `UnitedPizzaHelperEngine` | macOS 引擎 |
| Watch App | `TheLatteWatchApp`、`PizzaWatchApp` | |
| Watch Extension | `TheLatteWatchAppExtension`、`PizzaWatchAppExtension` | |
| Widget Extension | `TheLatteWidgetExtension`、`ThePizzaWidgetExtension` | |

發版相關細節見倉庫根目錄的 `AGENTS.md`。

---

## SPM 元件清單

依賴層級由下而上排列。

### 第 0 層：無本地依賴

- **`PZCoreDataKit`**：CoreData / SwiftData 的持久化底座，四個 target：
  - `PZCoreDataKitShared`：共用型別與協定。
  - `PZCoreDataKit4LocalAccounts`：舊版本機帳號資料（`AccountMO4GI`）與 Actor。
  - `PZCoreDataKit4GachaEntries`：舊版抽卡記錄（`CDGachaMO4GI` / `CDGachaMO4HSR`）模型。
  - `PZProfileCDMOBackports`：iOS 16 專用的 Profile CoreData 實作（與 SwiftData 之間透過 `PZProfileSendable` 接面）。
  - 外部依賴：`Sworm`、`Defaults`。平台：iOS 14 / macOS 14 / watchOS 9。

### 第 1 層：核心

- **`PZKit`**：最基層，內含：
  - **`PZBaseKit`**：最最基層的包，包含 Foundation 擴充、OS 擴充、UserDefaults Keys 等。
  - **`PZAccountKit`**：依賴 `PZBaseKit`，但包含下述內容：
    - 本地帳號 SwiftData MO 與 DataActor 以及相關的衍生內容（`PZProfileRelated/`、`DBActors/`）。
    - HoYoLAB / 米遊社 API 的共用部分（`HoYoAPIs/`），含 DailyNote、登入、帳號驗證等；與 Watch 和 Widget 無關的部分另見下方各功能套件。
    - `WatchSputnik.swift`：`AppleWatchSputnik` 單例，封裝 WatchConnectivity 雙向同步。
  - 外部依賴：`Alamofire`、`Defaults`、`SFSafeSymbols`、`CodableFileMonitor`、`Sworm`。平台：iOS 14 / macOS 14 / watchOS 9 / visionOS 1。

- **`WallpaperKit`**：畫廊包，定義 App 的視圖背景、Widget 背景、LiveActivity 背景。內含 `WallpaperConfigKit`（設定前端）。外部依賴：`AlertToast`。平台：iOS 14 / macOS 14 / watchOS 9 / visionOS 1。

### 第 2 層：功能套件

- **`EnkaKit`**：與 Enka Networks 展櫃支援有關的包，但也負責了所有角色肖像顯示（含 `EnkaDB4GI` / `EnkaDB4HSR` 本地 JSON DB、聖遺物評分、展櫃查詢）。外部依賴：`EnkaDBGenerator`、`ArtifactRatingDB`。平台：iOS 14 / macOS 14 / visionOS 1（**不支援 watchOS**）。
- **`GachaKit`**：抽卡記錄管理模組（依賴 SwiftData 與 CoreData 相容層），功能如下：
  - 完整的 UIGFv4 / SRGF / GIGF 抽卡記錄匯入支援、以及前兩者的匯出支援。
  - 線上抓取抽卡記錄，需要使用者自備抽卡 URL。
  - 舊版資料繼承：本地「難民檔」（胡桃 SQLite、舊披薩 PropertyList）匯入；另經由 **CloudKit 私有資料庫**從 iCloud 繼承舊版抽卡記錄（見 `GachaPersistence/GachaActor`）。
  - 外部依賴：`GachaMetaGenerator`、`CoreXLSX`、`AlertToast`。平台：iOS 14 / macOS 14 / visionOS 1（**不支援 watchOS**）。
- **`GITodayMaterialsKit`**：原神每日素材。平台：iOS 14 / macOS 14 / watchOS 9 / visionOS 1。
- **`PZInGameEventKit`**：遊戲內活動資訊（事件排程、素材整合）。平台：iOS 14 / macOS 14 / watchOS 9 / visionOS 1。
- **`PZHoYoLabKit`**：米遊社進階功能。目前 `FeatureModules/` 內有：
  - `BattleReport`：深淵／忘卻之庭戰報。
  - `Ledger`：原石／星瓊帳簿。
  - `CharacterInventory`：角色庫存清單。
  - 平台：iOS 14 / macOS 14 / visionOS 1（**不支援 watchOS**）。
- **`PZAboutKit`**：關於頁面（含 `AppStoreRelated`）。平台：iOS 14 / macOS 14 / visionOS 1。

> ⚠️ 昔列為獨立套件的 `AbyssRankKit`（深淵榜單）與 `PZDictionaryKit`（披薩辭典）**現已不存在於 `Packages/`**，相關功能未以獨立 SPM target 形式留存。深淵戰報、帳簿、角色庫存三者是 `PZHoYoLabKit/FeatureModules/` 下的子目錄，**不是**獨立套件。

### 第 3 層：App 主程式包

- **`PZWidgetsKit`**：Widget 共用程式碼（Timeline Provider 協定、Live Activity、`SPMManagableIntents`、桌面／鎖屏 Widget 視圖）。平台：iOS 14 / macOS 14 / watchOS 9 / visionOS 1。
- **`PZHelper`**：iOS & macOS 版主程式包，整合 `PZKit`、`EnkaKit`、`GachaKit`、`PZHoYoLabKit`、`PZWidgetsKit`、`WallpaperKit`、`GITodayMaterialsKit`、`PZInGameEventKit`、`PZAboutKit`、`PZCoreDataKit`，另加 `AlertToast`。平台：iOS 14 / macOS 14 / visionOS 1。
- **`PZHelper-Watch`**：watchOS 版主程式包（**已非空包**）。
  - 依賴：`PZKit`（`PZBaseKit` + `PZAccountKit`）。**不依賴 WallpaperKit**。平台：**watchOS 10**。
  - 內容：`Modules/` 內含 `ContentView`、`NotificationController`、`OSImpl`、`WatchProfileDetailView`、`WatchStaminaDetailView`、`WatchWidgetSettingView` 等。

---

## 外部依賴來源

- **Pizza Studio 自有**：`EnkaDBGenerator`、`ArtifactRatingDB`、`GachaMetaGenerator`。三者為同一工作區內的獨立倉庫（`../EnkaDBGenerator`、`../ArtifactRatingDB`、`../GachaMetaGenerator`），隨遊戲改版各自發 tag。更新流程見倉庫根目錄 `AGENTS.md` 步驟 A。
- **第三方**：`Alamofire`、`Defaults`、`SFSafeSymbols`、`CodableFileMonitor`、`Sworm`、`AlertToast`、`CoreXLSX`、`XMLCoder`、`ZIPFoundation`、`swift-syntax`。

$ EOF.
