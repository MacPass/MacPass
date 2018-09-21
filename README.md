[![Build Status](https://travis-ci.org/MacPass/MacPass.svg?branch=continuous)](https://travis-ci.org/MacPass/MacPass)

# MacPass

There are a lot of iOS KeePass tools around but a distinct lack of a good native macOS version.
KeePass can be used via Mono on macOS but lacks vital functionality and feels sluggish and simply out of place.

MacPass is an attempt to create a native macOS port of KeePass on a solid open source foundation with a vibrant community pushing it further to become the best KeePass client for macOS.

## Download

All pre-built releases can be found at [Github](https://github.com/mstarke/MacPass/releases).

An unsigned build of the current contiuous tag can be found here: [Continuous Build](https://github.com/mstarke/MacPass/releases/tag/continuous)

Due to the nature of the build it might be unstable, however this version contains all the latest changes and bug fixes!

## How to Contribute

If you want to contribute by fixing a bug, adding a feature or improving localization you're awesome!

## How to Build

* Fetch the source of MacPass
```bash
git clone https://github.com/mstarke/MacPass --recursive
```
* Install [Carthage](https://github.com/Carthage/Carthage#installing-carthage)
* Install all Dependencies
```bash
cd MacPass
carthage bootstrap --platform macOS
```
After that you can build and run in Xcode. The following command will build and make the application available through Spotlight. If you run into signing issues take a look at [Issue #92](https://github.com/mstarke/MacPass/issues/92). Since Sparkle is disabled only on the CI build and in Debug mode, you have to explicitly disable it in Release. Otherwise warnings on unsecure updates will appear.

    xcodebuild -scheme MacPass -target MacPass -configuration Release CODE_SIGNING_REQUIRED=NO NO_SPARKLE=NO_SPARKLE

## Help

Some questions might be ansered in the [FAQ](https://github.com/mstarke/MacPass/wiki/FAQ)

Another place to look is the IRC channel [#macpass](irc://irc.freenode.org/macpass) on [irc.freenode.org](irc://irc.freenode.org)

Or follow the Twitter account [@MacPassApp](https://twitter.com/MacPassApp)

## System Requirement

MacPass 0.7 requires macOS 10.10 Yosemite or later.
Earlier versions of MacPass require macOS 10.8 Mountain Lion or later.

## Status

The Status can be found on the dedicated [Wiki page](https://github.com/mstarke/MacPass/wiki/Status).

## What does it look like?

![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/MacPass.png)

More Screenshots in the [Wiki](https://github.com/mstarke/MacPass/wiki/Screenshots)

## Alternatives
 
[KeePassX](https://www.keepassx.org) and it's fork [KeePassXC](https://github.com/keepassxreboot/keepassxc). Qt based cross plattform port.

[KyPass Companion](http://www.kyuran.be/logiciels/kypass4mac/). Native macOS client.

[KeeWeb](https://keeweb.info). Electron based cross plattform port. Since it's browser based you can pretty much run it anywhere.

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

The following list might not be complete, please refer to [merged Pull Requests](https://github.com/mstarke/MacPass/pulls?utf8=✓&q=is%3Apr+is%3Aclosed+is%3Amerged) on GitHub for more details. Please open an issue if you think someone is missing from this list!

### Art

[Iiro Jäppinen](https://iiro.jappinen.me) MacPass icon

[Thom Williams](https://github.com/thomscode) Document icons

[Joanna Olsen](https://github.com/JoannaOlsen) Database Icons

### Contributors

[ad](github.mnms@mamber.net)
[Alex Borisov](alex@alexborisov.org)
[Alex Seeholzer](seeholzer@gmail.com)
[amd](amd@gurge.com)
[Andrew Schleifer](me@andrewschleifer.name)
[AntoineCa](antoine@carrincazeaux.fr)
[Benjamin Steinwender](b@stbe.at)
[binarious](bieder.martin@googlemail.com)
[Carlos Filipe Simões](ravemir@users.noreply.github.com)
[Chester Liu](skyline75489@outlook.com)
[Chhom Seng](chhom.seng@gmail.com)
[Christoph Leimbrock](christoph.leimbrock@gmx.de)
[Cory Hutchison](cjhutchi@users.noreply.github.com)
[Daniele Polencic](daniele.polencic@gmail.com)
[darnel](vojta.j@gmail.com)
[Deiwin Sarjas](deiwin.sarjas@gmail.com)
[Dennis Bolio](git@bolio.nl)
[Dylan Smith](dylansmith@gmail.com)
[eiermaaaan](37532252+eiermaaaan@users.noreply.github.com)
[Filipe Farinha](filipe@ktorn.com)
[floriangouy](florian.gouy@gmail.com)
[Francesco Servida](info@francescoservida.ch)
[Frank Enderle](frank.enderle@anamica.de)
[Frank Kooij](FrankKooij@users.noreply.github.com)
[Gaétan Ryckeboer](gryckeboer@jouve.com)
[Geigi](git@geigi.de)
[Henri de Jong](henridejong@gmail.com)
[James Hurst](jamesrhurst@outlook.com)
[Jannick Hemelhof](mister.jannick@gmail.com)
[Jefftree](jeffrey.ying86@live.com)
[Jellyfrog](Jellyfrog@users.noreply.github.com)
[Joanna Olsen](jo4flash@gmail.com)
[Josh Halstead](jhalstead85@gmail.com)
[Kurt](kurt@soapbox-software.com)
[Lenucksi](lenucksi@users.noreply.github.com)
[Leonardo Faoro](lfaoro@users.noreply.github.com)
[Liam Anderson](liam.anderson.91@gmail.com)
[Maarten Terpstra](m.l.terpstra@student.rug.nl)
[Mario Sangiorgio](mariosangiorgio@gmail.com)
[MBibal](michel.bibal@gmail.com)
[Michael Belz](mbelz@outlook.de)
[MichaelKo](viacheslav.sychov@gmail.com)
[Michal Jaglewicz](michalj@webii.pl)
[Moises Perez](moises@perez.lt)
[mrdoggy](mrdoggy.all@gmail.com)
[Nathan Landis](nathanlandis@gmail.com)
[Nathaniel Madura](nmadura@umich.edu)
[neuroine](d.dzieduch@gmail.com)
[Patrik Thunström](magebarf@gmail.com)
[rdoering](rdoering.info@gmail.com)
[Ryan Rogers](ryan@timewasted.me)
[Sitsofe Wheeler](sitsofe@yahoo.com)
[Stephen Taylor](schtee.taylor@gmail.com)
[Thom](thomscode@gmail.com)
[Thorsten Jacoby](tjacoby@gmail.com)
[Volcyy](Volcyy@users.noreply.github.com)
[Yonatan Mittlefehldt](yono@toojuice.com)
[Zero King](l2dy@icloud.com)
[Zhao Peng](patchao2000@gmail.com)

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
