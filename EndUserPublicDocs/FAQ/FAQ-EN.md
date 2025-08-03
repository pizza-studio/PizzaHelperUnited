# The Pizza Helper FAQ

This document only addresses questions not covered by *The Pizza Helper Privacy Policy* and *The Pizza Helper End-User License Agreement and Disclaimer*.

## // Security Concerns and Usability of App Features

#### Q: How to use widgets? Are widgets available for watchOS?

The Pizza Helper introduced watchOS widgets since v5.0.3. For information on how to use widgets on Apple devices, please consult Apple Support. Please note that widget functionalities may vary across different operating systems and their annual updates.

#### Q: Is there an Android version of The Pizza Helper?

Currently, there are no plans to develop an Android version.

#### Q: Will using this tool result in my game account being suspended?

Based on feedback received so far, there have been no reports of this happening. According to confirmation from enthusiastic players who contacted miHoYo's dedicated customer service, the response was that game accounts will not be suspended. (*The Pizza Helper End-User License Agreement and Disclaimer* mentions: **The developer is not responsible for any damages caused by user actions**.)

#### Q: Is it safe for me to login my Miyoushe / HoYoLAB account via The Pizza Helper?

**Miyoushe account logins in this app is through QRCode scan which does not need a password input**; For HoYoLAB accounts, **the process is protected by different methods supplied by Apple which varies by your device type**: if iOS, the system-provided secure input keyboard on your screen is the one retrieving your password input; if macOS, the system-provided hardware-level SecureEventInput API directly retrieving your physical keyboard inputs. **Both inputs will be directly passed through WKWebView to HoYoLAB login page**. Then the server generates the device-specific Cookie which this app utilizes for servicing the user's information needs. **This entire process is not interceptable by anyone else (nor The Pizza Helper app)**. Thanks to Apple for making these security efforts.

#### Q: How does The Pizza Helper handle users' gacha records?

As mentioned in *The Pizza Helper Privacy Policy*, players' gacha records are stored only in these three locations:

- The Apple device you use for The Pizza Helper.
- The iCloud private cloud space of the Apple ID currently signed in to iCloud Drive on that device.
- Any other digital devices logged into that Apple ID with iCloud Drive enabled and The Pizza Helper installed.

Although The Pizza Helper allows users to import and export gacha records, the development team does not recommend sharing these records to any third-party websites that may disclose statistical results without permission.

#### Q: Which online services of The Pizza Helper might be affected by external factors beyond our control?

At least the following types of services could be affected:

1. **HoYoLAB or miHoYo Community:** Real-time notes, personal battle reports, ledgers, gacha record retrieval, character inventory lists, in-game events.
2. **Enka Networks:** Character showcases.

Each supported game, during its major version updates, often comes with temporary unavailability of the aforementioned services. Especially Enka Networks, each version maintenance typically takes one to two days.

#### Q: Why some features are removed?

Features have been removed for the following reasons:

- Features where user experience cannot compete with Miyoushe / HoYoLAB app implementations, such as game statistics.
- Features that can no longer be maintained due to developer time constraints, such as the Pizza Dictionary.
- Features with unresolvable user experience issues, such as the Spiral Abyss Top Lists.

#### Q: After upgrading this app from the App Store, why have many features disappeared? Now only the data export function remains?

Starting from v5.5.0 (v5.5.1 for watchOS app), this software has reintroduced its installability for OS21 ~ OS23 (i.e., iOS 14 ~ 16 and macOS 11 ~ 13) to replace deprecated legacy versions. This decision was made due to security concerns in older versions (v4.x and earlier) and our inability to address them through other means. Considering the unique needs of OS23 users, we have backported some core features to OS23 (iOS 16.2+, macOS 13.0+, watchOS 9.2+) and later. However, SwiftUI remains highly unstable on these OS versions, which may cause operational issues. If your usage requirements and budget permit, please switch to a device supporting at least OS24+.

## // App and Development Team

#### Q: I am a refugee of the Pizza Helper for HSR. What should I be aware of when migrating to this new app?

1. **Data Sync**: Although the new unified Pizza Helper engine can read cloud data from Pizza Helper for HSR on the same Apple ID via iCloud, the data synchronization may take time and can be affected by factors like connection status. For a more reliable migration, you can export your local accounts from Pizza Helper for HSR as a JSON file (profile package) and import it into the new version of The Pizza Helper. Gacha records can also be migrated using a similar method (via file exchange conforming to UIGF v4 format).

2. **Widgets**: All widgets in the new The Pizza Helper that seem to be designed for Genshin Impact can now also display Star Rail content (excluding Genshin-specific widgets like the Realm Currency). Simply select the local profile dedicated to Star Rail in the widget settings. The Stamina Timer, implemented using iOS's built-in Live Activity feature, can also be used to show the Trailblaze Power refill status in Star Rail. User-customizable wallpaper support for widgets has been reintroduced since 5.2.1 update but cannot inherit its previous settings data. Please refer to the related UI text instructions regarding its usage.

#### Q: How does The Pizza Helper work?

The miHoYo / HoYoLAB client app requests game-related information from the miHoYo / Cognosphere server backend. This method can retrieve some game state information (such as stamina refill progress, etc.). The Pizza Helper uses your UID and Cookie information to replicate this query process and request this data from the corresponding server backend on your behalf, displaying it in The Pizza Helper's main interface and widgets. The Privacy Policy already explained how the Cookies will be used.

#### Q: Will there be any charges in the future?

miHoYo does not allow charging or embedding ads, so all features of The Pizza Helper are freely available. 

The Pizza Helper did accept voluntary donations from users for a while, and the development team does not have any obligations to the donors. These donations will be used for app development and maintenance of associated network infrastructure. Of course, the annual fee for the Apple Developer Program membership required to distribute software via the Apple App Store will be reimbursed from this donation fund. If large donations are received, the team may publicly acknowledge the contributors. The team may also consider donating any unused funds to charitable causes at an appropriate time.

#### Q: How do widgets automatically update a player's account status for Original Resin / Trailblaze Power / ZZZ Energy?

These are collectively referred to as "player stamina" in The Pizza Helper. Since version 5.0.4, The Pizza Helper's widgets will attempt to request real-time note data from the Miyoushe / HoYoLAB servers every certain minutes necessary for the recovery of a stamina point (which differs among supported game titles). The real-time note data includes the corresponding UID's Original Resin / Trailblaze Power / ZZZ Energy status. Desktop widgets also include a refresh button for reloading content. When you open The Pizza Helper app, all widgets will automatically request real-time data again. If you haven’t consumed stamina in-game, the stamina discrepancy shown in the widgets should not exceed 1.

However, for iPhone models that are more than 3 years old, even if the battery has been replaced with a new one, the above widget operating mode will put a strain on battery life, so please try to minimize the number of widgets you use on such models.

#### Q: How can I learn more about the development team or discuss other topics?

You can find the development team's QQ channel and Discord channel in the "About" section of The Pizza Helper. Since April 2023, the development team has grown to three members (Lava; Bill Haku; Shiki Suen). You can click "Development Team" at the top-right corner of the "About" section to see their contact details. Due to personal career plans, only Shiki Suen is the current development maintainer since October 1, 2024.

#### Q: Any plan on implementing advanced features regarding Zenless Zone Zero? e.g. Gacha Record Management, etc.

These features won't be considered to implment in at least a year. There were too many reasons and concerns behind this decision, but one of them is that we are almost running out of our available time on this project.

## // Technical Issues and Know-How

> This section discusses issues starting from The Pizza Helper version 5.2.1.

#### Q: What's the differences among the character build information (CBI) provided by Enka and HoYoLAB / Miyoushe?

Thereotically, Enka Network supplies the most-accurate CBI but limited to those characters disclosed in the showcase of an UID. Meanwhile, HoYoLAB / Miyoushe supplies the CBI of all characters owned by a UID.

CBI supplied by HoYoLAB / Miyoushe has the following limitations due to the nature of their provided backend data:

- Star Rail: When a weapon (light cone) has its level at 20 & 30 & 40 & 50 & 60 & 70, it is impossible to identify whether its ascension is finished. The Pizza Helper assume that all weapons at these levels are not ascended. This affect its deducted weapon build information.
- Genshin Impact: The elemental damage boost (EDB) information  of certain characters are not calculated correctly on the HoYoLAB / Miyoushe server side, omitting the EDB gained from the character's own level ascension. In such case, please refer to his / her in-game character build information when he / she is not in the team. Characters in a team may affect each other's build information data due to members' skills and their combinations.
- Genshin Impact: All skill levels are calculated as final results, hence inability of identifying which skill has its level boosted by the character's constellations.

#### Q: The iOS lock screen widgets are not loading content. How can I fix this?

This is likely because the widget is stuck in the data retrieval state. You can enter the lock screen widgets' edit mode, modify the widget content, and reselect the local profile (even if it's the same as the previous one). This will trigger the content update process.

#### Q: Apple Watch is unable to sync accounts from iCloud?

For iOS 18: First, turn off The Pizza Helper's iCloud sync feature, then turn it back on. Open The Pizza Helper app and leave it idle for a minute, then try syncing through the Apple Watch app. Please consult Apple Support for further instructions.

#### Q: Can't find widgets when trying to add them?

Try restarting the system and wait 10 minutes. If that doesn’t work, try turning off and on The Pizza Helper's notifications. This has a high chance of resolving the issue. If you're on macOS and the problem persists, please contact Apple Support to ensure that the app is installed in the correct location or is not duplicated in multiple locations.

#### Q: Error codes -1 (data not retrieved) or 10102, 10103, 10104 (Cookie and UID mismatch)

Check whether the real-time notes feature in Miyoushe or HoYoLAB is enabled and retrieve a new Cookie. Also, make sure the logged-in account is correct.

#### Q: Error code 10001 (Cookie error or expired Cookie)

It is recommended to log in again with the corresponding local profile. This process will retrieve a new Cookie.

#### Q: Error code 1008 (UID error)

Check if the UID corresponds to the server you selected (note: this refers to the Genshin Impact / Star Rail / Zenless Zone Zero UID, not the miHoYo / HoYoVerse Passport ID Number of your Miyoushe / HoYoLAB account). If you can't resolve the issue, please report it to us. Since version 5.0, The Pizza Helper will automatically attempt to determine the server when entering the UID in the local profile management screen.

#### Q: How to prepare device fingerprints for UIDs governed by Miyoushe?

(This question is irrelevant to those UIDs governed by HoYoLAB.)

This function requires traffic monitoring between the iOS version of the Miyoushe App and miHoYo server, specifically to obtain the `x-rpc-device_fp` field. Such tools will create a local virtual private network for the system to enable traffic monitoring.

The only current solution is for the user to use specialized traffic monitoring tools to perform packet capturing. We recommend "Stream" by Stream Lab Inc., an iOS app specifically designed for packet capture.

The captured contents are personal information. We suggest that the user captures & users his / her own data by himself / herself.

#### Q: How to handle the Paimon.moe gacha record format?

Due to the lack of critical information fields in the Excel gacha record format provided by the website (which are all specified by UIGFv4), we have already completely abandoned support for the proprietary Excel format of Paimon.moe when implementing UIGFv4 support in (the previously) Genshin Pizza Helper. This feature is indeed not implemented in (currently) The Pizza Helper. If you need to import the data into applications that support the UIGFv4 standard, please send a feature request to Paimon.moe.

#### Q: How to obtain gacha records URL for "Star Rail UID" and "Genshin UID hosted by HoYoLAB"?

This function requires traffic monitoring between these game clients (including miHoYo's cloud games) and the miHoYo server, specifically to filter any URLs containing specific fields and domains. Such tool will create a local virtual private network to enable traffic monitoring.

The only current solution is for the user to personally use specialized traffic monitoring tools to perform packet capturing.

- If you're using iOS, we recommend "Stream" by Stream Lab Inc., an iOS app specifically designed for packet capture.
- There are too many packet capture tools for Windows and macOS systems to list here.

The packet capturing rule is to filter all URLs containing the path "`/api/getGachaLog`". The domains of gacha URLs for different game regions will all start with "`public-operation`":

- Gacha URLs for UIDs governed by Miyoushe will have domains ending with `mihoyo.com`.
- Gacha URLs for UIDs governed by HoYoLAB will have domains ending with `hoyoverse.com`.

While capturing packets, the user needs to open the gacha record page (Wish / Warp history) in the game while traffic monitoring is active.

The validity period of the URL you capture may only be one or two hours, so please use it as soon as possible.

The URL & data you capture is of your personal privacy; please carefully consider whether to share it with others.

#### Q: Why all of my local profiles are gone everytime I reboot my iOS device? They may come back after approximately 30 seconds, but it's still annoying.

The Pizza Helper uses Group Containers to storage local profiles by default (with a mirrored copy saved in UserDefaults for Widgets). If you have encountered this issue, you can do the following steps:

1. Go to "Local Profile Manager -> Menu (at the top-trailing of the UI)" to use the related menu option to export all of your local profiles as a backup file. After you finishes the Step 2, you will need to import your local profiles back using this backup file.
2. In the same menu, you go to "Advanced Options" and switch the "Local Profile Storage Location" to "App Container" instead. The app will automatically quits after you toggling this option.
3. Import the local profiles back to the app. The option is situated in the same menu mentioned in Step 1.

This is a proven workaround for this issue.

#### Q: What is the Standard Hit Rate Confidence feature in gacha statistics?

The Standard Hit Rate Confidence feature in The Pizza Helper provides a reliability indicator for the standard item hit rate calculation in gacha games. This feature helps users understand how trustworthy their gacha statistics are based on the amount of available data.

**Confidence Levels and Thresholds:**

The confidence is determined by the number of relevant 5-star pulls available for analysis:

- **High confidence**: ≥10 cases - The calculated standard hit rate is highly reliable
- **Medium confidence**: 5-9 cases - The calculated standard hit rate has moderate reliability
- **Low confidence**: 3-4 cases - The calculated standard hit rate has limited reliability
- **Insufficient data**: <3 cases - Not enough data to provide a meaningful calculation

**How to Interpret Confidence Levels:**

- **High confidence** results can be trusted for making gameplay decisions
- **Medium confidence** results provide useful guidance but should be considered alongside other factors
- **Low confidence** results should be interpreted cautiously as they may not be representative
- **Insufficient data** indicates you need more gacha pulls before meaningful statistics can be calculated

**Common Reasons for Insufficient Confidence:**

- Too few 5-star pulls in your gacha history
- Incomplete gacha record (missing historical data)
- Recently started recording gacha pulls
- Statistical result exceeds theoretical bounds (>50%)

**Technical Details:**

When you see a confidence indicator in the gacha statistics section, you can tap it to view a detailed explanation. This triggers a localized alert using the i18n key `gachaKit.stats.confidence.alert.message`, which provides comprehensive information about confidence indicators in your preferred language.

The confidence calculation takes into account the complexity of gacha mechanics, including pity systems and the distinction between standard and limited items, ensuring that the reliability assessment reflects the actual statistical significance of your data.

$ EOF.
