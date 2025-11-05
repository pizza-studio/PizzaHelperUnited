// 《（统一）披萨小助手》v5.6.2 的更新内容简述：

- 新增了对《星穹铁道》3.7 版的新角色（「昔涟」曲冽涅 (キュレネ Kyurene)）、新武器、新圣遗物套装的支持。
- 改良了对《空月之歌》6.1 的支持：正式支持对奇偶角色（Manekin）的培养面板资料的显示。目前所有属性的奇偶均暂时将命途归类至「毁灭」。然而，出于开发工作量负担等因素的考量，披萨小助手目前不打算支持与千星奇域有关的抽卡记录管理。
- 修复了一个错误：与玩家体力有关的阈值通知会错误地将通知推送时间当作回满预期时间。同时，考虑到体力通知在被 iOS / macOS 正式推送给玩家之前、玩家可能已经清空体力的情况，体力通知的讯息现在会在末尾追加「该通知的签发日期」。每次 App 重新排定玩家体力通知时，会更新这个签发日期。
- 此前就 OS 25 (iOS 18 & macOS 15) 早期版本特有的与 Bottom Toolbar Placement 有关的 SwiftUI 故障的修补策略不再有效，原因在于 Xcode 26.0 内建 SDK 所带来的相容性变化。于是，在这些个别有问题的 OS 25 早期子版本系统内使用本 App 时，App 在窄版画面时的页面切换控件改成了荧幕左上角的下拉选单，以确保功能上的可用性。
- 继续调整整个 App 与 Liquid Glass 界面的相容性。部分界面元素移除了 Liquid Glass 效果。在 OS 26 系统下，如果在画面底端显示页面切换控件的话，无论当前页面是哪一个，被选中的页面的名称都会以蓝色作为主题色显示、以确保功能上的视认性。也解决了在「用户通过系统辅助使用设定（Accessibility）停用 UI 透明度」的情况下所可能导致的一些 UI 界面瑕疵。但请注意务必升级至 OS 26.1，因为 OS 26.0 有一个无法躲过的缺陷：small navigation title 等工具列元素会在任何有画面背景图的页签下顽固地认为其下方的内容是亮色的，进而导致 Liquid Glass 效果强制将这些内容变为白底黑字。
- 当用户手动在界面设定下启用了真实姓名显示开关的时候，角色「Ineffa (イネファ)」的中文名现在会显示成「伊涅珐」，与该姓名的原始发音一致。这与此前的行为「Furina (フリーナ) -> 芙黎娜」「Xilonen (シロネン) -> 希洛宁」「Asta (アスタ) -> 阿丝妲」一致。

（致所有 Apple 设备的 OS 26.0 用户：请尽快升级到 OS 26.1。本应用在 OS 26.0 上有兼容性问题，但在 OS 26.1 上兼容，因为 OS 26.1 包含系统端的错误修复。位于工具栏内的分段选择器（segmented pickers）仍存在 UI 显示问题，但我们预计 Apple 会在 OS 26 的后续小版本中修复该问题。）

(敬请留意：本软件团队可能面临与开发维护相关的人事存续问题。在最坏的情况下，本软件可能会从 App Store 下架，并以另一位团队成员名义及全新的 App Bundle ID 重新上架。由于本软件支持 macOS 且使用了 Group Container，因此不符合 App Store Connect 的易主资格。这意味着，若发生重新上架的情况，新版软件将无法访问原始软件的数据。用户只能通过既有的数据备份，在新版软件中还原其信息。我们强烈建议您定期备份您的抽卡记录与本地账号数据。最终决策或将于 2026 年 1 月底前做出。此外，请注意，重新上架的软件可能因需要重新申请 ICP 备案，而暂时无法对中国大陆的 iOS 用户提供服务。)

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.6.2 的更新內容簡述：

- 新增了對《星穹鐵道》3.7 版的新角色（「昔漣」曲冽涅 (キュレネ Kyurene)）、新武器、新聖遺物套裝的支援。
- 改良了對《空月之歌》6.1 的支援：正式支援對奇偶角色（Manekin）的培養面板資料的顯示。目前所有屬性的奇偶均暫時將命途歸類至「毀滅」。然而，出於研發工作量負擔等因素的考量，披薩小助手目前不打算支援與千星奇域有關的抽卡記錄管理。
- 修復了一個錯誤：與玩家體力有關的閾值通知會錯誤地將通知推送時間當作回滿預期時間。同時，考慮到體力通知在被 iOS / macOS 正式推送給玩家之前、玩家可能已經清空體力的情況，體力通知的訊息現在會在末尾追加「該通知的簽發日期」。每次 App 重新排定玩家體力通知時，會更新這個簽發日期。
- 此前就 OS 25 (iOS 18 & macOS 15) 早期版本特有的與 Bottom Toolbar Placement 有關的 SwiftUI 故障的修補策略不再有效，原因在於 Xcode 26.0 內建 SDK 所帶來的相容性變化。於是，在這些個別有問題的 OS 25 早期子版本系統內使用本 App 時，App 在窄版畫面時的頁面切換控件改成了熒幕左上角的下拉選單，以確保功能上的可用性。
- 繼續調整整個 App 與 Liquid Glass 界面的相容性。部分界面元素移除了 Liquid Glass 效果。在 OS 26 系統下，如果在畫面底端顯示頁面切換控件的話，無論當前頁面是哪一個，被選中的頁面的名稱都會以藍色作為主題色顯示、以確保功能上的視認性。也解決了在「使用者通過系統輔助使用設定（Accessibility）停用 UI 透明度」的情況下所可能導致的一些 UI 界面瑕疵。但請注意務必升級至 OS 26.1，因為 OS 26.0 有一個無法躲過的缺陷：small navigation title 等工具列元素會在任何有畫面背景圖的頁簽下頑固地認為其下方的內容是亮色的，進而導致 Liquid Glass 效果強制將這些內容變為白底黑字。
- 當使用者手動在界面設定下啟用了真實姓名顯示開關的時候，角色「Ineffa (イネファ)」的中文名現在會顯示成「伊涅琺」，與該姓名的原始發音一致。這與此前的行為「Furina (フリーナ) -> 芙黎娜」「Xilonen (シロネン) -> 希洛寧」「Asta (アスタ) -> 阿絲妲」一致。

（致所有 Apple 裝置的 OS 26.0 使用者：請盡速升級到 OS 26.1。本應用在 OS 26.0 上有相容性問題，但在 OS 26.1 上因系統端的錯誤修正、而尚未發現有這種相容性問題。位於工具列內的分段選擇器（segmented pickers）仍有 UI 顯示瑕疵，但我們預期 Apple 會在 OS 26 的未來小版本中修正此問題。）

(敬請留意：敝軟體或面臨與開發維護有關的人事存續問題。在最壞的情況下，敝軟體可能會從 App Store 下架，並以另一位團隊成員名義及全新的 App Bundle ID 重新上架。由於敝軟體支援 macOS 且使用了 Group Container，故不符合 App Store Connect 的易主資格。這意味著，若重新上架的情形發生，新軟體將無法存取原始軟體的資料。使用者只能透過既有的資料備份，在新軟體中還原其資訊。我們強烈建議您定期備份您的抽卡紀錄與本機帳號資料。最終決策或將於 2026 年 1 月底前做出。此外，請注意，重新上架的軟體可能會因需要重新申請 ICP 備案、而暫時無法對中國大陸的 iOS 使用者提供服務。)

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.6.2:

- Added support for **Star Rail** v3.7 update, incl. its new character (キュレネ Kyurene), new weapons, and new artifact sets.
- Improved the support against **Song of the Welkin' Moon** v6.1 update: Added full support for displaying cultivation panel data for Manekin and Manekina. Currently, their all element variants are classified under the "Destruction" lifepath for now. However, due to multiple different concerns (incl. workload), The Pizza Helper as of now has no plan to support Gacha Records for Millastra Wonderland.
- Fixed an error in Notification Sputnik which abuses the notification threshold timestamp as the expected stamina full timestamp. Meanwhile, considering that stamina notifications may be sent to players after they have already depleted their stamina before the official iOS/macOS release, the stamina notification message now appends "the issuance date of the notification" at the end. Whenever the app re-schedules player stamina notifications, this issuance date will be updated.
- The previous workaround for a SwiftUI issue related to Bottom Toolbar Placement specific to early OS 25 (iOS 18 & macOS 15) subversions is no longer effective due to compatibility changes introduced by Xcode 26.0's built-in SDK. As a result, when using this app on these specific problematic early OS 25 sub-versions, the page switching control on narrow screens has been moved to a dropdown menu in the top-left corner to ensure functional usability.
- Continued adjustments to the compatibility between the entire app and the Liquid Glass interface. Some UI elements have had the Liquid Glass effect removed. On OS 26 systems, if the page switching control is displayed at the bottom of the screen, the name of the selected page will be displayed in blue as the theme color regardless of the current page, ensuring visual recognizability of the functionality. Also resolved some UI glitches that could occur when "users disable UI transparency through system accessibility settings". However, please note that you must upgrade to OS 26.1, as OS 26.0 has an unavoidable defect: toolbar elements like small navigation titles will obstinately recognize the content below them as bright colors on any tabs with a page background image, causing the Liquid Glass effect to forcibly turn these contents white text on black background.
- When users manually enable the real name display toggle in the UI settings, the Chinese name of the character "Ineffa (イネファ)" will now be displayed as "伊涅珐", consistent with the original pronunciation of the name. This is consistent with previous behavior such as "Furina (フリーナ) -> 芙黎娜", "Xilonen (シロネン) -> 希洛宁" and "Asta (アスタ) -> 阿丝妲".

 (To OS 26.0 users of all Apple devices: Upgrade to OS 26.1 ASAP. This app has compatibility issues with OS 26.0 but is compatible with OS 26.1 since the latter has system-side bug fixes. There are still UI glitches with segmented pickers situated inside the toolbar, but we can expect Apple to address the issue in future minor releases of OS 26.)

(BEWARE: This app may face challenges related to the sustainability of its development and maintenance team. In the worst-case scenario, the app might be removed from the App Store and get re-released under a different team member's name and a new App Bundle ID: This app supports macOS and uses Group Containers, making it unable to meet App Store Connect’s criteria for a developer transfer. This means that if such re-release happens, it won't be able to access data from the original app. You will only be able to use your existing data backups to restore your information in the new app. We strongly recommend that you regularly back up your gacha records and local account data. A final decision may be made by the end of January 2026. Please also note that the new app may be temporarily unavailable for iOS users in mainland China due to the need to re-apply for an ICP record.)

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.6.2 の主な更新内容：

- 『スターレイル』v3.7アップデートで追加された新キャラクター（「昔漣」キュレネ）、新武器、新聖遺物セットに対応しました。
- 『空月の歌』v6.1 への対応を改善し、マネキンおよびマネキナの育成パネルデータを正式に表示できるようになりました。現時点では全属性のマネキンを暫定的に運命「壊滅」として扱います。なお、工数などの理由により、現段階でも「星々の幻境」のガチャ記録への対応予定はありません。
- Notification Sputnik が通知の閾値タイムスタンプをスタミナ満タン予定時刻として誤用していた不具合を修正しました。また、iOS / macOS に通知が正式配信される前にプレイヤーがすでにスタミナを使い切っている可能性を考慮し、スタミナ通知メッセージの末尾に「通知の発行日」を追記するようにしました。アプリがスタミナ通知を再スケジュールするたびに、この発行日は更新されます。
- OS 25（iOS 18 / macOS 15）の初期サブバージョン固有の Bottom Toolbar Placement 関連 SwiftUI 不具合に対する従来の回避策は、Xcode 26.0 の組み込み SDK による互換性変更の影響で無効になりました。そのため、該当する OS 25 の初期サブバージョンでは、狭幅レイアウト時のページ切り替えコントロールを画面左上のドロップダウンメニューに移し、操作性を確保しています。
- アプリ全体と Liquid Glass インターフェイスの互換性調整を継続し、一部の UI 要素から Liquid Glass 効果を削除しました。OS 26 環境で画面下部にページ切り替えコントロールを表示する場合、現在のページにかかわらず選択中のページ名をテーマカラーの青で表示し、機能の視認性を確保しています。システムのアクセシビリティ設定で UI の透明度を無効化した際に生じ得た UI の不具合も解消しました。ただし、必ず OS 26.1 にアップグレードしてください。OS 26.0 には回避不可能な欠陥があります：背景画像付きタブでは small navigation title などのツールバー要素が下層を強制的に明色と判定し、Liquid Glass 効果によって白地に黒文字へと置き換えられます。
- UI 設定で実名表示トグルを有効化した際、キャラクター「Ineffa (イネファ)」の中国語名を原音に合わせて「伊涅珐」と表示するようになりました。これは「Furina (フリーナ) → 芙黎娜」「Xilonen (シロネン) → 希洛寧」「Asta (アスタ) → 阿絲妲」と同様の扱いです。

 （すべての Apple デバイス上の OS 26.0 ユーザーへ：できるだけ早く OS 26.1 にアップグレードしてください。本アプリは OS 26.0 で互換性の問題がありますが、OS 26.1 ではシステム側の不具合修正により互換性があります。ツールバー内に配置されたセグメント化ピッカー（segmented pickers）には依然として UI 表示の不具合がありますが、Apple が OS 26 の今後のマイナーリリースで対応することが期待されます。）

（ご注意：当アプリは、開発・メンテナンスチームの継続性に関連する問題に直面する可能性があります。最悪の場合、当アプリはApp Storeから削除され、別のチームメンバーの名前と新しいApp Bundle IDで再リリースされる可能性があります。当アプリは　macOS に対応済み、且つ Group Container を使用中のため、App Store Connectの開発者譲渡条件を満たしていません。これは、再リリースが行われた場合、新しいアプリが元のアプリのデータにアクセスできないことを意味します。ユーザーは、既存のデータバックアップを使用して、新しいアプリで情報を復元することしかできません。ガチャの記録とローカルアカウントデータを定期的にバックアップすることを強くお勧めします。最終決定は2026年1月末頃までに行われる予定です。また、再リリースされたアプリは、ICP登録の再申請が必要となるため、中国本土のiOSユーザーには一時的に利用できなくなる可能性があることにご注意ください。）

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.6.2:

- Добавлена поддержка обновления «Star Rail» v3.7: нового персонажа («昔漣» Кирена (Kyurene)), нового оружия и новых наборов реликвий.
- Улучшена поддержка «Песни Полой Луны» 6.1: панели развития манекенов и манекинов теперь отображаются полностью. Пока что все их стихии временно классифицируются как путь «Уничтожение». Из-за трудозатрат и других факторов поддержка гача-записей режима «Астральный предел» по-прежнему не планируется.
- Исправлена ошибка в Notification Sputnik, из-за которой временная отметка порога уведомления ошибочно использовалась как ожидаемое время полного восстановления выносливости. Кроме того, учитывая, что уведомление о выносливости может поступить после того, как игрок уже израсходовал выносливость до официальной доставки iOS / macOS, в текст уведомления теперь добавляется «дата выдачи уведомления». При каждом повторном планировании таких уведомлений эта дата обновляется.
- Прежний обходной путь SwiftUI-проблемы с Bottom Toolbar Placement в ранних подверсиях OS 25 (iOS 18 и macOS 15) перестал работать из-за изменений совместимости во встроенном SDK Xcode 26.0. Поэтому на соответствующих сборках OS 25 переключатель страниц в узких макетах перемещён в раскрывающееся меню в левом верхнем углу, чтобы сохранить работоспособность.
- Продолжаем настраивать совместимость приложения с интерфейсом Liquid Glass: для ряда элементов интерфейса эффект Liquid Glass отключён. В системах OS 26 при показе переключателя страниц в нижней части экрана название выбранной страницы теперь всегда подсвечивается тематическим синим цветом для лучшей читаемости. Также устранены визуальные артефакты, возникавшие при отключении прозрачности интерфейса в системных настройках доступности. Однако обязательно обновитесь до OS 26.1, поскольку в OS 26.0 есть неизбежный дефект: элементы панели инструментов вроде small navigation title по-прежнему считаются системой светлыми на вкладках с фоновыми изображениями, из-за чего эффект Liquid Glass принудительно делает текст белым на чёрном фоне.
- При ручном включении переключателя отображения настоящих имён в настройках интерфейса имя персонажа «Ineffa (Инеффа, イネファ)» теперь отображается в китайской локали как «伊涅珐» в соответствии с исходным произношением. Это соответствует прежним преобразованиям «Furina (フリーナ) → 芙黎娜», «Xilonen (シロネン) → 希洛寧» и «Asta (アスタ) → 阿絲妲».

(Пользователям всех Apple‑устройств с OS 26.0: обновитесь до OS 26.1 как можно скорее. Приложение испытывает проблемы совместимости с OS 26.0, но совместимо с OS 26.1 — в ней содержатся системные исправления ошибок. По‑прежнему наблюдаются артефакты в UI у сегментированных селекторов (segmented pickers), расположенных в тулбаре, но ожидается, что Apple исправит это в будущих минорных релизах OS 26.)

(ВНИМАНИЕ: Приложение может столкнуться с проблемами команды разработки. В худшем случае, оно может быть удалено из App Store и переиздано под новым именем и App Bundle ID, что сделает невозможным доступ к старым данным из-за использования Group Containers и поддержки macOS. Пользователям придётся восстанавливать данные из резервных копий. Рекомендуется регулярно создавать резервные копии. Окончательное решение может быть принято до конца января 2026 года. Переизданное приложение может быть временно недоступно в материковом Китае из-за ICP-регистрации.)

$EOF.
