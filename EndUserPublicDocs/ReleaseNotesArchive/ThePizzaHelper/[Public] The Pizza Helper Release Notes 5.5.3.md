// 《（统一）披萨小助手》v5.5.2 ~ v5.5.3 的更新内容简述：

(v5.5.2 版在 Mac App Store 过审发布之后发现有与本地帐号管理器可用性有关的一些恶性故障。因此，v5.5.2 的 iOS 版发行计划已被废除。该修正直接套用至 v5.5.3 版。)

- 本地帐号管理器：新增帐号之后不会再出现页面导航无法自动返回的情况。
- 本地帐号管理器：修复了本地帐号可能无法删除的故障。
- 本地帐号管理器：修复了在给本地帐号排序时可能会把后台云同步下载来的本地帐号失手删除的故障。
- 本地帐号管理器将不会再响应无效的拖动排序操作。
- 对 OS23 (iOS 16, macOS 13) 专用的小工具的种类标帜符 `kind` 做了差分处理：该标识符会在 OS24 开始的系统上自动初始化为其他的标帜符）。此举或可解决可能在运行 OS24 的设备上无法继续使用小工具的故障。虽然升级到 OS25 倒是可以避免这个故障，但有些 iPad 的终末系统版本是 OS24（iOS 17）、仍受该问题影响。
- 详情页面的后端模组不再同时发起多个 API 请求，而是会彼此错开 300ms 的时间差。这有助于缓解对远端服务器的压力。
- 针对用户壁纸编辑器的剪裁模组做了一些与界面控件操作有关的效能改善。
- 对页签列的寸法做了一些调整。
- 修复了白厄的专武「黎明恰如此燃烧」的某些副词条的图示无法正常显示的故障。
- 抽卡记录管理器在获取抽卡记录时的折线图表画面尺寸现已锁定最低高度，不会再出现整个图表被压扁的情况。
- 解决了详情画面的后端模组在被首次被唤起时将某些变数重复初期化的故障。这显著减少了不必要的 API 连线请求。
- 对抽卡记录管理器的与星穹铁道跨品牌连动有关的几个跃迁类型做了统整：2025 年的星穹铁道跨品牌跃迁活动只有 21 与 22 这两种跃迁卡池，分别对应活动角色及各自的专武。该变更不会影响已经获取的资料，因为经查证发现这次连动活动不存在 23 号与 24 号卡池。
- 对星穹铁道 3.5 连动角色补充了真实姓名资料。
- 解决了在 iOS 18.0 ~ 18.3 系统下使用详情页面持给定 UID 查询展柜时出现的「页签列显示在软键盘顶端」的故障。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.5.2 ~ v5.5.3 的更新內容簡述：

(v5.5.2 版在 Mac App Store 過審發佈之後發現有與本機帳號管理器可用性有關的一些惡性故障。因此，v5.5.2 的 iOS 版發行計劃已被廢除。該修正直接套用至 v5.5.3 版。)

- 本機帳號管理器：新增帳號之後不會再出現頁面巡覽無法自動返回的情況。
- 本機帳號管理器：修復了本機帳號可能無法刪除的故障。
- 本機帳號管理器：修復了在給本機帳號排序時可能會把後台雲同步下載來的本機帳號失手刪除的故障。
- 本機帳號管理器將不會再響應無效的拖動排序操作。
- 對 OS23 (iOS 16, macOS 13) 專用的小工具的種類標幟符 `kind` 做了差分處理：該標識符會在 OS24 開始的系統上自動初期化為其他的標幟符）。此舉或可解決可能在運行 OS24 的裝置上無法繼續使用小工具的故障。雖然升級到 OS25 倒是可以避免這個故障，但有些 iPad 的終末系統版本是 OS24（iOS 17）、仍受該問題影響。
- 詳情頁面的後端模組不再同時發起多個 API 請求，而是會彼此錯開 300ms 的時間差。這有助於緩解對遠端伺服器的壓力。
- 針對使用者壁紙編輯器的剪裁模組做了一些與介面控件操作有關的效能改善。
- 對頁籤列的寸法做了一些調整。
- 修復了白厄的專武「黎明恰如此燃燒」的某些副詞條的圖示無法正常顯示的故障。
- 抽卡記錄管理器在獲取抽卡記錄時的折線圖表畫面尺寸現已鎖定最低高度，不會再出現整個圖表被壓扁的情況。
- 解決了詳情畫面的後端模組在被首次被喚起時將某些變數重複初期化的故障。這顯著減少了不必要的 API 連線請求。
- 對抽卡記錄管理器的與星穹鐵道跨品牌連動有關的幾個躍遷類型做了統整：2025 年的星穹鐵道跨品牌躍遷活動只有 21 與 22 這兩種躍遷卡池，分別對應活動角色及各自的專武。該變更不會影響已經獲取的資料，因為經查證發現這次連動活動不存在 23 號與 24 號卡池。
- 對星穹鐵道 3.5 連動角色補充了真實姓名資料。
- 解決了在 iOS 18.0 ~ 18.3 系統下使用詳情頁面持給定 UID 查詢展櫃時出現的「頁籤列顯示在軟鍵盤頂端」的故障。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.5.2 ~ v5.5.3:

(v5.5.2, after being approved and released on the Mac App Store, was found to have critical issues related to the usability of the local profile manager. As a result, the release plan for v5.5.2 on iOS has been canceled. The fixes have been directly applied to v5.5.3.)

- Locale Profile Manager will not fail its automatic page navigation anymore on a successful local profile creation.
- Locale Profile Manager will not hinder a profile from being removed.
- Locale Profile Manager will not remove local profiles synchronized from iCloud when the user manually changed the sorting priority of locale profiles.
- Locale Profile Manager will not response to invalid drag-and-drop sorting tasks.
- A change has been applied against all widgets backported to OS23: Their `kind` identifier will be initiated with a different value if the system is OS24 or later. This is to solve a possible issue on real devices running OS24 which all widgets are failed from loading. Although upgrading to OS25 can avoid this issue, some iPad models are still affected because their final OS version supported is OS24.
- The backend module of Details view no longer fires multiple API requests simultaneously. A 300ms-long time span has been introduced before each new task fires. This reduces the burden applied to the server side.
- Applied some performance optimization against the User Wallpaper Editor to make the UI controls of the image cropper more responsive.
- Tweaked some metrics against the bottom tab bar.
- Fixed an issue regarding Phainon's signature weapon "Thus Burns the Dawn": Some of its sub-properties cannot have their icons correctly displayed.
- Gacha Record Manager now applies a minimum visual height against the line chart visible during the process of retrieving the latest gacha records. This change prevents the line chart from becoming a peshanko on some users' devices.
- Fixed an issue that the backend module for Details view has some of its internal properties initialized multiple times when the module instance gets constructed. This changes prevents unnecessary API connection requests.
- Consolidated the gacha pool types related to 2025 Star Rail Collab. It now has only two pools: #21 for collab characters, and #22 for their signature weapons. This change won't affect those data already fetched since pools #23 and #24 are now proved invalid for this collab event.
- Added real name information for HSR 3.5 collab characters.
- Fixed an issue on iOS 18.0 ~ 18.3 that the app tab bar may appear to the top of the software keyboard when user trying to query showcases in the Detail view using a given UID.

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.5.2 ~ v5.5.3 の主な更新内容：

（v5.5.2は、Mac App Storeで承認およびリリースされた後、ローカルプロファイルマネージャーの利用可能性に関連する重大な問題が発見されました。そのため、iOS版のv5.5.2のリリース計画は取り消されました。この修正はv5.5.3に直接適用されました。）

- ローカルプロファイルマネージャー：新しいプロファイル追加後に自動ページ遷移が失敗する故障を修理ました。
- ローカルプロファイルマネージャー：プロファイルが削除できない故障を修理しました。
- ローカルプロファイルマネージャー：プロファイルの並び替え時に、iCloudから同期されたローカルプロファイルが誤って削除される故障を修理しました。
- ローカルプロファイルマネージャーは無効なドラッグ＆ドロップによる並び替え操作に反応してしまう不具合を修正しました。
- OS23（iOS 16、macOS 13）専用ウィジェットの `kind` 識別子に差分処理を適用しました：OS24以降のシステムでは自動的に他の識別子で初期化されます。これにより、OS24を実行しているデバイスでウィジェットが読み込めなくなる問題を解決したはずです。OS25にアップグレードすればこの問題は回避できますが、一部のiPadは最終サポートがOS24のため、この問題による影響を受けております。
- 詳細画面のバックエンドモジュールは複数のAPIリクエストを同時に送信せず、各リクエストの間に300msの間隔を設けるようになりました。これによりサーバーへの負荷が軽減されます。
- ユーザー壁紙エディターの画像トリミングモジュールのUI操作に関するパフォーマンスを改善しました。
- タブバーの寸法を調整しました。
- ファイノンの専用武器「燃え盛る黎明のように」の一部サブプロパティのアイコンが正しく表示されない問題を修正しました。
- ガチャ記録マネージャーで最新ガチャ記録取得時の折れ線グラフの最小高さを固定し、グラフが潰れる現象を防止しました。
- 詳細画面のバックエンドモジュールが初回起動時に一部変数を重複初期化していた問題を修正し、不要なAPI接続リクエストを削減しました。
- 2025年の「スターレイル」コラボ関連のガチャプールタイプを統合し、#21（コラボキャラクター）と#22（専用武器）の2種類のみとなりました。#23と#24は無効だと判明した故、今回のこの統合変更は既存データには影響ありません。
- スターレイル3.5コラボキャラクターの本名情報を追加しました。
- iOS 18.0～18.3環境で、詳細画面でUID指定のショーケースを検索する際にタブバーがソフトウェアキーボードの上部に表示される問題を修正しました。

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.5.2 ~ v5.5.3:

(v5.5.2, после одобрения и выпуска в Mac App Store, была обнаружена с критическими проблемами, связанными с доступностью локального менеджера профилей. В результате план выпуска v5.5.2 для iOS был отменён. Исправления были напрямую применены к v5.5.3.)

- Локальный менеджер профилей: после добавления нового профиля автоматический переход по страницам больше не будет проваливаться.
- Локальный менеджер профилей: исправлена ошибка, из-за которой профиль не удавалось удалить.
- Локальный менеджер профилей: исправлена ошибка, при которой при изменении порядка профилей могли быть случайно удалены локальные профили, синхронизированные из iCloud.
- Локальный менеджер профилей больше не реагирует на недопустимые операции сортировки методом drag-and-drop.
- В виджетах для OS23 (iOS 16, macOS 13) идентификатор `kind` теперь инициализируется по-другому на системах OS24 и выше. Это решает проблему, когда на устройствах с OS24 виджеты не загружаются. Хотя обновление до OS25 устраняет проблему, некоторые iPad поддерживают только OS24 и остаются затронутыми.
- Модуль backend страницы деталей больше не отправляет несколько API-запросов одновременно — между ними теперь задержка 300 мс, что снижает нагрузку на сервер.
- Улучшена производительность модуля обрезки изображений в редакторе обоев пользователя.
- Изменены размеры нижней панели вкладок.
- Исправлена ошибка, из-за которой некоторые иконки подпараметров фирменного оружия Фаенон «Так сгорает рассвет» отображались некорректно.
- В менеджере записей гача теперь минимальная высота графика фиксирована, чтобы он не сжимался на некоторых устройствах.
- Исправлена ошибка, когда модуль backend страницы деталей повторно инициализировал некоторые переменные при первом запуске, что приводило к лишним API-запросам.
- Объединены типы пулов гача для коллаборации Star Rail 2025 года: теперь только два пула — #21 для персонажей и #22 для их фирменного оружия. Уже полученные данные не затронуты, так как пулы #23 и #24 признаны недействительными.
- Добавлена информация о настоящих именах персонажей коллаборации Star Rail 3.5.
- Исправлена ошибка на iOS 18.0–18.3, когда панель вкладок могла отображаться над экранной клавиатурой при поиске витрин по UID на странице деталей.

$EOF.
