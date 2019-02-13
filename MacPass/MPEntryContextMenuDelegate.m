//
//  MPEntryContextMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
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

#import "MPEntryContextMenuDelegate.h"
#import "MPEntryViewController.h"

#import "KeePassKit/KeePassKit.h"

static NSUInteger const kMPCustomFieldMenuItem = 1000;
static NSUInteger const kMPAttachmentsMenuItem = 2000;
static NSUInteger const kMPCopyAsReferenceMenuItem = 3000;

@implementation MPEntryContextMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
  NSMenuItem *fieldsMenu = [menu itemWithTag:kMPCustomFieldMenuItem];
  NSMenuItem *attachmentsMenu = [menu itemWithTag:kMPAttachmentsMenuItem];
  NSMenuItem *copyReferenceMenu = [menu itemWithTag:kMPCopyAsReferenceMenuItem];
  if(fieldsMenu) {
    [menu removeItem:fieldsMenu];
  }
  if(attachmentsMenu) {
    [menu removeItem:attachmentsMenu];
  }
  if(copyReferenceMenu) {
    [menu removeItem:copyReferenceMenu];
  }
  
  NSMenuItem *lastItem = menu.itemArray.lastObject;
  if([lastItem isSeparatorItem]) {
    [menu removeItem:lastItem];
  }
  /* since we can get opened on the non-selected entry, we have to resolve the target node */
  id<MPTargetNodeResolving> entryResolver = [NSApp targetForAction:@selector(currentTargetEntries)];
  NSArray *entries  = [entryResolver currentTargetEntries];
  if(entries.count != 1) {
    return;
  }
  KPKEntry *entry = entries.lastObject;
  if(entry) {
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *copyReferenceItem = [[NSMenuItem alloc] init];
    copyReferenceItem.title = NSLocalizedString(@"COPY_AS_REFERENCE", "Submenu to copy attributes as reference");
    copyReferenceItem.tag = kMPCopyAsReferenceMenuItem;
    NSMenu *subMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"COPY_AS_REFERENCE_MENU", "Context menu sub-menu to copy attributes as reference")];
    
    NSDictionary *references = @{  kKPKReferenceURLKey: NSLocalizedString(@"COPY_URL_REFERENCE", "Context menu that copies reference to URL"),
                                   kKPKReferenceNotesKey: NSLocalizedString(@"COPY_NOTES_REFERENCE", "Context menu that copies reference to note"),
                                   kKPKReferenceTitleKey: NSLocalizedString(@"COPY_TITLE_REFERENCE", "Context menu that copies reference to title"),
                                   kKPKReferencePasswordKey: NSLocalizedString(@"COPY_PASSWORD_REFERENCE", "Context menu that copies reference to password"),
                                   kKPKReferenceUsernameKey: NSLocalizedString(@"COPY_USERNAME_REFERENCE", "Context menu that copies reference to username"),
                                   };
    for(NSString *key in references) {
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:references[key] action:@selector(copyAsReference:) keyEquivalent:@""];
      item.representedObject = key;
      [subMenu addItem:item];
    }
    
    copyReferenceItem.representedObject = entry.uuid.UUIDString;
    copyReferenceItem.submenu = subMenu;
    [menu addItem:copyReferenceItem];
  }
  if(entry.customAttributes.count > 0) {
    NSMenuItem *attributeItem = [[NSMenuItem alloc] init];
    NSMenu *submenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"COPY_CUSTOM_FIELDS_MENU", @"Context menu sub-menu to copy custom fields to clipboard")];
    attributeItem.title = NSLocalizedString(@"COPY_CUSTOM_FIELDS", "Submenu to Copy custom fields");
    attributeItem.tag = kMPCustomFieldMenuItem;
    for (KPKAttribute *attribute in entry.customAttributes) {
      NSString *title = [NSString stringWithFormat:NSLocalizedString(@"COPY_FIELD_%@", "Mask for title to copy field value"), attribute.key];
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(copyCustomAttribute:) keyEquivalent:@""];
      item.tag = [entry.customAttributes indexOfObject:attribute];
      [submenu addItem:item];
    }
    attributeItem.submenu = submenu;
    [menu addItem:attributeItem];
  }
}

@end
