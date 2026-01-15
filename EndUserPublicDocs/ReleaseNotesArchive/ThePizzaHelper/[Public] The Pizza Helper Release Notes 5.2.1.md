// 《（统一）披萨小助手》v5.2.1 的更新内容简述：

【新功能】

- 本次更新补上了从 5.x 以来（相对于《星铁披萨小助手》而言）一直缺失的「允许用户使用自己的图片给桌面小工具自订背景」的功能（简称「用户壁纸」）。出于对执行绪安全性的考量，该功能不再依赖在这方面有安全性缺陷的 Mantis 框架，而是使用了专门重写的图片处理模组暨剪裁交互系统。新的剪裁交互系统不支持对图片的旋转操作。用户可以通过「工具」选项卡的「用户壁纸管理器」来登记与管理用户壁纸，最多可以添加十个用户壁纸、且可以用 Base64 JSON 格式批次导入导出。由于 AppIntents 的限制，与用户自订壁纸有关的选项在桌面小工具的配置画面当中无法做互斥处理。桌面小工具一旦被配置了用户壁纸，则只会使用用户壁纸来当作自身的背景图像。Live Activity (实时活动/即时动态) 与 App 主介面的背景图像同理。
- 受米游社管辖（而非 HoYoLAB 管辖）的绝区零 UID 如今可以正常获取实时便笺内容，不再需要用户自备专用的设备指纹。注：该设备指纹与受米游社管辖的原神 UID 和星穹铁道 UID 仍有关系，会影响「每周征讨之花折扣次数」与「后备开拓力」等扩展资讯的获取。
- 新增了对《星穹铁道》的「逐光捡金」所有类型的个人战报显示的功能。之前，该功能仅支持其中的「忘却之庭」。
- 本地帐号管理器新增了一个进阶选项：用户可通过点击「统配指纹」按钮，手动将自定义的 `x-rpc-device_fp` 字段值批量应用于所有配置了米游社 UID 的本地帐号。此功能支持用户为关联米游社 UID 的本地帐号统一设置专属设备指纹参数，有效减少重复配置成本。该功能不会影响那些配置了 HoYoLAB UID 的本地帐号。

【杂项】

- 全专案进一步清扫了对 Combine Framework 没有刚需的使用情形。
- 修复了繁体中文介面的一些与资讯电子术语运用有关的失误。
- 通知阈值管理画面在尚无阈值登记的情况下不会再显示某些多余的内容。
- 修复了通知阈值管理画面在删除所有阈值之后没能自动退出编辑模式的故障。
- 修复了本地帐号管理器在删除所有本地帐号之后没能自动退出编辑模式的故障。
- 修复了双联本地帐号专用桌面小工具的配置介面的部分选项在特定情形下无法正常显示的故障。
- 新增了星穹铁道 v2.7 ~ v3.3 的四张官方手机壁纸。

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.2.1 的更新內容簡述：

- 本次更新補上了從 5.x 以來（相對於《星鐵披薩小助手》而言）一直缺失的「允許使用者使用自己的圖片給桌面小工具自訂背景」的功能（簡稱「使用者壁紙」）。出於對執行緒安全性的考量，該功能不再依賴在這方面有安全性缺陷的 Mantis 框架，而是使用了專門重寫的圖片處理模組暨剪裁交互系統。新的剪裁交互系統不支持對圖片的旋轉操作。使用者可以通過「工具」選項卡的「使用者壁紙管理器」來登記與管理使用者壁紙，最多可以添加十個使用者壁紙、且可以用 Base64 JSON 格式批次匯入匯出。由於 AppIntents 的限制，與使用者自訂壁紙有關的選項在桌面小工具的配置畫面當中無法做互斥處理。桌面小工具一旦被配置了使用者壁紙，則只會使用使用者壁紙來當作自身的背景圖像。Live Activity (實時活動/即時動態) 與 App 主介面的背景圖像同理。
- 受米遊社管轄（而非 HoYoLAB 管轄）的絕區零 UID 如今可以正常獲取實時便箋內容，不再需要使用者自備專用的設備指紋。注：該設備指紋與受米遊社管轄的原神 UID 和星穹鐵道 UID 仍有關係，會影響「每週征討之花折扣次數」與「後備開拓力」等擴展資訊的獲取。
- 新增了對《星穹鐵道》的「逐光撿金」所有類型的個人戰報顯示的功能。之前，該功能僅支持其中的「忘卻之庭」。
- 本機帳號管理器新增了一個進階選項：使用者可通過點擊「統配指紋」按鈕，手動將自定義的 `x-rpc-device_fp` 字段值批次套用給所有配置了米遊社 UID 的本機帳號。此功能支持使用者為關聯米遊社 UID 的本機帳號統一設置專屬設備指紋參數，有效減少重複配置成本。該功能不會影響那些配置了 HoYoLAB UID 的本機帳號。

【雜項】

- 全專案進一步清掃了對 Combine Framework 沒有剛需的使用情形。
- 修復了繁體中文介面的一些與資訊電子術語運用有關的失誤。
- 通知閾值管理畫面在尚無閾值登記的情況下不會再顯示某些多餘的內容。
- 修復了通知閾值管理畫面在刪除所有閾值之後沒能自動退出編輯模式的故障。
- 修復了本機帳號管理器在刪除所有本機帳號之後沒能自動退出編輯模式的故障。
- 修復了雙聯本機帳號專用桌面小工具的配置介面的部分選項在特定情形下無法正常顯示的故障。
- 新增了星穹鐵道 v2.7 ~ v3.3 的四張官方手機壁紙。

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.2.1 版が更新した内容：

【新機能】

- 本アップデートでは、5.x以降（「崩スタピザ助手」と比較して）長らく欠けていた「ユーザーが用意した画像をデスクトップウィジェットの背景として設定できる」機能（通称「ユーザー壁紙」）を再び実装しました。同時実行の安全性上の理由から、この機能は Mantis フレームワーク (この領域に脆弱性がある) に依存せず、代わりに新しく開発された専用の画像処理およびインタラクション モジュールを利用し始めました。新しい画像切抜用UIには画像の回転機能は実装しておりません。「ツール」タブの「ユーザー壁紙マネージャー」から最大10枚まで壁紙を登録・管理でき、Base64 JSON形式で一括読込・書出も可能です。AppIntentsの制約により、ウィジェット設定画面でユーザー壁紙関連のオプションを排他制御することはできません。ウィジェットにユーザー壁紙を設定すると、その壁紙のみが背景として使用されます。Live Activity（ライブアクティビティ）やアプリ本体の背景も同様です。
- 米遊社（米游社）管理下（HoYoLAB管理外）のゼンレスゾーンゼロUIDでも、専用端末指紋を用意せずにリアルタイム便箋を正常に取得できるようになりました。※この端末指紋は、米遊社在籍の原神UIDやスターレイルUIDにも関係し、「週ボス割引回数」や「予備開拓力」などの拡張情報の取得に影響します。
- 「崩壊：スターレイル」の「光追金掴」全タイプの個人戦報表示に対応しました。従来は「忘却の庭」のみ対応していました。
- プロファイルマネージャーに新しい上級オプションを追加。「端末指紋を一括適用する」ボタンを押すことで、カスタムした `x-rpc-device_fp` フィールド値を米遊社UIDが設定された全プロファイルに一括適用できます。この機能により、関連するプロファイルの端末指紋を統一設定でき、重複設定の手間を削減します。HoYoLAB UID設定されたプロファイルには影響しません。

【その他】

- プロジェクト全体で、不要なCombine Frameworkの利用をさらに整理しました。
- 繁体字中国語UIにおける情報技術用語の誤用を修正しました。
- 通知閾値管理画面で、閾値が未登録の場合、不要な内容が表示されなくなりました。
- 通知閾値管理画面で全ての閾値を削除した際に自動的に編集モードを終了しない不具合を修正しました。
- プロファイルマネージャーで全てのプロファイルを削除した際に自動的に編集モードを終了しない不具合を修正しました。
- デュアルプロファイル（２つのプロファイル）専用ウィジェットの設定画面で、一部オプションが特定条件下で正しく表示されない不具合を修正しました。
- スターレイル v2.7～v3.3 の公式スマホ壁紙4枚を追加しました。

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.2.1:

【New Features】

- This update adds the long-missing "User Wallpaper" feature (allowing users to set their own images as backgrounds for desktop widgets) that has been absent since version 5.x (compared to "Pizza Helper for HSR"). For concurrency safety reasons, this feature no longer relies on the Mantis framework (which has vulnerabilities in this area), but instead uses a newly developed dedicated image processing-and-interaction module. The new cropping system does not support image rotation. Users can register and manage up to 10 user wallpapers via the "User Wallpaper Manager" in the "Tools" tab, plus batch import / export them using Base64 JSON format. Due to AppIntents limitations, options related to user wallpapers cannot be made mutually exclusive in the widget configuration screen. Once a widget is configured with a user wallpaper, it will use only the user wallpaper as its background image. This also applies the App Main UI background and Live Activity.
- Zenless Zone UIDs governed by Miyoushe (not HoYoLAB) can now retrieve Real-Time Notes data without the need of dedicated device fingerprint configuration. Note that this configuration still affects Miyoushe-governed UIDs of Genshin Impact and Star Rail in retrieving extra data types like "Reserved Trailblaze Power" and "Trounce Blossom Weekly Discounts".
- In addition to the already-existed "Battle Report: Forgotten Hall", this update also brings support for "Battle Report: Apocalyptic Shadow" and "Battle Report: Pure Fiction". These 3 features are now combined as "Battle Report: Treasures Lightward" for Star Rail.
- Local Profile Manager now introduced a new advanced option, allowing a user to manually apply his / her own dedicated `x-rpc-device_fp` field value against all local profiles configured with Miyoushe UIDs by a single button-click. This feature does not affect those local profiles configured with HoYoLAB UIDs.

【Miscallenous Updates】

- Furtherly reduced scenarios whenever Combine Framework is not of vital necessity.
- Fixed some terminology mistakes related to information technology in the Traditional Chinese interface.
- The notification threshold management screen will no longer display certain unnecessary content when no thresholds are registered.
- Fixed an issue where the notification threshold management screen would not automatically exit Edit mode after all thresholds were manually deleted.
- Fixed an issue where the Local Profile Manager would not automatically exit Edit mode after all local profiles were manually deleted.
- Fixed an issue where certain options in the Dual Profile Widget configuration interface might not display correctly under specific conditions.
- Added 4 official cellphone wallpapers from Star Rail v2.7 ~ v3.3 release.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.2.1:

【Новые функции】

- В этом обновлении добавлена давно ожидаемая функция "Пользовательские обои" (возможность устанавливать собственные изображения в качестве фона для десктопных виджетов), которая отсутствовала с версии 5.x (по сравнению с «Pizza Helper for HSR»). Из соображений потокобезопасности эта функция больше не использует фреймворк Mantis, а реализована на базе собственного модуля обработки изображений и системы обрезки. Новый интерфейс обрезки не поддерживает поворот изображения. Пользователь может зарегистрировать и управлять до 10 пользовательскими обоями через "Менеджер пользовательских обоев" на вкладке "Инструменты", а также импортировать и экспортировать их пакетно в формате Base64 JSON. Из-за ограничений AppIntents опции, связанные с пользовательскими обоями, не могут быть сделаны взаимоисключающими в настройках виджета. Как только виджет настроен на использование пользовательских обоев, он будет использовать только их в качестве фона. То же касается Live Activity и основного интерфейса приложения.
- Для UID Zenless Zone Zero, находящихся под управлением Miyoushe (а не HoYoLAB), теперь можно получать данные Real-Time Notes без необходимости указывать специальный device fingerprint. Обратите внимание: этот device fingerprint по-прежнему влияет на получение расширенной информации ("еженедельные скидки на Trounce Blossom", "резервная энергия") для UID Genshin Impact и Star Rail, управляемых Miyoushe.
- Добавлена поддержка всех типов личных боевых отчетов "Озарённые светом сокровища для Honkai: Star Rail. Ранее поддерживался только "Забытый зал" (Forgotten Hall).
- В менеджере локальных аккаунтов добавлена новая расширенная опция: пользователь может нажатием кнопки "Универсальный отпечаток" массово применить собственное значение поля `x-rpc-device_fp` ко всем локальным аккаунтам с UID Miyoushe. Это позволяет быстро и удобно задать device fingerprint для всех связанных аккаунтов. На аккаунты только с HoYoLAB UID эта функция не влияет.

【Прочее】

- Проведена дополнительная очистка кода от ненужного использования Combine Framework.
- Исправлены ошибки в терминологии информационных технологий в традиционном китайском интерфейсе.
- На экране управления порогами уведомлений больше не отображается лишний контент, если пороги не зарегистрированы.
- Исправлена ошибка, из-за которой после удаления всех порогов уведомлений экран не выходил из режима редактирования.
- Исправлена ошибка, из-за которой после удаления всех локальных аккаунтов менеджер аккаунтов не выходил из режима редактирования.
- Исправлена ошибка, из-за которой некоторые опции в настройках виджета для двух аккаунтов могли не отображаться в определённых условиях.
- Добавлены четыре официальных мобильных обоев Star Rail v2.7–v3.3.
