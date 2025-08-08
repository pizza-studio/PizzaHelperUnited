// 《（统一）披萨小助手》v5.5.5 的更新内容简述：

(敬请留意：本软件团队可能面临与开发维护相关的人事存续问题。在最坏的情况下，本软件可能会从 App Store 下架，并以另一位团队成员名义及全新的 App Bundle ID 重新上架。由于本软件支持 macOS 且使用了 Group Container，因此不符合 App Store Connect 的易主资格。这意味着，若发生重新上架的情况，新版软件将无法访问原始软件的数据。用户只能通过既有的数据备份，在新版软件中还原其信息。我们强烈建议您定期备份您的抽卡记录与本地账号数据。最终决策将于 2025 年 11 月底前做出。此外，请注意，重新上架的软件可能因需要重新申请 ICP 备案，而暂时无法对中国大陆的 iOS 用户提供服务。)

- 抽卡记录管理器（GRM）：正式宣布对 UIGF v4.1 资料交换标准的支持。
- GRM：现对常驻命中率（SHR）的显示做出改良，新增自动可信度检测功能，对样本量不足显示警告文本，并对高于51%的SHR设置中等置信度上限，以降低法律风险。
- GRM：对纵向陈列的棒状图表的宽度的荧幕自适应行为做了防抖处理，借此改善了 UI 渲染效能。
- GRM：缩短了横向陈列的棒状图表的条目间隔，使排版更紧凑。
- GRM：将「限定五星平均抽数」改称为「非常驻五星平均抽数」。之前的称谓可能会在特定的情况下让部分用户感到困惑。
- GRM：抽卡人数据主画面做了一些 UI 排版风格调整，使其占用的纵向荧幕空间更少。
- GRM：引入了新的术语：「抽卡人（ガチャ主, Gacha Puller）」。这可以在部分语言介面下防止与本软件的其他模组的同名术语彼此混淆。
- GRM：现在会在发现当前设备的 GachaMetaDB 资料库过期时先尝试使用 App 同捆的资料。仅当两者均过期时，才会尝试线上更新。另对与 GachaMetaDB 过期有关的错误讯息内容做了一些调整。
- 将 App 语言切换器向下开放至 OS 21 (iOS 14 / macOS 11)，且允许用户取消对 App 语言的切换操作。
- 补上了 OOBE 画面针对某些语种的缺失的本地化翻译。
- 调整了个人战报画面的挑战类型选单的位置与样式，以应对今后新增的更多的挑战类型数量。
- 修改了最终用户授权合约，新增了与「用户展示的基于外部伪造数据有关的统计结果」有关的免责事项。
- 修复了玩家体力计时器在部分场合下的排版对齐故障。
- 出于对软件发行包体积的节省的需求，本软件同捆的原神名片素材的尺寸降低至 210x100。玩家体力计时器与桌面小工具的背景如果被设定成原神名片的话，则相关的图像素材会优先从 Enka Networks 线上载入，以保证图片的清晰显示效果。
- 利用 GitHub Copilot (Claude Sonnet 4 & GPT4o) 对日语本地化介面的语文做了一些与阅读舒适度有关的调整。
- 将部分可复用的原始码的释出方式改为 MIT License，包括 EnkaKit 展柜查询模组以及配套的圣遗物评分模组。

$EOF.

// CHT - - - - - - - - - - - -

// 《（統一）披薩小助手》v5.5.5 的更新內容簡述：

(敬請留意：敝軟體或面臨與開發維護有關的人事存續問題。在最壞的情況下，敝軟體可能會從 App Store 下架，並以另一位團隊成員名義及全新的 App Bundle ID 重新上架。由於敝軟體支援 macOS 且使用了 Group Container，故不符合 App Store Connect 的易主資格。這意味著，若重新上架的情形發生，新軟體將無法存取原始軟體的資料。使用者只能透過既有的資料備份，在新軟體中還原其資訊。我們強烈建議您定期備份您的抽卡紀錄與本機帳號資料。最終決策將於 2025 年 11 月底前做出。此外，請注意，重新上架的軟體可能會因需要重新申請 ICP 備案、而暫時無法對中國大陸的 iOS 使用者提供服務。)

- 抽卡記錄管理器（GRM）：正式宣佈對 UIGF v4.1 資料交換標準的支援。
- GRM：現對常駐命中率（SHR）的顯示做出改良，新增自動可信度檢測功能，對樣本量不足顯示警告文本，並對高於51%的SHR設置中等置信度上限，以降低法律風險。
- GRM：對縱向陳列的棒狀圖表的寬度的熒幕自適應行為做了防抖處理，藉此改善了 UI 渲染效能。
- GRM：縮短了橫向陳列的棒狀圖表的條目間隔，使排版更緊湊。
- GRM：將「限定五星平均抽數」改稱為「非常駐五星平均抽數」。之前的稱謂可能會在特定的情況下讓部分使用者感到困惑。
- GRM：抽卡人資料主畫面做了一些 UI 排版風格調整，使其佔用的縱向熒幕空間更少。
- GRM：引入了新的術語：「抽卡人（ガチャ主, Gacha Puller）」。這可以在部分語言介面下防止與敝軟體的其他模組的同名術語彼此混淆。
- GRM：現在會在發現當前設備的 GachaMetaDB 資料庫過期時先嚐試使用 App 同捆的資料。僅當兩者均過期時，才會嘗試線上更新。另對與 GachaMetaDB 過期有關的錯誤訊息內容做了一些調整。
- 將 App 語言切換器向下開放至 OS 21 (iOS 14 / macOS 11)，且允許使用者取消對 App 語言的切換操作。
- 補上了 OOBE 畫面針對某些語種的缺失的本地化翻譯。
- 調整了個人戰報畫面的挑戰類型選單的位置與樣式，以應對今後新增的更多的挑戰類型數量。
- 修改了最終使用者授權合約，新增了與「使用者展示的基於外部偽造數據有關的統計結果」有關的免責事項。
- 修復了玩家體力計時器在部分場合下的排版對齊故障。
- 出於對軟件發行包體積的節省的需求，敝軟體同捆的原神名片素材的尺寸降低至 210x100。玩家體力計時器與桌面小工具的背景如果被設定成原神名片的話，則相關的圖像素材會優先從 Enka Networks 線上載入，以保證圖片的清晰顯示效果。
- 利用 GitHub Copilot (Claude Sonnet 4 & GPT4o) 對日語本地化介面的語文做了一些與閱讀舒適度有關的調整。
- 將部分可複用的原始碼的釋出方式改為 MIT License，包括 EnkaKit 展櫃查詢模組以及配套的聖遺物評分模組。

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Pizza Helper v5.5.5:

(BEWARE: This app may face challenges related to the sustainability of its development and maintenance team. In the worst-case scenario, the app might be removed from the App Store and get re-released under a different team member's name and a new App Bundle ID: This app supports macOS and uses Group Containers, making it unable to meet App Store Connect’s criteria for a developer transfer. This means that if such re-release happens, it won't be able to access data from the original app. You will only be able to use your existing data backups to restore your information in the new app. We strongly recommend that you regularly back up your gacha records and local account data. A final decision will be made by the end of November 2025. Please also note that the new app may be temporarily unavailable for iOS users in mainland China due to the need to re-apply for an ICP record.)

- Gacha Record Manager (GRM): Formally announcing the support of UIGF v4.1 standard for data exchange.
- GRM: Its Standard Hit Rate (SHR) display is now equipped with automatic reliability detection, warning text for insufficient sample sizes, and a Medium confidence ceiling for SHR above 51% to mitigate legal risks.
- GRM: Implemented debounce handling for the screen-adaptive behavior of the width of vertically arranged bar charts. This improves UI rendering performance.
- GRM: Reduced the spacing between entries in horizontally arranged bar charts, making the layout more compact.
- GRM: Changed the term `Avrg. Pulls (limited 5-star)` to `Avrg. Pulls (Non-Std. 5-star)`. The previous term could confuse certain users in some cases.
- GRM: Made some UI layout adjustments to the main Gacha Puller view to reduce its vertical screen space usage.
- GRM: Introduced a new term "Gacha Puller (ガチャ主)." This prevents confusion with similarly named terms in other modules of the software under certain language interfaces.
- GRM: It now attempts to use bundled GachaMetaDB data first if the current device's GachaMetaDB cache is outdated. Online updates are only attempted if both are outdated. Also adjusted error message content related to GachaMetaDB expiration.
- Backported the app language switcher to OS 21 (iOS 14 / macOS 11), plus allowing users to cancel their app language switching action.
- Added missing translations (of secondary languages) for the OOBE view.
- Tweaked the layout and design of the challenge type picker in the Battle Report view. This is a preparation for new challenge types in the future.
- Amended the EULA to add disclaimer contents regarding user-displayed statistic results made by external forged data.
- Fixed a layout alignment issue in the Stamina Timer that occurs in some cases.
- Due to urgent needs to reduce the app bundle file size, all bundled Genshin namecard assets have had their dimensions reduced to 210x100. If the background image of the Stamina Timer or any desktop widget is set to use a Genshin namecard, online assets (hosted by Enka Networks) will be prioritized over the bundled low-resolution fallback assets.
- Used GitHub Copilot (Claude Sonnet 4 & GPT-4o) to make language adjustments to the Japanese localized interface for improved reading comfort.
- Changed the release method of some reusable source code to MIT License, including EnkaKit (Query Module & Artifact Rating Module).

$EOF.

// JPN - - - - - - - - - - - -

// 「ピザ助手（無印）」v5.5.5 の主な更新内容：

（ご注意：当アプリは、開発・メンテナンスチームの継続性に関連する問題に直面する可能性があります。最悪の場合、当アプリはApp Storeから削除され、別のチームメンバーの名前と新しいApp Bundle IDで再リリースされる可能性があります。当アプリは　macOS に対応済み、且つ Group Container を使用中のため、App Store Connectの開発者譲渡条件を満たしていません。これは、再リリースが行われた場合、新しいアプリが元のアプリのデータにアクセスできないことを意味します。ユーザーは、既存のデータバックアップを使用して、新しいアプリで情報を復元することしかできません。ガチャの記録とローカルアカウントデータを定期的にバックアップすることを強くお勧めします。最終決定は2025年11月末までに行われる予定です。また、再リリースされたアプリは、ICP登録の再申請が必要となるため、中国本土のiOSユーザーには一時的に利用できなくなる可能性があることにご注意ください。）

- ガチャ記録マネージャー（GRM）：UIGF v4.1 データ交換標準のサポートを正式発表。
- GRM：標準命中率（SHR）の表示を改良し、自動信頼性検出機能を追加。サンプル数が不足している場合の警告テキスト表示、51%を超えるSHRに対する中程度の信頼度上限設定により、法的リスクを軽減。
- GRM：縦向きに配置された棒グラフの幅に対するスクリーン適応動作にデバウンス処理を実装。UIレンダリング性能が向上。
- GRM：横向きに配置された棒グラフのエントリー間隔を縮小し、レイアウトをよりコンパクトに。
- GRM：「限定星5平均回数」を「非常駐星5平均回数」に変更。以前の用語は特定の場合に一部のユーザーを混乱させる可能性がありました。
- GRM：ガチャ主のメインデータ画面でUIレイアウトを調整し、縦方向の画面使用量を削減。
- GRM：新しい用語「ガチャ主（Gacha Puller）」を導入。特定の言語インターフェースにおいて、ソフトウェアの他のモジュールの類似用語との混乱を防止。
- GRM：現在のデバイスのGachaMetaDBキャッシュが古い場合、まずバンドルされたGachaMetaDBデータの使用を試行。両方が古い場合のみオンライン更新を試行。また、GachaMetaDB期限切れに関連するエラーメッセージの内容を調整。
- アプリ言語切り替え機能をOS 21（iOS 14 / macOS 11）まで下位対応し、ユーザーがアプリ言語の切り替え操作をキャンセルできるように。
- OOBE画面の一部言語における欠落していたローカライゼーション翻訳を追加。
- バトルレポート画面のチャレンジタイプピッカーのレイアウトとデザインを調整。今後の新しいチャレンジタイプに向けた準備。
- EULAを修正し、外部で偽造されたデータによるユーザー表示の統計結果に関する免責事項を追加。
- スタミナタイマーで一部のケースで発生していたレイアウト配置の問題を修正。
- アプリバンドルのファイルサイズ削減の緊急需要により、すべてのバンドルされた原神名刺アセットの寸法を210x100に縮小。スタミナタイマーやデスクトップウィジェットの背景画像に原神名刺が設定されている場合、バンドルされた低解像度フォールバックアセットよりも優先してオンラインアセット（Enka Networksがホスト）を使用。
- GitHub Copilot（Claude Sonnet 4およびGPT-4o）を使用して日本語ローカライズインターフェースの読みやすさ向上のための言語調整を実施。
- 一部の再利用可能なソースコードのリリース方法をMITライセンスに変更（EnkaKit（クエリモジュールおよび聖遺物評価モジュール）を含む）。

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Пицца Помощник» v5.5.5:

(ВНИМАНИЕ: Это приложение может столкнуться с проблемами, связанными с устойчивостью команды разработки и поддержки. В худшем случае приложение может быть удалено из App Store и переиздано под именем другого участника команды и с новым App Bundle ID. Это приложение поддерживает macOS и использует Group Containers, что делает его неспособным соответствовать критериям App Store Connect для передачи разработчика. Это означает, что если произойдет такое переиздание, оно не сможет получить доступ к данным из оригинального приложения. Вы сможете использовать только существующие резервные копии данных для восстановления информации в новом приложении. Мы настоятельно рекомендуем регулярно создавать резервные копии ваших записей гача и данных локальных аккаунтов. Окончательное решение будет принято до конца ноября 2025 года. Также обратите внимание, что новое приложение может быть временно недоступно для пользователей iOS в материковом Китае из-за необходимости повторной подачи заявки на регистрацию ICP.)

- Менеджер записей Gacha (GRM): Официально объявляем о поддержке стандарта обмена данными UIGF v4.1.
- GRM: Отображение стандартного уровня попаданий (SHR) теперь оснащено автоматическим определением надёжности, предупреждающим текстом для недостаточных размеров выборки и средним потолком доверия для SHR выше 51% для снижения правовых рисков.
- GRM: Реализована обработка устранения дребезга для адаптивного поведения ширины вертикально расположенных столбчатых диаграмм к экрану. Это улучшает производительность рендеринга UI.
- GRM: Уменьшено расстояние между записями в горизонтально расположенных столбчатых диаграммах, делая макет более компактным.
- GRM: Изменён термин «Средн. попыток (лимитированная 5-звёздочная)» на «Средн. попыток (не-стандартная 5-звёздочная)». Предыдущий термин мог запутать некоторых пользователей в определённых случаях.
- GRM: Внесены некоторые корректировки в макет UI основного представления владельца гача для уменьшения использования вертикального пространства экрана.
- GRM: Введён новый термин «владелец гача (ガチャ主)». Это предотвращает путаницу с аналогично названными терминами в других модулях программного обеспечения в определённых языковых интерфейсах.
- GRM: Теперь сначала пытается использовать встроенные данные GachaMetaDB, если кэш GachaMetaDB текущего устройства устарел. Онлайн-обновления пытаются выполнить только если оба устарели. Также скорректировано содержимое сообщений об ошибках, связанных с истечением срока действия GachaMetaDB.
- Портирован переключатель языка приложения на OS 21 (iOS 14 / macOS 11), плюс разрешено пользователям отменять действие переключения языка приложения.
- Добавлены отсутствующие переводы (вторичных языков) для представления OOBE.
- Скорректированы макет и дизайн селектора типа вызова в представлении боевого отчёта. Это подготовка к новым типам вызовов в будущем.
- Изменён EULA для добавления содержимого отказа от ответственности относительно статистических результатов, отображаемых пользователем на основе внешних поддельных данных.
- Исправлена проблема с выравниванием макета в таймере выносливости. Это происходит в некоторых случаях.
- Из-за срочных потребностей в уменьшении размера файла пакета приложения все встроенные ресурсы именных карточек Genshin имеют уменьшенные размеры до 210x100. Если фоновое изображение таймера выносливости или любого настольного виджета установлено с использованием именной карточки Genshin, онлайн-ресурсы (размещённые Enka Networks) будут использоваться до использования встроенных низкого разрешения резервных ресурсов.
- Использован GitHub Copilot (Claude Sonnet 4 и GPT-4o) для внесения языковых корректировок в японский локализованный интерфейс для улучшения комфорта чтения.
- Изменён метод выпуска некоторого многоразового исходного кода на лицензию MIT, включая EnkaKit (модуль запросов и модуль оценки артефактов).

$EOF.
