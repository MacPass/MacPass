//
//  MPToolbarDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPToolbarDelegate.h"
#import "MPIconHelper.h"

NSString *const MPToolbarItemAddGroup = @"AddGroup";
NSString *const MPToolbarItemAddEntry = @"AddEntry";
NSString *const MPToolbarItemEdit = @"Edit";
NSString *const MPToolbarItemDelete =@"Delete";
NSString *const MPToolbarItemAction = @"Action";

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
    self.toolbarIdentifiers = @[ MPToolbarItemAddEntry, MPToolbarItemDelete, MPToolbarItemEdit, MPToolbarItemAddGroup, MPToolbarItemAction ];
    self.toolbarItems = [NSMutableDictionary dictionaryWithCapacity:[self.toolbarItems count]];
    self.toolbarImages = [self createToolbarImages];
  }
  return self;
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *item = self.toolbarItems[ itemIdentifier ];
  if( !item ) {
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    NSButton *button;
    if([itemIdentifier isEqualToString:MPToolbarItemAction]) {
      NSPopUpButton *popupButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 50, 32) pullsDown:YES];
      [[popupButton cell] setBezelStyle:NSTexturedRoundedBezelStyle];
      [[popupButton cell] setImageScaling:NSImageScaleProportionallyDown];
      [popupButton setTitle:@""];
      /*
       Built menu
       */
      NSMenu *menu = [NSMenu allocWithZone:[NSMenu menuZone]];
      NSMenuItem *item = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
      [item setImage:self.toolbarImages[itemIdentifier]];
      [menu addItem:item];
      [menu addItemWithTitle:@"Foo" action:NULL keyEquivalent:@""];
      [menu addItemWithTitle:@"Bar" action:NULL keyEquivalent:@""];
      [popupButton setMenu:menu];
      
      /*
       Cleanup
       */
      [item release];
      [menu release];
      button = popupButton;
    }
    else {
      button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 32, 32)];
      [[button cell] setBezelStyle:NSTexturedRoundedBezelStyle];
      [[button cell] setImageScaling:NSImageScaleProportionallyDown];
      [button setTitle:@""];
      [button setButtonType:NSMomentaryPushInButton];
      NSImage *image = self.toolbarImages[itemIdentifier];
      [button setImage:image];
      [button setImagePosition:NSImageOnly];
    }
    [button sizeToFit];
    
    NSString *label = NSLocalizedString(itemIdentifier, @"");
    [item setLabel:label];
    
    [item setView:button];
    
    [item setAction:@selector(toolbarItemPressed:)];
    
    self.toolbarItems[itemIdentifier] = item;
    [item release];
    [button release];

    return item;
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
  NSDictionary *imageDict = @{ MPToolbarItemAddEntry: [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemAddGroup: [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemDelete: [NSImage imageNamed:NSImageNameRemoveTemplate],
                               MPToolbarItemEdit: [MPIconHelper icon:MPIconNotepad],
                               MPToolbarItemAction: [NSImage imageNamed:NSImageNameActionTemplate]
                               };
  return imageDict;
}


@end
