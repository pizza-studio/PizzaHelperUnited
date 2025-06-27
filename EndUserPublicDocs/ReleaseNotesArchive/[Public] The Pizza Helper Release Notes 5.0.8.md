// 《（统一）披萨小助手》v5.0.8 的更新内容简述：

[实时便笺]
- 当移除某个本地账号的时候，如果这个账号的「游戏-UID」配对信息不会再被其他剩余的本地账号所使用的话，现在会一并清除掉与此有关的所有已经排定的系统通知。
- 本次更新可对应星穹铁道 v3.1 新角色、新武器。

[个人战报]
- 修复了原神角色在深境螺旋个人战报画面不显示角色已经身着的课金时装的故障。

[抽卡记录管理器] 
- 想办法绕开了一个与日期格式编码解码有关的 Swift Foundation 故障（参见 Swift 官方 GitHub 仓库「swiftlang/swift」的工单 `#79571`）。该故障波及所有从「原神披萨小助手 2.x ~ 4.x」继承过来的抽卡记录、且「星铁披萨小助手」的继承过来的记录恐怕也受到波及。该故障会导致被波及的抽卡记录在导出的时候没有严格遵循 UIGF 委员会规定的「yyyy-MM-dd HH:mm:ss」格式，此乃米哈游抽卡记录官方原始日期时间戳格式。从这一版开始，披萨小助手会在适当的时机主动修复受波及的抽卡记录。当您导出记录的时候，披萨小助手会先主动检查并修复受此影响的时间戳字串。

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.0.8 的更新內容簡述：

[實時便箋]
- 當移除某個本機帳號的時候，如果這個帳號的「遊戲-UID」配對資訊不會再被其他剩餘的本地帳號所使用的話，現在會一併清除掉與此有關的所有已經排定的系統通知。
- 本次更新可對應星穹鐵道 v3.1 新角色、新武器。

[個人戰報]
- 修復了原神角色在深境螺旋個人戰報畫面不顯示角色已經身著的課金時裝的故障。

[抽卡記錄管理器] 
- 想辦法繞開了一個與日期格式編碼解碼有關的 Swift Foundation 故障（參見 Swift 官方 GitHub 倉庫「swiftlang/swift」的工單 `#79571`）。該故障波及所有從「原神披薩小助手 2.x ~ 4.x」繼承過來的抽卡記錄、且「星鐵披薩小助手」的繼承過來的記錄恐怕也受到波及。該故障會導致被波及的抽卡記錄在匯出的時候沒有嚴格遵循 UIGF 委員會規定的「yyyy-MM-dd HH:mm:ss」格式，此乃米哈遊抽卡記錄官方原始日期時間戳格式。從這一版開始，披薩小助手會在適當的時機主動修復受波及的抽卡記錄。當您匯出記錄的時候，披薩小助手會先主動檢查並修復受此影響的時間戳字串。

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.0.8 版が更新した内容：

[リアルタイム便箋]
- プロファイルを削除する際、そのプロファイルの「ゲームとUID」情報が他の残りのプロファイルで使用されていない場合、関連するすべてのスケジュールされたシステム通知も削除されるようになりました。
- スターレイル 3v.1 の新キャラクター、新武器に対応しました。

[個人戰報]
- 深境螺旋の個人戦報画面で原神キャラクターの着ている課金衣装が表示されない不具合を修正しました。

[ガチャ記録管理] 
- Swift Foundation の日付形式のエンコードとデコードに関する不具合を回避しました（Swift公式GitHubリポジトリ「swiftlang/swift」のissue `#79571` 参照）。この不具合は「原神ピザ助手 2.x ~ 4.x」および「崩スタピザ助手」から引き継いだガチャ記録に影響を与え、エクスポート時にUIGF委員会が定めた「yyyy-MM-dd HH:mm:ss」形式（miHoYo公式ガチャ履歴の原本タイムスタンプ形式）に厳密に従わない問題が発生していました。このバージョンより、弊アプリは適切なタイミングで影響を受けたガチャ記録を自動修正します。記録のエクスポート時に、影響を受けたタイムスタンプ文字列のこの問題を自動的に検出し修正します。

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.0.8:

[Real-Time Notes]
- When removing a local profile, if its "Game-UID" pair is no longer used by any other remaining local profiles, all scheduled system notifications related to it will now be cleaned up as well.
- This update now supports new characters and weapons from Star Rail v3.1.

[Personal Battle Reports]
- Fixed an issue where paid character outfits (if equipped in the game) were not displaying correctly in the Genshin Impact Spiral Abyss personal battle report view.

[Gacha Record Manager]
- Worked around a Swift Foundation issue related to date format encoding/decoding (see issue `#79571` in the official Swift GitHub repository "swiftlang/swift"). This issue affects all gacha records inherited from "Pizza Helper for Genshin 2.x ~ 4.x" and potentially those from "Pizza Helper for Star Rail". The affected records would not strictly follow the UIGF committee-specified "yyyy-MM-dd HH:mm:ss" format (miHoYo's official original gacha record timestamp format) when exported. Starting from this version, The Pizza Helper will proactively fix affected records at appropriate times. When you export records, the app will automatically check and fix any affected timestamp strings.

// RUS - - - - - - - - - - - -

// Основные изменения в The Pizza Helper v5.0.8:

[Заметки в реальном времени]
- При удалении локального профиля, если его пара "Игра-UID" больше не используется другими оставшимися локальными профилями, все запланированные системные уведомления, связанные с ним, теперь также будут удалены.
- Это обновление поддерживает новых персонажей и оружие из Star Rail v3.1.

[Личные боевые отчеты]
- Исправлена проблема, из-за которой платные костюмы персонажей (если они экипированы в игре) не отображались корректно в личном боевом отчете Спиральной Бездны в Genshin Impact.

[Менеджер записей гача]
- Обошли проблему Swift Foundation, связанную с кодированием/декодированием формата даты (см. issue `#79571` в официальном репозитории Swift на GitHub "swiftlang/swift"). Эта проблема затрагивает все записи гача, унаследованные из "Pizza Helper for Genshin 2.x ~ 4.x", и потенциально те, что из "Pizza Helper for Star Rail". Затронутые записи при экспорте не строго следовали формату "yyyy-MM-dd HH:mm:ss", указанному комитетом UIGF (официальный исходный формат временной метки записей гача miHoYo). Начиная с этой версии, The Pizza Helper будет проактивно исправлять затронутые записи в соответствующее время. При экспорте записей приложение автоматически проверит и исправит все затронутые строки временных меток.
