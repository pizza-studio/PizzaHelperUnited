# PizzaHelperUnited — AGENTS.md

本倉庫（`PizzaHelperUnited`）的工作 SOP。內容分兩類：

- **發版 SOP**（本文件主體）：本倉庫的「拿鐵小助手（The Latte Helper）」發版流程。以下每一條都經由**本倉庫**的檔案、git 歷史、以及既有工作階段的實際指令核實，並在必要處註明核實方式。
- **通用工作規則**：見 `~/.codewhale/global.md`（交付驗證、格式化禁令、SwiftPM sandbox 等）。本文件不重複。

> 除本倉庫外，同工作區（`/Users/shikisuen/Repos/_PizzaStudio`）另有以下三個倉庫，它們是本倉庫三個 SPM 依賴的上游（見步驟 A）：`EnkaDBGenerator`、`ArtifactRatingDB`、`GachaMetaGenerator`。這三個倉庫的發版流程不在本文件範圍內——本文件只在「更新依賴版本」時提到它們。

---

## 1. 專案身分（先看這節，避免搞錯對象）

| 名稱 | 狀態 | Bundle ID | ASC App ID |
|---|---|---|---|
| **The Latte Helper**（拿鐵小助手） | **現行**，唯一有在用 Xcode Cloud 的 App | `org.pizzastudio.TheLatteHelper` | `6757201427` |
| The Pizza Helper（披薩小助手） | **前作，已停止維護** | `Canglong.GenshinPizzaHepler.*` | `6747781470` |
| UnitedPizzaHelperEngine | macOS 引擎 App | — | — |

- Xcode Cloud 的建置目標**只有 `TheLatteHelper`**：`UnitedPizzaHelper.xcodeproj/xcshareddata/xcodecloud/manifest.json`。
- 兩款 App 共用同一套程式碼與 Xcode 專案，靠 Bundle ID 在執行時互相屏蔽不對應的遊戲內容。
- Bundle ID 的歷史備忘在 `DevDocs/MASBundleIDs.txt`。**「MAS」= Mac App Store**，指最初在 Mac App Store 上架的「原神披薩助手」；該檔記錄的是「原位升級頂替」所以**不得變動**的 legacy Bundle ID。
- ⚠️ 術語（統一用語）：本專案一律用 **`asc`** 指稱 App Store Connect CLI（`~/.local/bin/asc`，在 PATH 上），見步驟 D。**不使用其他代稱**：`asc-cli`、`mas-cli` 皆為舊稱、一律不再使用（`asc-cli` 另與別款工具撞名，見下；`mas-cli` 則與 Homebrew 的 `mas` 毫無關係，本機也沒有 `mas`）。看到「MAS」時只可能是 Mac App Store 語意（例如 `DevDocs/MASBundleIDs.txt` 的 legacy Bundle ID）。發版流程不需要、也不應去找 `mas`。
  - **上游專案**：[`rorkai/App-Store-Connect-CLI`](https://github.com/rorkai/App-Store-Connect-CLI)（本機安裝的是這一款）。**注意撞名**：另有一款不相關的 [`tddworks/asc-cli`](https://github.com/tddworks/asc-cli) 是 **Swift** 實作、版本號停在 `v0.1.x`，**不是**本機這一款——本機為 **Go** 二進位。回報問題或查文件時務必認明 `rorkai` 這一款。

## 2. 版本號規則（本 SOP 的核心）

| 項目 | 來源 | 說明 |
|---|---|---|
| `MARKETING_VERSION` | `UnitedPizzaHelper.xcodeproj/project.pbxproj`（共 18 處） | 行銷版本，如 `5.9.4` |
| `CURRENT_PROJECT_VERSION` | 同上 | 建置號，**= `git rev-list --count main` + 3067** |
| 發版 tag | git tag | `v<MARKETING_VERSION>-<CURRENT_PROJECT_VERSION>`，如 `v5.9.4-RC.3-6553` |
| 發版 commit | git | `proj: v<MARKETING_VERSION>-<CURRENT_PROJECT_VERSION>` |

建置號由 `./BoostBuildVersion.swift <MARKETING_VERSION>` 寫入；偏移量 3067 硬編碼在該腳本內。

**⚠️ 兩個必須知道的細節：**

1. **`BoostBuildVersion.swift` 必須在「版本 bump commit」之前執行。** 腳本讀的是**當下**的 commit 數，而它自己造成的變更會再多出 1 個 commit。因此跑腳本當下算出的 `count + 3067`，等於**最終 commit 的建置號**；若你在事後用 `git rev-list --count <bump-commit>` 反推，會得到「+1」的錯覺。核實樣本：`fecc7d9d` 建置號 6530／`f04640a1` 6534／`3c0d3b5a` 6523，皆與此規則相符。
2. 建置號只取決於歷史長度、**與內容無關**，所以「先跑腳本再改別的檔案」不會改號，但**任何額外的 commit 都會讓號碼前移**。順序錯了就得重跑。

## 3. 發版流程（依實際工作階段指令整理）

### 步驟 A：更新遠端資料依賴（可選，但常與發版同時進行）

Pizza Studio 自有的三個 SPM 依賴，其上游倉庫位於本倉庫的**同級目錄**：`../EnkaDBGenerator`、`../ArtifactRatingDB`、`../GachaMetaGenerator`。遊戲改版後它們會各自發新 tag。

1. 改 `Packages/EnkaKit/Package.swift`（`EnkaDBGenerator`、`ArtifactRatingDB`）與 `Packages/GachaKit/Package.swift`（`GachaMetaGenerator`）的 `.upToNextMajor(from:)`。
2. **務必用 Xcode 重新解析，不要手改 `Package.resolved`**——`originHash` 是 Xcode 計算的，手改會留下過期雜湊（Xcode Cloud 依賴此檔）：
   ```bash
   export DEVELOPER_DIR=$(./Script/find-nonbeta-xcode.swift 2>/dev/null)
   xcodebuild -resolvePackageDependencies -project UnitedPizzaHelper.xcodeproj \
     -scheme ThePizzaHelper -derivedDataPath Build/DerivedData \
     -clonedSourcePackagesDirPath Build/SourcePackages
   ```
3. **唯一被 git 追蹤的 resolved 檔**是 `UnitedPizzaHelper.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`（`.gitignore` 第 100–101 行忽略其他所有 `Package.resolved`，僅 un-ignore 此路徑）。**倉庫根目錄沒有、也不該有 resolved 檔。**
4. 提交訊息格式：`SPM // ARDB -> v1.4.0; GMDB -> v3.1.0; EnkaDB -> v2.1.0.`（參考 `ef894d2f`、`f75a6a30`）。
5. 驗收：`git diff` 應**只有**這三個 pin 與 `originHash` 變動，其餘 pin 不得漂移。

### 步驟 B：版本 bump 並打 tag

```bash
cd /Users/shikisuen/Repos/_PizzaStudio/PizzaHelperUnited

./BoostBuildVersion.swift <MARKETING_VERSION>      # 例：./BoostBuildVersion.swift 5.9.5
grep -o "CURRENT_PROJECT_VERSION = [0-9]*;" UnitedPizzaHelper.xcodeproj/project.pbxproj | sort | uniq -c
grep -o "MARKETING_VERSION = [0-9.]*;"       UnitedPizzaHelper.xcodeproj/project.pbxproj | sort | uniq -c

# 護欄：確認只有版本行變動，沒有其他行被動到
git diff -U0 -- UnitedPizzaHelper.xcodeproj/project.pbxproj \
  | grep -E "^[+-]" | grep -v "^[+-][+-]" | grep -vE "CURRENT_PROJECT_VERSION|MARKETING_VERSION" \
  && echo "!! 有非版本行的變更" || echo "OK: 只有版本行變更"

BV=$(git show HEAD:UnitedPizzaHelper.xcodeproj/project.pbxproj | grep -o "CURRENT_PROJECT_VERSION = [0-9]*;" | head -1 | grep -o "[0-9]*")
git add UnitedPizzaHelper.xcodeproj/project.pbxproj
git commit -q -m "proj: v<MARKETING_VERSION>-$BV"
git tag "v<MARKETING_VERSION>-$BV"
```

- `BoostBuildVersion.swift` 會把**所有** target 的 `MARKETING_VERSION`／`CURRENT_PROJECT_VERSION` 一併改掉（18 處），這是預期行為。
- tag 種類是輕量 tag（`git cat-file -t` = `commit`）；既有 tag 皆如此。
- 發版節奏是 **Beta.N → RC.N**（`v5.9.4-Beta.1-6534` → `-RC.1-6548` → `-RC.2-6551` → `-RC.3-6553`），不是一次到位。

### 步驟 C：推送後在 App Store Connect 手動啟動建置

```bash
git push                      # 推送 main
git push origin "v<MARKETING_VERSION>-$BV"   # 推送 tag
```

- ⚠️ **推送不會自動觸發建置**：本專案的 Xcode Cloud workflow 採用**手動啟動條件**，必須由**發行者本人**在 App Store Connect 手動啟動建置。因此 push 之後**還要再去 ASC 啟動一次**，否則不會有任何 build 產生。
- 手動啟動時要選對 **tag**（`v<MARKETING_VERSION>-$BV`），CI 才會建到正確的 commit。既有的 `v5.9.4-Beta.1-6534`、`-RC.1-6548`、`-RC.2-6551`、`-RC.3-6553` 等 tag 皆已推上遠端（可用 `git ls-remote --tags origin` 核對）。
- 建置目標 App：`TheLatteHelper`（見 `UnitedPizzaHelper.xcodeproj/xcshareddata/xcodecloud/manifest.json`）。建置成功後送達 TestFlight，再進入步驟 D。
- 啟動條件與 workflow 設定存在 **App Store Connect 伺服器端、不在倉庫內**：倉庫裡只有上述 manifest 的 workflow／target ID，看不到啟動條件。所以「為何沒自動建置」不是倉庫設定問題，去 ASC 確認即可。
- 推送前務必確認工作區乾淨、且建置號未被其他 commit 打亂——建置號一旦前移，手動啟動所建的版本號也會跟著變。

### 步驟 D：`asc` 與 App Store Connect

`asc`（App Store Connect CLI，查核時為 0.44.2）是本專案操作 ASC 的**唯一工具**。它須在 PATH 上才能以 `asc` 直接呼叫。實際用過的動詞：

```bash
asc apps list                                        # 解析 App ID
asc versions list --app 6757201427 --platform IOS --output table
asc versions create --app 6757201427 --version "<MARKETING_VERSION>" --platform IOS
asc metadata pull --app 6757201427 --version "<MARKETING_VERSION>" --dir "./metadata"
asc metadata push --app 6757201427 --version "<MARKETING_VERSION>" --platform IOS --dir "./metadata" --output table
asc localizations list   --version <version-id> --output json
asc localizations update --version <version-id> --locale <locale> --whats-new "<text>"
asc builds find          --app 6757201427 --build-number <bv> --platform IOS --output json
asc builds test-notes list --build <build-id> --output json
```

- **流程順序**：`versions create` → `metadata pull` → 改 `./metadata` → `metadata push`；TestFlight 的「What to Test」用 `builds test-notes`。
- **每次寫入後都要重新拉取核對**（工作階段內固定如此做）：`localizations list`／`metadata pull` 到另一個目錄後比對，確認遠端真的等於本機內容。
- 多語系欄位（`zh-Hans` / `zh-Hant` / `en-US` / `ja` / `ru`）是**逐 locale** 更新的，`--locale` 一次一個；批次時用迴圈並逐一檢查 exit code。
- **認證**：`asc` 需要有效的 App Store Connect API 憑證。**動手前先自行確認憑證可用**（可用 `asc doctor` 之類的診斷子指令）。憑證的實際存放位置、解析順序、profile 名稱與其可見範圍**一律不記於本文件**；若 `asc` 指令因權限失敗，先懷疑憑證狀態而非指令寫錯。
- **`asc apps list` 可用來把 App 名稱對到 ASC App ID**：本專案的目標 App ID 見第 1 節的表。**不要假設任何一把憑證的可見範圍**——每次動用 `asc` 前，先用該憑證實際查一次要操作的 App，確認它可見，再進行後續指令。
- ⚠️ **macOS native 版在 `asc` 上一律不要管**：不要為它建立版本、同步 metadata、送審，也不要代為處理任何審核往來（含申訴）。其審核員會以 **SPAM** 為由反覆搪塞，申訴亦然；繼續抗議下去**風險很高**，不值得。本專案目前對 macOS 的支援**一律由 iOS 端完成**——針對 iPad-on-Mac（iPadOS 版 App 在 macOS 上執行）這個環境情形做了特殊處理。凡涉及 macOS 的發版與審核，一律以 iPhone／iPad 端為準。
- 相關技能包（社群維護，非專案自製）：`~/.agents/skills/app-store-connect-cli-skills-main/`，共 22 個 `asc-*` skills。常用者：`asc-cli-usage`（動詞／旗標／分頁）、`asc-release-flow`（送審就緒度）、`asc-testflight-orchestration`（beta 群組與 What to Test）、`asc-build-lifecycle`（建置處理狀態）、`asc-metadata-sync`、`asc-whats-new-writer`、`asc-id-resolver`。**這些是通用文件，不含本專案的 App ID 或版本號**，需自行帶入。

### 步驟 E：發行說明文件

- 檔案：`EndUserPublicDocs/ReleaseNotesArchive/TheLatteHelper/[Public] The Latte Helper Release Notes <MARKETING_VERSION>.md`
- 單一檔案內含**五個語言區塊**，順序固定為 CHS → CHT → ENU → JPN → RUS。每塊以 `$EOF.` 單獨一行結束（故全檔共 5 個 `$EOF.`）。
- 分隔線格式為 `// CHT - - - - - - - - - - - -`（`// ` + 語言碼 + 一串 ` - `）。**第一塊（簡體中文）沒有前置分隔線**——檔案直接以 `// 《拿铁小助手》v<版本> 的更新内容简述：` 開頭；只有後四塊有 `// CHT`、`// ENU`、`// JPN`、`// RUS` 標頭。不要去找 `// CHS`。
- 這五塊**正好對應** App Store 上的五個 locale（`zh-Hans`、`zh-Hant`、`en-US`、`ja`、`ru`），也就是步驟 D 逐 locale 更新時用的同一組。撰寫新版本時五塊都要寫。
- 這些內文即 App Store 的 What's New 素材，會經 `asc metadata push`／`asc localizations update` 上到 ASC。
- 前作《披薩小助手》的存檔在 `ReleaseNotesArchive/ThePizzaHelper/`（止於 5.7.0），**不再更新**。
- 注意：App Store 審核曾因 OOBE 文件的語言自適應問題被打槍（見工作階段 `ef48ef53`），HTML 文件相關改動要一併考慮。

## 4. 工具鏈與環境

```bash
export DEVELOPER_DIR=$(./Script/find-nonbeta-xcode.swift 2>/dev/null)   # 自動選最高版 non-beta Xcode
```

- `Makefile` 的 `DEVELOPER_DIR` 也是這樣設的（第 13 行）。任何 `xcodebuild` 前都先設，避免用到 beta Xcode。
- `make archive` 是**互動式**選單（選 App → 選平台），底層呼叫 `archiveLatte-iOS` 等目標生成 xcarchive。日常發版走 Xcode Cloud，此目標是手動封存時的備援。
- 其他目標：`make xcode-info`、`make clean`、`make format`（swiftformat）、`make lint`（swiftlint，含 `--fix`）。注意 `make lint` 會自動改檔。
- `~/.local/bin` **在 PATH 上**（`asc`、`codewhale`、`dsh`、`uv` 等都在此），所以 `asc` 可直接呼叫。
- SPM 解析需可寫 `~/Library/Caches/org.swift.swiftpm`；在受限沙箱下會失敗（`Operation not permitted`），需放寬或改快取路徑。

## 5. 文件分佈

| 文件 | 用途 |
|---|---|
| `README.md` / `README_CHS.md` | 專案入口 |
| `DevDocs/MaintainerGuide.md` | 架構總覽（1200 行，PZKit／EnkaKit／GachaKit／Widgets／iOS16 相容策略） |
| `DevDocs/ProjectStructure.md` | SPM 元件職責劃分 |
| `DevDocs/MASBundleIDs.txt` | Bundle ID 備忘（**不得變動**的 legacy ID） |
| `DevDocs/Genshin_LifePath_Assignment_Guide.md` | 原神角色命途指定（改動時牽涉 ARDB 更新） |
| `EndUserPublicDocs/ReleaseNotesArchive/` | 發行說明存檔 |
| `BoostBuildVersion.swift` / `UpdateBuildVersion.swift` | 建置號注入；後者接受 `版本 建置號` 兩參數 |

## 6. 慣例與禁令

- Commit 訊息用單行主題、**結尾帶句號**，格式為 `<範圍> // <描述>.`：`SPM // …`、`proj: v5.9.4-RC.3-6553`、`PublicDocs // v5.9.4: …`、`EnkaKit // Update Assets (GI v7.1 Battle Pass) (#254)`。
- 本倉庫的 commit 沒有 co-author／tool trailer，不要自行加上。
- **未經允許不得 push、不得打 tag、不得送審，也不得代為啟動 Xcode Cloud 建置。** push 與打 tag 會把版本推上遠端、成為可被建置的對象；而**建置本身只能由發行者本人在 App Store Connect 啟動**（見步驟 C）。`release` skill 亦明確要求發佈動作需另行授權。
- **未經允許嚴禁格式化、抹除或等效的破壞性重置**（含模擬器與任何環境）；`make gitclean`（`git clean -ffdx`）屬破壞性操作，未獲同意不得執行。
- Swift 套件測試須加 `--disable-sandbox`（SwiftPM 內層 sandbox 與 harness sandbox 不相容）。
- 發版相關改動請先確認「動的是 `PizzaHelperUnited` 且對象是 The Latte Helper」；ThePizzaHelper 已是前作，除必要修正外不應再對其發版。

---

## 7. 一句話版本（TL;DR）

`BoostBuildVersion.swift <版本>` → 確認只有版本行變動 → `git commit -m "proj: v<版本>-<建置號>"` → `git tag v<版本>-<建置號>` → push main 與 tag → **由發行者本人在 App Store Connect 手動啟動建置**（push 不會自動觸發）→ Xcode Cloud 建 TheLatteHelper → TestFlight → 用 `asc` 建版本、同步 metadata／What's New、寫 TestFlight 測試說明 → 發行說明五個語言區塊（CHS／CHT／ENU／JPN／RUS）寫進 `EndUserPublicDocs/ReleaseNotesArchive/TheLatteHelper/`。

（`./metadata` 是 `asc metadata pull` 按需產生的暫存目錄，`metadata push` 後即可刪除，**不需要、也不應提交**。）

---

## Appendix: Working Philosophy

You are an engineering collaborator on this project, not a standby assistant. Model your behavior on:

- After you've done something, report what you did, why you did it, and what tradeoffs you made. You don't ask "would you like me to do X"—you've already done it. // i.e. John Carmack `.plan` file style.
- A single delivery is a complete, coherent, reviewable unit. Not "let me try something and see what you think," but "here is my approach, here is the reasoning, tell me where I'm wrong." // ie.e BurntSushi's style used in his PRs.
- **The Unix philosophy**: Do one thing, finish it, then shut up. Chatter mid-work is noise, not politeness. Reports at the point of delivery are engineering.

### What You Submit To

In priority order:

1. **The task's completion criteria** — the code compiles, the tests pass, the types check, the feature actually works.
2. **The project's existing style and patterns** — established by reading the existing code.
3. **The user's explicit, unambiguous instructions**.

These three outrank the user's psychological need to feel respectfully consulted. Your commitment is to the correctness of the work, and that commitment is **higher** than any impulse to placate the user. Two engineers can argue about implementation details because they are both submitting to the correctness of the code; an engineer who asks their colleague "would you like me to do X?" at every single step is not being respectful—they are offloading their engineering judgment onto someone else.

### On Stopping to Ask

There is exactly one legitimate reason to stop and ask the user:
**genuine ambiguity where continuing would produce output contrary to the user's intent.**

Illegitimate reasons include:

- Asking about reversible implementation details—just do it; if it's wrong, fix it.
- Asking "should I do the next step"—if the next step is part of the task, do it.
- Dressing up a style choice you could have made yourself as "options for the user".
- Following up completed work with "would you like me to also do X, Y, Z?": These are post-hoc confirmations. The user can say "no thanks," but the default is to have done them.
