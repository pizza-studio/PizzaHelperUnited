// 《（统一）披萨小助手》v5.2.2 的更新内容简述：

注意：如果您已经在使用本 App 的嵌入式小工具（用于 iOS 锁定画面等场合）的话，本次更新安装完毕之后请重新开机，否则可能会遇到嵌入式小工具失效的情况。原因出自系统本身（或设备太旧导致的可用硬件资源不足），开发者对此无解。

【主要改动】

- 本次更新对披萨小助手的小工具体系进行了大规模的重构。许多内容仅对程序维护有重大意义，但有两项对用户体验影响较大的更新：
- 近期 v5.2.1 版本中引入的与用户壁纸配置有关的交互设计并不理想，可能会让许多用户感到困惑。本次更新对相关实作进行了重构，将用户壁纸与 App 内置壁纸同时列出供用户选择。副作用是所有与 Live Activity（实时活动/即时动态）相关的选项都需要用户重新设置，App 主界面的背景图也需要用户重新设置。
- 桌面小工具新增了袖珍玻璃版式支持。所有可配置本地账号的桌面小工具，在手动启用新功能开关后即可使用该版式。该版式是此前《星铁披萨小助手》预设使用的小工具版式，会在要显示的文字资讯底部加上玻璃底层，提升文字可读性。至此，《星铁披萨小助手》的所有功能体验已全部被现在的《统一披萨小助手》继承。用户现在也可以让某个桌面小工具彻底关闭探索派遣显示，或令其独占显示。

【杂项】

- 修复了新闻模块无法获取绝区零官方新闻与活动资讯的问题。
- 修复了一个线程安全缺陷，该缺陷可能导致主程序在反复手动推送本地账号数据包到 Watch App 时让 Apple Watch 端崩溃。
- 修复了本地账号管理器在操作失败时会弹出操作成功提示的问题。
- 优化了 Live Activity 在启用壁纸时的文字阴影效果，提升可读性。
- 针对主程序界面的实时便签中的探索派遣肖像引入了本地临时缓存机制，减少相关网络请求次数。
- 原神的探索派遣肖像现在会被裁剪为圆形，减少排版不一致的问题。该修改同时影响主程序界面和桌面小工具。
- 用户壁纸管理器现在允许用户通过右键菜单将某张用户壁纸直接设置为 App 主界面背景图或 Live Activity 背景图。
- 修复了壁纸画廊右键菜单对某张壁纸「是否已被设置为 Live Activity 背景图」状态显示错误的问题。
- 规范了桌面小工具部分组件的尺寸实作。
- 移除了与深境螺旋排行榜相关的残留描述。该功能已在此前某次更新中彻底移除。
- 调整了日语界面对玩家体力满载状态的描述方式。
- 解决了嵌入式小工具在 iOS / watchOS 系统下与主程序争夺 SwiftData 数据库读写权限导致的性能问题。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.2.2 的更新內容簡述：

注意：如果您已經在使用本 App 的嵌入式小工具（用於 iOS 鎖定畫面等場合）的話，本次更新安裝完畢之後請重新開機，否則可能會遇到嵌入式小工具失效的情況。原因出自系統本身（或設備太舊導致的可用硬體資源不足），開發者對此無解。

【主要改動】

- 此版更新對披薩小助手的小工具體系進行了超大規模的修整手術。很多內容僅對程式維護而言意義重大，但仍有兩處對使用者體驗而言的重大更新：
- 近期 v5.2.1 版更新所引入的與使用者壁紙設定有關的交互設計並不理想，可能會讓很多使用者感到困惑。這一版更新對相關實作做了重構、將使用者壁紙與 App 內建壁紙同時列出來讓使用者選擇。副作用就是所有與 Live Activity (實時活動/即時動態) 有關的選項都需要使用者重新設定。App 主介面的背景圖也需要使用者重新設定。
- 對桌面小工具新增了袖珍玻璃版式支持。所有可以配置本機帳號的桌面小工具均可以在手動啟用這些新的功能開關之後喚醒這個版式。該版式是此前《星鐵披薩小助手》預設使用的桌面小工具的版式，會在要呈現的文字資訊的底部塗有玻璃底層、讓文字資訊更具視認性。至此，《星鐵披薩小助手》的所有功能體驗均被現在的《統一披薩小助手》全部繼承完畢。使用者現在也可以對某個桌面小工具徹底關掉探索派遣顯示、或者使其獨佔顯示。

【雜項】

- 修復了新聞模組拿不到絕區零官方新聞與活動資訊的故障。
- 修復了一處執行緒安全故障缺陷。該缺陷可導致主程式在嘗試往 Watch App 反覆手動推播本機帳號資料時讓 Apple Watch 的 App 崩潰掉。
- 修復了本機帳號管理器在操作失敗時「會彈出操作成功的訊息」的故障。
- 改良了 Live Activity 在使用壁紙時的文字陰影，以保證其可視性。
- 針對主程式畫面的實時便箋的探索派遣肖像引入了本機臨時快取機制，以減少與此有關的網路請求次數。
- 原神的探索派遣肖像現在會被乾淨整潔地切削成圓形，減少排版上的不一致性。該修改同時影響到主程式畫面與桌面小工具。
- 使用者壁紙管理器現在允許使用者通過上下文選單將某樣使用者壁紙直接設定為 App 主介面的背景圖、Live Activity 背景圖。
- 修復了壁紙畫廊上下文選單對某個壁紙「是否已經被設定為 Live Activity 背景圖」的狀態顯示錯誤的故障。
- 規範了用於桌面小工具的一些零件的寸法實作。
- 移除了與深境螺旋排行榜有關的殘留描述。該功能在先前的某次更新當中被徹底移除。
- 調整了日語介面對玩家體力的滿載情況的描述方法。
- 解決了嵌入式小工具在 iOS / watchOS 系統下與主程式爭奪 SwiftData 資料庫讀寫權限所導致的效能問題。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.2.2:

Note: If you are already using the embedded widgets of this app (for iOS Lock Screen or other scenarios), please restart your device after installing this update. Otherwise, you may encounter issues with the embedded widgets (of this app) failing to function. This is due to the system itself (or insufficient hardware resources caused by an outdated device), and the developer has no solution for this.

【Main Changes】

- This release involve a mass-scale surgery against the entire widget infrastructure of this app. Most of the changes are only meaningful to the maintenance of this app. However, there are two new significant changes regarding user experience:
- The interactive design related to user wallpaper settings introduced in the recent v5.2.1 update may confuse many users during use. This update refactors the relevant implementation, listing both user wallpapers and app-built-in wallpapers for users to choose from. The side affect of this refactoring is that users are required to reconfigure all options related to Live Activity. The background image of the app’s main interface also needs to be reconfigured by users.
- Added a new "Tiny Glass" layout style support for all desktop widgets configurable with local profiles. This new layout needs to be manually enabled through some newly-added toggles in the per-widget settings. This layout style is the default widget style used in the previously deprecated "Pizza Helper for HSR" and is its final feature migrated to this app. This new layout style uses glass-like rounded rectangles beneath the information object displayed in the widget, enhancing the legibility of the texts. Furthermore, user can now configure a desktop widget to let it display available expedition tasks exclusively or hide expedition tasks completely.

【Miscellaneous】

- Fixed an issue hindering the Ongoing Events feature from fetching Zenless Zone Zero official news data.
- Fixed a concurrency issue which can crash the watch app if the user repeated the action of letting the main app push the local profile data package to the watch app.
- Fixed a logical issue that the Local Profile Manager may toast a successful message instead when an operation fails.
- Live Activity now uses optimized text shadows for legibility when it gets configured with wallpapers feature enabled
- Introduced local image cache feature for expedition pilot photos for the Real Time Notes display in the main app. This reduces the frequency of its related network requests.
- All expedition pilot photos for Genshin Impact now gets cut cleanly into a circle. This reduces layout hassles significantly. This change affects the Real Time Notes display in both the main app and the desktop widgets.
- The user wallpaper manager now allows users to set a specific user wallpaper as the background image for the app’s main interface or Live Activity background directly via the context menu.
- Fixed an issue where the wallpaper gallery’s context menu incorrectly displayed the status of whether a wallpaper was set as the Live Activity background.
- Applied thorough formalization of UI component metrics against the view components used for desktop widgets.
- Removed residual descriptions related to the Spiral Abyss Top Lists feature. This feature was completely removed in a previous update.
- Changed the expression used in Japanese UI localization regarding how the max state of primary stamina gets described.
- Resolved a performance issue where embedded widgets were competing with the main app for SwiftData database read/write permissions on iOS and watchOS.

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.2.2 版が更新した内容：

ご注意：本アプリのウィジェットを iOS のロック画面などで使用している場合、この更新のインストール後に端末の再起動が必要になります。これを行わないとウィジェットが応答しなくなる可能性があります。この問題はシステム自体に起因するもの（または古い機種（iOS 端末）のハードウェア性能が不足）のため、開発者側では解決できません。

【主な更新内容】

- 本バージョンでは、ピザ助手のウィジェット関連のインフラを大規模に再構築しました。その多くはメンテナンス的な意味合いが強いですが、二つの重要な変更があります：
- 先日の v5.2.1 で導入した、ユーザー壁紙に関する設定方法が分かりにくいと認識しました。今回の更新で、ユーザー壁紙とアプリ内蔵の壁紙を同時に表示して選択できるように改善しました。これに伴い、Live Activity（ライブアクティビティ）の設定と、アプリのメイン画面の背景画像を再設定する必要があります。 
- デスクトップウィジェットに「袖珍硝子表示スタイル」レイアウトを追加しました。ローカルプロファイルを設定できるすべてのデスクトップウィジェットで、新しい設定トグルを有効にすることで使用できます。このレイアウトは以前の「崩スタピザ助手」で使用されていたもので、テキストの可読性を向上させるために硝子調の背景を表示します。これで「崩スタピザ助手」の全機能が現在の「ピザ助手（無印）」に移行完了しました。また、探索派遣の表示を完全に無効化したり、探索派遣のみを表示したりすることも可能になりました。

【その他の更新】

- ゼンレスゾーンゼロの公式ニュースとイベント情報が取得できない問題を修正しました。
- ローカルプロファイルデータを Watch App に手動で連続して送信した際に、 Watch App がクラッシュする可能性のある同時実行の問題を修正しました。
- ローカルプロファイル管理で操作が失敗した際に成功のメッセージが表示される問題を修正しました。
- 壁紙使用時の Live Activity のテキストシャドウを最適化し、視認性を向上させました。
- メイン画面のリアルタイムノートに表示される探索派遣のキャラクター画像にローカルキャッシュ機能を導入し、ネットワークリクエストの頻度を下げました。
- 原神の探索派遣のキャラクター画像を円形にトリミングし、レイアウトの一貫性を向上させました。この変更はメイン画面とデスクトップウィジェットの両方に適用されます。
- ユーザー壁紙管理画面で、コンテキストメニューから直接アプリのメイン画面背景や Live Activity の背景として設定できるようになりました。
- 壁紙ギャラリーのコンテキストメニューで、壁紙が Live Activity の背景として設定されているかどうかの表示が誤っていた問題を修正しました。
- デスクトップウィジェットで使用されるコンポーネントのサイズ指定を標準化しました。
- 深境螺旋ランキング機能に関する残存した説明を削除しました。この機能は以前のアップデートで完全に削除しました。
- スタミナが最大値に達した際の日本語表現を調整しました。
- メインアプリと（iOSロックスクリーンとwatchOS専用の）埋め込みウィジェットの間で SwiftData データベースのアクセス競合が発生していたパフォーマンスの問題を解決しました。

$EOF.


// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.2.2:

Внимание: если вы уже используете встроенные виджеты этого приложения (например, для экрана блокировки iOS), после установки этого обновления обязательно перезагрузите устройство. В противном случае встроенные виджеты могут перестать работать. Это связано с особенностями самой системы (или нехваткой аппаратных ресурсов на старых устройствах), и разработчик не может это исправить.

【Основные изменения】

- В этом обновлении была проведена масштабная реконструкция всей системы виджетов приложения. Большинство изменений важны для поддержки и развития программы, но есть два ключевых новшества, влияющих на пользовательский опыт：
- Взаимодействие, связанное с пользовательскими обоями, введённое в версии v5.2.1, оказалось неудачным и могло сбивать с толку многих пользователей. В этом обновлении реализация была переработана：теперь пользовательские обои и встроенные обои приложения отображаются вместе для выбора. Побочный эффект — все параметры, связанные с Live Activity (Живые активности), требуют повторной настройки, а фон главного экрана приложения также нужно выбрать заново。
- Для всех настольных виджетов, поддерживающих локальные профили, добавлен новый стиль оформления — «Tiny Glass» (мини-стекло). Этот стиль можно включить вручную через новые переключатели в настройках виджета. Такой стиль был стандартным для устаревшего приложения «Pizza Helper for HSR» и теперь полностью перенесён в это приложение。 Новый стиль добавляет стеклянную подложку под текстовую информацию, улучшая читаемость。Теперь пользователь может полностью отключить отображение экспедиций или, наоборот, сделать так, чтобы виджет показывал только экспедиции。

【Прочее】

- Исправлена проблема, из-за которой модуль новостей не мог получать официальные новости и события Zenless Zone Zero.
- Исправлен дефект потокобезопасности, который мог привести к сбою приложения на Apple Watch при многократной ручной отправке локальных профилей с основного приложения.
- Исправлена ошибка, из-за которой менеджер локальных профилей показывал сообщение об успешной операции даже при неудаче.
- Оптимизированы тени текста в Live Activity при использовании обоев для улучшения читаемости.
- Для портретов персонажей экспедиций в разделе «Реальные заметки» главного экрана введён локальный кэш изображений, что уменьшает количество сетевых запросов.
- Портреты персонажей экспедиций Genshin Impact теперь обрезаются по кругу для устранения несоответствий в верстке. Это изменение затрагивает как главный экран, так и настольные виджеты.
- В менеджере пользовательских обоев теперь можно через контекстное меню сразу установить выбранные обои как фон главного экрана приложения или Live Activity.
- Исправлена ошибка, из-за которой в контекстном меню галереи обоев неверно отображался статус «установлено как фон Live Activity».
- Стандартизированы размеры некоторых компонентов, используемых в настольных виджетах.
- Удалены остаточные описания, связанные с рейтингом Безды (Spiral Abyss Top Lists). Эта функция была полностью удалена в одном из предыдущих обновлений.
- Изменено описание состояния полной выносливости (стамины) в японской локализации.
- Решена проблема производительности, возникавшая из-за конкуренции за доступ к базе данных SwiftData между встроенными виджетами и основным приложением на iOS и watchOS。

$EOF.
