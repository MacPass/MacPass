//
//  MPToolbarDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPToolbarDelegate.h"
#import "MPIconHelper.h"
#import "MPAppDelegate.h"
#import "MPToolbarButton.h"

NSString *const MPToolbarItemAddGroup = @"AddGroup";
NSString *const MPToolbarItemAddEntry = @"AddEntry";
NSString *const MPToolbarItemEdit = @"Edit";
NSString *const MPToolbarItemDelete =@"Delete";
NSString *const MPToolbarItemAction = @"Action";
NSString *const MPToolbarItemSearch = @"Search";

@interface MPToolbarDelegate()

@property (retain) NSMutableDictionary *toolbarItems;
@property (retain) NSArray *toolbarIdentifiers;
@property (retain) NSDictionary *toolbarImages;

@end

@implementation MPToolbarDelegate


- (id)init {
  self = [super init];
  if (self) {
    _toolbarIdentifiers = [@[ MPToolbarItemAddEntry, MPToolbarItemDelete, MPToolbarItemEdit, MPToolbarItemAddGroup, MPToolbarItemAction, NSToolbarFlexibleSpaceItemIdentifier, MPToolbarItemSearch ] retain];
    _toolbarImages = [[self createToolbarImages] retain];
    _toolbarItems = [[NSMutableDictionary alloc] initWithCapacity:[self.toolbarIdentifiers count]];
  }
  return self;
}

- (void)dealloc
{
  self.toolbarIdentifiers = nil;
  self.toolbarImages = nil;
  self.toolbarItems = nil;
  [super dealloc];
}

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
  NSToolbarItem *item = self.toolbarItems[itemIdentifier];
  if(!item) {    
    item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    NSString *label = NSLocalizedString(itemIdentifier, @"");
    [item setLabel:label];
    
    if([itemIdentifier isEqualToString:MPToolbarItemSearch]) {
      NSSearchField *searchfield = [[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, 70, 32)];
      [item setView:searchfield];
      [searchfield setAction:@selector(updateFilter:)];
      [[searchfield cell] setSendsSearchStringImmediately:NO];
      [[[searchfield cell] cancelButtonCell] setTarget:nil];
      [[[searchfield cell] cancelButtonCell] setAction:@selector(clearFilter:)];
      [searchfield release];
      self.searchItem = item;
    }
    else if([itemIdentifier isEqualToString:MPToolbarItemAction]) {
      NSPopUpButton *popupButton = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(0, 0, 50, 32) pullsDown:YES];
      [[popupButton cell] setBezelStyle:NSTexturedRoundedBezelStyle];
      [[popupButton cell] setImageScaling:NSImageScaleProportionallyDown];
      [popupButton setTitle:@""];
      [popupButton sizeToFit];

      NSRect newFrame = [popupButton frame];
      newFrame.size.width += 20;
      
      
      
      NSMenu *menu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
      NSMenuItem *actionImageItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
      [actionImageItem setImage:self.toolbarImages[MPToolbarItemAction]];
      [menu addItem:actionImageItem];
      [actionImageItem release];
      NSArray *menuItems = [(MPAppDelegate *)[NSApp delegate] contextMenuItemsWithItems:MPContextMenuFull];
      for(NSMenuItem *item in menuItems) {
        [menu addItem:item];
      }
      [popupButton setFrame:newFrame];
      [popupButton setMenu:menu];
      [menu release];
      
      [item setView:popupButton];
      [popupButton release];
    }
    else {
      NSButton *button = [[MPToolbarButton alloc] initWithFrame:NSMakeRect(0, 0, 32, 32)];
      [[button cell] setBezelStyle:NSTexturedRoundedBezelStyle];
      [[button cell] setImageScaling:NSImageScaleProportionallyDown];
      [button setTitle:itemIdentifier];
      [button setButtonType:NSMomentaryPushInButton];
      NSImage *image = self.toolbarImages[itemIdentifier];
      [image setSize:NSMakeSize(16, 16)];
      [button setImage:image];
      [button setImagePosition:NSImageOnly];
      [button sizeToFit];
      if([itemIdentifier isEqualToString:MPToolbarItemEdit]) {
        [button setTarget:nil];
        [button setAction:@selector(showEditForm:)];
      }
      
      NSRect fittingRect = [button frame];
      fittingRect.size.width = MAX( (CGFloat)32.0,fittingRect.size.width);
      [button setFrame:fittingRect];
      [item setView:button];
      [button release];
    }
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
  NSDictionary *imageDict = @{ MPToolbarItemAddEntry: [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemAddGroup: [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemDelete: [NSImage imageNamed:NSImageNameRemoveTemplate],
                               MPToolbarItemEdit: [MPIconHelper icon:MPIconNotepad],
                               MPToolbarItemAction: [NSImage imageNamed:NSImageNameActionTemplate]
                               };
  return imageDict;
}

@end
