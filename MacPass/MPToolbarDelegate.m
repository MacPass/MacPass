//
//  MPToolbarDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPToolbarDelegate.h"

NSString *const MPToolbarItemAddGroup = @"AddGroup";
NSString *const MPToolbarItemAddEntry = @"AddEntry";
NSString *const MPToolbarItemEdit = @"Edit";
NSString *const MPToolbarItemDelete =@"Delete";

@interface MPToolbarDelegate()

@property (retain) NSMutableDictionary *toolbarItems;
@property (retain) NSArray *toolbarIdentifiers;
@property (retain) NSDictionary *toolbarImages;

@end

@implementation MPToolbarDelegate


- (id)init
{
  self = [super init];
  if (self) {
    self.toolbarIdentifiers = @[ MPToolbarItemAddEntry, MPToolbarItemDelete, MPToolbarItemEdit, MPToolbarItemAddGroup ];
    self.toolbarItems = [NSMutableDictionary dictionaryWithCapacity:[self.toolbarItems count]];
    self.toolbarImages = [self createToolbarImages];
  }
  return self;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *item = self.toolbarItems[ itemIdentifier ];
  if( !item ) {
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    [item setImage:self.toolbarImages[itemIdentifier]];
    
    NSString *label = NSLocalizedString(itemIdentifier, @"");
    [item setLabel:label];
    
    [item setAction:@selector(toolbarItemPressed:)];
    
    self.toolbarItems[itemIdentifier] = item;
    [item release];
  }
  
  return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
  return self.toolbarIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar
{
  return self.toolbarIdentifiers;
}

- (NSDictionary *)createToolbarImages{
  
  NSDictionary *imageDict = @{ MPToolbarItemAddEntry: [NSImage imageNamed:NSImageNameAddTemplate],
                               MPToolbarItemAddGroup: [NSImage imageNamed:NSImageNameAddTemplate],
                               MPToolbarItemDelete: [NSImage imageNamed:NSImageNameRemoveTemplate],
                               MPToolbarItemEdit: [NSImage imageNamed:NSImageNameRefreshTemplate]
                               };
  return imageDict;
}

@end
