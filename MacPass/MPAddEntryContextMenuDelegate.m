//
//  MPAddEntryContextMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 30.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAddEntryContextMenuDelegate.h"
#import "MPDocument.h"
#import "MPDocumentWindowController.h"
#import "MPActionHelper.h"

#import "KdbGroup+MPTreeTools.h"

#define EDIT_TEMPLATES_ITEM_TAG 10;

@implementation MPAddEntryContextMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
  /*
   The Method is rather brute force
   It's possible nicer to cache the entries and just update
   the menu entries, that actuyll need updating
   */
  MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  if(!document) {
    [menu removeAllItems];
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"EDIT_TEMPLATE_GROUP", "") action:[MPActionHelper actionOfType:MPActionEditTemplateGroup] keyEquivalent:@""];

  [menu addItem:[NSMenuItem separatorItem]];
  for(KdbEntry *entry in [document.templates childEntries]) {
    NSString *templateMask = NSLocalizedString(@"NEW_ENTRY_WITH_TEMPLATE_%@", "");
    NSMenuItem *templateItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:[NSString stringWithFormat:templateMask, entry.title]
                                                                                    action:@selector(createEntryFromTemplate:)
                                                                             keyEquivalent:@""];
    [templateItem setRepresentedObject:entry];
    [menu addItem:templateItem];
  }
  /* If there are no entries, add a note as disabled menu item */
  if([[menu itemArray] count] == 2) {
    [menu addItemWithTitle:NSLocalizedString(@"NO_TEMPLATES", "") action:NULL keyEquivalent:@""];
  }
}

@end
