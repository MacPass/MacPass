//
//  MPEntryMenuDelegate.m
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryContextMenuDelegate.h"
#import "MPEntryViewController.h"

#import "Kdb4Node.h"

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
  
  if([self.viewController.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entry = (Kdb4Entry *)self.viewController.selectedEntry;
    if([entry.stringFields count] > 0) {
      [menu addItem:[NSMenuItem separatorItem]];
      NSMenuItem *customFieldsItem = [[NSMenuItem alloc] init];
      NSMenu *submenu = [[NSMenu alloc] initWithTitle:@"Fields"];
      [customFieldsItem setTitle:NSLocalizedString(@"COPY_CUSTOM_FIELDS", "Submenu to Copy custom fields")];
      [customFieldsItem setTag:kMPCustomFieldMenuItem];
      for (StringField *field in entry.stringFields) {
        NSString *title = [NSString stringWithFormat:NSLocalizedString(@"COPY_FIELD_%@", "Mask for title to copy field value"), field.key];
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(copyCustomField:) keyEquivalent:@""];
        [item setTag:[entry.stringFields indexOfObject:field]];
        [submenu addItem:item];
      }
      [customFieldsItem setSubmenu:submenu];
      [menu addItem:customFieldsItem];
    }
  }
}

@end
