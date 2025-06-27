// 《（统一）披萨小助手》v5.0.4 的更新内容简述

- 从这一版开始，我们停止接受捐赠。相关的功能已经从 App 本体全部移除。
- [iOS / macOS / watchOS][小工具] 用多种综合手段改良了玩家体力桌面小工具的载入效率与运存占用、且以共用缓存的机制避免了多个小工具在配置了相同的本地账号时同时请求实时便笺资料的行为。与此有关的小工具的内容更新规律的改变请洽《常见问题解答 (FAQ)》。
- [iOS / macOS / watchOS][每日便笺] 修复了绝区零每日便笺的影像店营业状态描述文字。
- [iOS / macOS / watchOS][SwiftData] 尝试将本地帐号中的 `Enum(RAW: String)` 数据类型改为 `Data`，以解决 SwiftData 与 CloudKit 之间兼容性问题导致的「本机帐号数据丢失」问题：云端自动将其视为`Data (BYTES)`，而不是之前的 `String`，导致所有用户的 iCloud 披萨小助手本机帐号配置文件中的游戏字段也被这样搞成不兼容的数据值。
- [iOS / macOS][综合] 新增了对于原神 5.3 新角色、新武器等新内容的支持。
- [iOS / macOS][综合] 更换了 App 内部的官方游戏活动资讯来源。
- [iOS / macOS][综合] 主程式画面今日页签的原神每日材料现在会从指定伺服器时间的每日凌晨四点开始统计当天的材料。
- [iOS / macOS][综合] 更新了个人深渊战报介面的渊星素材，且针对 iPhone SE2 ~ SE3 启用紧缩排版模式。
- [iOS / macOS][展柜] 新增对米游社 / HoYoLAB 角色面板资料的显示支持。相关资料会专门用来显示 Enka 展柜查询结果所不包含的角色的内容。但 App 内建的「仅以 UID 查询展柜」的功能仍仅返回游戏展柜内的角色。
- [iOS / macOS][本地账号] 修复了本地账号编辑画面的「重新生成设备指纹」功能，且对《常见问题解答 (FAQ)》补遗了关于设备指纹等内容的表述。
- [iOS / macOS][本地账号] 现在起，在继承完旧版披萨的本地账号资料之后，相关内容会被立刻同步至小工具。
- [iOS / macOS][本地账号] 补充了本地账号资料库故障救灾机制的触发条件。
- [iOS / macOS][桌面小工具] 为显示玩家体力的桌面小工具实作了超宽大尺寸版式。该版式可用于 macOS 与 iPadOS。新的版式会利用右侧多出的空间来显示近期要结束的官方游戏活动、也会显示今天是星期几。
- [iOS / macOS][桌面小工具] 新增了一个桌面小工具、专门用来仅显示官方游戏活动资讯。该小工具允许只显示指定的游戏的活动资讯，且可以使用多种尺寸。
- [iOS / macOS][桌面小工具] 解决了原神每日材料桌面小工具「只能用英文显示今天星期几」的故障。
- [iOS / macOS][桌面小工具] 针对桌面小工具的配置介面补上了互斥特性：当您选择了随机背景时，对背景的具体选择的选项会被隐藏、直至您停用了随机背景。
- [iOS / macOS][通知] 对整个 App 的实时便笺通知排定工作做了优化、将其中的大部分环节转交给背景进程来完成。
- [iOS / macOS][本地化] 修复了几处与抽卡记录管理器有关的文字表述错误。
- [watchOS] 界面排版调整。
- [watchOS] 修复了小工具推荐清单会出现不合理内容的故障。

// CHT ---------------------------------------------

// 《（統一）披薩小助手》v5.0.4 的更新內容簡述

- 從這一版開始，我們停止接受捐贈。相關的功能已經從 App 本體全部移除。
- [iOS / macOS / watchOS][小工具] 用多種綜合手段改良了玩家體力桌面小工具的載入效率與記憶體佔用、且以共用快取的機制避免了多個小工具在配置了相同的本機帳號時同時請求實時便箋資料的行為。與此有關的小工具的內容更新規律的改變請洽《常見問題解答 (FAQ)》。
- [iOS / macOS / watchOS][每日便箋] 修復了絕區零每日便箋的影像店營業狀態描述文字。
- [iOS / macOS / watchOS][SwiftData] 嘗試將本機帳號中的 `Enum(RAW: String)` 資料類型改為 `Data`，以解決 SwiftData 與 CloudKit 之間相容性問題導致的「本機帳號資料頑固丟失」問題：雲端自動將其視為`Data (BYTES)`，而不是之前的 `String`，導致所有使用者的 iCloud 披薩小助手本地帳號設定檔中的遊戲欄位也被這樣搞成不兼容的資料值。
- [iOS / macOS][綜合] 新增了對於原神 5.3 新角色、新武器等新內容的支持。
- [iOS / macOS][綜合] 更換了 App 內部的官方遊戲活動資訊來源。
- [iOS / macOS][綜合] 主程式畫面今日頁籤的原神每日材料現在會從指定伺服器時間的每日凌晨四點開始統計當天的材料。
- [iOS / macOS][綜合] 更新了個人深淵戰報介面的淵星素材，且針對 iPhone SE2 ~ SE3 啟用緊縮排版模式。
- [iOS / macOS][展櫃] 新增對米遊社 / HoYoLAB 角色面板資料的顯示支持。相關資料會專門用來顯示 Enka 展櫃查詢結果所不包含的角色的內容。但 App 內建的「僅以 UID 查詢展櫃」的功能仍僅返回遊戲展櫃內的角色。
- [iOS / macOS][本機帳號] 修復了本機帳號編輯畫面的「重新生成設備指紋」功能，且對《常見問題解答 (FAQ)》補遺了關於設備指紋等內容的表述。
- [iOS / macOS][本機帳號] 現在起，在繼承完舊版披薩的本機帳號資料之後，相關內容會被立刻同步至小工具。
- [iOS / macOS][本機帳號] 補充了本機帳號資料庫故障救災機制的觸發條件。
- [iOS / macOS][桌面小工具] 為顯示玩家體力的桌面小工具實作了超寬大尺寸版式。該版式可用於 macOS 與 iPadOS。新的版式會利用右側多出的空間來顯示近期要結束的官方遊戲活動、也會顯示今天是星期幾。
- [iOS / macOS][桌面小工具] 新增了一個桌面小工具、專門用來僅顯示官方遊戲活動資訊。該小工具允許只顯示指定的遊戲的活動資訊，且可以使用多種尺寸。
- [iOS / macOS][桌面小工具] 解決了原神每日材料桌面小工具「只能用英文顯示今天星期幾」的故障。
- [iOS / macOS][桌面小工具] 針對桌面小工具的配置介面補上了互斥特性：當您選擇了隨機背景時，對背景的具體選擇的選項會被隱藏、直至您停用了隨機背景。
- [iOS / macOS][通知] 對整個 App 的實時便箋通知排定工作做了優化、將其中的大部分環節轉交給背景執行緒來完成。
- [iOS / macOS][本機化] 修復了幾處與抽卡記錄管理器有關的文字表述錯誤。
- [watchOS] 介面排版調整。
- [watchOS] 修復了小工具推薦清單會出現不合理內容的故障。

// JPN ---------------------------------------------

// 「ピザ助手（無印）」v5.0.4 版が更新した内容：

- 寄付の受付はこのバージョンから停止しました。関連する機能はアプリ本体からすべて削除ずみです。
- [iOS / macOS / watchOS][ウィジェット] さまざまな統合手段を用いて、スタミナウィジェットの読み込み効率とメモリ使用量を改善し、共有キャッシュの仕組みを採用して、同じプロファイルを設定した複数のウィジェットがリアルタイム便箋データを同時に請求する挙動を防止しました。これらのウィジェットに関連する更新頻度の変更については「よくある質問（FAQ）」をご参照ください。
- [iOS / macOS / watchOS][毎日の便箋] ゼンレスゾンゼロの毎日の便箋におけるビデオ屋の営業状態説明テキストを修正しました。
- [iOS / macOS / watchOS][SwiftData] SwiftData と CloudKit の間の互換性問題で発生した「プロファイルデータが急に消失してしまう」問題を解決するために、プロフィールの Enum(RAW: String) データ型を Data に再定義しています。クラウド側はこれを以前の String の代わりに自動的に Data (BYTES) と見なすため、すべてのユーザーの iCloud Pizza Helper プロフィールのゲームフィールドも不互換なデータ値に変わってしまいました。
- [iOS / macOS][全般] 原神バージョン5.3の新キャラクターや新武器などの新コンテンツへの対応を追加しました。
- [iOS / macOS][全般] アプリ内の公式のゲームイベント情報のソースを変更しました。
- [iOS / macOS][全般] 今日タブ内の原神の毎日の材料セクションは、指定されたサーバー時間の毎日午前4時からその日の材料を集計するように調整されました。
- [iOS / macOS][全般] 深淵戦報インターフェースの淵星素材を更新し、iPhone SE2～SE3に対してUIの圧縮組版を起用しました。
- [iOS / macOS][ショーケース] 個人ショーケースにはこれから HoYoLAB / 米遊社 から該当プロファイルの全てのキャラクターのビルド資料を表示することができるようにしましたが、一番正確なる Enka Networks のショーケース結果の優先度は第一順位としました。なお、「UIDでショーケースを調べる」機能で出た結果はショーケースのキャラクターのみです。
- [iOS / macOS][プロファイル] プロファイル編集画面の「デバイス指紋を再生成」機能を修正し、「FAQ」にデバイス指紋に関する説明を補足しました。
- [iOS / macOS][プロファイル] 原神ピザ助手から引き継がれたプロファイルデータがウィジェットに即時同期されるようになりました。
- [iOS / macOS][プロファイル] プロファイルデータベースのデータ災害復旧対策の発動条件を補足しました。
- [iOS / macOS][デスクトップウィジェット] スタミナウィジェットにXLサイズのレイアウトを実装しました。このレイアウトはmacOSおよびiPadOSで利用可能です。右側の余分なスペースを活用して、近日終了予定の公式のゲームイベントや今日の曜日を表示します。
- [iOS / macOS][デスクトップウィジェット] 公式のゲームイベント情報のみを表示する専用の新しいデスクトップウィジェットを追加しました。このウィジェットは特定のゲームのイベント情報のみを表示することができ、さまざまなサイズに対応しています。
- [iOS / macOS][デスクトップウィジェット] 原神の毎日の材料ウィジェットが「今日の曜日」を英語でしか表示できない不具合を修正しました。
- [iOS / macOS][デスクトップウィジェット] ウィジェット構成画面に排他機能を追加しました：ランダム背景を選択すると、具体的な背景選択オプションが非表示になり、ランダム背景を無効にするまで再表示されません。
- [iOS / macOS][通知] アプリ全体のリアルタイム便箋通知のスケジューリングを最適化し、その大部分の処理をバックグラウンドスレッドに委譲しました。
- [iOS / macOS][ローカライズ] ガチャ記録管理に関連するいくつかのテキストエラーを修正しました。
- [watchOS] UIのレイアウトを調整しました。
- [watchOS] ウィジェット推奨リストに不合理な内容が表示される不具合を修正しました。

// ENU ---------------------------------------------

// Major changes introduced in The Pizza Helper v5.0.4:

- Starting from this version, we have stopped accepting donations. All related features have been removed from the app.
- [iOS / macOS / watchOS][Widgets] Improved the loading efficiency and memory usage of the player stamina widgets using various integrated methods, and adopted a shared cache mechanism to prevent multiple widgets (configured with the same profile) from simultaneously requesting Realtime Notes data. For changes in update frequency related to these widgets, please refer to the "FAQ".
- [iOS / macOS / watchOS][Daily Notes] Fixed the description text for the VHS Store operating status in the Zenless Zone Zero daily notes.
- [iOS / macOS / watchOS][SwiftData] Attempting to redefine certain fields of the local profile's `Enum(RAW: String)` data type as `Data` to solve the "persistent local profile data loss" issue caused by the compatibility problem between SwiftData and CloudKit: The cloud automatically treats it as `Data (BYTES)` instead of the previous actual type `String`, resulting in all users' iCloud Pizza Helper profiles having their `game` field recorded into incompatible data values.
- [iOS / macOS][General] Added support for new characters, new weapons, and other new content from Genshin Impact v5.3 release.
- [iOS / macOS][General] Updated the source of official in-game event information within the app.
- [iOS / macOS][General] Adjusted the Genshin Impact Daily Materials section in the Today tab to now start counting materials for the day from 0400hrs based on the user-specified server timezone.
- [iOS / macOS][General] Updated Abyss Battle Report materials for Abyss Stars and enabled a compressed UI layout for iPhone SE2 ~ SE3.
- [iOS / macOS][Showcase] Add support for displaying character details using data from Miyoushe / HoYoLAB. These are used as fallback data for Enka Showcase query results since the latter can only cover those characters pinned in the showcase. Note that "Use UID to query the showcase" feature still only returns the results from the character showcase.
- [iOS / macOS][Profile] Fixed the "Regenerate Device Fingerprint" function in the profile editing interface and supplemented the "FAQ" with explanations regarding device fingerprints.
- [iOS / macOS][Profile] Local profile data inherited from the previous "Pizza Helper for Genshin" will now sync immediately to the widgets right after the inheritation process is done.
- [iOS / macOS][Profile] Added supplementary conditions for triggering the disaster recovery mechanism of the local profile database.
- [iOS / macOS][Desktop Widgets] Implemented the ExtraLarge layout for the player stamina desktop widget, available on macOS and iPadOS. This layout uses the extra right-side space to display upcoming official in-game events and the current day of the week.
- [iOS / macOS][Desktop Widgets] Introduced a new desktop widget dedicated to displaying only official in-game event information. This widget supports filtering events by specific games and can be used in various sizes.
- [iOS / macOS][Desktop Widgets] Fixed an issue where the Genshin Impact Daily Materials widget could only display the day of the week in English.
- [iOS / macOS][Desktop Widgets] Added an exclusion feature to the widget configuration interface: selecting a random background will hide specific background selection options until the random background is disabled.
- [iOS / macOS][Notifications] Optimized scheduling for Realtime Notes notifications across the app, delegating most processes to background threads.
- [iOS / macOS][Localization] Fixed several textual errors related to the Gacha Record Manager.
- [watchOS] Adjusted interface layouts.
- [watchOS] Fixed an issue where unreasonable content appeared in the widget recommendation list.

// RUS ---------------------------------------------

// Основные изменения в The Pizza Helper v5.0.4:

- Начиная с этой версии, мы прекращаем принимать пожертвования. Все связанные функции были удалены из приложения.
- [iOS / macOS / watchOS][Виджеты] Улучшена эффективность загрузки и использование памяти виджетов выносливости игрока с помощью различных интегрированных методов. Также внедрен механизм общего кэша, чтобы предотвратить одновременные запросы данных "Заметок в реальном времени" несколькими виджетами, настроенными с одинаковым профилем. Изменения в частоте обновления этих виджетов описаны в разделе "FAQ".
- [iOS / macOS / watchOS][Ежедневные заметки] Исправлен текст описания статуса работы видеопроката в ежедневных заметках Zenless Zone Zero.
- [iOS / macOS / watchOS][SwiftData] Пытаемся изменить тип данных Enum(RAW: String) локального профиля на Data, чтобы решить проблему «потери данных локального аккаунта», вызванную несовместимостью между SwiftData и CloudKit: облако автоматически рассматривает это как Data (BYTES) вместо предыдущего String, из-за чего поле игры в профилях всех пользователей iCloud Pizza Helper становится несовместимым.
- [iOS / macOS][Общее] Добавлена поддержка новых персонажей, нового оружия и других новых материалов из обновления Genshin Impact версии 5.3.
- [iOS / macOS][Общее] Обновлен источник информации о официальных игровых событиях в приложении.
- [iOS / macOS][Общее] В разделе "Материалы дня" для Genshin Impact на вкладке "Сегодня" теперь учитываются материалы с 4:00 утра по указанному пользователем часовому поясу сервера.
- [iOS / macOS][Общее] Обновлены материалы отчета о сражениях бездны для "Звезд бездны" и включен сжатый макет интерфейса для iPhone SE2 ~ SE3.
- [iOS / macOS][Витрина] Добавлена поддержка отображения информации о персонажах с использованием данных из Miyoushe / HoYoLAB. Эти данные используются как резервная информация для результатов запросов Enka Showcase, поскольку последние охватывают только тех персонажей, которые закреплены в витрине. Обратите внимание, что функция "Использовать UID для запроса витрины" по-прежнему возвращает результаты только из витрины персонажей.
- [iOS / macOS][Профиль] Исправлена функция "Перегенерация отпечатка устройства" в интерфейсе редактирования профиля. Также в разделе "FAQ" добавлены объяснения, касающиеся отпечатков устройств.
- [iOS / macOS][Профиль] Локальные данные профиля, унаследованные от предыдущего "Pizza Helper for Genshin", теперь сразу синхронизируются с виджетами после завершения процесса наследования.
- [iOS / macOS][Профиль] Добавлены дополнительные условия для запуска механизма восстановления локальной базы данных профилей в случае сбоя.
- [iOS / macOS][Рабочий стол Виджеты] Реализован макет ExtraLarge для рабочего стола виджета выносливости игрока, доступный на macOS и iPadOS. Этот макет использует дополнительное пространство справа для отображения предстоящих официальных игровых событий и текущего дня недели.
- [iOS / macOS][Рабочий стол Виджеты] Добавлен новый виджет рабочего стола, предназначенный только для отображения информации об официальных игровых событиях. Этот виджет поддерживает фильтрацию событий по конкретным играм и доступен в различных размерах.
- [iOS / macOS][Рабочий стол Виджеты] Исправлена ошибка, из-за которой виджет "Материалы дня" для Genshin Impact мог отображать день недели только на английском языке.
- [iOS / macOS][Рабочий стол Виджеты] Добавлена функция исключения в интерфейс настройки виджетов: при выборе случайного фона параметры выбора конкретного фона будут скрыты до тех пор, пока случайный фон не будет отключен.
- [iOS / macOS][Уведомления] Оптимизировано планирование уведомлений "Заметок в реальном времени" по всему приложению. Большинство процессов теперь выполняется в фоновом режиме.
- [iOS / macOS][Локализация] Исправлены несколько текстовых ошибок, связанных с менеджером записи гачи.
- [watchOS] Скорректированы макеты интерфейса.
- [watchOS] Исправлена ошибка, из-за которой в списке рекомендаций виджетов появлялся некорректный контент.

