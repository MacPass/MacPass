#MacPass

There a lot of iOS KeePass tools around but a distinct lack of a good OS X Version.
KeePass can be used via Mono on OS X but lacks vital functionality and feels sluggish.

This is an attempt to create an OS X port that should at least be able to read KeePass files.

##Disclaimer

The Project is in heavy development and it's likely to take some time till it reaches a usable state.
Beware that I'm going to shift things around so stuff is going to break. A lot.

##Status

A rough overview, of what works (or at least I think does)

###Data handling

* Open/Save Kdbx and Kdb Databases.
* Undo/Redo on all supported Edit operations
* Groups
 * Add/Remove/Move
 * Edit Name
* Entries
 * Add/Remove/Move
 * Edit Title, Username, Password, URL
* Clear pasteboard on quit/after timeout
* Search for Username/Title/Url

###UI

* Drag'n'Drop of groups in outline
* Double click to quick copy entry values (Username,Password,URL)

##Alternatives

Currently there is an alpha Version available of [KeePassX](http://www.keepassx.org).
It's Qt based KeePass manager, than can handle KeePass 1 and 2 containers rather nicely.
Compared to running KeePass with Mono it very fast and remarkably stable for an alpha relaese.
Feel free to give it a try. The biggest draw-back is it's inablity to create passwords via a wizzard.

##What does it look like?

![image](https://raw.github.com/mstarke/MacPass/master/Assets/MacPass.png)

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
