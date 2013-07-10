#MacPass

There a lot of iOS KeePass tools around but a distinct lack of a good OS X Version.
KeePass can be used via Mono on OS X but lacks vital functionality and feels sluggish.

MacPass is an attempt to create an OS X port of KeePass.

##Disclaimer
The Project is in heavy development. Beware that I'm going to shift things around so stuff is going to break. A lot.

##Dowload

Since github now provieds a release feature, I'm trying to upload binaries on all the tags I create along the way.
Use it with caution, it's unfinished finished.

All releases can be found at [Github](https://github.com/mstarke/MacPass/releases) are server from Github.

##Known Major Issues

* Databas V1 handling is dodgy. (e.g. ttachments)

##System Requirement

The Minimum OS X Version for MacPass currently is 10.8 Mountain Lion.
With 10.9 Mavericks around the corner, I'm a bit hesitant to support 10.7 Lion.

##Status

The Status can be found on the dedicated [Wiki page](https://github.com/mstarke/MacPass/wiki/Status).

##What does it look like?

![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/MacPass.png)

More Screenshots in the [Wiki](https://github.com/mstarke/MacPass/wiki/Screenshots)

##Alternatives

[KeePassX](http://www.keepassx.org) is a Qt based KeePass port, than can read Databases Version 1 and 2 and write Version 2 containers rather nicely.
It's in active development, open source. Sadly there's only an older alpha binary release. It fully supports all database features.

[KyPass Companion](http://www.kyuran.be/logiciels/kypass4mac/) is a native Cocoa port and offers KeePassHttp compatiblity.
Should be able to read and write version 1 and 2 database. Is closed source and in early development. Beta releases have an expiry date. Not all database features are fully supported.

[S3crets](http://s3crets.com/en/help/) native Cocoa Port with a different approach to displaying the database fully inside a tree.
Is able to read and write version 1 and 2 databases. Not all database features are fully supported.

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
