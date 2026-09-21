// 《拿铁小助手》v5.9.4 的更新内容简述：

- 新增对《原神》v7.1 的新角色与新武器装备的支持。新角色（及其命途）：薇斯纳（毁灭）、沃雅妮莎（同谐）。
- 调整了部分原神角色在本应用内的命途定位：奇偶（Manekin／Manekina，所有属性）「毁灭」→「欢愉」。
- 补上了《星穹铁道》v4.5 的纪行肖像。
- 重构了针对 iOS 26 与 macOS 26 系统的底部浮动页签列的触控与动画行为，并修正了若干版面计算故障。
  - [追记] 过去一年间，屡有使用者提议改用 SwiftUI 的 TabView 来实作分页列（以期在较新系统上取得原生的液态玻璃页签效果）。需要说明的是：在 macOS 14 / 15 的部分系统版本上，与 TabView 有关的 SwiftUI API 存在会影响本 App 运作的行为差异；这些差异存在于已发行的旧系统版本上，不会随系统更新而改变，本 App 端也无法修补。另一方面，本 App 必须在 iPhone 与 Mac（在 macOS 上运行的 iPadOS 版）之间共用同一套界面架构，因此无法只为 iPhone 一侧的需求而牺牲 macOS 下的使用体验。此外，本 App 仍有相当比例的使用者因为经济能力等原因、仍在使用内存容量为 6GB 或以下的装置，将最低系统需求自 iOS 17 / macOS 14 提高到 iOS 26 / macOS 26 并不现实。因此，敝专案今后不再受理任何以 TabView 重写分页列的代码贡献，此类 Pull Request 将直接关闭。感谢各位的关心与理解。
- 将 iOS 26+ 与 macOS 26+ 系统下界面的卷动边缘效果由「硬边」调整为「柔边」。
- 新增对折叠装置（iPhone Duo）转轴状态的支援，改良了折叠装置展开时的侧边栏显示判定。
- 修复了米游社 QRCode 登入流程中「已扫描，请检查」按钮的故障：该按钮原先会中断正在进行的登入轮询，导致部分本可成功的登入失败、且会废掉与该 QR 码有关的自动轮询更新。

注意：用户拿尚未发行过正式版的年度大版本更新的测试版系统来运行的情形不受敝团队所支持。Apple 研发者会员授权合约限制我们在对 App Store 张贴的版本更新日志当中提及与这类操作系统有关的情形细节（特别是与系统 API 有关的年度行为变化）。我们只能说这种情形可能会导致任何形式的资料丢失与软件可用性问题。

开发者在此恳请各位参与了 iOS / macOS Beta 测试计划的祖宗们注意不要滥用自己的测试资格。「遇到 beta 版系统才会触发的软件故障」并不能成为你们在 App Store 滥用评论评分功能的理由，哪怕你可能会为此专门切换到你那尚未安装 beta 系统的设备来评论。请你们多动动脑子：如果你们遇到的「beta 版系统才会触发的软件可用性故障」真的是问题的话，那还会过审吗？

(本软件不再在 App Store 提供 macCatalyst 版本。这可以减轻 App Store 审委会的审核工作量。这也导致该 App 无法继续支持 Intel Mac 机种，因为只有 Apple Silicon Mac 可以直接运行 iPad 应用。上文中讨论到的与 macOS 有关的内容更新均指该 App 的 iPadOS 版本在 macOS 系统下的行为。本软件以 SwiftUI 技术制作，而 SwiftUI 在 Apple Silicon 电脑上往往能得到更良好的效能体验。)

$EOF.

// CHT - - - - - - - - - - - -

// 《拿鐵小助手》v5.9.4 的更新內容簡述：

- 新增對《原神》v7.1 的新角色與新武器裝備的支援。新角色（及其命途）：薇斯納（毀滅）、沃雅妮莎（同諧）。
- 調整了部分原神角色在敝應用內的命途定位：奇偶（Manekin／Manekina，所有屬性）「毀滅」→「歡愉」。
- 補上了《星穹鐵道》v4.5 的紀行肖像。
- 重構了針對 iOS 26 與 macOS 26 系統的底部浮動分頁列的觸控與動畫行為，並修正了若干版面計算故障。
  - [追記] 過去一年間，屢有使用者提議改用 SwiftUI 的 TabView 來實作分頁列（以期在較新系統上取得原生的液態玻璃分頁效果）。需要說明的是：在 macOS 14 / 15 的部分系統版本上，與 TabView 有關的 SwiftUI API 存在會影響本 App 運作的行為差異；這些差異存在於已發行的舊系統版本上，不會隨系統更新而改變，本 App 端也無法修補。另一方面，本 App 必須在 iPhone 與 Mac（在 macOS 上運行的 iPadOS 版）之間共用同一套介面架構，因此無法只為 iPhone 一側的需求而犧牲 macOS 下的使用體驗。此外，本 App 仍有相當比例的使用者因為經濟能力等原因、仍在使用記憶體容量為 6GB 或以下的裝置，將最低系統需求自 iOS 17 / macOS 14 提高到 iOS 26 / macOS 26 並不現實。因此，敝專案今後不再受理任何以 TabView 重寫分頁列的程式碼貢獻，此類 Pull Request 將直接關閉。感謝各位的關心與諒解。
- 將 iOS 26+ 與 macOS 26+ 系統下介面的捲動邊緣效果由「硬邊」調整為「柔邊」。
- 新增對摺疊裝置（iPhone Duo）轉軸狀態的支援，改良了摺疊裝置展開時的側邊欄顯示判定。
- 修復了米遊社 QRCode 登入流程中「已掃描，請檢查」按鈕的故障：該按鈕原先會中斷正在進行的登入輪詢，導致部分本可成功的登入失敗、且會廢掉與該 QR 碼有關的自動輪詢更新。

注意：使用者拿尚未發行過正式版的年度大版本更新的測試版系統來運行的情形不受敝團隊所支援。Apple 研發者會員授權合約限制我們在對 App Store 張貼的版本更新日誌當中提及與這類操作系統有關的情形細節（特別是與系統 API 有關的年度行為變化）。我們只能說這種情形可能會導致任何形式的資料丟失與軟體可用性問題。

(敝軟體不再在 App Store 提供 macCatalyst 版本，以減輕 App Store 審委會的審核工作量。這也導致該 App 無法繼續支援 Intel Mac 機種，因為只有 Apple Silicon Mac 可以直接運行 iPad 應用。上文中討論到的與 macOS 有關的內容更新均指该 App 的 iPadOS 版本在 macOS 系統下的行為。敝軟體以 SwiftUI 技術製作，而 SwiftUI 在 Apple Silicon 電腦上往往能得到更良好的效能體驗。)

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Latte Helper v5.9.4:

- Added support for new characters and new weapons introduced in Genshin Impact v7.1. New characters (and their life-paths) are: Vesna (Destruction) and Vodyanitsa (Harmony).
- Some Genshin Impact character lifepath designations in this app have been adjusted: Manekin/Manekina (all elements) "Destruction" → "Elation."
- Added Star Rail v4.5 Battle Pass avatars.
- Refactored the touch and animation behavior of the floating bottom tab bar for iOS 26 and macOS 26 systems, and fixed several layout-calculation issues.
  - [Addendum] Over the past year, users have repeatedly proposed rewriting the tab bar with SwiftUI's TabView, hoping to obtain the native Liquid Glass tab appearance on newer systems. Please note: on certain versions of macOS 14 and macOS 15, the TabView-related SwiftUI APIs exhibit behavioral differences that affect how this app works; these differences exist on already-released older system versions, will not change with future system updates, and cannot be worked around from within the app itself. In addition, this app must share a single interface architecture between iPhone and Mac (the iPadOS build running on macOS), so we cannot sacrifice the macOS experience merely to serve the needs of a subset of iPhone users. Furthermore, a considerable share of this app's users, because of financial constraints and other reasons, still use devices with 6 GB of RAM or less, so raising the minimum system requirement from iOS 17 / macOS 14 to iOS 26 / macOS 26 at once is not realistic. Therefore, this project will no longer accept code contributions that rewrite the tab bar with TabView; such pull requests will be closed. Thank you for your understanding.
- Changed the scroll-edge effect of this app's interface on iOS 26+ and macOS 26+ from "hard" to "soft."
- Added support for the hinge status of foldable devices (iPhone Duo), improving the sidebar visibility judgment when such a device is unfolded.
- Fixed an issue with the manual scanned-status check button in the Miyoushe QR Code login flow: the button used to interrupt the ongoing login polling, causing some otherwise-successful logins to fail and voiding the automatic polling refresh associated with that QR code.

Note: Scenarios where users run a beta version of an annual major system update that has not yet been officially released are not supported by us. The Apple Developer Program License Agreement restricts us from mentioning details of annual OS-level API behavioral changes related to such operating systems in public release notes for App Store. We can only state that such scenarios may lead to any form of data loss and software usability issues.

(This app no longer supplies a macCatalyst build on the App Store. This helps reduce the App Review workload. As a result, the app can no longer support Intel-based Macs, since only Apple Silicon Macs can run the iPad app directly. All macOS-related mentions above refer to the behavior of the iPadOS version of this app running on macOS. This app is built with SwiftUI, which generally delivers better performance on Apple Silicon machines.)

$EOF.

// JPN - - - - - - - - - - - -

// 「ラテ助手」v5.9.4 の主な更新内容：

- 《原神》v7.1 で追加された新キャラクターおよび新武器への対応を追加しました。新キャラクター（とその運命）：ヴェスナ（壊滅）、ヴォジャニーツァ（調和）。
- 本アプリ内における一部原神キャラクターの命途パスを調整しました：ドール（男）／ドール（女）（全属性）「壊滅」→「愉悦」。
- 《スターレイル》v4.5 の紀行アバター写真素材を追加しました。
- iOS 26およびmacOS 26システム向けに、底部フローティングタブバーのタッチおよびアニメーションの挙動を再実装し、レイアウト計算に関するいくつかの不具合を修正しました。
  - [追記] この一年間、SwiftUI の TabView を用いてタブバーを再実装する（新しいシステムでネイティブの Liquid Glass タブ表示を得る）というご提案を度々いただいております。あらためてご説明いたします：macOS 14 / 15 の一部のシステムバージョンでは、TabView に関連する SwiftUI API に、本アプリの動作へ影響する挙動の差異があります。この差異は既に提供済みの旧システムバージョン上に存在するもので、今後のシステム更新によって変化することはなく、アプリ側で回避することもできません。また、本アプリは iPhone と Mac（macOS 上で動作する iPadOS 版）の間で同一のインターフェース構成を共有する必要があり、iPhone 側の一部のご要望のためだけに macOS での使用体験を犠牲にすることはできません。加えて、本アプリの利用者のかなりの割合が、経済的な事情などにより、メモリ容量 6GB 以下のデバイスを引き続きご利用であり、最低システム要件を iOS 17 / macOS 14 から iOS 26 / macOS 26 へ引き上げることは現実的ではありません。したがって、本プロジェクトは今後、TabView によるタブバー再実装を含むコード貢献を受け付けません。該当する Pull Request はクローズさせていただきます。ご理解のほどお願いいたします。
- iOS 26+およびmacOS 26+システムにおけるインターフェースのスクロールエッジ効果を「ハード」から「ソフト」に変更しました。
- 折りたたみデバイス（iPhone Duo）のヒンジ状態への対応を追加し、展開時のサイドバー表示判定を改善しました。
- 米遊社のQRコードログインにおけるスキャン状態の手動確認ボタンの不具合を修正しました：このボタンは進行中のログインポーリングを中断してしまい、本来成功するはずのログインが失敗したり、そのQRコードに係る自動ポーリング更新が無効化されてしまったりする問題がありました。

注意：まだ正式リリースされていない年次メジャーシステムアップデートのベータ版をユーザーが実行するシナリオは、当チームのサポート対象外です。Apple Developer Program ライセンス契約により、App Store の公開リリースノートにおいて、このようなオペレーティングシステムに関連する年次 OS レベル API の動作変更の詳細を記載することが制限されています。当チームから言えるのは、このようなシナリオがあらゆる形式のデータ損失やソフトウェアの可用性問題を引き起こす可能性があるということのみです。

（当アプリは App Store で macCatalyst ビルドの提供を終了しました。これにより App Review の作業負荷が軽減されます。その結果、当アプリは Intel ベースの Mac をサポートしなくなりました。Apple Silicon Mac のみが iPad アプリを直接実行できるためです。上記の macOS に関する言及はすべて、macOS 上で動作する本アプリの iPadOS 版の動作を指します。本アプリは SwiftUI で構築されており、SwiftUI は一般的に Apple Silicon マシンでより優れたパフォーマンスを発揮します。）

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Латте помощник» v5.9.4:

- Добавлена поддержка новых персонажей и нового оружия, добавленных в «Genshin Impact» v7.1. Новые персонажи (и их Пути): Весна (Уничтожение), Водяница (Гармония).
- В приложении скорректированы жизненные пути некоторых персонажей Genshin Impact: Манекен (м)/Манекен (ж) (все элементы) «Уничтожение» → «Радость».
- Добавлены портреты Боевого пропуска Star Rail v4.5.
- Для систем iOS 26 и macOS 26 переработано поведение касаний и анимации плавающей нижней панели вкладок; исправлены некоторые проблемы расчёта макета.
  - [Дополнение] за прошедший год пользователи неоднократно предлагали переписать панель вкладок средствами SwiftUI TabView в надежде получить нативный вид вкладок Liquid Glass на новых системах. Поясняем: в некоторых версиях macOS 14 и macOS 15 API SwiftUI, связанные с TabView, ведут себя по-разному, что влияет на работу приложения; эти различия существуют в уже выпущенных старых версиях систем, не изменятся с будущими обновлениями системы и не могут быть обойдены средствами самого приложения. Кроме того, приложение должно использовать единую архитектуру интерфейса и на iPhone, и на Mac (версия для iPadOS, работающая на macOS), поэтому мы не можем пожертвовать работой на macOS ради потребностей лишь части пользователей iPhone. К тому же значительная доля пользователей приложения по финансовым и иным причинам по-прежнему пользуется устройствами с объёмом памяти 6 ГБ и менее, так что повышение минимальных требований с iOS 17 / macOS 14 сразу до iOS 26 / macOS 26 не представляется реалистичным. Поэтому проект больше не принимает вклад в код, переписывающий панель вкладок на TabView; такие pull request'ы будут закрываться. Благодарим за понимание.
- Эффект края прокрутки в интерфейсе приложения для систем iOS 26+ и macOS 26+ изменён с «жёсткого» на «мягкий».
- Добавлена поддержка состояния шарнира складных устройств (iPhone Duo); улучшено определение видимости боковой панели в развёрнутом состоянии.
- Исправлена проблема с кнопкой ручной проверки статуса сканирования при входе по QR-коду Miyoushe: эта кнопка прерывала текущий опрос статуса входа, из-за чего некоторые успешные входы завершались неудачей, а автоматическое обновление опроса, связанное с этим QR-кодом, аннулировалось.

Примечание: сценарии, при которых пользователи запускают бета-версию ежегодного крупного обновления системы, ещё не выпущенного официально, не поддерживаются нашей командой. Лицензионное соглашение Apple Developer Program ограничивает нас в упоминании подробностей ежегодных изменений поведения API на уровне ОС, связанных с такими операционными системами, в публичных примечаниях к выпуску для App Store. Мы можем лишь заявить, что такие сценарии могут привести к любым формам потери данных и проблемам с работоспособностью программного обеспечения.

(Приложение больше не предоставляет сборку macCatalyst в App Store. Это помогает снизить нагрузку на команду App Review. В результате приложение больше не поддерживает компьютеры Mac на базе Intel, поскольку только Apple Silicon Mac могут напрямую запускать iPad-приложения. Все вышеупомянутые упоминания macOS относятся к поведению версии этого приложения для iPadOS, работающей на macOS. Это приложение создано с использованием SwiftUI, который, как правило, обеспечивает более высокую производительность на компьютерах Apple Silicon.)

$EOF.
