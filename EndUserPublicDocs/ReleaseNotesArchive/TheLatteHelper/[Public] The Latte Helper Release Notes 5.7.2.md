// 《拿铁小助手》v5.7.2 的更新内容简述：

- 修复了详情画面在载入资料时无法显示载入动画的故障。与此有关的环形载入动画图示已彻底重写、取代了 SwiftUI 原生的有故障的 ProgressView。
- 微调了小工具的一些文字排版与字型套用。
- 重构了开箱画面（OOBE画面）的排版，且新增了与难民 plist 资料包有关的使用说明文字。对于已经无法再触发开箱画面的用户而言，可以阅读 FAQ 来了解如何读入难民资料。
- 修复了一个故障。该故障可能会妨碍小工具对自身所需的图片素材的读取。
- 解决了官方游戏活动讯息画面点开时会卡死的故障。该故障实质为跨执行绪冲突。
- 允许使用者在 UI 设定画面内手动重设本机 EnkaDB 缓存。
- 重新启用了 Liquid Glass 画面风格，且改良了对玻璃特效的应用。也重新给 iPhone 设计了 OS26+ 专用的画面底部页签条。也允许使用者在 UI 设定画面内停用部分 UI 玻璃特效。
- 调整了主视窗在 macOS 系统下的最小尺寸。
- 仅 macOS: 个人战报画面的类型选单现在挪到了工具列当中。

(现阶段暂停提供 macCatalyst 版本，以减轻 App Store 审委会的审核工作量。这导致该 App 目前无法支持 Intel Mac 机种，因为只有 Apple Silicon Mac 可以直接运行 iPad 应用。上文中讨论到的与 macOS 有关的内容更新均指该 App 的 iPadOS 版本在 macOS 系统下的行为。)

$EOF.

// CHT - - - - - - - - - - - -

// 《拿铁小助手》v5.7.2 的更新內容簡述：

- 修復了詳情畫面在載入資料時無法顯示載入動畫的故障。與此有關的環形載入動畫圖示已徹底重寫、取代了 SwiftUI 原生的有故障的 ProgressView。
- 微調了小工具的一些文字排版與字型套用。
- 重構了開箱畫面（OOBE畫面）的排版，且新增了與難民 plist 資料包有關的使用說明文字。對於已經無法再觸發開箱畫面的使用者而言，可以閱讀 FAQ 來瞭解如何讀入難民資料。
- 修復了一個故障。該故障可能會妨礙小工具對自身所需的圖片素材的讀取。
- 解決了官方遊戲活動訊息畫面點開時會卡死的故障。該故障實質為跨執行緒衝突。
- 允許使用者在 UI 設定畫面內手動重設本機 EnkaDB 緩存。
- 重新啟用了 Liquid Glass 畫面風格，且改良了對玻璃特效的應用。也重新給 iPhone 設計了 OS26+ 專用的畫面底部頁籤條。也允許使用者在 UI 設定畫面內停用部分 UI 玻璃特效。
- 調整了主視窗在 macOS 系統下的最小尺寸。
- 僅 macOS: 個人戰報畫面的類型選單現在挪到了工具列當中。

(現階段暫停提供 macCatalyst 版本，以減輕 App Store 審委會的審核工作量。這導致該 App 目前無法支援 Intel Mac 機種，因為只有 Apple Silicon Mac 可以直接運行 iPad 應用。上文中討論到的與 macOS 有關的內容更新均指该 App 的 iPadOS 版本在 macOS 系統下的行為。)

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Latte Helper v5.7.2:

- Fixed an issue where the detail view failed to display loading animations when loading data. The related circular loading progress indicator has been completely rewritten to replace the buggy native SwiftUI ProgressView.
- Fine-tuned certain typographic and font settings for widgets.
- Refactored the layout of the OOBE view, adding instructions regaring how to import the refugee data (plist file). For those users who already triggered OOBE view, they can read FAQ to understand how to import the refugee data.
- Fixed an issue hindering widgets from accessing their image assets on certain circumstances.
- Fixed a concurrency conflict which hangs the app to death when trying to open the official in-game events sheet.
- Allowing users to reset local EnkaDB cache in UI Settings.
- Reenabled Liquid Glass UI theme with optimized toolbar liquid glass decoration applications, plus a new redesigned bottom-tab-bar for iPhone devices running OS26 and later. Users are now allowed to disable certain UI glass effects through UI settings.
- Fixed minimum window dimension on macOS.
- Battle Report View: Report type picker is now moved to the toolbar on macOS.

(We stopped supplying the macCatalyst build at App Store in order to reduce the App Review workload, so the app is currently unavailable on Intel-based Macs: Only Apple Silicon Macs are capable of running iPad apps. All above mentionings of macOS are related to the behavor of the iPadOS version on macOS.)

$EOF.

// JPN - - - - - - - - - - - -

// 「ラテ助手」v5.7.2 の主な更新内容：

- 詳細画面がデータを読み込む際にローディングアニメーションを表示できない不具合を修正しました。関連する円形ローディング進度インジケーターは完全に書き直され、不具合のある SwiftUI ネイティブの ProgressView に置き換わりました。
- ウィジェットのテキストレイアウトとフォント設定を微調整しました。
- OOBE 画面のレイアウトを再構成し、難民データ（plist ファイル）の取り込み方法に関する説明を追加しました。OOBE をまだ見たことのないユーザーの場合は、FAQ を読んで難民データの取り込み方法をご確認ください。
- ウィジェットが特定の状況下でイメージアセットにアクセスできない不具合を修正しました。
- 公式ゲーム内イベントシートを開く時にアプリが応答なくなる並行処理の不具合を修正しました。
- UI 設定画面で、ローカル EnkaDB キャッシュをリセットできるようになりました。
- Liquid Glass UI テーマを再度有効化し、ツールバーのリキッドガラス装飾の適用を最適化しました。また iOS 26 以降の iPhone デバイス用に新しい下部タブバーを再設計しました。ユーザーは UI 設定を通じて特定の UI ガラス効果を無効にできるようになりました。
- macOS での最小ウィンドウサイズを調整しました。
- 戦闘報告画面：macOS では報告タイプ選択メニューがツールバーに移動されました。

（App Review の作業負荷を軽減するため、macCatalyst 版の提供を一時停止しています。そのため現時点では Intel 製 Mac ではご利用できませんので、ご了承くださいませ。Apple Silicon 機種では iPad アプリを使うのは可能です。上記の macOS に関する全ての説明は、macOS 上で実行されている当アプリの iPadOS 版の動作に関連しています。）

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Латте помощник» v5.7.2:

- Исправлена ошибка, из-за которой экран сведений не отображал анимацию загрузки при загрузке данных. Связанный индикатор кольцевой загрузки полностью переписан, заменяя баглый встроенный ProgressView SwiftUI.
- Микрорегулировка типографических и шрифтовых параметров виджетов.
- Переработана структура экрана OOBE, добавлены инструкции по импорту файла данных беженцев (plist-файл). Для пользователей, которые ещё не видели экран OOBE, информация о способе импорта данных беженцев доступна в разделе FAQ.
- Исправлена проблема, которая препятствовала доступу ресурсам изображений виджетов при определённых обстоятельствах.
- Исправлена ошибка параллельного доступа, которая приводила к зависанию приложения при попытке открыть таблицу официальных игровых событий.
- Добавлена возможность сбросить локальный кэш EnkaDB вручную в параметрах интерфейса.
- Повторно включена тема Liquid Glass с оптимизированным применением эффектов жидкого стекла на панели инструментов, а также новая переработанная нижняя панель табуляции для устройств iPhone на OS 26 и новее. Пользователи теперь могут отключать определённые эффекты стекла интерфейса через параметры интерфейса.
- Исправлены минимальные размеры окна на macOS.
- Представление боевого доклада: селектор типа доклада перемещён на панель инструментов в macOS.

(Временно приостановлен выпуск версии macCatalyst, чтобы снизить нагрузку на команду App Review. Поэтому приложение сейчас недоступно на компьютерах Mac с процессорами Intel. Apple Silicon Mac могут запускать приложение iPad напрямую. Все упоминания macOS выше относятся к поведению версии для iPad этого приложения, работающей на macOS.)

$EOF.
