// 《（统一）披萨小助手》v5.6.3 的更新内容简述：

- 抽卡记录管理器：新增对 Snap Hutao (胡桃工具箱) 的 `Userdata.db` 抽卡记录资料库的读入支持。读入时直接选 UIGFv4 即可。
- 抽卡记录管理器：在试图删除某个抽卡人的所有的本机抽卡记录时，现在会显示有多少笔对应的本机抽卡记录。
- 抽卡记录管理器：修复了前端画面无法及时反映后端资料变更的故障。
- 小工具：尝试修复了嵌入式小工具的介面素材在某些类型的 Apple 设备上无法正常显示的故障。问题的祸根在于这些设备的小工具无法从 Swift Package Module Bundle 读取素材、只能从 Main Bundle 读取素材。以 watchOS 为例：该故障曾在 watchOS 10 以及早期版本的 watchOS 11 内得到解决，但在 watchOS 11 晚期版本复发、也影响到 watchOS 26。
- 小工具：给所有小工具加装了数学计算保障，防止出现除零等数学错误。这些错误可能会妨碍小工具的正常显示。
- 小工具：修复了嵌入式小工具的名称本地化失效的故障。
- 用户界面：调整了一些角色的多语种姓名在「UI设定 -> 真实姓名开关」被手动开启时的显示，以尊重这些角色的姓名的原始语种读音。例：「Hysilens (海瑟音) -> Hyusilens (许谢纶, 希腊姓名)」、「Cerydra -> Keryudra (刻律德菈, 希腊姓名) 」等。该开关在预设状态下是不启用的。该修改不影响日语介面，因为官方的日语翻译已遵循正确的语源读音。
- 用户界面：在 iOS 与 macOS 系统下停用了 LiquidGlass 显示模式，因为 OS 26 的 LiquidGlass 显示模式会导致翻倍的 UI 运存占用量（暨与此有关的 ARC 运存回收效率低下等问题）。开发者根据最近十几年来对 Apple 的 OS 演变规律推论这个问题在下一个 OS 年度大更新问世之前不太可能保证得到有效解决，所以接下来一年之内不会考虑给本 App 重新开启 LiquidGlass 显示支持。

(敬请留意：本软件团队可能面临与开发维护相关的人事存续问题。在最坏的情况下，本软件可能会从 App Store 下架，并以另一位团队成员名义及全新的 App Bundle ID 重新上架。由于本软件支持 macOS 且使用了 Group Container，因此不符合 App Store Connect 的易主资格。这意味着，若发生重新上架的情况，新版软件将无法访问原始软件的数据。用户只能通过既有的数据备份，在新版软件中还原其信息。我们强烈建议您定期备份您的抽卡记录与本地账号数据。最终决策或将于 2026 年 1 月底前做出。此外，请注意，重新上架的软件可能因需要重新申请 ICP 备案，而暂时无法对中国大陆的 iOS 用户提供服务。)

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.6.3 的更新內容簡述：

- 抽卡記錄管理器：新增對 Snap Hutao (胡桃工具箱) 的 `Userdata.db` 抽卡記錄資料庫的讀入支持。讀入時直接選 UIGFv4 即可。
- 抽卡記錄管理器：在試圖刪除某個抽卡人的所有的本機抽卡記錄時，現在會顯示有多少筆對應的本機抽卡記錄。
- 抽卡記錄管理器：修復了前端畫面無法及時反映後端資料變更的故障。
- 小工具：嘗試修復了嵌入式小工具的介面素材在某些類型的 Apple 設備上無法正常顯示的故障。問題的禍根在於這些設備的小工具在真實設備（而非模擬器）當中無法從 Swift Package Module Bundle 讀取素材，也就是說只能從 Main Bundle 讀取素材。以 watchOS 為例：該故障曾在 watchOS 10 以及早期版本的 watchOS 11 內得到解決，但在 watchOS 11 晚期版本復發、也影響到 watchOS 26。
- 小工具：給所有小工具加裝了數學計算保障，防止出現除零等數學錯誤。這些錯誤可能會妨礙小工具的正常顯示。
- 小工具：修復了嵌入式小工具的名稱本地化失效的故障。
- 使用者介面：調整了一些角色的多語種姓名在「UI設定 -> 真實姓名開關」被手動開啟時的顯示，以尊重這些角色的姓名的原始語種讀音。例：「Hysilens (海瑟音) -> Hyusilens (許謝綸, 希臘姓名)」、「Cerydra -> Keryudra (刻律德菈, 希臘姓名) 」等。該開關在預設狀態下是不啟用的。該修改不影響日語介面，因為官方的日語翻譯已遵循正確的語源讀音。
- 使用者介面：在 iOS 與 macOS 系統下停用了 LiquidGlass 顯示模式，因為 OS 26 的 LiquidGlass 顯示模式會導致翻倍的 UI 記憶體佔用量（暨與此有關的 ARC 記憶體回收效率低下等問題）。開發者根據最近十幾年來對 Apple 的 OS 演變規律推論這個問題在下一個 OS 年度大更新問世之前不太可能保證得到有效解決，所以接下來一年之內不會考慮給本 App 重新開啟 LiquidGlass 顯示支持。

(敬請留意：敝軟體或面臨與開發維護有關的人事存續問題。在最壞的情況下，敝軟體可能會從 App Store 下架，並以另一位團隊成員名義及全新的 App Bundle ID 重新上架。由於敝軟體支援 macOS 且使用了 Group Container，故不符合 App Store Connect 的易主資格。這意味著，若重新上架的情形發生，新軟體將無法存取原始軟體的資料。使用者只能透過既有的資料備份，在新軟體中還原其資訊。我們強烈建議您定期備份您的抽卡紀錄與本機帳號資料。最終決策或將於 2026 年 1 月底前做出。此外，請注意，重新上架的軟體可能會因需要重新申請 ICP 備案、而暫時無法對中國大陸的 iOS 使用者提供服務。)

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.6.3:

- Gacha Record Manager (GRM): Added support for reading Snap Hutao's `Userdata.db` gacha record database; when importing, simply choose UIGFv4.
- Gacha Record Manager (GRM): When attempting to delete all local gacha records for a particular puller (a combination of the game and the UID), the app now shows how many corresponding local gacha record entries will be deleted.
- Gacha Record Manager (GRM): Fixed an issue where the frontend UI did not promptly reflect backend data changes.
- Widgets: Attempted to fix an issue where embedded widget assets could not be displayed on certain Apple devices. The root cause is that these devices' widgets on real hardware (not Xcode Simulator) cannot read assets from the Swift Package Module Bundle and can only read assets from the Main Bundle. For example on Apple Watch: this issue was fixed in watchOS 10 and early watchOS 11 but resurfaced in late watchOS 11 and affects watchOS 26.
- Widgets: Added math-safety protections to all widgets to prevent divide-by-zero and other numeric errors; these errors could otherwise prevent a widget from rendering.
- Widgets: Fixed an issue where embedded widget names failed to be localized.
- UI: Adjusted how some characters' multilingual names are shown when the "UI Settings -> Real Name" toggle is manually enabled so that the original-language pronunciation is respected (examples: "Hysilens -> Hyusilens", "Cerydra -> Keryudra", "Cyrene" -> "Kyurene", "Cipher" -> "Saphere"). This toggle is off by default. Japanese UI is not affected because things are already officially done correctly with respect to the original greek pronunciations of their names.
- UI: Disabled LiquidGlass display mode on iOS and macOS because LiquidGlass in OS 26 can lead to doubled UI memory usage (and related ARC reclamation inefficiencies). Based on recent OS evolution history in the last decade, the developers believes that this issue is unlikely to be reliably fixed before the next year's major OS update. Therefore, the app won't re-enable LiquidGlass support within the coming year.

(BEWARE: This app may face challenges related to the sustainability of its development and maintenance team. In the worst-case scenario, the app might be removed from the App Store and get re-released under a different team member's name and a new App Bundle ID: This app supports macOS and uses Group Containers, making it unable to meet App Store Connect’s criteria for a developer transfer. This means that if such re-release happens, it won't be able to access data from the original app. You will only be able to use your existing data backups to restore your information in the new app. We strongly recommend that you regularly back up your gacha records and local account data. A final decision may be made by the end of January 2026. Please also note that the new app may be temporarily unavailable for iOS users in mainland China due to the need to re-apply for an ICP record.)

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.6.3 の主な更新内容：

- ガチャ記録管理: Snap Hutao の `Userdata.db` ガチャ記録データベースの読み込み対応を追加しました。読み込む時は UIGFv4 を選択してください。
- ガチャ記録管理: 特定のガチャ対象のすべてのローカルガチャ記録を削除しようとする際、該当するローカルガチャ記録の件数が表示されるようになりました。
- ガチャ記録管理: フロントエンド画面がバックエンドデータの変更を即時に反映しない不具合を修正しました。
- ウィジェット: 一部の Apple デバイスで埋め込みウィジェットの画像資産 (Image Assets) が表示されない問題の修正を試みました。根本原因は、（シミュレータでなく）実機で動作するこれらのデバイスではウィジェットが Swift Package Module Bundle から画像資産を読み込めず、Main Bundle からのみ読み込めることにあります。例として watchOS：この問題は watchOS 10 および早期の watchOS 11 で一度修正されましたが、後期の watchOS 11 で再発し、OS 26 にも影響しています。
- ウィジェット: すべてのウィジェットに数値計算防御を追加し、「0 での除算」などの数値誤算による「レンダリング停止」故障を防ぐようにしました。
- ウィジェット: 埋め込みウィジェットの名称のローカリゼーションが失効する不具合を修正しました。
- UI: 「UI設定 -> 実名表示」スィッチを手動でONにした際に、一部キャラクターの多言語表記を原語の発音に配慮して表示を調整しました（例：「Hysilens -> Hyusilens」、「Cerydra -> Keryudra」、「Cyrene -> Kyurene」、「Cipher -> Saphere」）。このスィッチの最初状態はOFFです。この変更は日本語UIには影響しません。公式の日本語翻訳は既に正しいギリシャ語源に基づく発音に従っています。
- UI: iOS と macOS で LiquidGlass 表示モードを無効化しました。OS 26 の LiquidGlass は UI メモリ使用量を倍増させ（ARC によるメモリ解放効率の低下含む）得るため、直近の OS 変遷を踏まえた開発側の判断として、少なくとも今後 1 年間は LiquidGlass を再度有効化しない予定です。

（ご注意：当アプリは、開発・メンテナンスチームの継続性に関連する問題に直面する可能性があります。最悪の場合、当アプリはApp Storeから削除され、別のチームメンバーの名前と新しいApp Bundle IDで再リリースされる可能性があります。当アプリは　macOS に対応済み、且つ Group Container を使用中のため、App Store Connectの開発者譲渡条件を満たしていません。これは、再リリースが行われた場合、新しいアプリが元のアプリのデータにアクセスできないことを意味します。ユーザーは、既存のデータバックアップを使用して、新しいアプリで情報を復元することしかできません。ガチャの記録とローカルアカウントデータを定期的にバックアップすることを強くお勧めします。最終決定は2026年1月末頃までに行われる予定です。また、再リリースされたアプリは、ICP登録の再申請が必要となるため、中国本土のiOSユーザーには一時的に利用できなくなる可能性があることにご注意ください。）

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.6.3:

- Менеджер записей Gacha (GRM): Добавлена поддержка чтения базы данных гача Snap Hutao (`Userdata.db`). При импорте просто выберите UIGFv4.
- Менеджер записей Gacha (GRM): При попытке удалить все локальные записи гача для конкретного владельца гача (комбинации игры и UID) теперь отображается, сколько локальных записей будет удалено.
- Менеджер записей Gacha (GRM): Исправлена ошибка, из‑за которой фронтенд не всегда своевременно отображал изменения в бэкенд-данных.
- Виджеты: Попытка исправить проблему, при которой ресурсы интерфейса встроенных виджетов не отображаются на некоторых моделях Apple-устройств. Корень проблемы заключается в том, что на реальных устройствах эти виджеты не могут загружать ресурсы из Swift Package Module Bundle и могут читать данные только из Main Bundle. Например: проблема уже была исправлена в watchOS 10 и ранних версиях watchOS 11, но затем вновь проявилась в поздних версиях watchOS 11 и затронула watchOS 26.
- Виджеты: Добавлены математические защитные меры во все виджеты, чтобы предотвращать деление на ноль и другие числовые ошибки, которые могли мешать корректному отображению виджета.
- Виджеты: Исправлена проблема с локализацией названий встроенных виджетов.
- Интерфейс: Слегка скорректировано отображение многоязычных имён некоторых персонажей при ручном включении опции «UI Settings -> Real Name», чтобы уважать произношение в оригинальном языке (примеры: «Hysilens -> Hyusilens (Хюсиленс)», «Cerydra -> Keryudra (Керюдра)», «Cyrene -> Kyurene (Кюрене)», «Cipher -> Saphere (Сафере)»).
- Интерфейс: В iOS и macOS отключён режим отображения LiquidGlass, поскольку в OS 26 он может привести к двукратному увеличению объёма используемой UI-памяти (и связанным с этим проблемам эффективности сборки ARC). Разработчики считают, что это не будет гарантированно исправлено до следующего годового крупного обновления ОС, поэтому повторное включение LiquidGlass в течение следующего года не рассматривается.

(ВНИМАНИЕ: Приложение может столкнуться с проблемами команды разработки. В худшем случае, оно может быть удалено из App Store и переиздано под новым именем и App Bundle ID, что сделает невозможным доступ к старым данным из-за использования Group Containers и поддержки macOS. Пользователям придётся восстанавливать данные из резервных копий. Рекомендуется регулярно создавать резервные копии. Окончательное решение может быть принято до конца января 2026 года. Переизданное приложение может быть временно недоступно в материковом Китае из-за ICP-регистрации.)

$EOF.
