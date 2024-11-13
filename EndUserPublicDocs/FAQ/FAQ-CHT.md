# 披薩小助手常見問題解答（FAQ）

本文僅解答那些無法由《披薩小助手隱私政策》與《披薩小助手使用者授權合約與免責聲明（EULA）》回答的問題。

## // 安全疑慮

#### Q: 披薩小助手有沒有 Android 版本？

暫無開發 Android 版本之計劃。

#### Q: 使用該工具是否會導致遊戲帳號被停權？

根據到目前為止的反饋來看，迄今為止尚無先例。根據熱心玩家向米哈遊專屬客服的求證，得到的答覆是遊戲帳號不會被停權。（《披薩小助手使用者授權合約與免責聲明（EULA）》有提及：**開發者對於因使用者行為所導致之任何損害不承擔任何責任**。）

#### Q: 我藉由披薩小助手登入米遊社 / HoYoLAB 帳號的過程是安全的嗎？

披薩小助手**對米游社帳號是採取 QRCode 掃碼登入的、不會牽涉到帳號盜取的嫌疑**；對 HoYoLAB 帳號雖然需要密碼登入，但使用者對自己帳號的密碼輸入是**直接由 iOS 系統的安全鍵盤接管（macOS 平台則是 SecureEventInput 模式從硬體層面接管所有的鍵盤輸入訊號）、然後直接被 iOS / macOS 內建的 WKWebView 轉交給 HoYoLAB 完成登入**、才產生了可以由披薩小助手在所處裝置賴以使用的 Cookie。**整個登入過程當中，披薩小助手始終無權截獲使用者對密碼的鍵盤輸入**。感謝 Apple 一直以來致力於對資訊安全環境的營造。

#### Q: 披薩小助手會怎麼處理使用者的抽卡記錄？

在《披薩小助手隱私政策》有提及：玩家的抽卡記錄只會被披薩小助手存放在這三個位置：

- 閣下使用披薩小助手時之 Apple 數位裝置。
- 以及該數位裝置當時所已經登入使用 iCloud Drive 的 Apple ID 之自身的 iCloud 私有雲空間。
- 以及任何被登入該 Apple ID 使用 iCloud Drive 且有安裝披薩小助手之數位裝置。

雖然披薩小助手允許使用者匯入、匯出抽卡記錄，但開發團隊不建議您將這些資料上交給任何可能會擅自公開統計結果的第三方網站。

## // App 與開發團隊

#### Q: 我是星鐵披薩小助手的使用者，請問在遷移過來時需要注意什麼？

一是資料同步：雖然基於統一披薩引擎的全新的披薩小助手可以藉由 iCloud 讀取到同一 Apple ID 下的星鐵披薩小助手的雲端資料，但同步讀取資料是需要時間的、且可能受到包括連線狀態等多方因素之影響。如希望能有更穩妥的遷移手段的話，您可以藉由星鐵披薩小助手將其本機帳號全部匯出為一個 JSON、再匯入到目前的新版披薩小助手內。抽卡記錄也可以用類似的手段遷移（使用 UIGF v4 格式）。

二是小工具（小組件）：全新的披薩小助手的所有看似給原神設計的小工具都是可以顯示星穹鐵道的內容的（洞天寶錢等原神專屬小工具除外），直接在小工具設定裡面選擇您創建的星穹鐵道專用的本機帳號即可。依賴 iOS 內建的即時動態（Live Activity）功能實作的玩家體力計時器也可以用來顯示星穹鐵道的開拓力回滿狀態。對於小工具的自訂背景的功能支持會欠奉一段時間，待諸多條件允許之後可能會再行實作。

#### Q: 披薩小助手的工作原理是什麼？

米游社 / HoYoLAB 客體應用（client app）會藉由向米哈遊 / Cognosphere 的伺服器的後端請求遊戲內的一些資訊。這個手段可以查詢到一些與此有關的遊戲狀態資訊（比如玩家體力的回滿進度，等）。披薩小助手使用您的 UID 與 Cookie 資訊可以重複這個查詢過程、代替您使用這兩款 App 向對應的伺服器的後端請求遊戲內的這些資訊、並展示於披薩小助手的主介面與小工具當中。《披薩小助手隱私政策》已經解釋了與這些 Cookies 的使用有關的內容。

#### Q: 未來會收費嗎？

米哈遊不允許收費或植入收費廣告，所以披薩小助手的所有功能都是免費提供開放使用的。

披薩小助手倒是有在接受來自使用者的自發捐贈，且敝團隊不會因此對捐贈者產生任何義務。這類捐贈內容會用於 App 開發、及其連帶網路設施的維護。當然，藉由 Apple App Store 發行軟體所必須的 Apple Developer Program 會員身分的年費也會從這筆捐贈金報銷。如有收到大宗捐贈的話，敝團隊可能會公示他們的貢獻。敝團隊也可能會考慮在適當的時間點將用不完的經費捐贈給社會公益之用途。

#### Q: 小工具（小組件）是怎樣自動更新玩家的帳號的原粹樹脂 / 開拓力 / 絕區電量狀態的？

這些在披薩小助手被統稱為「玩家體力（Stamina）」。根據既往的經驗來看，iOS 與 macOS 的小工具每八分鐘會重新載入一次當前的內容。同時，披薩小助手的小工具從 5.0 版開始會每隔 15 分鐘嘗試向米遊社 / HoYoLAB 伺服器請求一次最新的實時便箋資料（裡面包括了對應 UID 的原粹樹脂 / 開拓力 / 絕區電量狀態等資訊）。桌面小工具額外會有用於重載內容專用的刷新按鈕。開啟披薩小助手本體 App 時，所有小工具都會自動重新請求一次實時便箋資料。如果您未曾登入遊戲消耗過玩家體力的話，理論上藉由小工具顯示的玩家體力的誤差不會超過 1。

#### Q: 開發團隊的自我介紹呢？如何解決其他疑問和討論其他話題？

各位可以在披薩小助手的「關於」畫面找到披薩小助手的 QQ 頻道和 Discord 頻道。從 2023 年四月開始，開發團隊變成了三個人（Lava; Bill Haku; Shiki Suen）。各位可以在「關於」畫面的右上角點一下「開發組」就能看到他們的聯絡資料。

#### Q: 請問何時會實作與絕區零有關的進階功能？比如抽卡記錄管理之類的。

至少一年內不會實作。原因有很多，但開發團隊分身乏術也是重要原因之一。

## // 技術故障

> 本章節內容以披薩小助手 5.0 版開始的版本為討論情形。

#### Q: iOS 鎖屏小工具（小組件）無法加載出內容，怎麼解決？

這有很大概率是小工具卡在資料獲取狀態了。可以進入鎖屏小工具編輯狀態，編輯對應的小工具的內容，重新選擇本機帳號（哪怕選擇的還是之前的本機帳號），這樣可以觸發鎖屏小工具的內容更新流程。

#### Q: Apple Watch 無法從 iCloud 同步帳號？

以 iOS 18 為例：先關閉披薩小助手的 iCloud 同步功能、再重新打開，並進入披薩小助手的本體應用、再靜置一分鐘，隨後打開 Apple Watch App 嘗試同步即可。具體操作方法為：在 iPhone 上點按「設定」-「你的 Apple 帳號」-「iCloud」-「儲存至 iCloud」，然後把頁面往下翻，找到披薩小助手的開關，關掉之後再重新點開就可以了。

#### Q: 嘗試添加小工具（小組件）時，找不到小工具。

請嘗試重新啟動系統後靜置十分鐘、不行的話再試試關閉再打開披薩小助手的通知，有較大概率解決。如果您在用 macOS 的且這樣做之後該問題仍舊存在的話，請洽 Apple Support 讓他們的專員引導您確認 App 是否被安裝到了正確的位置、或者在不同的位置有重複安裝。

#### Q: 錯誤碼 -1（未獲取到數據）或 錯誤碼 10102、10103、10104（Cookie 與 UID 不對應）

檢查是否開啟米遊社的實時便箋（或 HoYoLAB 的實時便箋）功能，並重新獲取 Cookie。另請注意登入的帳號本身是否正確。

#### Q: 錯誤碼 10001 （Cookie 有誤或 Cookie 失效）

建議將對應的本機帳號重新登入。這個過程會重新獲取 Cookie。

#### Q: 錯誤碼 1008（UID 有誤）

檢查 UID 是否與您選擇的伺服器彼此對應（注意：是原神/星穹鐵道/絕區零的UID，不是米遊社通行證帳號的 ID 數字）。如無法解決，請向我們反饋。另：披薩小助手自從 v5.0 版本開始，會在藉由本機帳號管理畫面輸入 UID 時自動嘗試判定所屬的伺服器。

$ EOF.