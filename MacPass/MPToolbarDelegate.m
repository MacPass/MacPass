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
#import "MPDocument.h"

NSString *const MPToolbarItemLock = @"TOOLBAR_LOCK";
NSString *const MPToolbarItemAddGroup = @"TOOLBAR_ADD_GROUP";
NSString *const MPToolbarItemAddEntry = @"TOOLBAR_ADD_ENTRY";
NSString *const MPToolbarItemDelete =@"TOOLBAR_DELETE";
NSString *const MPToolbarItemAction = @"TOOLBAR_ACTION";
NSString *const MPToolbarItemInspector = @"TOOLBAR_INSPECTOR";
NSString *const MPToolbarItemSearch = @"TOOLBAR_SEARCH";
NSString *const MPToolbarItemCopyUsername = @"TOOLBAR_COPY_USERNAME";
NSString *const MPToolbarItemCopyPassword = @"TOOLBAR_COPY_PASSWORD";
NSString *const MPToolbarItemHistory = @"TOOLBAR_HISTORY";

@interface MPToolbarDelegate() {
  MPAddEntryContextMenuDelegate *_entryMenuDelegate;
  BOOL _didShowToolbarForSearch;
  BOOL _didAddSearchfieldForSearch;
  NSToolbarDisplayMode _displayModeBeforeSearch;
}

@property (strong) NSMutableDictionary *toolbarItems;
@property (strong) NSArray *toolbarIdentifiers;
@property (strong) NSArray *defaultToolbarIdentifiers;
@property (strong) NSDictionary *toolbarImages;
@property (weak) NSSearchField *searchField;

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
                             MPToolbarItemCopyPassword,
                             MPToolbarItemCopyUsername,
                             NSToolbarFlexibleSpaceItemIdentifier,
                             MPToolbarItemSearch,
                             MPToolbarItemLock,
                             MPToolbarItemInspector,
                             MPToolbarItemHistory ];
    _defaultToolbarIdentifiers = @[ MPToolbarItemAddEntry,
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
      popupButton.bezelStyle = NSTexturedRoundedBezelStyle;
      popupButton.focusRingType = NSFocusRingTypeNone;
      popupButton.title = @"";
      [popupButton.cell setImageScaling:NSImageScaleProportionallyDown];
      [popupButton sizeToFit];
      
      NSRect newFrame = popupButton.frame;
      newFrame.size.width += 20;
      
      NSMenu *menu = [[NSMenu alloc] init];
      NSMenuItem *actionImageItem = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
      actionImageItem.image = self.toolbarImages[MPToolbarItemAction];
      [menu addItem:actionImageItem];
      NSArray *menuItems = [MPContextMenuHelper contextMenuItemsWithItems:MPContextMenuExtended];
      for(NSMenuItem *item in menuItems) {
        [menu addItem:item];
      }
      NSMenuItem *menuRepresentation = [[NSMenuItem alloc] initWithTitle:itemLabel
                                                                  action:[self _actionForToolbarItemIdentifier:itemIdentifier]
                                                           keyEquivalent:@""];
      menuRepresentation.submenu = menu;
      
      popupButton.frame = newFrame;
      popupButton.menu = menu;
      item.menuFormRepresentation = menuRepresentation;
      item.view = popupButton;
    }
    else if( [itemIdentifier isEqualToString:MPToolbarItemAddEntry]) {
      MPContextToolbarButton *button = [[MPContextToolbarButton alloc] initWithFrame:NSMakeRect(0, 0, 32, 32)];
      [button setAction:[self _actionForToolbarItemIdentifier:itemIdentifier]];
      NSImage *image = self.toolbarImages[itemIdentifier];
      image.size = NSMakeSize(16, 16);
      [button setImage:image];
      [button sizeToFit];
      
      NSMenu *menu = [NSMenu allocWithZone:[NSMenu menuZone]];
      [menu addItemWithTitle:NSLocalizedString(@"UNKNOWN_TOOLBAR_ITEM", @"") action:NULL keyEquivalent:@""];
      menu.delegate = _entryMenuDelegate;
      [button setContextMenu:menu];
      
      
      NSRect fittingRect = button.frame;
      fittingRect.size.width = MAX( (CGFloat)32.0,fittingRect.size.width);
      button.frame = fittingRect;
      item.view = button;
      /* Create the Contextual Menu button */
      NSMenuItem *menuRepresentation = [[NSMenuItem alloc] initWithTitle:itemLabel
                                                                  action:[self _actionForToolbarItemIdentifier:itemIdentifier]
                                                           keyEquivalent:@""];
      [item setMenuFormRepresentation:menuRepresentation];
      
    }
    else if( [itemIdentifier isEqualToString:MPToolbarItemSearch]){
      NSSearchField *searchField = [[NSSearchField alloc] init];
      searchField.action = @selector(updateSearch:);
      NSSearchFieldCell *cell = searchField.cell;
      cell.cancelButtonCell.action = @selector(exitSearch:);
      cell.cancelButtonCell.target = nil;
      searchField.recentsAutosaveName = @"RecentEntrySearches";
      item.view = searchField;
      /* Use default size base on documentation */
      item.minSize = NSMakeSize(140, 32);
      item.maxSize = NSMakeSize(240, 32);
      NSMenu *templateMenu = [self _allocateSearchMenuTemplate];
      [searchField.cell setSearchMenuTemplate:templateMenu];
      self.searchField = searchField;
    }
    else {
      NSButton *button = [[MPToolbarButton alloc] initWithFrame:NSMakeRect(0, 0, 32, 32)];
      NSImage *image = self.toolbarImages[itemIdentifier];
      image.size = NSMakeSize(16, 16);
      [button setImage:image];
      [button sizeToFit];
      button.action = [self _actionForToolbarItemIdentifier:itemIdentifier];
      
      NSRect fittingRect = [button frame];
      fittingRect.size.width = MAX( (CGFloat)32.0,fittingRect.size.width);
      button.frame = fittingRect;
      item.view = button;
      NSMenuItem *menuRepresentation = [[NSMenuItem alloc] initWithTitle:itemLabel
                                                                  action:[self _actionForToolbarItemIdentifier:itemIdentifier]
                                                           keyEquivalent:@""];
      item.menuFormRepresentation = menuRepresentation;
    }
    self.toolbarItems[itemIdentifier] = item;
  }
  return item;
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
  return self.defaultToolbarIdentifiers;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
  return self.toolbarIdentifiers;
}

- (NSDictionary *)createToolbarImages {
  NSDictionary *imageDict = @{ MPToolbarItemLock: [NSImage imageNamed:NSImageNameLockUnlockedTemplate],
                               MPToolbarItemAddEntry: [MPIconHelper icon:MPIconAddEntry],
                               MPToolbarItemAddGroup: [MPIconHelper icon:MPIconAddFolder],
                               MPToolbarItemCopyUsername : [MPIconHelper icon:MPIconIdentity],
                               MPToolbarItemCopyPassword : [MPIconHelper icon:MPIconPassword],
                               MPToolbarItemDelete: [MPIconHelper icon:MPIconTrash],
                               MPToolbarItemAction: [NSImage imageNamed:NSImageNameActionTemplate],
                               MPToolbarItemInspector: [MPIconHelper icon:MPIconInfo],
                               MPToolbarItemHistory: [MPIconHelper icon:MPIconHistory]
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
                   MPToolbarItemCopyPassword: NSLocalizedString(@"COPY_PASSWORD", @""),
                   MPToolbarItemCopyUsername: NSLocalizedString(@"COPY_USERNAME", @""),
                   MPToolbarItemDelete: NSLocalizedString(@"DELETE", @""),
                   MPToolbarItemInspector: NSLocalizedString(@"INSPECTOR", @""),
                   MPToolbarItemSearch: NSLocalizedString(@"SEARCH", @""),
                   MPToolbarItemHistory: NSLocalizedString(@"SHOW_HISTORY", @""),
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
                    MPToolbarItemCopyPassword: @(MPActionCopyPassword),
                    MPToolbarItemCopyUsername: @(MPActionCopyUsername),
                    MPToolbarItemInspector: @(MPActionToggleInspector),
                    MPToolbarItemHistory: @(MPActionShowEntryHistory),
                    };
  });
  MPActionType actionType = (MPActionType)[actionDict[identifier] integerValue];
  return [MPActionHelper actionOfType:actionType];
}

- (NSMenu *)_allocateSearchMenuTemplate {
  NSMenu *menu = [[NSMenu alloc] init];
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"CLEAR_RECENT_SEARCHES", @"") action:NULL keyEquivalent:@""];
  item.tag = NSSearchFieldClearRecentsMenuItemTag;
  [menu addItem:item];
  
  [menu addItem:[NSMenuItem separatorItem]];

  item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"RECENT_SEARCHES", @"") action:NULL keyEquivalent:@""];
  item.tag = NSSearchFieldRecentsTitleMenuItemTag;
  [menu addItem:item];
  
  item = [[NSMenuItem alloc] initWithTitle:@"Recents" action:NULL keyEquivalent:@""];
  item.tag = NSSearchFieldRecentsMenuItemTag;
  [menu addItem:item];
  
  item = [[NSMenuItem alloc] initWithTitle:@"NoEntries" action:NULL keyEquivalent:@""];
  item.tag = NSSearchFieldNoRecentsMenuItemTag;
  [menu addItem:item];
  
  return menu;
}

- (void)_didEnterSearch:(NSNotification *)notification {
  /* We enter search. If there is no Item to search in the toolbar, we need to add it */
  NSArray *currentItems = self.toolbar.items;
  NSToolbarItem *searchItem = self.toolbarItems[MPToolbarItemSearch];
  if(!searchItem || ![currentItems containsObject:searchItem]) {
    [self.toolbar insertItemWithItemIdentifier:MPToolbarItemSearch atIndex:[currentItems count]];
    _didAddSearchfieldForSearch = YES;
  }
  /* Then we should make sure the toolbar is visible. Just to make life easier */
  if(!self.toolbar.visible) {
    _didShowToolbarForSearch = YES;
    self.toolbar.visible = YES;
  }
  _displayModeBeforeSearch = self.toolbar.displayMode;
  if(_displayModeBeforeSearch == NSToolbarDisplayModeLabelOnly) {
    self.toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
  }
  /* only make the searchfield first responder if it's not already in an active search */
  if(![self.searchField currentEditor]) {
    [self.searchField.window makeFirstResponder:self.searchField];
    [self.searchField selectText:self];
  }
}

- (void)_didExitSearch:(NSNotification *)notification {
  [self.searchField setStringValue:@""];
  NSWindow *window = [self.searchField window];
  /* Resign first responder form search field only if it was the first responder */
  if(window.firstResponder == [self.searchField currentEditor]) {
    [window makeFirstResponder:nil];
  }
  if(_didAddSearchfieldForSearch) {
    NSToolbarItem *searchItem = self.toolbarItems[MPToolbarItemSearch];
    NSUInteger index = [self.toolbar.items indexOfObject:searchItem];
    if(index != NSNotFound) {
      [self.toolbar removeItemAtIndex:index];
      _didAddSearchfieldForSearch = NO;
    }
  }
  if(_displayModeBeforeSearch != self.toolbar.displayMode) {
    self.toolbar.displayMode = _displayModeBeforeSearch;
  }
  if(_didShowToolbarForSearch && self.toolbar.visible) {
    _didShowToolbarForSearch = NO;
    self.toolbar.visible = NO;
  }
}

@end
