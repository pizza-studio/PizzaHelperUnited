// 《（统一）披萨小助手》v5.5.1 的更新内容简述：

（开发团队急切呼吁：请本软件的用户们不要因为所谓『设备发热变慢』等原因而停留在年度系统更新的早期小版本上，这些早期小版本的系统可能会有各种与 SwiftUI 和 SwiftData 有关的故障、只能通过升级系统的方法来解决。任何仅在每年的系统的早期小版本上才能复现的软件故障，都不会受到本软件的专门应对处置。）

- 将 watchOS App 及其小工具体系的向下支持降至 watchOS 9.2 (亦属于 OS23 系列)。由于系统限制等原因，watchOS 9.x 所使用的嵌入式小工具在显示某些图示时会改用 SF Symbols 来显示、以规避 SVG 素材不相容的情况。
- 修复了在 OS24 (iOS 17 / macOS 14) 开始的系统下编辑本機帐号之后、被编辑的本機帐号的所属排列顺序擅自出现异动的故障。本機帐号管理器现在会正确地处理可能存在的排序故障，会在用户每次编辑内容时主动修复排序。
- 对详情画面的后端模组做了翻新，使其不会再在明明没取消资料获取任务的时候显示「请求已被明确地取消」。详情画面现在也会响应来自后端的本地帐号资料更新。
- 使用了一个特殊技巧来绕过了「键盘方向键会导致 App 页面导航失控」的故障，但该技巧仅对 OS24 (iOS 17 / macOS 14) 开始的系统生效。
- 解决了 iPadOS 在极端画面尺寸下显示角色库存画面时崩溃的故障。
- 上一个大版本更新有将 OS24 (iOS 17 / macOS 14) 开始才能用的「专门用来监视后端参数变更状况」的系统 API「`.onChange(of:initial:_:)`」向下移植给 OS23 为止的系统，命名为「`.react(to:initial:_:)`」。然而，其实作方式错误地将响应任务放在参数变更事件发生之前来执行，直接导致了整个 App 出现了各种各样的可用性故障。本次更新用 Combine 框架重写了相关的实作。由于这次的新版实作的效能不佳（此乃 Combine 框架的通病）且无法监视由 Swift Observation Macro 生成的广播成员变数，本软件从这一版更新开始对 OS24 开始的系统恢复使用 Apple 官方的 `.onChange(of:initial:_:)` API。
- 修复了在 OS24 (iOS 17 / macOS 14) 开始的系统下编辑本機帐号时「哪怕没递交修改，也会在每修改一个字符时触发其他视图的链式反应、产生一次 API 连线请求」的设计缺陷。该缺陷不影响 OS23 系统，因为基于 Combine-Publisher 的观测体系的固有缺陷使然。
- 解决了 OS21 ~ OS22 (也就是 iOS 14 ~ 15 和 macOS 11 ~ 12) 系统下在刚刚启动 App 时「不主动自动统计可以导出的资料数量」的故障。
- 针对 OS24 (iOS 17 / macOS 14) 为止的系统下的本機帐号管理器引入了一些特殊应对策略、以规避这几代系统内建的 SwiftUI 的导航系统的失能缺陷。
- 修复了部分图片素材被 Xcode 过度压缩而导致的失真。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.5.1 的更新內容簡述：

- 將 watchOS App 及其小工具體系的向下支持降至 watchOS 9.2 (亦屬於 OS23 系列)。由於系統限制等原因，watchOS 9.x 所使用的嵌入式小工具在顯示某些圖示時會改用 SF Symbols 來顯示、以規避 SVG 素材不相容的情況。
- 修復了在 OS24 (iOS 17 / macOS 14) 開始的系統下編輯本機帳號之後、被編輯的本機帳號的所屬排列順序擅自出現異動的故障。本機帳號管理器現在會正確地處理可能存在的排序故障，會在使用者每次編輯內容時主動修復排序。
- 對詳情畫面的後端模組做了翻新，使其不會再在明明沒取消資料獲取任務的時候顯示「請求已被明確地取消」。詳情畫面現在也會響應來自後端的本機帳號資料更新。
- 使用了一個特殊技巧來繞過了「鍵盤方向鍵會導致 App 頁面巡覽失控」的故障，但該技巧僅對 OS24 (iOS 17 / macOS 14) 開始的系統生效。
- 解決了 iPadOS 在極端畫面尺寸下顯示角色庫存畫面時崩潰的故障。
- 上一個大版本更新有將 OS24 (iOS 17 / macOS 14) 開始才能用的「專門用來監視後端參數變更狀況」的系統 API「`.onChange(of:initial:_:)`」向下移植給 OS23 為止的系統，命名為「`.react(to:initial:_:)`」。然而，其實作方式錯誤地將響應任務放在參數變更事件發生之前來執行，直接導致了整個 App 出現了各種各樣的可用性故障。本次更新用 Combine 框架重寫了相關的實作。由於這次的新版實作的效能不佳（此乃 Combine 框架的通病）且無法監視由 Swift Observation Macro 生成的廣播成員變數，敝軟體從這一版更新開始對 OS24 開始的系統恢復使用 Apple 官方的 `.onChange(of:initial:_:)` API。
- 修復了在 OS24 (iOS 17 / macOS 14) 開始的系統下編輯本機帳號時「哪怕沒遞交修改，也會在每修改一個字符時觸發其他視圖的鏈式反應、產生一次 API 連線請求」的設計缺陷。該缺陷不影響 OS23 系統，因為基於 Combine-Publisher 的觀測體系的固有缺陷使然。
- 解決了 OS21 ~ OS22 (也就是 iOS 14 ~ 15 和 macOS 11 ~ 12) 系統下在剛剛啟動 App 時「不主動自動統計可以導出的資料數量」的故障。
- 針對 OS24 (iOS 17 / macOS 14) 為止的系統下的本機帳號管理器引入了一些特殊應對策略、以規避這幾代系統內建的 SwiftUI 的導航系統的失能缺陷。
- 修復了部分圖片素材被 Xcode 過度壓縮而導致的失真。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.5.1:

- Backported the support of watchOS (and its widgets) to watchOS 9.2 (also part of the OS23 series). Due to system limitations, embedded widgets on watchOS 9.x will use SF Symbols for certain icons to avoid incompatibility with SVG assets.
- Fixed an issue on OS24 (iOS 17 / macOS 14) and later where the sorting order of a local profile would change unexpectedly after editing. Local Profile Manager now handles sorting priority issues better than before. It will attempt to automatically fix the sorting issues on editing or adding local profiles.
- Refactored the backend module of the Details view so that it no longer shows "The request was explicitly cancelled" when the data fetch task was not actually cancelled. The Details view now responds to local profile data changes from backend.
- Used a special workaround to bypass the issue where keyboard arrow keys would cause navigation failures in the app, but this only applies to OS24 (i.e., iOS 17 / macOS 14) and later.
- Fixed a crash on iPadOS when displaying the character inventory screen at extreme screen sizes.
- In the previous major update, the system API `.onChange(of:initial:_:)`, used to monitor backend parameter changes and only available on OS24 (i.e., iOS 17 / macOS 14) and later, was backported to OS23 and earlier as `.react(to:initial:_:)`. However, the implementation mistakenly turn the response task into a preemtive task, causing various usability issues. This update rewrites the implementation using the Combine framework. Due to the poor performance of the new implementation (a common issue with Combine) and its inability of monitoring property changes announced by Swift Observation Macro, the app now reverts to using Apple's official `.onChange(of:initial:_:)` API on OS24 and later.
- Fixed a design flaw on OS24 (Apple systems released in 2024, iOS 17 / macOS 14 and later) where editing a local profile would trigger a chain reaction in other views and an API request for every character change, even if no changes were submitted. This issue does not occur on OS23 due to inherent limitations in the Combine-Publisher observation system.
- Resolved an issue on OS21 ~ OS22 (i.e., iOS 14 ~ 15 and macOS 11 ~ 12) where the app would not proactively count the number of exportable items upon launch.
- Introduced a special hack in the local profile manager on OS24 (iOS 17 / macOS 14) to work around navigation system issues in the built-in SwiftUI of this annual OS release.
- Fixed distortion in some image assets caused by excessive compression by Xcode.

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.5.1 の主な更新内容：

- watchOSアプリおよびウィジェットのサポートをwatchOS 9.2（OS23シリーズ）まで拡張しました。システム制限により、watchOS 9.xのウィジェットでは一部アイコン表示にSF Symbolsを使用し、SVG素材の非互換を回避しました。
- OS24以降でローカルプロファイル編集後、並び順が意図せず変更される不具合を修正しました。ローカルプロファイル管理機能がソート順の問題をより適切に処理するようになり、編集時に自動修正を試みました。
- 詳細画面のバックエンドモジュールを刷新し、データ取得タスクが実際にキャンセルされていない場合に「リクエストは明示的にキャンセルされました」と表示されなくなりました。詳細画面は現在、バックエンドからのローカルプロファイルデータの変更に対応しています。
- キーボードの矢印キーによるナビゲーション不具合を回避する特殊な対策を導入しました（OS24以降のみ有効）。
- iPadOSの極端な画面サイズでキャラクターインベントリ画面表示時のクラッシュを修正しました。
- OS24以降で利用可能なAPI「`.onChange(of:initial:_:)`」をOS23以前にも「`.react(to:initial:_:)`」として移植しましたが、実装ミスにより様々な不具合が発生。本バージョンでCombineフレームワークによる新実装に変更。ただし、Combineの性能問題やSwift Observation Macroによるプロパティ変更の監視不可のため、OS24以降は公式APIに戻しました。
- OS24以降でローカルプロファイル編集時、未送信でも文字変更ごとに他ビューの連鎖反応やAPIリクエストが発生する設計不具合を修正しました（OS23では発生しません）。
- OS21～OS22（iOS 14～15、macOS 11～12）でアプリ起動時にエクスポート可能データ数を自動集計しない不具合を修正しました。
- OS24までのローカルプロファイル管理機能にSwiftUIナビゲーション不具合回避のための特殊対策を追加しました。
- 一部画像素材がXcodeによる過度な圧縮で劣化する問題を修正しました。

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.5.1:

- Поддержка watchOS и его виджетов расширена до watchOS 9.2 (серия OS23). Из-за ограничений системы, встроенные виджеты на watchOS 9.x используют SF Symbols для некоторых иконок, чтобы избежать несовместимости с SVG.
- Исправлена проблема на OS24+, когда порядок сортировки локального профиля неожиданно менялся после редактирования. Локальный менеджер профилей теперь лучше справляется с проблемами сортировки и автоматически исправляет их при редактировании или добавлении профилей.
- Модуль backend для экрана деталей переработан: больше не появляется сообщение «Запрос был явно отменён», если задача получения данных не была отменена. Экран деталей теперь реагирует на изменения локальных данных профиля от серверной части.
- Введён специальный обходной механизм для устранения проблем с навигацией при использовании клавиш-стрелок на клавиатуре (только для OS24 и новее).
- Исправлен сбой на iPadOS при отображении экрана инвентаря персонажей на экстремальных размерах экрана.
- В предыдущей версии API `.onChange(of:initial:_:)` для отслеживания изменений параметров backend был портирован на OS23 и ниже как `.react(to:initial:_:)`, но из-за ошибки реализации возникли проблемы с удобством. В этой версии реализация переписана с использованием Combine, однако из-за низкой производительности и невозможности отслеживать изменения свойств через Swift Observation Macro, на OS24 и новее используется официальный API.
- Исправлен дефект на OS24+, когда при редактировании локального профиля происходила цепная реакция в других представлениях и отправлялся API-запрос при каждом изменении символа, даже без сохранения изменений (на OS23 не проявляется).
- Исправлена ошибка на OS21–OS22 (iOS 14–15, macOS 11–12), когда при запуске приложения не подсчитывалось количество экспортируемых данных.
- Для менеджера локальных профилей на OS24 и ниже добавлены специальные меры для обхода проблем с навигацией в SwiftUI.
- Исправлены искажения некоторых изображений, вызванные чрезмерным сжатием в Xcode.

$EOF.
