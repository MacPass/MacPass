#MacPass

There a lot of iOS KeePass tools around but a distinct lack of a good OS X Version.
KeePass can be used via Mono on OS X but lacks vital functionality and feels sluggish.

This is an attempt to create an OS X port that should at least be able to read KeePass files.

##Disclaimer

The Project is in heavy development and it's likely to take some time till it reaches a usable state.
Beware that I'm going to shift things around so stuff is going to break. A lot.

##Dowload

I'm trying to upload new builds along the way for all of you that just want to take a quick look.
As stated in the disclaimer, this software cannot be considered safe for work in it's current development status.
Use it with caution! Since I did start refactoring the KeePassLib there is even more potential broken code!

[Download MacPass at Dropbox](https://www.dropbox.com/sh/yqgfwi7f8mnd747/NCQlJmg0f0) (build 1164 06/26/2013)

##Help

I'm in constant need of a full set of Databases with all possible keyfile/password and format combinations.
If you are able to provide databases with keyfiles (Hashed, Binary, XML) I would love to hear from you!

##Requirement

MacPass needs OS X 10.8 as a minimum OS version since it takes advantage of some of the enhancements in Autolayout in 10.8.
It might be possible to target 10.7 but with the upcomming 10.9 release, I think 10.8 is a feasable minimum.

##Status

Take a look at the [Wiki](https://github.com/mstarke/MacPass/wiki/Status)

##Alternatives

Currently there is an alpha Version available of [KeePassX](http://www.keepassx.org).
It's Qt based KeePass manager, than can handle KeePass 1 and 2 containers rather nicely.
Compared to running KeePass with Mono it very fast and remarkably stable for an alpha relaese.
Feel free to give it a try. The biggest draw-back is it's inablity to create passwords via a wizzard.

##What does it look like?

![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/MacPass.png)
![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/PasswordGenerator.png)
![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/Locked.png)
![image](https://raw.github.com/mstarke/MacPass/master/Assets/Screenshots/Settings.png)

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
