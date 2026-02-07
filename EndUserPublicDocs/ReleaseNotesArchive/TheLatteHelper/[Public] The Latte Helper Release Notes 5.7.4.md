// 《拿铁小助手》v5.7.4 的更新内容简述：

- 为确保 App 可用性，现对机载运存容量的机种强制启用位于 App 本身的 UI 设定内的「减少 UI 玻璃装饰」开关，除非满足特定条件：macOS 的话，运存容量不低于 16GB；iPhoneOS 的话，运存容量不低于 8GB；iPadOS 的话：如果是 iPadOS 26，则运存容量不低于 16GB；如果是更早的系统，则运存容量不低于 8GB。如果您在使用 iOS 26 / macOS 26 且设备不满足这些条件的话，也请在系统偏好设定的辅助功能设定里面停用整个系统的透明玻璃特性。
- 优化了部分视图元件的渲染效率，借此降低与此有关的运算压力。
- 优化了在启用 App 本身的「减少 UI 玻璃装饰」偏好设定时的 UI 美术表现。
- 优化了对画面视图尺寸的先手测量方法，借此减轻对 iOS 设备的运算压力。
- 修复了玩家体力通知调度模组内与探索派遣委托剩余时间有关的计算错误导致的崩溃故障。
- 修复了与本地账号有关的 SwiftData 初期化失败的自纠过程有关的自纠失败故障。
- 将 Alamofire 组件升级到 v5.11.1，其中包含一个关键修复：解决了一个罕见的逻辑竞态问题，该问题会导致相同的响应序列化器同时执行多次，从而多次调用完成回调，在包装 continuation 时引发崩溃。

(现阶段暂停提供 macCatalyst 版本，以减轻 App Store 审委会的审核工作量。这导致该 App 目前无法支持 Intel Mac 机种，因为只有 Apple Silicon Mac 可以直接运行 iPad 应用。上文中讨论到的与 macOS 有关的内容更新均指该 App 的 iPadOS 版本在 macOS 系统下的行为。)

$EOF.

// CHT - - - - - - - - - - - -

// 《拿铁小助手》v5.7.4 的更新內容簡述：

- 為確保 App 可用性，現對機載記憶體容量的機種強制啟用位於 App 本身的 UI 設定內的「減少 UI 玻璃裝飾」開關，除非滿足特定條件：macOS 的話，記憶體容量不低於 16GB；iPhoneOS 的話，記憶體容量不低於 8GB；iPadOS 的話：如果是 iPadOS 26，則記憶體容量不低於 16GB；如果是更早的系統，則記憶體容量不低於 8GB。如果您在使用 iOS 26 / macOS 26 且設備不滿足這些條件的話，也請在系統偏好設定的輔助功能設定裡面停用整個系統的透明玻璃特性。
- 優化了部分視圖元件的渲染效率，借此降低與此有關的運算壓力。
- 優化了在啟用 App 本身的「減少 UI 玻璃裝飾」偏好設定時的 UI 美術表現。
- 優化了對畫面視圖尺寸的先手測量方法，借此減輕對 iOS 設備的運算壓力。
- 修復了玩家體力通知調度模組內與探索派遣委託剩餘時間有關的計算錯誤導致的崩潰故障。
- 修復了與本機帳號有關的 SwiftData 初期化失敗的自糾過程有關的自糾失敗故障。
- 將 Alamofire 組件升級到 v5.11.1，其中包含一項關鍵修復：解決了一個罕見的邏輯競態問題，該問題會導致相同的回應序列化器同時執行多次，從而多次調用完成回調，在包裝 continuation 時引發崩潰。

(現階段暫停提供 macCatalyst 版本，以減輕 App Store 審委會的審核工作量。這導致該 App 目前無法支援 Intel Mac 機種，因為只有 Apple Silicon Mac 可以直接運行 iPad 應用。上文中討論到的與 macOS 有關的內容更新均指该 App 的 iPadOS 版本在 macOS 系統下的行為。)

$EOF.

// ENU - - - - - - - - - - - -

// Major changes introduced in The Latte Helper v5.7.4:

- To ensure usability, the in-app “Reduce Glass Decorations” setting is now forcibly enabled on low-memory devices unless these conditions are met: macOS ≥ 16 GB RAM; iPhoneOS ≥ 8 GB RAM; iPadOS ≥ 16 GB on iPadOS 26 or ≥ 8 GB on earlier systems. Devices running iOS 26 / macOS 26 below these thresholds should also disable system transparency in Accessibility.
- Improved rendering efficiency of certain view components, reducing related computational overhead.
- Refined the visual presentation of the UI when the app’s “Reduce Glass Decorations” preference is enabled.
- Optimized the proactive size measurement of UI view canvases, reducing computational overhead on iOS.
- Fixed a crash issue caused by calculation errors related to the remaining time of exploration dispatch commissions within the player stamina notification scheduling module.
- Fixed a self-correction failure related to the self-correction process of SwiftData initialization failure related to Local Profile Database.
- Alamofire component upgraded to v5.11.1 which brings a crucial fix: a rare logical race condition that allowed the same response serializer to execute multiple times simultaneously, which would call the completion handler multiple times, leading to crashes when wrapping continuations.

(We stopped supplying the macCatalyst build at App Store to reduce the App Review workload. As a result, the app is currently unavailable on Intel-based Macs. Only Apple Silicon Macs are capable of running the iPad app. All macOS-related mentions above refer to the behavior of the iPadOS version running on macOS.)

$EOF.

// JPN - - - - - - - - - - - -

// 「ラテ助手」v5.7.4 の主な更新内容：

- アプリを安定して利用できるようにするため、メモリ容量が少ないデバイスでは、アプリ内の「ガラス効果を軽減」設定が強制的に有効になります。ただし、以下の条件を満たす場合は除きます：macOS は 16GB 以上のメモリ；iPhoneOS は 8GB 以上のメモリ；iPadOS は iPadOS 26 の場合 16GB 以上、それ以前のシステムの場合 8GB 以上のメモリ。iOS 26 / macOS 26 を使用していて、これらの条件を満たさないデバイスの場合は、システム設定の「アクセシビリティ」でシステム全体の透明効果を無効にしてください。
- 特定の画面コンポーネントの描きの効率を改善し、関連する計算タスクの重みを削減しました。
- アプリの「ガラス効果を軽減」設定が有効な場合の UI の見た目を改善しました。
- UI 画面コンポーネントのキャンバスのサイズ測定方法（先手で測定）を最適化し、iOS デバイスの計算オーバーヘッドを削減しました。
- プレイヤー体力通知スケジューリングモジュール内での探索派遣委託の残り時間に関する計算エラーによって引き起こされたクラッシュの問題を修正しました。
- ローカルプロファイルに関連する SwiftData 初期化失敗の自己修正プロセスに関連する自己修正失敗の問題を修正しました。
- Alamofire コンポーネントを v5.11.1 にアップグレードしました。これには重要な修正が含まれています：同じレスポンスシリアライザーが同時に複数回実行される可能性のある稀なロジック競合状態を修正しました。これにより完了ハンドラが複数回呼び出され、continuation をラップするときにクラッシュが発生していました。

（App Review の作業負荷を軽減するため、macCatalyst 版の提供を一時停止しています。そのため現時点では Intel 製 Mac ではご利用できませんので、ご了承くださいませ。Apple Silicon 機種では iPad アプリを使うのは可能です。上記の macOS に関する全ての説明は、macOS 上で実行されている当アプリの iPadOS 版の動作に関連しています。）

$EOF.

// RUS - - - - - - - - - - - -

// Основные изменения в «Латте помощник» v5.7.4:

- Для обеспечения удобства использования функция «Снизить эффекты прозрачности» в приложении теперь принудительно включена на устройствах с малым объемом памяти, если не выполнены следующие условия: macOS ≥ 16 ГБ ОЗУ; iPhoneOS ≥ 8 ГБ ОЗУ; iPadOS ≥ 16 ГБ на iPadOS 26 или ≥ 8 ГБ на более ранних системах. На устройствах с iOS 26 / macOS 26, не отвечающих этим требованиям, также отключите эффекты прозрачности системы в Специальных возможностях.
- Улучшена эффективность рендеринга отдельных компонентов интерфейса, что снижает вычислительные затраты.
- Улучшено визуальное представление интерфейса при включении функции «Снизить эффекты прозрачности».
- Оптимизирован метод предварительного измерения размера холста представления интерфейса, что снижает вычислительные затраты на iOS.
- Исправлена ошибка сбоя, вызванная ошибкой в расчётах, связанной с оставшимся временем комиссии от разведочной экспедиции в модуле планирования уведомлений о выносливости игроков.
- Исправлена ошибка самокоррекции, связанная с процессом самокоррекции сбоя инициализации SwiftData, связанного с локальным профилем.
- Компонент Alamofire обновлён до версии v5.11.1 с критическим исправлением: была решена редкая проблема логической гонки, при которой один и тот же сериализатор ответа мог выполняться одновременно несколько раз, что приводило к многократному вызову обработчика завершения и сбоям при обёртывании continuation.

(Временно приостановлен выпуск версии macCatalyst, чтобы снизить нагрузку на команду App Review. Поэтому приложение сейчас недоступно на компьютерах Mac с процессорами Intel. Apple Silicon Mac могут запускать приложение iPad напрямую. Все упоминания macOS выше относятся к поведению версии для iPad этого приложения, работающей на macOS.)

$EOF.
