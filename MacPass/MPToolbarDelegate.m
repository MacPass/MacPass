//
//  MPToolbarDelegate.m
//  MacPass
//
//  Created by michael starke on 18.02.13.
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

#import "MPToolbarDelegate.h"

#import "MPToolbarButton.h"
#import "MPToolbarItem.h"
#import "MPContextToolbarButton.h"
#import "MPAddEntryContextMenuDelegate.h"

#import "MPActionHelper.h"
#import "MPContextMenuHelper.h"
#import "MPIconHelper.h"

#import "MPDocumentWindowController.h"
#import "MPDocument+Search.h"

NSString *const MPToolbarItemLock = @"TOOLBAR_LOCK";
NSString *const MPToolbarItemAddGroup = @"TOOLBAR_ADD_GROUP";
NSString *const MPToolbarItemAddEntry = @"TOOLBAR_ADD_ENTRY";
NSString *const MPToolbarItemDelete =@"TOOLBAR_DELETE";
NSString *const MPToolbarItemAction = @"TOOLBAR_ACTION";
NSString *const MPToolbarItemInspector = @"TOOLBAR_INSPECTOR";
NSString *const MPToolbarItemSearch = @"TOOLBAR_SEARCH";

@interface MPToolbarDelegate() {
  MPAddEntryContextMenuDelegate *_entryMenuDelegate;
  BOOL _didShowToolbarForSearch;
  BOOL _didAddSearchfieldForSearch;
  NSToolbarDisplayMode _displayModeBeforeSearch;
}

@property (strong) NSMutableDictionary *toolbarItems;
@property (strong) NSArray *toolbarIdentifiers;
@property (strong) NSDictionary *toolbarImages;
@property (weak) NSSearchField *searchField;

- (NSString *)_localizedLabelForToolbarItemIdentifier:(NSString *)identifier;
- (SEL)_actionForToolbarItemIdentifier:(NSString *)identifier;

@end

@implementation MPToolbarDelegate


- (id)init {
  self = [super init];
  if (self) {
    _didShowToolbarForSearch = NO;
    _didAddSearchfieldForSearch = NO;
    _toolbarIdentifiers = @[ MPToolbarItemAddEntry,
                             MPToolbarItemDelete,
                             MPToolbarItemAddGroup,
                             MPToolbarItemAction,
                             NSToolbarFlexibleSpaceItemIdentifier,
                             MPToolbarItemSearch,
                             MPToolbarItemLock,
                             MPToolbarItemInspector ];
    _toolbarImages = [self createToolbarImages];
    _toolbarItems = [[NSMutableDictionary alloc] initWithCapacity:[self.toolbarIdentifiers count]];
    _entryMenuDelegate = [[MPAddEntryContextMenuDelegate alloc] init];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
      [popupButton setFocusRingType:NSFocusRingTypeNone];
      [popupButton setTitle:@""];
      [popupButton sizeToFit];
      
      NSRect newFrame = [popupButton frame];
      newFrame.size.width += 20;
      
      NSMenu *menu = [[NSMenu allocWithZone:[NSMenu menuZone]] init];
      NSMenuItem *actionImageItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]] initWithTitle:@"" action:NULL keyEquivalent:@""];
      [actionImageItem setImage:self.toolbarImages[MPToolbarItemAction]];
      [menu addItem:actionImageItem];
      NSArray *menuItems = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuExtended];
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
    }
    else if( [itemIdentifier isEqualToString:MPToolbarItemAddEntry]) {
      MPContextToolbarButton *button = [[MPContextToolbarButton alloc] initWithFrame:NSMakeRect(0, 0, 32, 32)];
      [button setAction:[self _actionForToolbarItemIdentifier:itemIdentifier]];
      NSImage *image = self.toolbarImages[itemIdentifier];
      [image setSize:NSMakeSize(16, 16)];
      [button setImage:image];
      [button sizeToFit];
      
      NSMenu *menu = [NSMenu allocWithZone:[NSMenu menuZone]];
      [menu addItemWithTitle:@"Dummy" action:NULL keyEquivalent:@""];
      [menu setDelegate:_entryMenuDelegate];
      [button setContextMenu:menu];
      
      
      NSRect fittingRect = [button frame];
      fittingRect.size.width = MAX( (CGFloat)32.0,fittingRect.size.width);
      [button setFrame:fittingRect];
      [item setView:button];
      /* Create the Contextual Menu button */
      NSMenuItem *menuRepresentation = [[NSMenuItem alloc] initWithTitle:itemLabel
                                                                  action:[self _actionForToolbarItemIdentifier:itemIdentifier]
                                                           keyEquivalent:@""];
      [item setMenuFormRepresentation:menuRepresentation];
      
    }
    else if( [itemIdentifier isEqualToString:MPToolbarItemSearch]){
      NSSearchField *searchField = [[NSSearchField alloc] init];
      [searchField setAction:@selector(updateSearch:)];
      NSSearchFieldCell *cell = [searchField cell];
      [[cell cancelButtonCell] setAction:@selector(exitSearch:)];
      [[cell cancelButtonCell] setTarget:nil];
      [searchField setRecentsAutosaveName:@"RecentEntrySearches"];
      [item setView:searchField];
      [item setMinSize:NSMakeSize(140, 32)];
      [item setMaxSize:NSMakeSize(240, 32)];
      self.searchField = searchField;
    }
    else {
      NSButton *button = [[MPToolbarButton alloc] initWithFrame:NSMakeRect(0, 0, 32, 32)];
      NSImage *image = self.toolbarImages[itemIdentifier];
      [image setSize:NSMakeSize(16, 16)];
      [button setImage:image];
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
    }
    self.toolbarItems[itemIdentifier] = item;
  }
  return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
  return self.toolbarIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
  return self.toolbarIdentifiers;
}

- (NSDictionary *)createToolbarImages {
  NSDictionary *imageDict = @{ MPToolbarItemLock: [NSImage imageNamed:NSImageNameLockUnlockedTemplate],
                               MPToolbarItemAddEntry: [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemAddGroup: [MPIconHelper icon:MPIconAddFolder],
                               MPToolbarItemDelete: [MPIconHelper icon:MPIconTrash],
                               MPToolbarItemAction: [NSImage imageNamed:NSImageNameActionTemplate],
                               MPToolbarItemInspector: [MPIconHelper icon:MPIconInfo],
                               };
  return imageDict;
}


- (void)registerNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didExitSearch:) name:MPDocumentDidExitSearchNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterSearch:) name:MPDocumentDidEnterSearchNotification object:document];
}

- (NSString *)_localizedLabelForToolbarItemIdentifier:(NSString *)identifier {
  static NSDictionary *labelDict;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    labelDict = @{ MPToolbarItemLock: NSLocalizedString(@"LOCK", @""),
                   MPToolbarItemAction: NSLocalizedString(@"ACTION", @""),
                   MPToolbarItemAddEntry: NSLocalizedString(@"ADD_ENTRY", @""),
                   MPToolbarItemAddGroup: NSLocalizedString(@"ADD_GROUP", @""),
                   MPToolbarItemDelete: NSLocalizedString(@"DELETE", @""),
                   MPToolbarItemInspector: NSLocalizedString(@"INSPECTOR", @""),
                   MPToolbarItemSearch: NSLocalizedString(@"SEARCH", @"")
                   };
  });
  return labelDict[identifier];
}

- (SEL)_actionForToolbarItemIdentifier:(NSString *)identifier {
  static NSDictionary *actionDict;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    actionDict = @{ MPToolbarItemLock: @(MPActionLock),
                    MPToolbarItemAddEntry: @(MPActionAddEntry),
                    MPToolbarItemAddGroup: @(MPActionAddGroup),
                    MPToolbarItemDelete: @(MPActionDelete),
                    MPToolbarItemInspector: @(MPActionToggleInspector)
                    };
  });
  MPActionType actionType = (MPActionType)[actionDict[identifier] integerValue];
  return [MPActionHelper actionOfType:actionType];
}

- (void)_didEnterSearch:(NSNotification *)notification {
  /* We enter search. If there is no Item to search in the toolbar, we need to add it */
  NSArray *currentItems = [self.toolbar items];
  NSToolbarItem *searchItem = self.toolbarItems[MPToolbarItemSearch];
  if(!searchItem || ![currentItems containsObject:searchItem]) {
    [self.toolbar insertItemWithItemIdentifier:MPToolbarItemSearch atIndex:[currentItems count]];
    _didAddSearchfieldForSearch = YES;
  }
  /* Then we should make sure the toolbar is visible. Just to make life easier */
  if(![self.toolbar isVisible]) {
    _didShowToolbarForSearch = YES;
    [self.toolbar setVisible:YES];
  }
  _displayModeBeforeSearch = [self.toolbar displayMode];
  if(_displayModeBeforeSearch == NSToolbarDisplayModeLabelOnly) {
    [self.toolbar setDisplayMode:NSToolbarDisplayModeIconAndLabel];
  }
  /* only make the searchfield first responder if it's not aleady in an active search */
  if(![self.searchField currentEditor]) {
    [[self.searchField window] makeFirstResponder:self.searchField];
    [self.searchField selectText:self];
  }
}

- (void)_didExitSearch:(NSNotification *)notification {
  [self.searchField setStringValue:@""];
  NSWindow *window = [self.searchField window];
  /* Resign first responder form search field only if it was the first responder */
  if([window firstResponder] == [self.searchField currentEditor]) {
    [window makeFirstResponder:nil];
  }
  if(_didAddSearchfieldForSearch) {
    NSToolbarItem *searchItem = self.toolbarItems[MPToolbarItemSearch];
    NSUInteger index = [[self.toolbar items] indexOfObject:searchItem];
    if(index != NSNotFound) {
      [self.toolbar removeItemAtIndex:index];
      _didAddSearchfieldForSearch = NO;
    }
  }
  if(_displayModeBeforeSearch != [self.toolbar displayMode]) {
    [self.toolbar setDisplayMode:_displayModeBeforeSearch];
  }
  if(_didShowToolbarForSearch && [self.toolbar isVisible]) {
    _didShowToolbarForSearch = NO;
    [self.toolbar setVisible:NO];
  }
}

@end
