# Localization Guidelines

## General

1. All localization exchangeable bundles in this folder will be updated immediately following each major update of The Pizza Helper, unless there are no changes to the base internationalization (i18n) content. Additional updates may occur during the beta development phase.

2. **Please focus solely on the XLIFF file within the XCLOC bundle for the language you wish to contribute to**. The XCStrings files in the XCLOC bundle are included only for data integrity verification by Xcode.
    - If you have Xcode 16 (or newer) installed on your computer, you can just use Xcode to open the XCLOC bundle to start your localization work.

3. Please coordinate with the development team before beginning any translation work. This allows developers to adjust their schedule to accommodate your timeline.

## Language-Specific Guidelines

- We do not accept internationalization (i18n) contributions for these languages unless there are genuine errors (such as grammatical mistakes): `en-US`, `zh-Hans`, `zh-Hant`.

- For Japanese (`ja-JP`) localization, we prefer written expressions with minimal use of katakana-based loan words (unless absolutely necessary). For **legal documents** (Privacy Policy & EULA), please use formal language consistent with the style of Japanese legal documents from the 1945-1960 period.

- For all non-CJK languages: This project deliberately shares terminology with Genshin Impact and Star Rail. All elements follow Genshin Impact's naming conventions, even when an element is originated from Star Rail. Below is the official English naming of all elements:
    - Elements in both Genshin and Star Rail: `Physico`, `Anemo`, `Electro`, `Pyro`, `Cryo`.
        - Eula is considered a Physical character, despite her Cryo vision.
    - Star Rail exclusive elements: `Quanto`, `Imago`.
    - Genshin exclusive elements: `Geo`, `Hydro`, `Dendro`.
