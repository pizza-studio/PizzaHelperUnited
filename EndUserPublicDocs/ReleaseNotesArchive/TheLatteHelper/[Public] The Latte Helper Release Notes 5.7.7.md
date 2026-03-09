// 《拿铁小助手》v5.7.7 的更新内容简述：

- 调整了软件「关于」画面内所随附的一些文件资料的内容。这些内容也会反映在 OOBE 画面。
- 从嵌入式小工具与 Watch 主应用移除了星穹铁道的探索派遣内容。
- 修复了官方游戏活动资讯模块故障：文章内链接现在会在点击之后使用 Safari 单独打开。若您的 IP 位于中国大陆，可能部分链接（如 YouTube）无法访问。请手动查看米哈游在米游社或 Bilibili 等官方渠道的简体中文资讯。
- 与米游社账号用户无关的一项重要更新：从这一版开始，HoYoLAB 账号可以使用 Sign-in-with-Apple 的功能来登入。
  - - [原理] 这个实作方法就是对 WKWebView 的某些与 WKUIDelegate 协定有关的遵守过程做了正确的配置处理，且这些变更不会接触到 Apple ID 账密资讯，甚至在这个过程中都不需要在新的配置选项里面提到 `apple.com` 域名。然而，副厂软件在没有 Cognosphere 官方的特别许可与技术协作的情况下，无法对这种功能实装 FIDO Passkey 免密登入的特性。于是，您在使用该功能登入 Apple ID 时只能通过密码来登入。如果您有资讯安全疑虑的话，请启用 Apple 推荐的 Apple ID 账号安全设定（包括但不限于双因认证）。
  - - [注意] 在使用 Apple ID 登录 HoYoLAB 账号之前，请务必先将您现有的 HoYoLAB 账号与 Apple ID 完成绑定。该绑定操作可以在 iOS 全球版本的《原神》《星穹铁道》《绝区零》游戏内完成。如果在未完成绑定的情况下直接使用 Apple ID 登录的话，HoYoVerse 的系统会自动创建一个全新的空白 HoYoLAB 账号，并将您的 Apple ID 强制绑定至该新账号。在这种情况下，您可能需要等待约 30 天的账号注销冷静期，才能成功注销该新账号并重新完成绑定。
  - - [意图] 此次功能更新旨在从技术层面实现 HoYoLAB 账号登录时无需输入其账密资讯的需求。
  - - 另：本软件在技术上无法支持通过 Google & Facebook & Twitter (X) 等社群网站登入 HoYoLAB 账号的特性。

(现阶段暂停提供 macCatalyst 版本，以减轻 App Store 审委会的审核工作量。这导致该 App 目前无法支持 Intel Mac 机种，因为只有 Apple Silicon Mac 可以直接运行 iPad 应用。上文中讨论到的与 macOS 有关的内容更新均指该 App 的 iPadOS 版本在 macOS 系统下的行为。)

$EOF.

// CHT - - - - - - - - - - - -

// 《拿鐵小助手》v5.7.7 的更新內容簡述：

- 調整了軟體「關於」畫面內所隨附的一些文件資料的內容。這些內容也會反映在 OOBE 畫面。
- 從嵌入式小工具與 Watch 主應用移除了星穹鐵道的探索派遣內容。
- 修復了官方遊戲活動資訊模組故障：文章內鏈接現在會在點按之後使用 Safari 單獨開啟。若您的 IP 位於中國大陸，可能部分鏈接（如 YouTube）無法訪問。請手動查看米哈遊在米遊社或 Bilibili 等官方渠道的簡體中文資訊。
- 與米遊社帳號使用者無關的一項重要更新：從這一版開始，HoYoLAB 帳號可以使用 Sign-in-with-Apple 的功能來登入。
  - - [原理] 這個實作方法就是對 WKWebView 的某些與 WKUIDelegate 協定有關的遵守過程做了正確的配置處理，且這些變更不會接觸到 Apple ID 帳密資訊，甚至在這個過程中都不需要在新的配置選項裡面提到 `apple.com` 域名。然而，副廠軟體在沒有 Cognosphere 官方的特別許可與技術協作的情況下，無法對這種功能實裝 FIDO Passkey 免密登入的特性。於是，您在使用該功能登入 Apple ID 時只能通過密碼來登入。如果您有資訊安全疑慮的話，請啟用 Apple 推薦的 Apple ID 帳號安全設定（包括但不限於雙因認證）。
  - - [注意] 在使用 Apple ID 登入 HoYoLAB 帳號之前，請務必先將您現有的 HoYoLAB 帳號與 Apple ID 完成綁定。該綁定操作可以在 iOS 全球版本的《原神》《星穹鐵道》《絕區零》遊戲內完成。如果在未完成綁定的情況下直接使用 Apple ID 登入的話，HoYoVerse 的系統會自動創建一個全新的空白 HoYoLAB 帳號，並將您的 Apple ID 強制綁定至該新帳號。在這種情況下，您可能需要等待約 30 天的帳號註銷冷靜期，才能成功註銷該新帳號並重新完成綁定。
  - - [意圖] 此次功能更新旨在從技術層面實現 HoYoLAB 帳號登入時無需輸入其帳密資訊的需求。
  - - 另：敝軟體在技術上無法支援通過 Google & Facebook & Twitter (X) 等社群網站登入 HoYoLAB 帳號的特性。

(現階段暫停提供 macCatalyst 版本，以減輕 App Store 審委會的審核工作量。這導致該 App 目前無法支援 Intel Mac 機種，因為只有 Apple Silicon Mac 可以直接運行 iPad 應用。上文中討論到的與 macOS 有關的內容更新均指该 App 的 iPadOS 版本在 macOS 系統下的行為。)

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Latte Helper v5.7.7:

- Adjusted the contents of the documents accessible from the "About" view of this app. These changes will also be reflected in the OOBE view.
- Trimmed expedition task contents from embedded widgets and the Apple Watch app.
- Fixed malfunction in official game events module: Links within articles now open separately in Safari upon clicking. If your IP is located in mainland China, some links (e.g., YouTube) may be inaccessible. Please manually check Mihoyo's official Simplified Chinese updates on platforms like Miyoushe or Bilibili.
- An important feature update which is irrelevant to Miyoushe users: Starting with this app version, HoYoLAB accounts can use Sign-in-with-Apple for login.
  - - [METHOD] This implementation simply involves correctly configuring certain conformation processes in WKWebView that are related to the WKUIDelegate protocol without touching Apple ID login credentials. Moreover, the code changes of this implementation doesn't mention the `apple.com` domain, in the WKWebView configuration options. However, third-party software cannot implement FIDO Passkey password-free login functionality without special permission and technical collaboration from Cognosphere. Therefore, when using this feature to log in with your Apple ID, you must log in using your password. If you have security concerns, please enable Apple's recommended Apple ID security settings (including but not limited to two-factor authentication).
  - - [ATTENTION] Before signing in to your HoYoLAB account with your Apple ID, you must first link your existing HoYoLAB account to your Apple ID. This linkage can be completed within the iOS global versions of Genshin Impact, Star Rail, or Zenless Zone Zero. If you attempt to sign in with your Apple ID before completing the linkage, the HoYoVerse system will automatically create a new blank HoYoLAB account and bind your Apple ID to that account. In such cases, you may need to wait approximately 30 days (the account deletion cool-down period) before you can delete the newly created account and rebind your Apple ID to your original HoYoLAB account.
  - - [INTENTION] This feature update is intended to technically achieve a feature request: signing in to a HoYoLAB account without the need of entering its login / password.
  - - Note: This software technically cannot support logging into HoYoLAB accounts via social media accounts like Google, Facebook, and Twitter (X).

(We stopped supplying the macCatalyst build at App Store to reduce the App Review workload. As a result, the app is currently unavailable on Intel-based Macs. Only Apple Silicon Macs are capable of running the iPad app. All macOS-related mentions above refer to the behavior of the iPadOS version running on macOS.)

$EOF.

// JPN - - - - - - - - - - - -

// 「ラテ助手」v5.7.7 の主な更新内容：

- 当アプリの「情報」ビューから利用可能なドキュメントの内容を調整しました。これらの変更は OOBE 画面にも反映されます。
- 埋め込みウィジェットと Apple Watch メインアプリからスターレイルの依頼派遣コンテンツを削除しました。
- 公式ゲームイベント モジュールの不具合を修正しました：記事内のリンクはクリック後に Safari で個別に開くようになりました。ご利用の IP が中国本土に位置している場合、一部のリンク（例：YouTube）にアクセスできない可能性があります。Miyoushe または Bilibili などのプラットフォームで Mihoyo の公式簡体字中国語アップデートを手動で確認してください。
- Miyoushe ユーザーに関連しない重要な機能アップデート：当アプリバージョンから、HoYoLAB アカウントは Sign-in-with-Apple を使用してログインできます。
  - - [方法] この実装は、WKWebView での WKUIDelegate プロトコルに関連する特定の構成プロセスを正しく構成することのみで、Apple ID のログイン認証情報に触れることなく実現されます。さらに、この実装のコード変更は WKWebView 構成オプションで `apple.com` ドメインを言及する必要はありません。ただし、サードパーティ ソフトウェアは Cognosphere の公式な許可と技術協力なしに FIDO Passkey パスワードレス ログイン機能を実装することはできません。したがって、この機能を使用して Apple ID でログインする場合は、パスワードを使用してログインする必要があります。セキュリティに関する懸念がある場合は、Apple が推奨する Apple ID セキュリティ設定を有効にしてください（二要素認証を含むがこれに限定されません）。
  - - [注意] HoYoLAB アカウントに Apple ID でサインインする前に、既存の HoYoLAB アカウントを Apple ID とリンクする必要があります。このリンクは、『原神』、『スターレイル』、または『ゼンレスゾーンゼロ』の iOS グローバル版内で完了できます。リンク完了前に Apple ID でサインインしようとすると、HoYoVerse システムは自動的に新しいブランク HoYoLAB アカウントを作成し、Apple ID をそのアカウントにバインドします。この場合、新しく作成されたアカウントを削除して、Apple ID を元の HoYoLAB アカウントに再度バインドするには、約 30 日間（アカウント削除のクールダウン期間）待つ必要があります。
  - - [意図] HoYoLAB アカウントへのログイン時にログイン認証情報を入力する必要を外すことを技術的に実現すること。
  - - 注：当アプリは技術的に Google & Facebook & Twitter (X) などのSNS アカウント経由の HoYoLAB  ログインをサポートできません。

（App Review の作業負荷を軽減するため、macCatalyst 版の提供を一時停止しています。そのため現時点では Intel 製 Mac ではご利用できませんので、ご了承くださいませ。Apple Silicon 機種では iPad アプリを使うのは可能です。上記の macOS に関する全ての説明は、macOS 上で実行されている当アプリの iPadOS 版の動作に関連しています。）

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Латте помощник» v5.7.7:

- Отрегулировано содержимое документов, доступных из представления «О приложении» этого приложения. Эти изменения также будут отражены в представлении OOBE.
- Удалено содержимое задач экспедиции из встроенных виджетов и основного приложения Apple Watch.
- Исправлена неисправность модуля официальных игровых событий: ссылки в статьях теперь открываются отдельно в Safari при нажатии. Если ваш IP находится на территории материкового Китая, некоторые ссылки (например, YouTube) могут быть недоступны. Пожалуйста, вручную проверьте официальные обновления Mihoyo на упрощенном китайском языке на платформах, таких как Miyoushe или Bilibili.
- Важное обновление функций, не имеющее отношения к пользователям Miyoushe: начиная с этой версии приложения, учетные записи HoYoLAB могут использовать Sign-in-with-Apple для входа.
  - - [МЕТОД] Эта реализация просто включает правильную настройку определенных процессов соответствия в WKWebView, которые связаны с протоколом WKUIDelegate, без обращения к учетным данным входа Apple ID. Более того, изменения кода этой реализации не упоминают домен `apple.com` в параметрах конфигурации WKWebView. Однако стороннее программное обеспечение не может реализовать функцию входа без пароля FIDO Passkey без специального разрешения и технического сотрудничества от Cognosphere. Поэтому при использовании этой функции для входа с помощью Apple ID необходимо входить с помощью пароля. Если у вас есть проблемы с безопасностью, включите рекомендуемые Apple параметры безопасности Apple ID (включая двухфакторную аутентификацию).
  - - [ВНИМАНИЕ] Перед входом в учетную запись HoYoLAB с использованием Apple ID необходимо сначала связать существующую учетную запись HoYoLAB с Apple ID. Эту связь можно завершить в глобальной версии iOS для Genshin Impact, Star Rail или Zenless Zone Zero. Если вы попытаетесь войти с Apple ID до завершения связи, система HoYoVerse автоматически создаст новую пустую учетную запись HoYoLAB и привяжет ваш Apple ID к этой учетной записи. В таких случаях вам может потребоваться подождать примерно 30 дней (период охлаждения удаления учетной записи) прежде чем вы сможете удалить вновь созданную учетную запись и повторно привязать Apple ID к исходной учетной записи HoYoLAB.
  - - [ЦЕЛЬ] Это обновление функций предназначено технически реализовать запрос на функцию: вход в учетную запись HoYoLAB без необходимости ввода учетных данных учетной записи.
  - - Примечание: Это программное обеспечение технически не может поддерживать вход в учетные записи HoYoLAB через учетные записи социальных сетей, такие как Google, Facebook и Twitter (X).

(Временно приостановлен выпуск версии macCatalyst, чтобы снизить нагрузку на команду App Review. Поэтому приложение сейчас недоступно на компьютерах Mac с процессорами Intel. Apple Silicon Mac могут запускать приложение iPad напрямую. Все упоминания macOS выше относятся к поведению версии для iPad этого приложения, работающей на macOS.)

$EOF.
