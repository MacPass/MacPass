//
//  MPAddEntryContextMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 30.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "MPAddEntryContextMenuDelegate.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPActionHelper.h"

#import "KPKEntry.h"
#import "KPKGroup.h"

#define EDIT_TEMPLATES_ITEM_TAG 10;

@implementation MPAddEntryContextMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
  /*
   The Method is rather brute force
   It's possible nicer to cache the entries and just update
   the menu entries, that actually need updating
   */
  MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  if(!document) {
    [menu removeAllItems];
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"EDIT_TEMPLATE_GROUP", "") action:[MPActionHelper actionOfType:MPActionEditTemplateGroup] keyEquivalent:@""];

  [menu addItem:[NSMenuItem separatorItem]];
  for(KPKEntry *entry in [document.templates childEntries]) {
    NSString *templateMask = NSLocalizedString(@"NEW_ENTRY_WITH_TEMPLATE_%@", "");
    NSMenuItem *templateItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[NSString stringWithFormat:templateMask, entry.title]
                                                                                    action:@selector(createEntryFromTemplate:)
                                                                             keyEquivalent:@""];
    [templateItem setRepresentedObject:entry.uuid];
    [menu addItem:templateItem];
  }
  /* If there are no entries, add a note as disabled menu item */
  if([[menu itemArray] count] == 2) {
    [menu addItemWithTitle:NSLocalizedString(@"NO_TEMPLATES", "") action:NULL keyEquivalent:@""];
  }
}

@end
