[![Build Status](https://travis-ci.org/mstarke/MacPass.svg?branch=continuous)](https://travis-ci.org/mstarke/MacPass)

# MacPass

There are a lot of iOS KeePass tools around but a distinct lack of a good native macOS version.
KeePass can be used via Mono on macOS but lacks vital functionality and feels sluggish and simply out of place.

MacPass is an attempt to create a native macOS port of KeePass on a solid open source foundation with a vibrant community pushing it further to become the best KeePass client for macOS.

## Download

All pre-built releases can be found at [Github](https://github.com/mstarke/MacPass/releases).

An unsigned build of the current contiuous tag can be found here: [Continuous Build](https://github.com/mstarke/MacPass/releases/tag/continuous)

Due to the nature of the build it might be unstable, however this version contains all the latest changes and bug fixes!

## How to Build

* Fetch the source of MacPass
```bash
git clone https://github.com/mstarke/MacPass --recursive
```
* Install [Carthage](https://github.com/Carthage/Carthage#installing-carthage)
* Install all Dependencies
```bash
carthage bootstrap --platform Mac
```
After that you can build and run in Xcode. The following command will build and make the application available through Spotlight. If you run into signing issues take a look at [Issue #92](https://github.com/mstarke/MacPass/issues/92)

    xcodebuild -scheme MacPass -target MacPass -configuration Release

There have been some changes in the submodule urls. Please consider re-syncing and initalizing all submodules.

	git submodule sync
	git submodule init

## Known Major Issues

* Binary releases (0.5.x):
  * KDBX History is only preserved. Editing doesn't create new history entries

## How to Contribute

If you want to contribute by fixing a bug, adding a feature or improving localization you're awesome. Please open a pull request!

## Help

Some questions might be ansered in the [FAQ](https://github.com/mstarke/MacPass/wiki/FAQ)

Another place to look is the IRC channel [#macpass](irc://irc.freenode.org/macpass) on [irc.freenode.org](irc://irc.freenode.org)

Or follow the Twitter account [@MacPassApp](https://twitter.com/MacPassApp)

## System Requirement

The minimum OS X version required for MacPass is currently 10.8 Mountain Lion.

## Status

The Status can be found on the dedicated [Wiki page](https://github.com/mstarke/MacPass/wiki/Status).

## What does it look like?

![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/MacPass.png)

More Screenshots in the [Wiki](https://github.com/mstarke/MacPass/wiki/Screenshots)

## Alternatives

[KeePassX](http://www.keepassx.org) is a Qt based KeePass port. It's in active development and open source. It fully supports all KDBX features and can import KDB into a KDBX file but is unable to safe as KDB. There's an older release that only handles KDB files. KDBX3.1 is fully supported, KDBX4.0 is currently unsupported.

[KeePassXC](https://github.com/keepassxreboot/keepassxc) straight from the project's README:
>KeePassXC is a fork of KeePassX that aims to incorporate stalled pull requests, features, and bug fixes that have never made it into the main KeePassX repository.

[KyPass Companion](http://www.kyuran.be/logiciels/kypass4mac/) is a native Cocoa port and offers KeePassHttp compatibility.
Should be able to read and write KDB and KDBX files. It is closed source and currently available in the Mac App Store. It's rather expensive considering the bugs and missing features. Based on the user reviews it should work. Not all KDBX features are supported. It is unable to convert between database versions. KDBX4.0 support is in development.

[KeeWeb](https://keeweb.info) is a cross platform web client in active development based on [electron](http://electron.atom.io) and thus also is available as an offline version for all major platforms. The project is open source. It supports all features of KDBX files but has no KDB support. Because of the technology its look is customizable, but the native one is quite pretty. Full KDBX 4 support is present. Performance for Argon2 requires WebAssembly.

## License

MacPass, a KeePass compatible Password Manager for OS X
Copyright (c) 2012-2017  Michael Starke (HicknHack Software GmbH) and all [MacPass contributors](https://github.com/mstarke/MacPass/graphs/contributors)

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of

MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

## App Store

Due to being licensed under GPLv3 it's not possible to publish a version of MacPass on the App Store.
For further details, take a look at the [explanation](https://www.fsf.org/news/2010-05-app-store-compliance) of the Free Software Foundation.

## Contributions

The following list might not be complete, please refer to [merged Pull Requests](https://github.com/mstarke/MacPass/pulls?utf8=✓&q=is%3Apr+is%3Aclosed+is%3Amerged) on GitHub for more details. Please report open an issue if you think someone is missing from this list!

### Art

[Iiro Jäppinen](https://iiro.jappinen.me) MacPass icon

[Thom Williams](https://github.com/thomscode) Document icons

[Joanna Olsen](https://github.com/JoannaOlsen) Database Icons

### Localization

[Gil André](mailto:gil@panix.com) and [Michel Bibal](https://github.com/MBibal) French localization

[Jannick Hemelhof](https://github.com/clone1612) Dutch localization

[Benjamin Steinwender](https://github.com/auge) German localization

[Francesco Servida](mailto:info@francescoservida.ch) Italian localization

[Michał Jaglewicz](http://www.webii.pl) Polish localization

[Alex Petkevich](mailto:alex@mrdoggy.info) Russian localization

[Zhao Peng](mailto:patchao2000@gmail.com) Simplified Chinese localization

[Moises Perez](https://github.com/m0yP) Spanish localization

### Other

[Jellyfrog](https://github.com/Jellyfrog) Asset file size optimization

[Nathaniel Madura](mailto:nmadura@umich.edu) Refacotrings, first create Database

[Kurt Legerlotz](https://github.com/lotz) Settings to open or copy URL on double click

[Adam Doppelt](mailto:amd@gurge.com) whitespace polish on EntryInspectorView, Autosave table sorting. Default to sort by title.

[Stephen Taylor](http://www.makegames.co.uk/) Fixed tab ordering

[Andrew Schleifer](mailto:me@andrewschleifer.name) Enable fullscreen option for document windows, Centralise the Validation, Only enable password entry fields when option is checked

[Frank Enderle](http://www.anamica.de/) Cmd+F now marks the text of the search field if the filterbar is already visible and sets the focus. Set remaining password fields to fixed width font.

[Josh Halstead](mailto:jhalstead85@gmail.com) and [Sebastian Lövdahl](https://github.com/slovdahl) Fixed typos in Readme

[Chhom Seng](https://github.com/cseng) Fixed issue with blank outline and entry views if the inspector was hidden before unlocking the database. Implemented context menu validation for entry context menu.

[James Hurst](https://github.com/jamesrhurst) Obfuscated autotyping and restoring of pasteboard objects. Fixed issues when exiting search. Implemented workflow double click settings. Make selected textfield end editing when a save will occur. Finished custom browser support for open URL action. Percent escape strings before creating URLs. Fixed issues with Autotype key events. Added missing characters for password generation. Improved "Add Entry" workflow. Fixed bug with icon resetting to default after closing popover. Added ability to set default password generation settings. Made autotype work in more situations. Fixed various issues with Sparkle.

[Yono Mittlefehldt](https://twitter.com/yonomitt) Added 90 days expiration preset.

[Dennis Bolio](https://github.com/dennisbolio) Fixes issues with icon selection

[Mario Sangiorgio](mailto:mariosangiorgio@gmail.com) Improved password generation, Improved English localization

[Michael Belz](https://github.com/sub0ne) Fixed MacPass not opening any window, when lastly opened Database is missing.

## Copyright

This Project is based upon the following work:

[KeePassKit](https://github.com/mstarke/KeePassKit) Copyright 2012 HicknHack Software GmbH. All rights reserved.

[HNHUi](https://github.com/mstarke/HNHUi) Copyright 2012 HicknHack Software GmbH. All rights reserved.

[MiniKeePass](https://github.com/MiniKeePass/MiniKeePass) Copyright 2011 Jason Rush and John Flanagan. All rights reserved.

[KeePass Database Library](https://github.com/mpowrie/KeePassLib) Copyright 2010 Qiang Yu. All rights reserved.

[PXSourceList](https://github.com/Perspx/PXSourceList) Copyright 2011, Alex Rozanski. All rights reserved.

[KSPasswordField](https://github.com/karelia/SecurityInterface) Copyright 2012 Mike Abdullah, Karelia Software. All rights reserved.

[DDHotKey](https://github.com/davedelong/DDHotKey) Copyright [Dave DeLong](http://www.davedelong.com). All rights reserved.

[Sparkle](http://sparkle.andymatuschak.org) Copyright 2006 Andy Matuschak

[TransformerKit](https://github.com/mattt/TransformerKit) Licensed under MIT license. Copyright 2012 [Mattt Thompson](http://mattt.me/). All rights reserved

[MJGFoundation](https://github.com/mstarke/MJGFoundation) Licensed under BSD 2-Clause License. Copyright 2011 [Matt Galloway](http://www.galloway.me.uk/). All rights reserved.

[ShortcutRecorder](http://wafflesoftware.net/shortcut/) Copyright 2006—2013 all [Shortcut Recorder contributors](http://wafflesoftware.net/shortcut/contributors/)

[NSBundle Codesignature Check](http://jedda.me/2012/03/verifying-plugin-bundles-using-code-signing/) Copyright 2014 [Jedda Wignall](http://jedda.me). All rights reserved.

See submodules for additional Licenses

## Feedback

[![Flattr this](https://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/thing/1550529/mstarkeMacPass-on-GitHub)
