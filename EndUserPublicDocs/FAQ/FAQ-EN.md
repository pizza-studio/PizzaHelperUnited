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

1. **HoYoLAB or miHoYo Community:** Real-time notes, personal battle reports, ledgers, game statistics, gacha record retrieval, character inventory lists.
2. **Enka Networks:** Character showcases.
3. **Yatta.moe:** Genshin Impact daily materials.
4. **Ennead.cc:** Star Rail daily HoYoLAB news (plain-text only).

Each supported game, during its major version updates, often comes with temporary unavailability of the aforementioned services. Especially Enka Networks, each version maintenance typically takes one to two days.

## // App and Development Team

#### Q: I am a refugee of the Pizza Helper for HSR. What should I be aware of when migrating to this new app?

1. **Data Sync**: Although the new unified Pizza Helper engine can read cloud data from Pizza Helper for HSR on the same Apple ID via iCloud, the data synchronization may take time and can be affected by factors like connection status. For a more reliable migration, you can export your local accounts from Pizza Helper for HSR as a JSON file (profile package) and import it into the new version of The Pizza Helper. Gacha records can also be migrated using a similar method (via file exchange conforming to UIGF v4 format).

2. **Widgets**: All widgets in the new The Pizza Helper that seem to be designed for Genshin Impact can now also display Star Rail content (excluding Genshin-specific widgets like the Realm Currency). Simply select the local profile dedicated to Star Rail in the widget settings. The Stamina Timer, implemented using iOS's built-in Live Activity feature, can also be used to show the Trailblaze Power refill status in Star Rail. Custom background support for widgets will be delayed for some time and may be implemented later, depending on conditions.

#### Q: How does The Pizza Helper work?

The miHoYo / HoYoLAB client app requests game-related information from the miHoYo / Cognosphere server backend. This method can retrieve some game state information (such as stamina refill progress, etc.). The Pizza Helper uses your UID and Cookie information to replicate this query process and request this data from the corresponding server backend on your behalf, displaying it in The Pizza Helper's main interface and widgets. The Privacy Policy already explained how the Cookies will be used.

#### Q: Will there be any charges in the future?

miHoYo does not allow charging or embedding ads, so all features of The Pizza Helper are freely available. 

The Pizza Helper does accept voluntary donations from users, and the development team does not have any obligations to the donors. These donations will be used for app development and maintenance of associated network infrastructure. Of course, the annual fee for the Apple Developer Program membership required to distribute software via the Apple App Store will be reimbursed from this donation fund. If large donations are received, the team may publicly acknowledge the contributors. The team may also consider donating any unused funds to charitable causes at an appropriate time.

#### Q: How do widgets automatically update a player's account status for Original Resin / Trailblaze Power / ZZZ Energy?

These are collectively referred to as "player stamina" in The Pizza Helper. Widgets reload every certain minutes necessary for the recovery of a stamina point (which differs among supported game titles). Since version 5.0.4, The Pizza Helper's widgets will attempt to request real-time data from the Miyoushe / HoYoLAB servers every 2 hours (including the corresponding UID's Original Resin / Trailblaze Power / ZZZ Energy status). Desktop widgets also include a refresh button for reloading content. When you open The Pizza Helper app, all widgets will automatically request real-time data again. If you haven’t consumed stamina in-game, the stamina discrepancy shown in the widgets should not exceed 1.

#### Q: How can I learn more about the development team or discuss other topics?

You can find the development team's QQ channel and Discord channel in the "About" section of The Pizza Helper. Since April 2023, the development team has grown to three members (Lava; Bill Haku; Shiki Suen). You can click "Development Team" at the top-right corner of the "About" section to see their contact details.

#### Q: Any plan on implementing advanced features regarding Zenless Zone Zero? e.g. Gacha Record Management, etc.

These features won't be considered to implment in at least a year. There were too many reasons and concerns behind this decision, but one of them is that we are almost running out of our available time on this project.

## // Technical Issues

> This section discusses issues starting from The Pizza Helper version 5.0.

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

Check if the UID corresponds to the server you selected (note: this refers to the Genshin Impact / Star Rail / Honkai: Star Rail UID, not the Miyoushe Passport ID Number). If you can't resolve the issue, please report it to us. Since version 5.0, The Pizza Helper will automatically attempt to determine the server when entering the UID in the local profile management screen.

$ EOF.
