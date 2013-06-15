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
#import "MPContextMenuHelper.h"

NSString *const MPToolbarItemLock = @"TOOLBAR_LOCK";
NSString *const MPToolbarItemAddGroup = @"TOOLBAR_ADD_GROUP";
NSString *const MPToolbarItemAddEntry = @"TOOLBAR_ADD_ENTRY";
NSString *const MPToolbarItemEdit = @"TOOLBAR_EDIT";
NSString *const MPToolbarItemDelete =@"TOOLBAR_DELETE";
NSString *const MPToolbarItemAction = @"TOOLBAR_ACTION";
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
    _toolbarIdentifiers = [@[ MPToolbarItemAddEntry, MPToolbarItemDelete, MPToolbarItemAddGroup, MPToolbarItemAction, NSToolbarFlexibleSpaceItemIdentifier, MPToolbarItemLock, MPToolbarItemInspector ] retain];
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
    NSString *itemLabel = [self _localizedLabelForToolbarItemIdentifier:itemIdentifier];
    [item setLabel:itemLabel];
    
    if([itemIdentifier isEqualToString:MPToolbarItemAction]) {
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
      NSArray *menuItems = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuFull];
      for(NSMenuItem *item in menuItems) {
        [menu addItem:item];
      }
      NSMenuItem *menuRepresentation = [[NSMenuItem alloc] initWithTitle:itemLabel
                                                                  action:[self _actionForToolbarItemIdentifier:itemIdentifier]
                                                           keyEquivalent:@""];
      [menuRepresentation setSubmenu:menu];
      
      [popupButton setFrame:newFrame];
      [popupButton setMenu:menu];
      [item setMenuFormRepresentation:menuRepresentation];
      [item setView:popupButton];
      [popupButton release];
      [menu release];
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
      NSMenuItem *menuRepresentation = [[NSMenuItem alloc] initWithTitle:itemLabel
                                                                  action:[self _actionForToolbarItemIdentifier:itemIdentifier]
                                                           keyEquivalent:@""];
      [item setMenuFormRepresentation:menuRepresentation];
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
  NSDictionary *imageDict = @{ MPToolbarItemLock: [NSImage imageNamed:NSImageNameLockUnlockedTemplate],
                               MPToolbarItemAddEntry: [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemAddGroup: [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemDelete: [MPIconHelper icon:MPIconTrash],
                               MPToolbarItemAction: [NSImage imageNamed:NSImageNameActionTemplate],
                               MPToolbarItemInspector: [MPIconHelper icon:MPIconInfo],
                               };
  return imageDict;
}

- (NSString *)_localizedLabelForToolbarItemIdentifier:(NSString *)identifier {
  NSDictionary *labelDict = @{ MPToolbarItemLock: NSLocalizedString(@"LOCK", @""),
                               MPToolbarItemAction: NSLocalizedString(@"ACTION", @""),
                               MPToolbarItemAddEntry: NSLocalizedString(@"ADD_ENTRY", @""),
                               MPToolbarItemAddGroup: NSLocalizedString(@"ADD_GROUP", @""),
                               MPToolbarItemDelete: NSLocalizedString(@"DELETE", @""),
                               MPToolbarItemEdit: NSLocalizedString(@"EDIT", @""),
                               MPToolbarItemInspector: NSLocalizedString(@"INSPECTOR", @"")
                               };
  return labelDict[identifier];
}

- (SEL)_actionForToolbarItemIdentifier:(NSString *)identifier {
  NSDictionary *actionDict = @{ MPToolbarItemLock: @(MPActionLock),
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
