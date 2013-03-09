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
#import "MPToolbarItem.h"
#import "MPActionHelper.h"

NSString *const MPToolbarItemAddGroup = @"TOOLBAR_ADD_GROUP";
NSString *const MPToolbarItemAddEntry = @"TOOLBAR_ADD_ENTRY";
NSString *const MPToolbarItemEdit = @"TOOLBAR_EDIT";
NSString *const MPToolbarItemDelete =@"TOOLBAR_DELETE";
NSString *const MPToolbarItemAction = @"TOOLBAR_ACTION";
NSString *const MPToolbarItemSearch = @"TOOLBAR_SEARCH";
NSString *const MPToolbarItemInspector = @"TOOLBAR_INSPECTOR";

@interface MPToolbarDelegate()

@property (retain) NSMutableDictionary *toolbarItems;
@property (retain) NSArray *toolbarIdentifiers;
@property (retain) NSDictionary *toolbarImages;

- (NSString *)_localizedLabelForToolbarItemIdentifier:(NSString *)identifier;
- (SEL)_actionForToolbarItemIdentifier:(NSString *)identifier;

@end

@implementation MPToolbarDelegate


- (id)init {
  self = [super init];
  if (self) {
    _toolbarIdentifiers = [@[ MPToolbarItemAddEntry, MPToolbarItemDelete, MPToolbarItemAddGroup, MPToolbarItemAction, NSToolbarFlexibleSpaceItemIdentifier, NSToolbarSpaceItemIdentifier, MPToolbarItemInspector, MPToolbarItemSearch ] retain];
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
    item = [[MPToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    NSString *label = [self _localizedLabelForToolbarItemIdentifier:itemIdentifier];
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
      [button setAction:[self _actionForToolbarItemIdentifier:itemIdentifier]];
      
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
                               MPToolbarItemAction: [NSImage imageNamed:NSImageNameActionTemplate],
                               MPToolbarItemInspector: [NSImage imageNamed:NSImageNameInfo],
                               };
  return imageDict;
}

- (NSString *)_localizedLabelForToolbarItemIdentifier:(NSString *)identifier {
  NSDictionary *labelDict = @{
                              MPToolbarItemAction: NSLocalizedString(@"ACTION", @""),
                              MPToolbarItemAddEntry: NSLocalizedString(@"ADD_ENTRY", @""),
                              MPToolbarItemAddGroup: NSLocalizedString(@"ADD_GROUP", @""),
                              MPToolbarItemDelete: NSLocalizedString(@"DELETE", @""),
                              MPToolbarItemEdit: NSLocalizedString(@"EDIT", @""),
                              MPToolbarItemInspector: NSLocalizedString(@"TOGGLE_INSPECTOR", @""),
                              MPToolbarItemSearch: NSLocalizedString(@"SEARCH", @"")
                              };
  return labelDict[identifier];
}

- (SEL)_actionForToolbarItemIdentifier:(NSString *)identifier {
  NSDictionary *actionDict = @{
                               MPToolbarItemAddEntry: @(MPActionAddEntry),
                               MPToolbarItemAddGroup: @(MPActionAddGroup),
                               MPToolbarItemDelete: @(MPActionDelete),
                               MPToolbarItemEdit: @(MPActionEdit),
                               MPToolbarItemInspector: @(MPActionToggleInspector)
                               };
  MPActionType actionType = (MPActionType)[actionDict[identifier] integerValue];
  return [MPActionHelper actionOfType:actionType];
}

@end
