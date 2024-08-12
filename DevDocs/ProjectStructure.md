# PZKit

为了方便多人开发维护、解决「非得登入专案主管的 Apple ID 才能正常编译」的窘境，特此设立 PZKit 这个 SPM。

因为涉及到多个平台的编译，所以 `Package.swift` 的构造有些复杂、且有异于常见的 Swift Package。实际上呢，这个文件是个 Swift JIT 脚本，不用担心太多。

> 本文所有「米游社」一词均同时代称米游社与 HoYoLab，除非有特殊的说明。

几个注意点：

1. 针对 SwiftUI 的全平台通用扩展放到 `PZBaseKit` 的 Shared 分支内。
2. `PZAccountKit` 负责存放与米游社帐号登入有关的一些内容。然而，下述内容均得放到专门的 SPM target 内：
  - 对于抽卡记录的抽取有关的米游社后端互动内容。
  - DailyNote（树脂/开拓力）、摩拉帐簿、个人深渊记录、深渊排行（这些都会各自弄成各自的 SPM target。
3. 前端的内容，只要是两款 App 共用的，都塞到 `PZHelper` 或 `PZHelper-Watch` 这两个 targets 当中。
4. 开发时是按照 UnitedPizzaHelper 开发的，但：
  1. 实际上会就原披助手与穹披助手分别设立两个不同的 Xcode target、以各自的 BundleIdentifier 来区分彼此。
  2. App 实际运行时，会检查 BundleIdentifier 来自动屏蔽与自身不对应的游戏。
    - 比如说原神披萨助手会自动隐藏任何与星穹铁道有关的内容。反之亦然。
    - 原披助手与穹披助手会有各自专用的图片素材 Asset SPM，不属于 PZKit 的子包。两者之间用 Protocol 的方式互动。
      - 这避免了需要将「A披助手」的素材塞到「B披助手」的 App Bundle 内的局面（反之亦然）。
      - 不指定 Asset SPM 的话，`EnkaKit` 与 `GachaKit` 的默认行为一律是从 Enka.Networks 线上载入素材、以便于对两者的单独开发调试。
        - 该行为函式自然是得设定成可复写的，或者设计成在接入 Asset SPM 的情况下自动以 Protocol 的方式优先请求本地素材。
    - DailyNote 的角色肖像素材、以及玩家游戏进度统计画面的图示素材……这些内容是直接从米游社伺服器载入的，不属于 Asset SPM 的管辖范围。

$ EOF.
