// 《（统一）披萨小助手》v5.0.10 的更新内容简述：

- 本次更新对应原神 5.5 版内容更新。
- 此应用现在改用 `appearsActive` API 来处理 macOS 15 及更高版本上的应用唤醒情况。
- 修复了在除了中日英以外的语言介面下的乱破的真实姓名（乱破在星穹铁道官方日语配音包内的姓名读音为「Ranha(らんは)」而非「Rappa(らっぱ))」）。
    - 本 App 的角色真实姓名显示开关在预设情况下是关闭的，且不影响抽卡记录的资料交换。
- 修复了 EachAvatarStatView 对过长的角色名称的显示问题。（例如「丹恒・饮月」的非 CJK 本地化的名称包括空格与符号在内长达 26 个字元。）
- 优化了 EachAvatarStatView 中的属性名称在除了中日英以外的语言介面下的简称显示，此外还对 EachAvatarStatView 中的字体做了一些调整。
- 添加了由 Estartem 进行的法语本地化修正内容。
- 调整了本地帐号管理器中的每一行本地帐号的内容显示排版。

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.0.10 的更新內容簡述：

- 本次更新對應原神 5.5 版內容更新。
- 此應用現在改用 `appearsActive` API 來處理 macOS 15 及更高版本上的應用喚醒情況。
- 修復了在除了中日英以外的語言介面下的亂破的真實姓名（亂破在星穹鐵道官方日語配音包內的姓名讀音為「Ranha(らんは)」而非「Rappa(らっぱ))」）。
    - 本 App 的角色真實姓名顯示開關在預設情況下是關閉的，且不影響抽卡記錄的資料交換。
- 修復了 EachAvatarStatView 對過長的角色名稱的顯示問題。（例如「丹恆・飲月」的非 CJK 本地化的名稱包括空格與符號在內長達 26 個字元。）
- 優化了 EachAvatarStatView 中的屬性名稱在除了中日英以外的語言介面下的簡稱顯示，此外還對 EachAvatarStatView 中的字體做了一些調整。
- 添加了由 Estartem 進行的法語本地化修正內容。
- 調整了本地帳號管理器中的每一行本地帳號的內容顯示排版。

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.0.10 版が更新した内容：

- 本アップデートは原神 5.5 バージョンに対応しました。
- macOS 15以降では、アプリの起動状態を処理するために `appearsActive` APIを使用するようになりました。
- 中国語、日本語、英語以外のUI言語で「乱破」の本名が間違って表示される問題を修正しました（乱破は「らっぱ(Rappa)」ではなく「らんは(Ranha)」と読まれております）。
    - なお、キャラクターの本名の表示は既定では無効になっており、ガチャ記録のデータ交換にも影響しません。
- EachAvatarStatView で長いキャラクター名が正しく表示されない問題を修正しました（例：「丹恒・飲月」の非CJK言語での名称は空白と記号を含めて26文字に及びます）。
- 中国語、日本語、英語以外のUI言語での EachAvatarStatView における属性名の省略表示を最適化し、さらにEachAvatarStatView のフォントも調整しました。
- Estartem による フランス語のローカライズの改善内容を追加しました。
- プロファイルマネージャーにおけるプロファイル行の表示レイアウトを調整しました。


// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.0.10:

- This release corresponds to Genshin Impact 5.5 update.
- This app now uses `appearsActive` API instead to handle the app awake situations on macOS 15 and later.
- Fixed the real name of a Star-Rail character from Rappa (らっぱ) to Ranha (らんは). This real name is from her official Japanese voice dub.
    - Note: The display of character real names (Raiden Mei as Acheron, Jelena as Topaz, Kakavasha as Aventurine, etc.) are not toggled by default in this app, nor affecting the exchanged gacha record data.
- Fixed the display of overlengthened character names in EachAvatarStatView. (e.g. Dan Heng • Imbibitor Lunae, taking more than 20 chars.)
- Property names in EachAvatarStatView are now truncated nicely, plus some font adjustments in EachAvatarStatView.
- Added French localization ameliorations by Estartem.
- Tweak how profile row contents are displayed in the Profile Manager.

// RUS - - - - - - - - - - - -

// Основные изменения в The Pizza Helper v5.0.10:

- Это обновление соответствует обновлению Genshin Impact 5.5.
- Приложение теперь использует API `appearsActive` для обработки состояний пробуждения на macOS 15 и выше.
- Исправлено отображение настоящего имени персонажа "Ранха" во всех языках интерфейса, кроме китайского, японского и английского (в официальной японской озвучке Star Rail её имя произносится как "Ranha(らんは)", а не "Rappa(らっぱ)").
    - Примечание: отображение настоящих имен персонажей по умолчанию отключено и не влияет на обмен данными записей молитв.
- Исправлено отображение длинных имен персонажей в EachAvatarStatView (например, имя "Dan Heng • Imbibitor Lunae" включая пробелы и символы содержит 26 символов в не-CJK локализациях).
- Оптимизировано отображение сокращенных названий характеристик в EachAvatarStatView для всех языков интерфейса, кроме китайского, японского и английского, а также внесены некоторые корректировки шрифтов.
- Добавлены улучшения французской локализации от Estartem.
- Улучшено отображение содержимого строк профилей в менеджере локальных профилей.
