//
//  MPEntryMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryContextMenuDelegate.h"
#import "MPDocument.h"

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
  MPDocument *document = [[NSDocumentController sharedDocumentController] currentDocument];
  
  KPKEntry *entry = document.selectedEntry;
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
