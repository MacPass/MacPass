#MacPass

There are a lot of iOS KeePass tools around but a distinct lack of a good OS X version.
KeePass can be used via Mono on OS X but lacks vital functionality and feels sluggish.

MacPass is an attempt to create a native OS X port of KeePass.

##Disclaimer
The Project is in heavy development. Beware that I'm going to shift things around so stuff is going to break. A lot.

##Download

Since Github now provides a release feature, I'm trying to upload binaries for all the tags I create along the way.
Use it with caution, it's unfinished. Really!

All releases can be found at [Github](https://github.com/mstarke/MacPass/releases).

If you want to live dangerously and want to take a look at the master:

    git clone https://github.com/mstarke/MacPass
    cd MacPass
    git submodule init
    git submodule update

After that you can build and run in Xcode. If you run into signing issues take a look at [Issue #92](https://github.com/mstarke/MacPass/issues/92)

There have been some changes in the submodule urls. Please consider re-syncing and initalizing all submodules.

	git submodule sync
	git submodule init

##Known Major Issues

* Binary releases (0.2.x - 0.3.x):
  * KDBX DeletedObjects are stripped on save. This will break synchronisation features!
* Binary releases (since 0.4.x):
  * KDBX History is only preseverd. Editting doesn't create new history entries
  * Default Autotype Sequences will get stored although they shouldn't be stored
  * Default Autotype sequence is wrong ````{TAB}{USERNAME}{TAB}{PASSWORD}{ENTER}```` instead of ````{USERNAME}{TAB}{PASSWORD}{ENTER}````
  
##System Requirement

The minimum OS X version required for MacPass is currently 10.8 Mountain Lion.
Since 10.9 Mavericks is a free upgrade I have no plans to support 10.7 Lion.

##Status

The Status can be found on the dedicated [Wiki page](https://github.com/mstarke/MacPass/wiki/Status).

##What does it look like?

![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/MacPass.png)

More Screenshots in the [Wiki](https://github.com/mstarke/MacPass/wiki/Screenshots)

##Alternatives

[KeePassX](http://www.keepassx.org) is a Qt based KeePass port. The stable 0.4.3 release only supports the version 1 format. The Alpha can read database version 1 and 2 and write version 2 containers rather nicely.
It's in active development and open source. Since Alpha 4 the random password generator has found it's way back into the Alpha releases, version 0.4.3 includes one as well. The Alpha fully supports all database 2 features and should be stable enough for daily usage. It can import version 1 into a version 2 file but is unable to natively write version 1 files.

[KyPass Companion](http://www.kyuran.be/logiciels/kypass4mac/) is a native Cocoa port and offers KeePassHttp compatiblity.
Should be able to read and write database version 1 and 2. It is closed source and currently available in the Mac App Store. It's rather expensive considering the bugs and missing features. Based on the user reviews it should work. Not all version 2 features are supported. It is unable to convert between database versions.

[S3crets](http://s3crets.com/en/help/) native Cocoa Port with a different approach to displaying the database fully inside a tree.
It is able to read and write database version 1 and 2. Not all database features are fully supported.

## Help

Some questions might be ansered in the [FAQ](https://github.com/mstarke/MacPass/wiki/FAQ)

Another place to look is the IRC channel [#macpass](irc://irc.freenode.org/macpass) on [irc.freenode.org](irc://irc.freenode.org)

##License

MacPass, a KeePass compatible Password Manager for OS X
Copyright (c) 2012-2014  Michael Starke (HicknHack Software GmbH) and all [MacPass contributors](https://github.com/mstarke/MacPass/graphs/contributors)
  
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

##Contribtuions

[Iiro Jäppinen](https://iiro.jappinen.me) MacPass icon

[Gil André](mailto:gil@panix.com) French localizations

[Nathaniel Madura](mailto:nmadura@umich.edu) Refacotrings, first create Database 

[Kurt Legerlotz](https://github.com/lotz) Settings to open or copy URL on double click

[Adam Doppelt](mailto:amd@gurge.com) whitespace polish on EntryInspectorView, Autosave table sorting. Default to sort by title.

[Stephen Taylor](http://www.makegames.co.uk/) Fixed tab ordering

[Andrew Schleifer](mailto:me@andrewschleifer.name) Enable fullscreen option for document windows, Centralise the Validation, Only enable password entry fields when option is checked

[Frank Enderle](http://www.anamica.de/) Cmd+F now marks the text of the search field if the filterbar is already visible and sets the focus. Set remaining password fields to fixed width font.

[Josh Halstead](mailto:jhalstead85@gmail.com) Update Readme (typo)

[Chhom Seng](https://github.com/cseng) Fixed issue with blank outline and entry views if the inspector was hidden before unlocking the database. Implemented context menu validation for entry context menu.

[James Hurst](https://github.com/jamesrhurst) Obfuscated autotyping and restoring of pasteboard objects. Fixed issues when exiting search. Implemented workflow double click settings. Make selected textfield end editing when a save will occur. Finished custom browser support for open URL action. Percent escape strings before creating URLs. Fixed issues with Autotype key events. Added missing characters for password generation. Improved "Add Entry" workflow. Fixed bug with icon resetting to default after closing popover. Added ability to set default password generation settings. Made autotype work in more situations

##Copyright

This Project is based upon the following work:

[KissXML](https://github.com/robbiehanson/KissXML) Copyright 2012 Robbie Hanson. All rights reserved.

[MiniKeePass](https://github.com/MiniKeePass/MiniKeePass) Copyright 2011 Jason Rush and John Flanagan. All rights reserved.

[KeePass Database Library](https://github.com/mpowrie/KeePassLib) Copyright 2010 Qiang Yu. All rights reserved.

[PXSourceList](https://github.com/Perspx/PXSourceList) Copyright 2011, Alex Rozanski. All rights reserved.

[CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer ) Copyright 2011, Deusty, LLC. All rights reserved.

[KSPasswordField](https://github.com/karelia/SecurityInterface) Copyright 2012 Mike Abdullah, Karelia Software. All rights reserved.

[DDHotKey](https://github.com/davedelong/DDHotKey) Copyright [Dave DeLong](http://www.davedelong.com). All rights reserved.

[Sparkle](http://sparkle.andymatuschak.org) Copyright 2006 Andy Matuschak

[TransformerKit](https://github.com/mattt/TransformerKit) Licensed under MIT license. Copyright 2012 [Mattt Thompson](http://mattt.me/). All rights reseverd

[MJGFoundation](https://github.com/mstarke/MJGFoundation) Licensed under BSD 2-Clause License. Copyright 2011 [Matt Galloway](http://www.galloway.me.uk/). All rights reserved.

[ShortcutRecorder](http://wafflesoftware.net/shortcut/) Copyright 2006—2013 all [Shortcut Recorder contributors](http://wafflesoftware.net/shortcut/contributors/) 

See submodules for additional Licenses

##Feedback

[![Flattr this](http://api.flattr.com/button/flattr-badge-large.png)](http://flattr.com/thing/1550529/mstarkeMacPass-on-GitHub)
