// 《（统一）披萨小助手》v5.4.2 ~ v5.5.0 的更新内容简述：

（v5.4.2 的 macOS 版在发行后被发现有与 CoreData / SwiftData 有关的严重的协程死锁故障。其对应的 iOS 版发行计划已经废黜，改为就两个平台同时发布 v5.5.0 更新。）

- 新增了对《星穹铁道》3.4 的跨品牌连动卡池及相关新角色的支持。
- 本软件现可安装给 OS21 ~ OS23 (也就是 iOS 14 ~ 16 和 macOS 11 ~ 13)，但在这三个版本的系统下仅提供 Plist 格式的难民资料导出之功能。详细原因请洽本软件的本次更新在这三个版本的系统下运行时显示的介面文字说明。FOSS 类软件从来都不意味着无限可用性与无限责任，望各位受影响的用户群体们谅解。难民资料可以直接在本地帐号管理器与抽卡记录管理器内导入。另将下述内容正式下放给 OS23：桌面小工具、锁屏小工具、玩家体力计时器、玩家体力通知。与这些功能有关的本地帐号管理器也一同下放了，但这个管理器可能因为 OS23 固有的 SwiftUI 设计缺陷的原因、在本地帐号管理器内经常无法正常翻页。
- App 现在会主动对位于档案系统层面的用户壁纸档案组态的外来变化做出响应。
- 改良了今日画面的便笺的重载显示过程，同时解决了今日画面可能会过于频繁地存取实时便笺 API 的故障。
- 修复了某些带有任务管理功能的画面「可能会在任务完成时无法进入任务完成的状态」的故障。
- 改良了角色库存画面的显示渲染效能。
- 修复了贡献者人员名单里面部分贡献者的肖像无法正常显示的故障。
- 抽卡记录管理器现在会在后台有 SwiftData 资料变更时用文字提醒的方式劝用户主动执行「重建抽卡记录 UID 清单」功能、或重启 App。该功能不自动执行的原因是为了避免打断用户可能正在执行的其他涉及 SwiftData 资料读写的操作。
- 构了对 SwiftData & CoreData 后端资料内容变化时的响应方式，以实现更精细的响应规则判定。本次重构也避免了一些与并行安全有关的风险。
- 修复了无法在 SwiftData & CoreData 本地帐号资料内容变化时及时做出后续响应行为的 Bug。
- 修复了用户壁纸裁剪画面的预览图在介面中的尺寸不正常的故障。
- 尝试修复了可能存在的圆形嵌入式小工具的文字尺寸失控的故障。
- 修复了 FAQ 当中的一些排版错乱的内容，也调整了一些介面说明文字。
- 使 SwiftData / CoreData 的 actor 仅能被主程序存取。这解决了某些设备上特定类型的小工具可能无法正常载入的问题。
- 修复了玩家体力计时器背景无法启用其玻璃材质背景的故障。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.4.2 ~ v5.5.0 的更新內容簡述：

（v5.4.2 的 macOS 版在發行後被發現有與 CoreData / SwiftData 有關的嚴重的協程死鎖故障。其對應的 iOS 版發行計畫已經廢黜，改為就兩個平台同時發佈 v5.5.0 更新。）

- 新增了對《星穹鐵道》3.4 的跨品牌連動卡池及相關新角色的支援。
- 敝軟體現可安裝給 OS21 ~ OS23 (也就是 iOS 14 ~ 16 和 macOS 11 ~ 13)，但在這三個版本的系統下僅提供 Plist 格式的難民資料匯出之功能。詳細原因請洽本軟體的本次更新在這三個版本的系統下運行時顯示的介面文字說明。FOSS 類軟體從來都不意味著無限可用性與無限責任，望各位受影響的使用者群體們諒解。難民資料可以直接在本機帳號管理器與抽卡記錄管理器內匯入。另將下述內容下放給 OS23：桌面小工具、鎖屏小工具、玩家體力計時器、玩家體力通知。與這些功能有關的本機帳號管理器也一同下放了，但這個管理器可能因為 OS23 固有的 SwiftUI 設計缺陷的原因、在本機帳號管理器內經常無法正常翻頁。
- App 現在會主動對位於檔案系統層面的使用者壁紙檔案組態的外來變化做出響應。
- 改良了今日畫面的便箋的重載顯示過程，同時解決了今日畫面可能會過於頻繁地存取實時便箋 API 的故障。
- 修復了某些帶有任務管理功能的畫面「可能會在任務完成時無法進入任務完成的狀態」的故障。
- 改良了角色庫存畫面的顯示渲染效能。
- 修復了貢獻者人員名單裡面部分貢獻者的肖像無法正常顯示的故障。
- 抽卡記錄管理器現在會在後台有 SwiftData 資料變更時用文字提醒的方式勸使用者主動執行「重建抽卡記錄 UID 清單」功能、或重啟 App。該功能不自動執行的原因是為了避免打斷使用者可能正在執行的其他涉及 SwiftData 資料讀寫的操作。
- 構了對 SwiftData & CoreData 後端資料內容變化時的響應方式，以實現更精細的響應規則判定。本次重構也避免了一些與並行安全有關的風險。
- 修復了無法在 SwiftData & CoreData 本機帳號資料內容變化時及時做出後續響應行為的 Bug。
- 修復了使用者壁紙裁剪畫面的預覽圖在介面中的尺寸不正常的故障。
- 嘗試修復了可能存在的圓形嵌入式小工具的文字尺寸失控的故障。
- 修復了 FAQ 當中的一些排版錯亂的內容，也調整了一些介面說明文字。
- 使 SwiftData / CoreData 的 actor 僅能被主程式存取。這解決了某些設備上特定類型的小工具可能無法正常載入的問題。
- 修復了玩家體力計時器背景無法啟用其玻璃材質背景的故障。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.4.2 ~ v5.5.0:

(The macOS version of v5.4.2 was found to have a severe coroutine deadlock issue related to CoreData/SwiftData after its release. The corresponding iOS version release plan has been scrapped due to the same issue, and instead, an update to v5.5.0 will be released simultaneously for both platforms.)

- Added support for new collaborative characters and weapons introduced in Star Rail v3.4.
- The app can now be installed on OS21 ~ OS23 (i.e.: iOS 14 ~ 16 and macOS 11 ~ 13). However, on these three system versions, only refugee data export in Plist format is available. For details, please refer to the in-app text shown when running this update on these systems. FOSS does not mean unlimited availability or unlimited liability, and we ask for the understanding of affected users. Refugee data can be imported directly in the local profile manager and gacha record manager. An exception is that the following features are now backported to OS23: desktop widgets, lock screen widgets, player stamina timer, and player stamina notifications. The local profile manager related to these features is also available with buggy navigation experiences caused by SwiftUI issues plagued in OS23.
- The app now actively responds to external changes in user wallpaper configuration files at the file system level.
- Improved the reload process of the real-time notes on Today View, and fixed an issue where Today View might access the real-time notes API too frequently.
- Fixed an issue where some screens with task management features might not enter the completed state when a task is finished.
- Improved rendering performance of the character inventory view.
- Fixed an issue where some contributors' portraits could not be displayed correctly in the contributor list.
- The gacha record manager will now prompt users with a text reminder to manually perform the "Rebuild Gacha UID List" function or restart the app when there are SwiftData changes in the background. This is not done automatically to avoid interrupting other ongoing SwiftData operations.
- Refactored the response mechanism to SwiftData & CoreData backend data changes, enabling more precise response rules. This refactor also avoids some concurrency safety risks.
- Fixed a bug where the app could not respond in time to changes in local profile data in SwiftData & CoreData.
- Fixed an issue where the preview image in the user wallpaper cropping screen was displayed at an incorrect size.
- Attempted to fix a possible issue where text size in circular embedded widgets could become abnormal.
- Fixed some layout issues in the FAQ and adjusted some interface descriptions.
- Make SwiftData / CoreData actors only accessible by the main app. This solves the issue why certain types of widgets may fail on certain devices.
- Fixed an issue where Player Stamina Timer backgrounds cannot have its glass-material background enabled.

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.4.2 ~ v5.5.0 版が更新した内容：

（v5.4.2のmacOS版は、リリース後にCoreData/SwiftDataに関連する深刻なコルーチンデッドロックの問題が発見されました。対応するiOS版のリリース計画は廃止され、代わりに両プラットフォームで同時にv5.5.0のアップデートがリリースされる予定です。）

- このアップデートより、当アプリは『スターレイル』v3.4の新たなコラボキャラクターおよび武器に対応しました。
- 当アプリはOS21～OS23（いわゆるiOS 14～16およびmacOS 11～13）向けにもインストール可能となりましたが、これら3つのシステムバージョンでは難民データのPlist形式エクスポート機能のみ提供されます。詳細は該当システムで本アップデートを実行した際に表示されるアプリ内の説明文をご参照ください。FOSS（オープンソース）であることは無制限の利用や無限の責任を意味しません。影響を受けるユーザーの皆様のご理解をお願いいたします。難民データはローカルプロファイルマネージャーおよびガチャ記録マネージャーで直接インポートできます。例外としては、以下の機能がOS23にバックポートされました：デスクトップウィジェット、ロック画面ウィジェット、プレイヤースタミナタイマー、プレイヤースタミナ通知。これらの機能に関連するローカルプロファイルマネージャーも同時に利用可能ですが、OS23固有のSwiftUI設計上の問題により、プロファイルマネージャー内でページ送りが正常に動作しない場合があります。
- ファイルシステムレベルでのユーザー壁紙設定ファイルの外部変更にアプリが能動的に対応するようになりました。
- 今日画面のリアルタイム便箋のリロード処理を改善し、APIへの過剰アクセスが発生する不具合も修正しました。
- タスク管理機能を持つ一部画面で、タスク完了時に完了状態へ遷移できない場合がある不具合を修正しました。
- キャラクターインベントリ（持っているキャラの一覧）画面の描画パフォーマンスを改善しました。
- 貢献者リスト内の一部貢献者のアバター画像が正しく表示されない不具合を修正しました。
- ガチャ記録マネージャーは、バックグラウンドでSwiftDataのデータ変更があった場合、「ガチャUIDリスト再構築」機能の手動実行やアプリ再起動を促すテキスト通知を行うようになりました。これは他のSwiftData関連操作を妨げないため自動実行されません。
- SwiftDataおよびCoreDataのバックエンドデータ変更への応答方式をリファクタリングし、より精密な応答ルール判定を実現しました。このリファクタリングにより並行処理の安全性リスクも回避しています。
- SwiftDataおよびCoreDataのローカルプロファイルデータ変更時に、アプリが即時に後続処理を行えないバグを修正しました。
- ユーザー壁紙トリミング画面のプレビュー画像サイズが正しく表示されない不具合を修正しました。
- 円形埋め込みウィジェットでテキストサイズが異常になる可能性のある不具合の修正を試みました。
- FAQ内のレイアウト崩れや一部インターフェース説明文を修正しました。
- SwiftData / CoreData のアクターをメインアプリのみがアクセスできるようにする。これにより、特定のデバイスで特定の種類のウィジェットが起動できぬ問題が解決される。
- スタミナタイマーの背景にガラス材質の背景を有効にできない問題を修正しました。

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.4.2 ~ v5.5.0:

(Версия v5.4.2 для macOS после выпуска была обнаружена с серьезной проблемой взаимоблокировки корутин, связанной с CoreData/SwiftData. План выпуска соответствующей версии для iOS был отменен, и вместо этого обновление v5.5.0 будет выпущено одновременно для обеих платформ.)

- Добавлена поддержка новых коллаборационных персонажей и оружия, представленных в Star Rail v3.4.
- Приложение теперь можно устанавливать на OS21 ~ OS23 (т.е. iOS 14 ~ 16 и macOS 11 ~ 13). Однако на этих трех версиях системы доступен только экспорт данных беженцев в формате Plist. Для получения дополнительной информации, пожалуйста, обратитесь к тексту в приложении, отображаемому при запуске этого обновления на этих системах. FOSS не означает неограниченной доступности или неограниченной ответственности, и мы просим понять это пользователей, на которых это может повлиять. Данные беженцев можно импортировать непосредственно в локальный менеджер профилей и менеджер записей гача. Исключение составляет то, что следующие функции теперь обратно портированы на OS23: виджеты рабочего стола, виджеты экрана блокировки, таймер выносливости игрока и уведомления о выносливости игрока. Локальный менеджер профилей, связанный с этими функциями, также доступен, но с ошибками навигации, вызванными проблемами SwiftUI в OS23.
- Приложение теперь активно реагирует на внешние изменения в конфигурационных файлах обоев пользователя на уровне файловой системы.
- Улучшен процесс перезагрузки заметок в реальном времени на экране «Сегодня», а также исправлена проблема, из-за которой экран «Сегодня» мог слишком часто обращаться к API заметок в реальном времени.
- Исправлена проблема, из-за которой некоторые экраны с функциями управления задачами могли не переходить в состояние завершения, когда задача была выполнена.
- Улучшена производительность рендеринга представления инвентаря персонажа.
- Исправлена проблема, из-за которой портреты некоторых участников не отображались корректно в списке участников.
- Менеджер записей гача теперь будет напоминать пользователям текстовым уведомлением вручную выполнить функцию «Восстановить список UID гача» или перезапустить приложение, когда в фоновом режиме происходят изменения SwiftData. Это не делается автоматически, чтобы избежать прерывания других текущих операций SwiftData.
- Переработан механизм реагирования на изменения данных на стороне SwiftData и CoreData, что позволяет установить более точные правила реагирования. Эта переработка также избегает некоторых рисков безопасности параллелизма.
- Исправлена ошибка, из-за которой приложение не могло вовремя реагировать на изменения данных профиля в SwiftData и CoreData.
- Исправлена проблема, из-за которой изображение предварительного просмотра на экране обрезки обоев пользователя отображалось неправильного размера.
- Попытка исправить возможную проблему, из-за которой размер текста в круглых встроенных виджетах мог становиться аномальным.
- Исправлены некоторые проблемы с макетом в разделе FAQ и скорректированы некоторые описания интерфейса.
- Сделать акторы SwiftData / CoreData доступными только для основного приложения. Это решает проблему, из-за которой определённые типы виджетов могут не работать на некоторых устройствах.
- Исправлена проблема, из-за которой фон Таймера Выносливости не мог использовать стеклянный материал.

$EOF.
