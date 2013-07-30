//
//  MPOutlineMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 29.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPOutlineContextMenuDelegate.h"
#import "MPOutlineViewController.h"

#import "MPRootAdapter.h"
#import "MPDocument.h"

#import "MPActionHelper.h"
#import "MPContextMenuHelper.h"

#import "Kdb.h"

NSString *const _MPOutlineMenuDefault = @"Default";
NSString *const _MPOutlineMenuTrash = @"Trash";
NSString *const _MPOutlineMenuTrashItem = @"TrashItem";
NSString *const _MPOutlineMenuRoot = @"Root";
NSString *const _MPOutlineMenuTemplate = @"Template";

@implementation MPOutlineContextMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
  /*
   Scenarios are
   
   1. Root adapter
   2. Normal Group
   3. Template Group
   4. Trash Group
   5. Trashed Item
   */
  
  id item = [self.viewController itemUnderMouse];
  if( [item isKindOfClass:[MPRootAdapter class]]) {
    [self _updateRootMenu:menu];
  }
  
  if( [item isKindOfClass:[KdbGroup class]]) {
    KdbGroup *group = (KdbGroup *)item;
    MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
    if(group && document.trash == group) {
      [self _updateTrashMenu:menu];
    }
    else if( group && document.templates == group) {
      [self _updateTemplateMenu:menu];
    }
    else if([document isItemTrashed:group]) {
      [self _updateTrashItemMenu:menu];
    }
    else {
      [self _updateDefaultMenu:menu];
    }
  }
}

- (void)_updateRootMenu:(NSMenu *)menu {
  if([[menu title] isEqualToString:_MPOutlineMenuRoot]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"CHANGE_DATABASE_NAME", "")
                  action:[MPActionHelper actionOfType:MPActionDatabaseSettings]
           keyEquivalent:@""];
  
  [menu setTitle:_MPOutlineMenuRoot];
}

- (void)_updateTrashMenu:(NSMenu *)menu {
  if([[menu title] isEqualToString:_MPOutlineMenuTrash]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"CHANGE_TRASH_GROUP", "")
                  action:@selector(editTrashGroup:)
           keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:NSLocalizedString(@"EMPTY_TRASH", "")
                  action:[MPActionHelper actionOfType:MPActionEmptyTrash]
           keyEquivalent:@""];
  
  [menu setTitle:_MPOutlineMenuTrash];
}

- (void)_updateTrashItemMenu:(NSMenu *)menu {
  if([[menu title] isEqualToString:_MPOutlineMenuTrashItem]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"DELETE", "")
                  action:[MPActionHelper actionOfType:MPActionDelete]
           keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:NSLocalizedString(@"EMPTY_TRASH", "")
                  action:[MPActionHelper actionOfType:MPActionEmptyTrash]
           keyEquivalent:@""];
  
  [menu setTitle:_MPOutlineMenuTrashItem];
}

- (void)_updateTemplateMenu:(NSMenu *)menu {
  if([[menu title] isEqualToString:_MPOutlineMenuTemplate]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"EDIT_TEMPLATE_GROUP", "")
                  action:[MPActionHelper actionOfType:MPActionEditTemplateGroup]
           keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  for(NSMenuItem *item in [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuMinimal]) {
    [menu addItem:item];
  }
  [menu setTitle:_MPOutlineMenuTemplate];
}


- (void)_updateDefaultMenu:(NSMenu *)menu {
  if([[menu title] isEqualToString:_MPOutlineMenuDefault]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  for(NSMenuItem *item in [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuMinimal]) {
    [menu addItem:item];
  }
}

@end
