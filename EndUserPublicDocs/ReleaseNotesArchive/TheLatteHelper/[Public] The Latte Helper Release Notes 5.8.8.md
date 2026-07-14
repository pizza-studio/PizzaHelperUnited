// 《拿铁小助手》v5.8.8 的更新内容简述：

- 新增对《星穹铁道》v4.4 的新角色与新武器、新圣遗物的支持。
- 新增了原神 6.7 的纪行肖像。
- 对某些 Beta 版系统启用了一个相容策略：将 iPhone 专用的底部页签列挪到左上角。开发者无法阻止某些使用者拿 Beta 版系统作死，只能祭出这项特性更动、以保证 App 的可用性。
- 抽卡记录资料库管理体系现在会在 App 进入背景状态时延缓处理新的 SwiftData 内容更新通知。
- 抽卡记录获取画面：App 现在会对设备效能羸弱的机种始终停用动画。
- 修订了原神抽卡记录的卡池种类名称。
- 修复了在 App 于 macOS / iPadOS 启动之后主视图某些画面在初始显示时会「以 iPhone 尺寸来显示」的故障。
- 减少了在获取抽卡记录时的介面动画绘制频次，借此解决了与此有关的死当故障。
- 全专案彻底剿灭了与 Combine-based Observability 有关的 API 的使用，因为这类 Deprecated API 在比 OS 26 更新的系统下的实际表现不如 Swift Observation Macro 那样稳定。这解决了本机账号管理器在新系统下无法正常使用的故障。

注意：用户拿尚未发行过正式版的年度大版本更新的测试版系统来运行的情形不受敝团队所支持。Apple 研发者会员授权合约限制我们在对 App Store 张贴的版本更新日志当中提及与这类操作系统有关的情形细节（特别是与系统 API 有关的年度行为变化）。我们只能说这种情形可能会导致任何形式的资料丢失与软件可用性问题。

(本软件不再在 App Store 提供 macCatalyst 版本。这可以减轻 App Store 审委会的审核工作量。这也导致该 App 无法继续支持 Intel Mac 机种，因为只有 Apple Silicon Mac 可以直接运行 iPad 应用。上文中讨论到的与 macOS 有关的内容更新均指该 App 的 iPadOS 版本在 macOS 系统下的行为。本软件以 SwiftUI 技术制作，而 SwiftUI 在 Apple Silicon 电脑上往往能得到更良好的效能体验。)

$EOF.

// CHT - - - - - - - - - - - -

// 《拿鐵小助手》v5.8.8 的更新內容簡述：

- 新增了原神 6.7 的紀行肖像。
- 對某些 Beta 版系統啟用了一個相容策略：將 iPhone 專用的底部頁簽列挪到左上角。開發者無法阻止某些使用者拿 Beta 版系統作死，只能祭出這項特性更動、以保證 App 的可用性。
- 抽卡記錄資料庫管理體系現在會在 App 進入背景狀態時延緩處理新的 SwiftData 內容更新通知。
- 抽卡記錄獲取畫面：App 現在會對設備效能羸弱的機種始終停用動畫。
- 修訂了原神抽卡記錄的卡池種類名稱。
- 修復了在 App 於 macOS / iPadOS 啟動之後主視圖某些畫面在初始顯示時會「以 iPhone 尺寸來顯示」的故障。
- 減少了在獲取抽卡記錄時的介面動畫繪製頻次，藉此解決了與此有關的死當故障。
- 全專案徹底剿滅了與 Combine-based Observability 有關的 API 的使用，因為這類 Deprecated API 在比 OS 26 更新的系統下的實際表現不如 Swift Observation Macro 那樣穩定。這解決了本機帳號管理器在新系統下無法正常使用的故障。
- 新增對《星穹鐵道》v4.4 的新角色與新武器、新聖遺物的支援。

注意：使用者拿尚未發行過正式版的年度大版本更新的測試版系統來運行的情形不受敝團隊所支援。Apple 研發者會員授權合約限制我們在對 App Store 張貼的版本更新日誌當中提及與這類操作系統有關的情形細節（特別是與系統 API 有關的年度行為變化）。我們只能說這種情形可能會導致任何形式的資料丟失與軟體可用性問題。

(敝軟體不再在 App Store 提供 macCatalyst 版本，以減輕 App Store 審委會的審核工作量。這也導致該 App 無法繼續支援 Intel Mac 機種，因為只有 Apple Silicon Mac 可以直接運行 iPad 應用。上文中討論到的與 macOS 有關的內容更新均指该 App 的 iPadOS 版本在 macOS 系統下的行為。敝軟體以 SwiftUI 技術製作，而 SwiftUI 在 Apple Silicon 電腦上往往能得到更良好的效能體驗。)

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Latte Helper v5.8.8:

- Added support for new characters and new weapons & new artifacts introduced in Star Rail v4.4.
- Added Genshin Impact 6.7 Battle Pass avatars.
- A compatibility policy has been implemented for certain beta OS releases: the iPhone-exclusive bottom tab bar is moved to the top left corner. Developers cannot prevent some users from abusing beta systems, hence featuring this change to ensure the usability of this app.
- The entire Gacha Record Manager infrasture now defers the response against backend SwiftData changes when the app is in the background.
- On performance-impaired devices, the app now always disables the UI animation during the process of retrieving gacha records.
- Revised Genshin Impact gacha banner type names.
- Fixed various views initially rendering at iPhone size on macOS / iPadOS after launch.
- Reduced UI animation frequency when fetching gacha records, resolving related freeze issues.
- Completely eliminated Combine-based Observation APIs project-wide, as these deprecated APIs are less stable than Swift Observation on systems newer than OS 26. This resolved the Profile Manager being non-functional on newer OS releases.

Note: Scenarios where users run a beta version of an annual major system update that has not yet been officially released are not supported by us. The Apple Developer Program License Agreement restricts us from mentioning details of annual OS-level API behavioral changes related to such operating systems in public release notes for App Store. We can only state that such scenarios may lead to any form of data loss and software usability issues.

(This app no longer supplies a macCatalyst build on the App Store. This helps reduce the App Review workload. As a result, the app can no longer support Intel-based Macs, since only Apple Silicon Macs can run the iPad app directly. All macOS-related mentions above refer to the behavior of the iPadOS version of this app running on macOS. This app is built with SwiftUI, which generally delivers better performance on Apple Silicon machines.)

$EOF.

// JPN - - - - - - - - - - - -

// 「ラテ助手」v5.8.8 の主な更新内容：

- このアップデートにて、当アプリは『スターレイル』v4.4 の新キャラクターと新しい武器＆聖遺物に対応しました。
- 原神 6.7 の紀行アバターを追加しました。
- 特定のベータ版 OS リリースに対して互換性ポリシーを実装しました：iPhone 専用の下部タブバーを左上隅に移動します。開発者は一部のユーザーがベータ版システムを乱用することを防げないため、当アプリの可用性を確保するためにこの変更を実施しました。
- ガチャ履歴マネージャー基盤全体が、当アプリがバックグラウンド状態のときにバックエンドの SwiftData 変更への応答を遅延するようになりました。
- パフォーマンスの低いデバイスでは、ガチャ履歴取得中の UI アニメーションが常に無効化されるようになりました。
- 原神のガチャ祈願の種類名を修正しました。
- macOS / iPadOS で起動後に一部のビューが最初に iPhone サイズで表示される問題を修正しました。
- ガチャ履歴取得時の UI アニメーション頻度を削減し、関連するフリーズ問題を解決しました。
- プロジェクト全体から Combine ベースの Observation API を完全に排除しました。これらの非推奨 API は OS 26 以降のシステムでは Swift Observation よりも安定性に劣るためです。これにより、新しい OS リリースでプロフィールマネージャーが機能しなくなる問題が解決されました。

注意：まだ正式リリースされていない年次大型アップデートのベータ版システムで当アプリを動作させることは、当チームのサポート対象外です。Apple Developer Programのライセンス契約により、App Storeの公開リリースノートでこのような非正式版OSに関する詳細（特にAPIの年次動作変更）を記載することは禁止されていますが、言えるのはこれだけです：こうした環境での弊アプリの利用は、いかなる形式のデータ損失およびソフトウェアの可用性の問題が発生しても責任を負いかねます。

（当アプリは今後、App StoreでのmacCatalyst版の提供を終了いたしました。これによりApp Store 審査委員会の作業負荷が軽減されます。そのため、Intel製Macではご利用いただけなくなりました。Apple Silicon機種ではiPadアプリを直接実行できます。上記のmacOSに関する全ての説明は、macOS上で実行されている当アプリのiPadOS版の動作に関連しています。当アプリはSwiftUIで構築されており、SwiftUIは一般にApple Siliconマシンでより優れたパフォーマンスを発揮します。）

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Латте помощник» v5.8.8:

- Добавлена поддержка новых персонажей, а также нового оружия и артефактов, представленных в Star Rail v4.4.
- Добавлены аватары Боевого пропуска Genshin Impact 6.7.
- Реализована политика совместимости для определённых бета-версий ОС: эксклюзивная для iPhone нижняя панель вкладок перемещена в верхний левый угол. Разработчики не могут предотвратить использование некоторыми пользователями бета-версий систем, поэтому данное изменение внедрено для обеспечения работоспособности приложения.
- Вся инфраструктура менеджера истории молитв теперь откладывает ответ на изменения SwiftData в фоновом режиме, когда приложение находится в фоне.
- На устройствах с низкой производительностью приложение теперь всегда отключает анимацию интерфейса во время получения истории молитв.
- Исправлены названия типов молитв Genshin Impact.
- Исправлена проблема, при которой некоторые представления после запуска на macOS / iPadOS изначально отображались в размере iPhone.
- Снижена частота анимации интерфейса при получении истории молитв, что решило связанные с этим проблемы зависания.
- Полностью удалены API на основе Combine Observation во всём проекте, поскольку эти устаревшие API менее стабильны, чем Swift Observation, в системах новее OS 26. Это решило проблему неработоспособности менеджера профилей на новых версиях ОС.
Внимание: Сценарии, при которых пользователи запускают приложение на бета-версии ежегодного крупного обновления системы, ещё не выпущенной официально, не поддерживаются нашей командой. Лицензионное соглашение Apple Developer Program ограничивает нас в упоминании деталей изменений поведения API таких операционных систем в публичных заметках к обновлениям для App Store. Мы можем лишь предупредить, что такие сценарии могут привести к потере любых данных и проблемам с работоспособностью программного обеспечения.

(Приложение больше не предоставляет сборку macCatalyst в App Store. Это помогает снизить нагрузку на команду App Review. В связи с этим приложение больше не поддерживает компьютеры Mac с процессорами Intel, поскольку только Apple Silicon Mac могут напрямую запускать iPad-приложения. Все упоминания macOS выше относятся к поведению версии этого приложения для iPad, работающей на macOS. Это приложение создано с использованием SwiftUI, который, как правило, обеспечивает более высокую производительность на машинах Apple Silicon.)

$EOF.
