// 《（统一）披萨小助手》v5.5.6 的更新内容简述：

(敬请留意：本软件团队可能面临与开发维护相关的人事存续问题。在最坏的情况下，本软件可能会从 App Store 下架，并以另一位团队成员名义及全新的 App Bundle ID 重新上架。由于本软件支持 macOS 且使用了 Group Container，因此不符合 App Store Connect 的易主资格。这意味着，若发生重新上架的情况，新版软件将无法访问原始软件的数据。用户只能通过既有的数据备份，在新版软件中还原其信息。我们强烈建议您定期备份您的抽卡记录与本地账号数据。最终决策或将于 2025 年 11 月底前做出。此外，请注意，重新上架的软件可能因需要重新申请 ICP 备案，而暂时无法对中国大陆的 iOS 用户提供服务。)

- 新增了对《空月之歌 (Song of the Welkin Moon)》6.0 的新角色与新武器的支持。三名新角色与命途的对应关系：菈乌玛 -> 同谐；菲林斯 -> 智识；爱诺 -> 记忆。
- 将 EnkaDB、GachaMetaDB、ArtifactRatingDB 的储存位置由 UserDefaults 卸货至文件系统，借此减少此类滥用行为对 UserDefaults 带来的数据压力。此举在理论上或可解决抽卡记录管理器在某些 iOS 设备上出现的「忙碌状态无限切换，构成死循环」的问题，但其有效性需持续数月的观察。
- 小工具：解决了一处因「浮点小数运算临界情形」而导致的某些小工具无法正常载入之情况。
- 个人战报：解决了幽境危战第六难易度的个人战报 JSON 资料无法被正确解码的故障。
- 玩家体力通知：修复了一处与模拟宇宙有关的提醒内容在简体中文与日文系统下将参数值的顺序搞错的故障。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.5.6 的更新內容簡述：

(敬請留意：敝軟體或面臨與開發維護有關的人事存續問題。在最壞的情況下，敝軟體可能會從 App Store 下架，並以另一位團隊成員名義及全新的 App Bundle ID 重新上架。由於敝軟體支援 macOS 且使用了 Group Container，故不符合 App Store Connect 的易主資格。這意味著，若重新上架的情形發生，新軟體將無法存取原始軟體的資料。使用者只能透過既有的資料備份，在新軟體中還原其資訊。我們強烈建議您定期備份您的抽卡紀錄與本機帳號資料。最終決策或將於 2025 年 11 月底前做出。此外，請注意，重新上架的軟體可能會因需要重新申請 ICP 備案、而暫時無法對中國大陸的 iOS 使用者提供服務。)

- 新增了對《空月之歌 (Song of the Welkin Moon)》6.0 的新角色與新武器的支持。三名新角色與命途的對應關係：菈烏瑪 -> 同諧；菲林斯 -> 智識；愛諾 -> 記憶。
- 將 EnkaDB、GachaMetaDB、ArtifactRatingDB 的儲存位置由 UserDefaults 卸貨至檔案系統，借此減少此類濫用行為對 UserDefaults 帶來的資料壓力。此舉在理論上或可解決抽卡記錄管理器在某些 iOS 裝置上出現的「忙碌狀態無限切換，構成死循環」的問題，但其有效性需持續數月的觀察。
- 小工具：解決了一處因「浮點小數運算臨界情形」而導致的某些小工具無法正常載入之情況。
- 個人戰報：解決了幽境危戰第六難易度的個人戰報 JSON 資料無法被正確解碼的故障。
- 玩家體力通知：修復了一處與模擬宇宙有關的提醒內容在簡體中文與日文系統下將參數值的順序搞錯的故障。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.5.6:

(BEWARE: This app may face challenges related to the sustainability of its development and maintenance team. In the worst-case scenario, the app might be removed from the App Store and get re-released under a different team member's name and a new App Bundle ID: This app supports macOS and uses Group Containers, making it unable to meet App Store Connect’s criteria for a developer transfer. This means that if such re-release happens, it won't be able to access data from the original app. You will only be able to use your existing data backups to restore your information in the new app. We strongly recommend that you regularly back up your gacha records and local account data. A final decision may be made by the end of November 2025. Please also note that the new app may be temporarily unavailable for iOS users in mainland China due to the need to re-apply for an ICP record.)

- Added support for new characters and weapons introduced in Song of the Welkin Moon v6.0. New characters have these life-paths assigned: Lauma -> Harmony; Flins -> Erudition; Aino -> Remembrance.
- Offloading the storage of EnkaDB, GachaMetaDB, and ArtifactRatingDB from UserDefaults to the file system in order to reduce the data amount pressure against UserDefaults (which is considered as an abuse, according to Xcode documentation). Theoreotically, this should solve an issue that Gacha Record Manager may have infinite loop in switching its busy state. Still, the effectiveness of this fix needs months of observations against real-world usage.
- Widgets: Fixed an issue of widget loading failure which caused by values made of infinite double numbers.
- Battle Report: Fixed a failure on decoding Stygian Onslaught battle report JSON data if the difficulty level is 6.
- Player Stamina Notification: Fixed the wrong sequence of values regarding notifications of Simulated Universe when the UI language is Simplified Chinese or Japanese.

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.5.6 の主な更新内容：

（ご注意：当アプリは、開発・メンテナンスチームの継続性に関連する問題に直面する可能性があります。最悪の場合、当アプリはApp Storeから削除され、別のチームメンバーの名前と新しいApp Bundle IDで再リリースされる可能性があります。当アプリは　macOS に対応済み、且つ Group Container を使用中のため、App Store Connectの開発者譲渡条件を満たしていません。これは、再リリースが行われた場合、新しいアプリが元のアプリのデータにアクセスできないことを意味します。ユーザーは、既存のデータバックアップを使用して、新しいアプリで情報を復元することしかできません。ガチャの記録とローカルアカウントデータを定期的にバックアップすることを強くお勧めします。最終決定は2025年11月末頃までに行われる予定です。また、再リリースされたアプリは、ICP登録の再申請が必要となるため、中国本土のiOSユーザーには一時的に利用できなくなる可能性があることにご注意ください。）

- 「空月の歌（Song of the Welkin Moon）」v6.0の新キャラクターと新武器に対応しました。新キャラクターの命途割り当ては以下の通りです：ラウマ -> 調和；フィリンス -> 知恵；アイノ -> 記憶。
- EnkaDB、GachaMetaDB、ArtifactRatingDBの保存先をUserDefaultsからファイルシステムに移行し、UserDefaultsへのデータ負荷を軽減しました。これにより、一部iOSデバイスで発生していた「ビジーステータスが無限に切り替わる（ループする）」問題が理論上解消される見込みですが、効果の検証には数ヶ月の観察が必要です。
- ウィジェット：浮動小数点演算の境界状況により一部ウィジェットが正常に読み込めない問題を修正しました。
- 個人戦績：「幽境の激戦」の第六難易度の個人戦績JSONデータが正しくデコードできない不具合を修正しました。
- プレイヤースタミナ通知：シミュレーテッドユニバース関連の通知内容で、簡体字中国語および日本語システム時にパラメータ値の順序が誤っていた問題を修正しました。

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.5.6:

(ВНИМАНИЕ: Приложение может столкнуться с проблемами команды разработки. В худшем случае, оно может быть удалено из App Store и переиздано под новым именем и App Bundle ID, что сделает невозможным доступ к старым данным из-за использования Group Containers и поддержки macOS. Пользователям придётся восстанавливать данные из резервных копий. Рекомендуется регулярно создавать резервные копии. Окончательное решение может быть принято до конца ноября 2025 года. Переизданное приложение может быть временно недоступно в материковом Китае из-за ICP-регистрации.)

- Добавлена поддержка новых персонажей и оружия из обновления «Song of the Welkin Moon» v6.0. Новым персонажам назначены следующие пути: Лаума -> Гармония; Флинс -> Эрудиция; Айно -> Память.
- Перенос хранения EnkaDB, GachaMetaDB и ArtifactRatingDB из UserDefaults в файловую систему для снижения нагрузки на UserDefaults. Теоретически это должно решить проблему бесконечного переключения состояния занятости в менеджере истории гача на некоторых устройствах iOS, однако для подтверждения эффективности потребуется несколько месяцев наблюдений.
- Виджеты: Исправлена ошибка, из-за которой некоторые виджеты не загружались при граничных значениях с плавающей точкой.
- Личный отчёт о битве: Исправлена ошибка декодирования JSON-отчёта о битве Мрачный Натиск на шестом уровне сложности.
- Уведомления о выносливости игрока: Исправлен неправильный порядок параметров в уведомлениях о Simulated Universe при использовании упрощённого китайского или японского языка интерфейса.

$EOF.
