// 《（统一）披萨小助手》v5.5.8 的更新内容简述：

(敬请留意：本软件团队可能面临与开发维护相关的人事存续问题。在最坏的情况下，本软件可能会从 App Store 下架，并以另一位团队成员名义及全新的 App Bundle ID 重新上架。由于本软件支持 macOS 且使用了 Group Container，因此不符合 App Store Connect 的易主资格。这意味着，若发生重新上架的情况，新版软件将无法访问原始软件的数据。用户只能通过既有的数据备份，在新版软件中还原其信息。我们强烈建议您定期备份您的抽卡记录与本地账号数据。最终决策或将于 2025 年 11 月底前做出。此外，请注意，重新上架的软件可能因需要重新申请 ICP 备案，而暂时无法对中国大陆的 iOS 用户提供服务。)

- **资料：** 新增对《星穹铁道》v3.6 的新角色（长夜月、丹恒（存护））、新武器、新圣遗物套装的支持。
- **紧急资讯安全修补：** 本 App 现已全面禁用文字输入区的自动校正功能。这个改动是为了绕开一个已知的系统级运存泄漏故障。该故障主要影响 OS24 (iOS 17 & macOS 14) 开始的系统的 UIKit（iOS & macCatalyst），当系统处理与自动填充相关的模块时，可能会在 TextField 析构时造成不可控的运存泄漏。此问题由 Swift Documentation Workgroup 成员 Kyle Ye 回报给 Apple (Apple Feedback 工单: FB20302615)，并经他本人证实此应对策略有效。
- **新增：** 桌面小工具**通用偏好设定**页面。使用者可在此决定是否允许小工具线上载入高画质原神名片背景。同时，此页面也允许使用者为玩家体力数字指定字体，甚至可输入字体家族名称 (前提是系统已安装该字体)。
- **优化：** 玩家体力相关的系统通知讯息不再使用「今天」、「明天」等相对时间，而改为「周一」、「周二」等**星期数**。这么做是为了避免因通知发送时间延迟而导致的日期误判。
- **优化：** 针对 iOS 26 与 macOS 26 系统，优化了软件界面排版 (包含画面右上角按钮的配色)，并提升部分复杂界面元件的渲染效能。同时修正了 macOS 26 下的**玩家展柜**面板背景右侧出现空白区域的问题。
- **修复：** 设法绕过 OS26.0 系统中，与 `TabView` 相关的故障。此问题曾导致 Enka 展柜角色面版画面的**上下文选单**中，角色页面跳转功能失效。
- **修复：** 解决 App 启动时无法从文件系统载入诸如 EnkaDB 等资料库的静态缓存的故障。
- **调整：** 尝试改良了桌面小工具中**探索派遣**任务的排列逻辑。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.5.8 的更新內容簡述：

(敬請留意：敝軟體或面臨與開發維護有關的人事存續問題。在最壞的情況下，敝軟體可能會從 App Store 下架，並以另一位團隊成員名義及全新的 App Bundle ID 重新上架。由於敝軟體支援 macOS 且使用了 Group Container，故不符合 App Store Connect 的易主資格。這意味著，若重新上架的情形發生，新軟體將無法存取原始軟體的資料。用户只能透過既有的資料備份，在新軟體中還原其資訊。我們強烈建議您定期備份您的抽卡紀錄與本機帳號資料。最終決策或將於 2025 年 11 月底前做出。此外，請注意，重新上架的軟體可能會因需要重新申請 ICP 備案、而暫時無法對中國大陸的 iOS 用户提供服務。)

- **資料：** 新增對《星穹鐵道》v3.6 的新角色（長夜月、丹恆（存護））、新武器、新聖遺物套裝的支援。
- **緊急資訊安全修補：** 敝應用現已全面禁用文字輸入區的自動校正功能。這個改動是為了繞開一個已知的系統級記憶體洩漏故障。該故障主要影響 OS24 (iOS 17 & macOS 14) 開始的系統的 UIKit（iOS & macCatalyst），當系統處理與自動填充相關的模組時，可能會在 TextField 析構時造成不可控的記憶體洩漏。此問題由 Swift Documentation Workgroup 成員 Kyle Ye 回報給 Apple (Apple Feedback 工單: FB20302615)，並經他本人證實此應對策略有效。
- **新增：** 桌面小工具**通用偏好設定**頁面。使用者可在此決定是否允許小工具線上載入高畫質原神名片背景。同時，此頁面也允許使用者為玩家體力數字指定字型，甚至可輸入字型家族名稱 (前提是系統已安裝該字型)。
- **改良：** 玩家體力相關的系統通知訊息不再使用「今天」、「明天」等相對時間，而改為「週一」、「週二」等**星期數**。這麼做是為了避免因通知發送時間延遲而導致的日期誤判。
- **改良：** 針對 iOS 26 與 macOS 26 系統，優化了軟體介面排版 (包含畫面右上角按鈕的配色)，並提升部分複雜介面元件的渲染效能。同時修正了 macOS 26 下的**玩家展櫃**面板背景右側出現空白區域的問題。
- **修復：** 設法繞過 OS26.0 系統中，與 `TabView` 相關的故障。此問題曾導致 Enka 展櫃角色面板畫面的**上下文選單**中，角色頁面跳轉功能失效。
- **修復：** 解決 App 啟動時無法從檔案系統載入諸如 EnkaDB 等資料庫的靜態快取的故障。
- **調整：** 嘗試改良了桌面小工具中**探索派遣**任務的排列邏輯。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.5.8:

(BEWARE: This app may face challenges related to the sustainability of its development and maintenance team. In the worst-case scenario, the app might be removed from the App Store and get re-released under a different team member's name and a new App Bundle ID: This app supports macOS and uses Group Containers, making it unable to meet App Store Connect’s criteria for a developer transfer. This means that if such re-release happens, it won't be able to access data from the original app. You will only be able to use your existing data backups to restore your information in the new app. We strongly recommend that you regularly back up your gacha records and local account data. A final decision may be made by the end of November 2025. Please also note that the new app may be temporarily unavailable for iOS users in mainland China due to the need to re-apply for an ICP record.)

- **Data:** Added support for new characters (Dan Heng (Preservation) and Nagayoduki), weapons, and relic sets introduced in Houkai: Star Rail v3.6.
- **Emergency Security Patch:** This app has now completely disabled the auto-correction feature for text input fields. This change is to work around a known system-level memory leak issue. This bug primarily affects UIKit (iOS & macCatalyst) on systems starting from OS24 (iOS 17 & macOS 14), which may cause memory leaks during TextField destruction when the system processes auto-fill related modules. This issue was reported to Apple by Swift Documentation Workgroup member Kyle Ye (Apple Feedback ticket: FB20302615), and he has confirmed the effectiveness of this workaround strategy.
- **New:** **Widget Shared Settings** page for desktop widgets. Users can decide whether to allow widgets to load high-quality Genshin namecard backgrounds online. Additionally, this page allows users to specify fonts for player stamina numbers, and even input font family names (provided the font is installed on the system).
- **Improvement:** System notification messages for Player Stamina recovery status no longer use relative time expressions like "today" and "tomorrow", but instead use **day of the week** like "Monday" and "Tuesday". This is to avoid date misjudgments caused by delayed notification delivery.
- **Improvement:** For iOS 26 and macOS 26 systems, optimized the software interface layout (including the color scheme of buttons in the top-right corner of the screen) and improved the rendering performance of some complex interface components. Also fixed the issue where blank areas appeared on the right side of the **Player Showcase** panel background on macOS 26.
- **Fix:** Worked around a bug in OS26.0 systems related to `TabView`. This issue had caused the character page navigation function in the **context menu** of the Enka showcase character panel view to become ineffective.
- **Fix:** Resolved the issue where the app could not load static caches of databases such as EnkaDB from the file system during app startup.
- **Adjustment:** Attempted to improve the sorting logic of **Expedition** tasks in desktop widgets.

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.5.8 の主な更新内容：

（ご注意：当アプリは、開発・メンテナンスチームの継続性に関連する問題に直面する可能性があります。最悪の場合、当アプリはApp Storeから削除され、別のチームメンバーの名前と新しいApp Bundle IDで再リリースされる可能性があります。当アプリは　macOS に対応済み、且つ Group Container を使用中のため、App Store Connectの開発者譲渡条件を満たしていません。これは、再リリースが行われた場合、新しいアプリが元のアプリのデータにアクセスできないことを意味します。ユーザーは、既存のデータバックアップを使用して、新しいアプリで情報を復元することしかできません。ガチャの記録とローカルアカウントデータを定期的にバックアップすることを強くお勧めします。最終決定は2025年11月末頃までに行われる予定です。また、再リリースされたアプリは、ICP登録の再申請が必要となるため、中国本土のiOSユーザーには一時的に利用できなくなる可能性があることにご注意ください。）

- **データ：** 『スターレイル』v3.6の新キャラクター（丹恒（存護）と長夜月）、新武器、新聖遺物セットに対応しました。
- **緊急セキュリティパッチ：** 当アプリは、テキスト入力フィールドの自動校正機能を完全に無効にしました。この変更は、既知のシステムレベルのメモリリークの問題を回避するためです。この不具合は主にOS24（iOS 17およびmacOS 14）以降のシステムのUIKit（iOSおよびmacCatalyst）に影響し、システムが自動入力関連モジュールを処理する際にTextFieldオブジェクトの破棄時にメモリリークを引き起こす可能性があります。この問題はSwift Documentation WorkgroupメンバーのKyle YeによってAppleに報告され（Apple Feedbackチケット：FB20302615）、彼自身がこの対応策の有効性を確認しました。
- **新機能：** デスクトップウィジェットのための**ウィジェット共通設定**ページを追加。ユーザーはウィジェットが高品質の原神名刺背景をオンラインで読み込むことを許可するかどうかを決定できます。また、このページではプレイヤースタミナの数字にフォントを指定することも可能で、フォントファミリー名を入力することもできます（システムにそのフォントがインストールされている場合）。
- **改良：** プレイヤースタミナ関連のシステム通知メッセージで、「今日」や「明日」などの相対時間ではなく、「月曜」、「火曜」などの**曜日**を使用するようになりました。これは、通知配信の遅延による日付の誤判定を避けるためです。
- **改良：** iOS 26およびmacOS 26システム向けに、ソフトウェアのインターフェースレイアウトを最適化（画面右上のボタンの配色を含む）し、一部の複雑なインターフェース要素のレンダリング性能を向上させました。また、macOS 26での**プレイヤーショーケース**パネル背景の右側に空白領域が表示される問題を修正しました。
- **修正：** OS26.0システムの`TabView`関連の不具合を回避しました。この問題により、Enkaショーケースキャラクターパネル画面の**コンテキストメニュー**でキャラクターページナビゲーション機能が無効になっていました。
- **修正：** アプリ起動時にファイルシステムからEnkaDBなどのデータベースの静的キャッシュを読み込めない問題を解決しました。
- **調整：** デスクトップウィジェットの**探索派遣**タスクの陳列ロジックの改良を試みました。

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.5.8:

(ВНИМАНИЕ: Приложение может столкнуться с проблемами команды разработки. В худшем случае, оно может быть удалено из App Store и переиздано под новым именем и App Bundle ID, что сделает невозможным доступ к старым данным из-за использования Group Containers и поддержки macOS. Пользователям придётся восстанавливать данные из резервных копий. Рекомендуется регулярно создавать резервные копии. Окончательное решение может быть принято до конца ноября 2025 года. Переизданное приложение может быть временно недоступно в материковом Китае из-за ICP-регистрации.)

- **Данные:** Добавлена поддержка новых персонажей, оружия и наборов реликвий из Honkai: Star Rail v3.6.
- **Экстренное исправление безопасности:** Приложение теперь полностью отключило функцию автокоррекции для текстовых полей. Это изменение направлено на обход известной системной проблемы утечки памяти. Данная ошибка в основном влияет на UIKit (iOS и macCatalyst) в системах начиная с OS24 (iOS 17 и macOS 14), которая может вызывать утечку памяти при разрушении TextField при обработке системой модулей автозаполнения. Эта проблема была сообщена в Apple участником рабочей группы Swift Documentation Workgroup Кайлом Е (тикет Apple Feedback: FB20302615), и он подтвердил эффективность данного решения.
- **Новое:** Страница **общих настроек виджетов** для виджетов рабочего стола. Пользователи могут решить, разрешить ли виджетам загружать высококачественные фоны именных карточек Genshin онлайн. Кроме того, эта страница позволяет пользователям указывать шрифты для чисел выносливости игрока и даже вводить названия семейств шрифтов (при условии, что шрифт установлен в системе).
- **Улучшение:** Системные уведомления о выносливости игрока больше не используют относительные временные выражения, такие как «сегодня» и «завтра», а вместо этого используют **дни недели**, такие как «понедельник» и «вторник». Это сделано для избежания неправильной интерпретации дат из-за задержки доставки уведомлений.
- **Улучшение:** Для систем iOS 26 и macOS 26 оптимизирован макет интерфейса программы (включая цветовую схему кнопок в правом верхнем углу экрана) и улучшена производительность рендеринга некоторых сложных элементов интерфейса. Также исправлена проблема появления пустых областей справа от фона панели **витрины игрока** в macOS 26.
- **Исправление:** Обойдена ошибка в системах OS26.0, связанная с `TabView`. Эта проблема приводила к неработоспособности функции навигации по страницам персонажей в **контекстном меню** панели персонажей витрины Enka.
- **Исправление:** Решена проблема, при которой приложение не могло загрузить статический кэш баз данных, таких как EnkaDB, из файловой системы при запуске.
- **Настройка:** Предпринята попытка улучшить логику сортировки задач **экспедиций** в виджетах рабочего стола.

$EOF.
