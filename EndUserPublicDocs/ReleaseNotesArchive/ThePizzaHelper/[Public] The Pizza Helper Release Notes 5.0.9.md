// 《（统一）披萨小助手》v5.0.9 的更新内容简述：

- 修复了在启用非公元年历（比如两位数的日本年历）的 iOS / macOS 系统下出现的星穹铁道玩家体力上限计数异常，也同时修复了任何因为这个触发条件而可能导致的其他潜在故障。
- 调整了米游社 / HoYoLAB 登入手续前导页面的一些文字描述（仅影响到日语介面）。
- 全平台统一使用相同的介面语言切换方法。
- 解决了「在详情画面进行 Captcha 人机验证时、当前画面会跳转到角色库存画面」的问题。
- 对星穹铁道的圣遗物评分也引入特殊规则。第一笔特殊规则是针对「哀歌覆国的诗人」圣遗物四件套的。任何会妨碍该套装特有效果的因素均可能会导致降分或零分。
- 修复了所有与实时便笺有关的通知当中的日期格式本地化错误。
- Enka 展柜专用资料库模组改以 String 的形式来读取星穹铁道本地化词条编号。该变更是对 Enka Networks 上游的该决定的同步响应。这会对旧版应用带来下述负面影响：
    - 披萨小助手 5.0.8 的角色展柜面板系统会在今后星穹铁道 3.2 版更新开服之后瘫痪、无法正常使用，因为其内建的对星穹铁道 EnkaDB 的 JSON 解码规则只会把 nameTextMapHash 当 UInt64 来解码、无法处理 String 格式的 nameTextMapHash。
    - 披萨小助手 5.0.7 版为止的所有版本（包括被淘汰的两款前身应用：原神披萨小助手 4.x 以及星铁披萨小助手）已经无法正常使用展柜功能，因为其内建的对星穹铁道 EnkaDB 的 JSON 解码规则只会把 nameTextMapHash 当 Int64 来解码、无法处理 UInt64 (Int128 的非负数范围）以及 String 格式的 nameTextMapHash。
    - Enka API 的查询结果的解码不受此影响。
- 补上了与万敌有关的缺失素材。

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.0.9 的更新內容簡述：

- 修復了在啟用非西元年曆（比如兩位數的日本年曆）的 iOS / macOS 系統下出現的星穹鐵道玩家體力上限計數異常，也同時修復了任何因為這個觸發條件而可能導致的其他潛在故障。
- 調整了米遊社 / HoYoLAB 登入手續前導頁面的一些文字描述（僅影響到日語介面）。
- 全平臺統一使用相同的介面語言切換方法。
- 解決了「在詳情畫面進行 Captcha 人機驗證時、當前畫面會跳轉到角色庫存畫面」的問題。
- 對星穹鐵道的聖遺物評分也引入特殊規則。第一筆特殊規則是針對「哀歌覆國的詩人」聖遺物四件套的。任何會妨礙該套裝特有效果的因素均可能會導致降分或零分。
- 修復了所有與實時便箋有關的通知當中的日期格式本地化錯誤。
- Enka 展櫃專用資料庫模組改以 String 的形式來讀取星穹鐵道本地化詞條編號。該變更是對 Enka Networks 上游的該決定的同步響應。這會對舊版應用帶來下述負面影響：
    - 披薩小助手 5.0.8 的角色展櫃面板系統會在今後星穹鐵道 3.2 版更新開服之後癱瘓、無法正常使用，因為其內建的對星穹鐵道 EnkaDB 的 JSON 解碼規則只會把 nameTextMapHash 當 UInt64 來解碼、無法處理 String 格式的 nameTextMapHash。
    - 披薩小助手 5.0.7 版為止的所有版本（包括被淘汰的兩款前身應用：原神披薩小助手 4.x 以及星鐵披薩小助手）已經無法正常使用展櫃功能，因為其內建的對星穹鐵道 EnkaDB 的 JSON 解碼規則只會把 nameTextMapHash 當 Int64 來解碼、無法處理 UInt64 (Int128 的非負數範圍）以及 String 格式的 nameTextMapHash。
    - Enka API 的查詢結果的解碼不受此影響。
- 補上了與萬敵有關的缺失素材。

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.0.9 版が更新した内容：

- このアップデートから、カレンダー情報を処理する際に4桁のグレゴリオ暦を強制するようになりました。この変更により、少なくとも日本の元号（2桁の年表示）を使用しているiOS/macOSデバイスでのスターレイルの最大スタミナ値の誤表示が修正されました。
- プロファイルマネージャーの日本語UIテキストに関するいくつかの修正を行いました。
- このアップデートから、アプリのUI言語を変更する方法がプラットフォーム間で統一されました。
- 「詳細」タブでCaptchaテストをしようとする際に発生可能のナビゲーション支障を修正しました。
- このアップデートから、スターレイルのキャラクターの遺物を評価する際に特殊なルールを追加しました。最初のルールは「亡国の悲哀を詠う詩人」セットに関連しています：このセットの特殊効果を妨げる要因がある場合、採点が低下したり零点になったりする可能性があります。
- リアルタイム便箋に関連するすべての日時の言語表示を修正しました。
- スターレイルのEnkaDB JSONのnameTextMapHash値（スターレイルEnkaDBコンテンツの各ローカライズエントリの一意のID）が、最新のEnkaDB JSONファイルを正しくデコードするために文字列として処理されるようになりました。この変更はEnka Networksの最近の変更に同期したものです。
    - 前回のリリース（5.0.8）は、将来miHoYoによってスターレイルv3.2が一般公開されるとすぐに、JSON文字列からnameTextMapHash値をデコードできないため、スターレイルのショーケース機能に影響が出ます。
    - 5.0.8より前のすべてのリリース（廃止された2つの前身アプリ：原神ピザ助手4.xとスターレイルピザ助手を含む）は、JSON文字列とUInt64（Int128の非負の範囲）の両方からnameTextMapHash値をデコードできないため、すでにスターレイルのショーケース機能に影響が出ています。
    - Enka APIクエリ結果のデコードはこの変更の影響を受けません。
- 万敵（モーディス）のいくつか欠けた画像素材を追加しました。

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.0.9:

- Since this update, this app now enforces 4-digit Gregorian calendar while handling year information. This change fixes at least the wrong maximum primary stamina of Star Rail on iOS / macOS devices using Japan Royal Calendar.
- Some miscellaneous fixes against Japanese UI texts in the locale profile manager.
- Since this update, this app ensures a platform-independent approach of changing the UI language of this app.
- Fixed a navigation issue in Details tab which may hinder users from finishing their possible captcha tests.
- Since this update, this app also added special rules for artifact sets when appraising artifacts for Star Rail characters. The first rule is related to the set "Poet of Mourning Collapse": Any factor that can hinders the speciality of this set can lead to degraded scores or a zero score.
- Fixed all date-time localization errors happened wherever relative to real-time notes.
- Star Rail EnkaDB JSON nameTextMapHash values (the unique ID of each localization entry for Star Rail EnkaDB contents) are now handled as string in order to decode the latest EnkaDB JSON files correctly. This change is synchronized from recent changes happened on Enka Network's side.
    - The previous release (5.0.8) will have its Star Rail showcase feature impacted as soon as the Star Rail v3.2 released to the public by miHoYo in the future due to its inabilities of decoding nameTextMapHash values from JSON String.
    - All releases earlier than 5.0.8 are already having the Star Rail showcase feature impacted due to their inabilities of decoding nameTextMapHash values from both JSON String and UInt64.
    - The decoding of Enka API query results are not affected by this change.
- Patched the missing assets for Mydei.

// RUS - - - - - - - - - - - -

// Основные изменения в The Pizza Helper v5.0.9:

- Начиная с этого обновления, приложение теперь использует 4-значный григорианский календарь при обработке информации о годе. Это изменение исправляет как минимум неправильный максимальный предел основной выносливости в Star Rail на устройствах iOS/macOS, использующих японский императорский календарь.
- Внесены некоторые исправления в японские тексты пользовательского интерфейса в менеджере локальных профилей.
- Начиная с этого обновления, приложение обеспечивает платформенно-независимый подход к изменению языка пользовательского интерфейса.
- Исправлена проблема с навигацией во вкладке "Подробности", которая могла помешать пользователям завершить возможные тесты Captcha.
- Начиная с этого обновления, приложение также добавило специальные правила для наборов артефактов при оценке артефактов для персонажей Star Rail. Первое правило связано с набором "Поющий элегии рапсод": любой фактор, который может помешать особенности этого набора, может привести к снижению оценки или нулевой оценке.
- Исправлены все ошибки локализации даты и времени, возникающие в уведомлениях, связанных с заметками в реальном времени.
- Значения nameTextMapHash в JSON файлах EnkaDB для Star Rail (уникальный идентификатор каждой записи локализации для содержимого EnkaDB Star Rail) теперь обрабатываются как строки для правильного декодирования последних JSON файлов EnkaDB. Это изменение синхронизировано с недавними изменениями на стороне Enka Network.
    - Предыдущий релиз (5.0.8) будет иметь проблемы с функцией Showcase для Star Rail, как только Star Rail v3.2 будет выпущен публично компанией miHoYo в будущем, из-за невозможности декодирования значений nameTextMapHash из JSON String.
    - Все релизы ранее 5.0.8 (включая устаревшие приложения-предшественники: Pizza Helper for Genshin 4.x и Pizza Helper for Star Rail) уже имеют проблемы с функцией Showcase для Star Rail из-за невозможности декодирования значений nameTextMapHash как из JSON String, так и из UInt64.
    - Декодирование результатов запросов Enka API не затрагивается этим изменением.
- Добавлены отсутствующие ресурсы для Mydei.