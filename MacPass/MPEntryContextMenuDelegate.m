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

#import "KPKEntry.h"
#import "KPKAttribute.h"

static NSUInteger const kMPCustomFieldMenuItem = 1000;
static NSUInteger const kMPAttachmentsMenuItem = 2000;

@implementation MPEntryContextMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu {
  NSMenuItem *fieldsMenu = [menu itemWithTag:kMPCustomFieldMenuItem];
  NSMenuItem *attachmentsMenu = [menu itemWithTag:kMPAttachmentsMenuItem];
  if(fieldsMenu) {
    [menu removeItem:fieldsMenu];
  }
  if(attachmentsMenu) {
    [menu removeItem:attachmentsMenu];
  }
  
  NSMenuItem *lastItem = [[menu itemArray] lastObject];
  if([lastItem isSeparatorItem]) {
    [menu removeItem:lastItem];
  }
  /* since we can get opend on the non-selected entry, we have to resolve the target node */
  id<MPTargetNodeResolving> entryResolver = [NSApp targetForAction:@selector(currentTargetEntry)];
  KPKEntry *entry  = [entryResolver currentTargetEntry];

  if([entry.customAttributes count] > 0) {
    [menu addItem:[NSMenuItem separatorItem]];
    NSMenuItem *attributeItem = [[NSMenuItem alloc] init];
    NSMenu *submenu = [[NSMenu alloc] initWithTitle:@"Fields"];
    [attributeItem setTitle:NSLocalizedString(@"COPY_CUSTOM_FIELDS", "Submenu to Copy custom fields")];
    [attributeItem setTag:kMPCustomFieldMenuItem];
    for (KPKAttribute *attribute in entry.customAttributes) {
      NSString *title = [NSString stringWithFormat:NSLocalizedString(@"COPY_FIELD_%@", "Mask for title to copy field value"), attribute.key];
      NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(copyCustomAttribute:) keyEquivalent:@""];
      [item setTag:[entry.customAttributes indexOfObject:attribute]];
      [submenu addItem:item];
    }
    [attributeItem setSubmenu:submenu];
    [menu addItem:attributeItem];
  }
}

@end
