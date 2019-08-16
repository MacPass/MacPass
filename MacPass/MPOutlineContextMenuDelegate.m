//
//  MPOutlineMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 29.07.13.
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

#import "MPOutlineContextMenuDelegate.h"
#import "MPOutlineViewController.h"
#import "MPDocumentWindowController.h"

#import "MPDocument.h"

#import "MPActionHelper.h"
#import "MPContextMenuHelper.h"

#import "KeePassKit/KeePassKit.h"

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
  if( [item isKindOfClass:KPKTree.class]) {
    [self _updateRootMenu:menu];
  }
  
  if( [item isKindOfClass:KPKGroup.class]) {
    KPKGroup *group = (KPKGroup *)item;
    MPDocument *document = NSDocumentController.sharedDocumentController.currentDocument;
    if(group && document.root == group ) {
      
    }
    if(group.isTrash) {
      [self _updateTrashMenu:menu];
    }
    else if( group && document.templates == group) {
      [self _updateTemplateMenu:menu];
    }
    else if(group.isTrashed) {
      [self _updateTrashItemMenu:menu];
    }
    else {
      [self _updateDefaultMenu:menu];
    }
  }
}

- (void)_updateRootMenu:(NSMenu *)menu {
  if([menu.title isEqualToString:_MPOutlineMenuRoot]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"CHANGE_DATABASE_NAME", "Menu item in the database outline context menu to change the database name")
                  action:[MPActionHelper actionOfType:MPActionDatabaseSettings]
           keyEquivalent:@""];
  
  menu.title = _MPOutlineMenuRoot;
}

- (void)_updateTrashMenu:(NSMenu *)menu {
  if([menu.title isEqualToString:_MPOutlineMenuTrash]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"CHANGE_TRASH_GROUP", "Menu item in the database outline context menu to change the trash group")
                  action:@selector(editTrashGroup:)
           keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:NSLocalizedString(@"EMPTY_TRASH", "Menu item in the database outline context menu to empyt the trash")
                  action:[MPActionHelper actionOfType:MPActionEmptyTrash]
           keyEquivalent:@""];
  
  menu.title = _MPOutlineMenuTrash;
}

- (void)_updateTrashItemMenu:(NSMenu *)menu {
  if([menu.title isEqualToString:_MPOutlineMenuTrashItem]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"DELETE", "Menu item in the database outline context menu to delete the node from the trash")
                  action:[MPActionHelper actionOfType:MPActionDelete]
           keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItemWithTitle:NSLocalizedString(@"EMPTY_TRASH", "Menu item in the database outline to empty the trash")
                  action:[MPActionHelper actionOfType:MPActionEmptyTrash]
           keyEquivalent:@""];
  
  menu.title = _MPOutlineMenuTrashItem;
}

- (void)_updateTemplateMenu:(NSMenu *)menu {
  if([menu.title isEqualToString:_MPOutlineMenuTemplate]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  [menu addItemWithTitle:NSLocalizedString(@"EDIT_TEMPLATE_GROUP", "Menu item in the database outline context menu to change the template group")
                  action:[MPActionHelper actionOfType:MPActionEditTemplateGroup]
           keyEquivalent:@""];
  [menu addItem:[NSMenuItem separatorItem]];
  for(NSMenuItem *item in [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuMinimal]) {
    [menu addItem:item];
  }
  menu.title = _MPOutlineMenuTemplate;
}


- (void)_updateDefaultMenu:(NSMenu *)menu {
  if([menu.title isEqualToString:_MPOutlineMenuDefault]) {
    return; // nothing to do, all fine
  }
  [menu removeAllItems];
  for(NSMenuItem *item in [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuMinimal]) {
    [menu addItem:item];
  }
}

@end
