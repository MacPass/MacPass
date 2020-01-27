# Contribute to MacPass

Thanks for taking the time to contribute to MacPass! This documents describes a few guidelines for contributing. When in doubt about how to contribute, ask another contributor.

## Translations
MacPass has translations for a few languages. If you can translate to another language, or you think a translation is wrong, follow the next steps to add or improve a translation:

- Get a XLIFF editor for translating localization files. For example [XLIFFTool](https://itunes.apple.com/us/app/xlifftool/id1074282695)
- Get the current XLIFF export for your language. You can either download the `Localizations.zip` on the [Continous release](https://github.com/MacPass/MacPass/releases) or you can export them in Xcode:
  - For a new localization only:
    - Select MacPass in the project navigator
    - Select the MacPass project in the project and targets list
    - Open the info tab and click the `+` button un the localizations section.
    - Choose the language you want to translate
    - Select all resources and click finish, now the new language is available for export in the next step
  - For present localizations directly Export the XLIFF file
    - Select the MacPass project in Xcode
    - Go to `Editor -> Export for Localization`
    - Select the language you want to translate
- Now use your XLIFF editor and save the file after you are done with your translations
- Go back to XCode and use `Editor -> Import Localization` to import the changes
- Open a Pull Request with your changes.

Alternatively, you can open an issue to ask a dev to create the XLIFF file for you and send it back after you've finished localising.
