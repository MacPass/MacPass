#MacPass

There a lot of iOS KeePass tools around but a distinct lack of a good OS X Version.
KeePass can be used via Mono on OS X but lacks vital functionality and feels sluggish.

MacPass is an attempt to create an OS X port of KeePass.

##Disclaimer
The Project is in heavy development. Beware that I'm going to shift things around so stuff is going to break. A lot.

##Download

Since Github now provides a release feature, I'm trying to upload binaries on all the tags I create along the way.
Use it with caution, it's unfinished. Really!

All releases can be found at [Github](https://github.com/mstarke/MacPass/releases).

If you want to live dangerously and want to take a look at the master:

    git clone https://github.com/mstarke/MacPass
    cd MacPass
    git submodule init
    git submodule update

After that you can build and run in XCode. If you run into signing issues take a look at [Issue #92](https://github.com/mstarke/MacPass/issues/92)

##Known Major Issues

* **Currently Search is broken in master, as the interface is in limbo!**
* Binary releases (0.2.x - 0.3.x):
  * KDBX DeletedObjects are stripped on save. This will break synchronisation features!
* All Versions (including master branch)
  * KDBX History is not supported
  
##System Requirement

The Minimum OS X Version for MacPass currently is 10.8 Mountain Lion.
Since 10.9 Mavericks is a free upgrade I have no plans to support 10.7 Lion.

##Status

The Status can be found on the dedicated [Wiki page](https://github.com/mstarke/MacPass/wiki/Status).

##What does it look like?

![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/MacPass.png)

More Screenshots in the [Wiki](https://github.com/mstarke/MacPass/wiki/Screenshots)

##Alternatives

[KeePassX](http://www.keepassx.org) is a Qt based KeePass port, than can read database version 1 and 2 and write version 2 containers rather nicely.
It's in active development, open source. Alpha 5 is out and now includes the previously missing password generator. It fully supports all database features and should be stable enough for daily usage. It can import version 1 into a version 2 file but is unable to natively write version 1 files.

[KyPass Companion](http://www.kyuran.be/logiciels/kypass4mac/) is a native Cocoa port and offers KeePassHttp compatiblity.
Should be able to read and write database version 1 and 2. It is closed source and currently available in the Mac App Store. It's rather expensive considering the bugs and missing features. Based on the user reviews it should work. Not all version 2 features are supported. It is unable to convert between database versions.

[S3crets](http://s3crets.com/en/help/) native Cocoa Port with a different approach to displaying the database fully inside a tree.
It is able to read and write database version 1 and 2. Not all database features are fully supported.

## Help

You might get help in the IRC channel [#macpass](irc://irc.freenode.org/macpass) on [irc.freenode.org](irc://irc.freenode.org)

##License

MacPass KeePass compatible client for OS X
Copyright (c) 2012-2013  Michael Starke, HicknHack Software GmbH
  
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

##Copyright

This Project is based upon the following work:

[KissXML](https://github.com/robbiehanson/KissXML) Copyright 2012 Robbie Hanson. All rights reserved.

[MiniKeePass](https://github.com/MiniKeePass/MiniKeePass) Copyright 2011 Jason Rush and John Flanagan. All rights reserved.

[KeePass Database Library](https://github.com/mpowrie/KeePassLib) Copyright 2010 Qiang Yu. All rights reserved.

[PXSourceList](https://github.com/Perspx/PXSourceList) Copyright 2011, Alex Rozanski. All rights reserved.

[CocoaHTTPServer](https://github.com/robbiehanson/CocoaHTTPServer ) Copyright 2011, Deusty, LLC. All rights reserved.

[KSPasswordField](https://github.com/karelia/SecurityInterface) Copyright 2012 Mike Abdullah, Karelia Software. All rights reserved.

[DDHotKey](https://github.com/davedelong/DDHotKey) Copyright Dave DeLong http://www.davedelong.com. All rights reserved.

[Sparkle](http://sparkle.andymatuschak.org) Copyright 2006 Andy Matuschak

See submodules for additional Licenses

##Feedback

![Flattr this](http://api.flattr.com/button/flattr-badge-large.png)
