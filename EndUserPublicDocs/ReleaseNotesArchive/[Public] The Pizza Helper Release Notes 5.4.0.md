// 《（统一）披萨小助手》v5.4.0 的更新内容简述：

注意：用户拿尚未发行过正式版的年度大版本更新的测试版系统来运行的情形不受敝团队所支持。Apple 研发者会员授权合约限制我们在对 App Store 张贴的版本更新日志当中提及与这类操作系统有关的情形细节（特别是与系统 API 有关的年度行为变化）。我们只能说这种情形可能会导致任何形式的资料丢失。

- 注：本次更新不包含对《星穹铁道》3.4 的支援。目前仍可正常获取除了联动卡池以外的《星穹铁道》抽卡记录，只是某些抽卡内容的名称与图示恐无法正常显示而已。
- 针对原神的个人战报展示系统做了升级。与针对星穹铁道的个人战报展示系统「逐光捡金」相似：新版的原神个人战报展示系统「逐星捡银」支持对「幽境危战」与「深境螺旋」的个人战报展示。该系统目前不对「幻想真境剧诗」提供战报展示支持。
- 本应用现已全面弃用用于全局页面管理的 SwiftUI TabView，转而采用以主栏目与侧边栏分栏为主的全新的分栏架构。在 iPhone 上仅显示主栏目，在 iPadOS 横屏宽版或 macOS 下会显示侧边栏，且侧边栏仅在 iPadOS 横屏宽版或 macOS 下可见。当显示侧边栏时，今日画面不会在主栏目内显示。对于 iPhone 等超窄布局，底部页签列已重新实作，保留了用户的使用习惯（类似于此前 iPhone 上的 TabView 效果）。
- 今日画面会在适当时机显示跳转设定画面的按钮，但有例外：分栏模式下，主栏目已显示设定画面时，该按钮不会显示。此外，今日画面在极端条件下的版式兼容性得到优化，实时便笺中的原神内容倒计时文字格式也已调整。
- 优化了 StaggeredGrid 组件的性能，并修复了其对鼠标滚轮滚动操作无响应的问题。此优化影响了全角色证件照清单、角色库存清单、壁纸画廊等界面。
- 修复了壁纸画廊上下文选单的触发点作用对象范围过大的故障。
- App 壁纸设定画面已重构，支持通过壁纸标题文字检索。
- 新增壁纸时，「用户壁纸管理器」会弹出警告提示，提醒用户务必自行保留原始图片。
- 角色面板界面现已支持窗口尺寸变化响应，并修复了无法通过点击背景关闭的问题。
- 个人战报画面渊星在部分设备上的绘制异常已修复。
- 现采用后台任务保续 API 管理大规模 SwiftData 增删改操作，可防止设备休眠时被系统强制结束进程（避免 SQLite 死锁崩溃 0xdead10cc）。
- 针对 iOS 17 与 macOS 14 的 SwiftData 写入通知缺陷，现已采用 CoreData 的同类广播机制作为替代，暂无计划因该问题放弃对 iOS 17 / macOS 14 的支持。
- 画面尺寸、设备旋转方向、宽窄版状态的监听与处理逻辑已全面重构，相关操作的响应效率进一步提升。
- 鉴于 UserDefaults 容量已超限，角色展柜面板缓存与用户壁纸已迁移至硬盘直读存储，用户壁纸数量上限仍为 10，以免因内容过多导致解码耗时增加。
- 从这一版开始，本应用针对 iOS 启用了背景资料获取特性，这样可以在后台执行 iCloud 同步任务。用户仍可以通过 iOS 系统设定来针对本应用停用该特性。
- 调整了部分原神角色在本应用内的命途定位：香菱「巡猎」→「记忆」，克洛琳德「巡猎」→「毁灭」。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.4.0 的更新內容簡述：

注意：使用者拿尚未發行過正式版的年度大版本更新的測試版系統來運行的情形不受敝團隊所支援。Apple 研發者會員授權合約限制我們在對 App Store 張貼的版本更新日誌當中提及與這類操作系統有關的情形細節（特別是與系統 API 有關的年度行為變化）。我們只能說這種情形可能會導致任何形式的資料丟失。

- 注：本次更新不包含對《星穹鐵道》3.4 的支援。目前仍可正常獲取除了聯動卡池以外的《星穹鐵道》抽卡記錄，只是某些抽卡內容的名稱與圖示恐無法正常顯示而已。
- 針對原神的個人戰報展示系統做了升級。與針對星穹鐵道的「逐光撿金」戰報系統類似，全新「逐星撿銀」系統現已支援「幽境危戰」與「深境螺旋」戰報。此系統目前不支援「幻想真境劇詩」。
- 敝應用已全面棄用用於全域頁面管理的 SwiftUI TabView，改採主分欄與側邊欄為主的新架構。iPhone 僅顯示主分欄，iPadOS 或 macOS 橫屏寬版下有側邊欄，且側邊欄僅於 iPadOS 橫屏寬版或 macOS 下可見。顯示側邊欄時，今日畫面不會在主分欄內顯示。針對 iPhone 等超窄版，底部分頁列已重新實作，保留了使用者的操作習慣（類似過去 iPhone 上的 TabView）。
- 今日畫面會在適當時機顯示跳轉設定畫面按鈕，但有例外：分欄模式下主分欄已顯示設定畫面時，該按鈕不會顯示。此外，今日畫面在極端條件下的版型相容性已優化，並調整了即時便籤中原神內容倒數的文字格式。
- StaggeredGrid 元件效能已優化，並修正滑鼠滾輪對該元件無效的問題。此變更影響所有角色證件照清單、角色庫存清單、壁紙畫廊等介面。
- 修復了壁紙畫廊上下文選單的觸發點作用對象範圍過大的問題。
- App 壁紙設定畫面已重構，現支援以壁紙標題文字檢索。
- 新增壁紙時，「使用者壁紙管理器」將顯示警示，提醒使用者務必自行保留原始圖片。
- 角色面板畫面現可即時響應視窗尺寸變更，並修正了無法點擊背景關閉的問題。
- 個人戰報畫面淵星於部分裝置上的繪製異常問題已修復。
- 現採用背景任務保續 API 管理大規模 SwiftData 增刪改操作，可避免裝置休眠時遭系統強制結束進程（防止 SQLite 死鎖崩潰 0xdead10cc）。
- 針對 iOS 17 及 macOS 14 的 SwiftData 寫入通知缺陷，現已改用 CoreData 同類廣播機制，暫無因該問題放棄對 iOS 17 / macOS 14 的支援計畫。
- 畫面尺寸、裝置旋轉方向、寬窄狀態的監聽及處理邏輯已全面重構，相關操作的回應效率進一步提升。
- 因 UserDefaults 容量已超限，角色展櫃快取與使用者壁紙已遷移至硬碟直讀儲存，使用者壁紙數量上限仍為 10，以避免內容過多導致解碼效能下降。
- 從此版本起，敝應用於 iOS 啟用背景資料擷取功能，允許系統於背景自動同步 iCloud 資料。使用者仍可通過 iOS 系統設定停用此功能。
- 調整了部分原神角色在敝應用內的命途定位：香菱「巡獵」→「記憶」，克洛琳德「巡獵」→「毀滅」。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.4.0:

Note: Scenarios where users run a beta version of an annual major system update that has not yet been officially released are not supported by us. The Apple Developer Program License Agreement restricts us from mentioning details of annual OS-level API behavioral changes related to such operating systems in public release notes for App Store. We can only state that such scenarios may lead to any form of data loss.

- Note: The support of Star Rail v3.4 is not included in this update. It is still fine to get the gacha records from non-collaborative gacha pools for Star Rail at this time. It's just a matter that the app is unable to display the icons and names of certain gacha items correctly in the gacha record manager.
- Upgraded the Battle Report display system for Genshin Impact. Similar to "Treasure Lightward" for Star Rail, the new "Treasure Starward" system for Genshin Impact supports both Stygian Onslaught and Spiral Abyss. This system currently has no plan to implement the support of Imaginarium Theater.
- The use of SwiftUI TabView for global page management has been completely phased out in favor of a new architecture based on a main column and a sidebar. On iPhone, only the main column is shown; on iPadOS or macOS in wide landscape mode, the sidebar is present. The sidebar appears only on iPadOS in wide landscape or on macOS. When the sidebar is visible, the Today view will not appear in the main column. For iPhone and other ultra-compact layouts, the bottom tab bar has been reimplemented, preserving user habits (similar to what TabView previously provided on iPhone).
- The Today view now displays a button to jump to the Settings view when appropriate, with one exception: in split view mode, if the main column is already showing the Settings view, this button will not appear. Additional improvements include enhanced layout compatibility for the Today view under extreme conditions and better formatting for Genshin Impact countdown text in real-time notes.
- The performance of the StaggeredGrid component has been optimized, including a fix for lack of responsiveness to mouse wheel scrolling actions. This affects, at a minimum, the All-Character Photo Specimen View, Character Inventory View, and Wallpaper Gallery View.
- Fixed an issue in Wallpaper Gallery that the triggering spot scope of the context menu is way too large.
- The app’s wallpaper settings view has been reworked to allow searching by wallpaper title.
- The User Wallpaper Manager now displays a warning when adding a new wallpaper, reminding users to keep the original image files.
- The character build panel now properly responds to window size changes and can be closed by tapping the background.
- An issue where Abyss Stars could render incorrectly in the personal Battle Report view on certain devices has been fixed.
- Background task continuation APIs are now used to manage large-scale SwiftData add, delete, and update operations, preventing system-forced process termination during device sleep (which could cause SQLite deadlocks or crashes, such as 0xdead10cc).
- For a SwiftData write notification defect found in iOS 17 and macOS 14, a similar CoreData broadcast mechanism is now used instead. We do not plan to drop iOS 17 / macOS 14 support solely for this reason.
- The app’s handling of screen size, device orientation, and compact/expanded state context changes has been completely refactored, resulting in improved responsiveness for all related operations.
- Due to UserDefaults storage limitations, the Character Showcase panel cache and user wallpapers are now stored directly on disk. The maximum number of user wallpapers remains 10 to prevent decoding slowdowns from excessive data.
- Starting from this release, this app has its Background Fetch feature enabled on iOS to allow its iCloud data synchronized by the system in the background. This feature can be turned off through iOS system settings.
- Some Genshin Impact character lifepath designations in this app have been adjusted: Xiangling "The Hunt" → "Remembrance" and Clorinde "The Hunt" → "Destruction."

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.4.0 版が更新した内容：

注意：まだ正式リリースされていない年次大型アップデートのベータ版システムで本アプリを動作させることは、当チームのサポート対象外です。Apple Developer Programのライセンス契約により、App Storeの公開リリースノートでこのような非正式版OSに関する詳細（特にAPIの年次動作変更）を記載することは禁止されていますが、言えるのはこれだけです：こうした環境での弊アプリの利用は、いかなる形式のデータ損失が発生しても責任を負いかねます。

- 補記：本アップデートは『スターレイル』v3.4 にはまだ対応していません。現時点ではコラボガチャ以外の『スターレイル』ガチャ記録の取得は引き続き可能ですが、一部ガチャアイテムの名称やアイコンがガチャ記録管理画面で正しく表示できない場合があります。
- 原神向けの個人作戦報告表示システムをアップグレードしました。星穹鉄道向けの「光追金掴」と同様に、原神向けの新システム「星追銀掴」は「幽境の激戦」と「深境螺旋」の両方に対応しています（現時点では「幻想シアター」には非対応）。
- 当アプリは、アプリ全般ページ管理のための SwiftUI TabView の利用を全面的に廃止し、メインカラム＋サイドバーを主軸とした新しいアーキテクチャを採用しました。iPhone ではメインカラムのみが表示され、iPadOS または macOS の横画面ワイドモード時のみサイドバーが表示されます。サイドバーが表示される場合、「今日」画面はメインカラムには表示されません。iPhone など超コンパクトレイアウトでは、従来の iPhone 上の TabView と同様の操作感を維持したまま、ボトムタブバーを新たに実装しています。
- 「今日」画面では、適切なタイミングで設定画面へのジャンプボタンが表示されます。ただし、分割表示モードでメインカラムがすでに設定画面を表示している場合は、このボタンは表示されません。また、「今日」画面の極端なレイアウト条件下での互換性も最適化され、リアルタイムメモ内の原神カウントダウン表記も調整されています。
- StaggeredGrid コンポーネントのパフォーマンスを最適化し、マウスホイール操作に反応しない問題も修正しました。この変更は、「全キャラ身分証明用写真一覧」、「持っているキャラの一覧」、「壁紙の画廊」などの画面に影響します。
- 壁紙の画廊において、コンテキストメニューの発動範囲が大きすぎる不具合を修正しました。
- アプリの壁紙設定画面の実作を手直しし、壁紙タイトルによる検索に対応しました。
- ユーザー壁紙マネージャーで新しい壁紙を追加する際、元画像の保持を促す警告が表示されるようになりました。
- キャラクター育成パネルはウィンドウサイズの変更に正しく対応し、背景タップで閉じることもできるようになりました。
- 一部端末で作戦報告画面の淵星が正しく描画されない不具合を修正しました。
- バックグラウンドタスク継続 API を利用し、大量の SwiftData データの追加・削除・更新処理を管理することで、デバイスのスリープ中にシステムによる強制終了（SQLite デッドロックや 0xdead10cc クラッシュ）を防止します。
- iOS 17 および macOS 14 における SwiftData 書き込み通知の不具合に対し、同様の CoreData ブロードキャスト機構で代替しています。この問題を理由に iOS 17 / macOS 14 のサポートを打ち切る予定はありません。
- 画面サイズ・端末回転・レイアウト状態の検知と処理ロジックを全面的に見直し、これにより関連する操作の応答性が大幅に向上しました。
- UserDefaults の容量制限により、キャラクターショーケースパネルのキャッシュおよびユーザー壁紙はファイルシステムに直接保存されるようになりました。ユーザー壁紙は最大 10 枚までの制限を維持し、大量データによるデコード遅延を防ぎます。
- 本バージョンより、iOS 環境で本アプリのバックグラウンドフェッチ機能が有効化され、iCloud データがシステムによってバックグラウンド同期されるようになりました。この機能は iOS のシステム設定から無効化できます。
- 当アプリ内における一部原神キャラクターの命途パスを調整しました：香菱「巡狩」→「追憶」、クロリンデ「巡狩」→「壊滅」。

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.4.0:

Внимание: Сценарии, при которых пользователи запускают приложение на бета-версии ежегодного крупного обновления системы, ещё не выпущенной официально, не поддерживаются нашей командой. Лицензионное соглашение Apple Developer Program ограничивает нас в упоминании деталей изменений поведения API таких операционных систем в публичных заметках к обновлениям для App Store. Мы можем лишь предупредить, что такие сценарии могут привести к потере любых данных.

- Примечание: Поддержка Star Rail v3.4 не входит в это обновление. В настоящее время возможно получать записи гача из некроссоверных пулов Star Rail, однако некоторые названия и иконки предметов могут отображаться некорректно в менеджере записей гача.
- Обновлена система отображения личных отчётов по Genshin Impact. Как и «Озарённые светом сокровища» для Star Rail, новая система «К звёздам за сокровищами» для Genshin Impact поддерживает отчёты по Мрачному Натиску и Витой Бездне. На данный момент поддержка Театра «Воображариум» не планируется.
- В приложении полностью прекращено использование SwiftUI TabView для глобального управления страницами. Теперь реализована новая архитектура с основной колонкой и боковой панелью. На iPhone отображается только основная колонка, а на iPadOS или macOS в широком горизонтальном режиме появляется боковая панель, которая видна только в этих условиях. Когда боковая панель видна, экран «Сегодня» не отображается в основной колонке. Для iPhone и других сверхкомпактных макетов нижняя панель вкладок была реализована заново, чтобы сохранить привычный для пользователей опыт (аналогично TabView на iPhone ранее).
- На экране «Сегодня» теперь появляется кнопка для перехода к настройкам, когда это уместно. Исключение: в режиме разделённого экрана, если основная колонка уже показывает настройки, кнопка не отображается. Кроме того, улучшена адаптация верстки экрана «Сегодня» в экстремальных условиях и форматирование текста обратного отсчёта Genshin Impact в быстрых заметках.
- Оптимизирована производительность компонента StaggeredGrid и исправлена проблема с отсутствием реакции на прокрутку колесиком мыши. Это затрагивает, в частности, экраны «Галерея удостоверяющих фото всех персонажей» (All-Character Photo Specimen View), «Список доступных персонажей» (Character Inventory View) и «Галерея обоев» (Wallpaper Gallery View).
- Исправлена проблема в галерее обоев, когда область срабатывания контекстного меню была слишком большой.
- Экран настроек обоев был переработан; теперь можно искать обои по названию.
- При добавлении новых обоев менеджер пользовательских обоев теперь показывает предупреждение, напоминающее сохранить оригинальные изображения.
- Панель развития персонажа теперь корректно реагирует на изменение размера окна и может быть закрыта нажатием на фон.
- Исправлена проблема с некорректным отображением звёзд Бездны на экране «Личный отчёт о сражениях» на некоторых устройствах.
- Для управления масштабными операциями добавления, удаления и изменения SwiftData теперь используется API фоновых задач, что предотвращает принудительное завершение процесса системой при уходе устройства в спящий режим (во избежание deadlock SQLite и сбоев вроде 0xdead10cc).
- В связи с недостатками уведомлений о записи SwiftData в iOS 17 и macOS 14 теперь применяется аналогичный механизм рассылки из CoreData. Поддержка iOS 17 / macOS 14 не будет прекращена из-за этой проблемы.
- Логика отслеживания размеров экрана, ориентации устройства и состояния ширины/компактности была полностью переработана, что повысило отзывчивость соответствующих операций.
- Из-за ограничения объёма UserDefaults кэш панели витрины персонажей и пользовательские обои теперь хранятся непосредственно на диске. Максимальное количество пользовательских обоев по-прежнему составляет 10, чтобы избежать замедления декодирования при избыточном объёме данных.
- Начиная с этой версии, в приложении на iOS включена функция фоновой загрузки данных (Background Fetch), что позволяет системе синхронизировать данные iCloud в фоновом режиме. Эту функцию можно отключить через системные настройки iOS.
- В приложении скорректированы жизненные пути некоторых персонажей Genshin Impact: Сянлин «Охота» → «Воспоминание», Клоринда «Охота» → «Уничтожение».

$EOF.
