//
//  MPContextBarViewController.m
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
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

#import "MPContextBarViewController.h"

#import "KeePassKit/KeePassKit.h"

#import "MPDocument.h"
#import "MPFlagsHelper.h"
#import "MPEntrySearchContext.h"

#import "HNHUi/HNHUi.h"

NSUInteger const MPContextBarViewControllerActiveFilterMenuItemTag = 1000;

typedef NS_ENUM(NSUInteger, MPContextTab) {
  MPContextTabFilter,
  MPContextTabTrash,
  MPContextTabHistory
};


@interface MPContextBarViewController ()

@property (strong) NSString *selectMenuItemTitle;
@property (strong) NSString *multipleMenuItemTitle;

@property (nonatomic, assign) MPContextTab activeTab;

/* Filter */
@property (weak) IBOutlet NSButton *filterDoneButton;
/* History */
@property (weak) IBOutlet NSTextField *historyLabel;
@property (weak) IBOutlet NSButton *exitHistoryButton;
/* Trash*/
@property (weak) IBOutlet NSButton *emptyTrashButton;

@end

@implementation MPContextBarViewController

#pragma mark Nib handling
- (NSString *)nibName {
  return @"ContextBar";
}

#pragma mark Livecycle

- (void)dealloc {
  [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)awakeFromNib {
  self.selectMenuItemTitle = NSLocalizedString(@"SELECT_FILTER_WITH_DOTS", "Menu displayed as popup selection for search options if no filter is selected");
  self.multipleMenuItemTitle = NSLocalizedString(@"MULTIPLE_FILTERS_ACTIVE_WITH_DOTS", "Menu displayed as popup selection for search options when multiple items are selected");
  
  [self.view bind:NSSelectedIndexBinding toObject:self withKeyPath:NSStringFromSelector(@selector(activeTab)) options:nil];
  
  /* Setup Filter Bar buttons and menu */
  NSInteger tags[] = { MPEntrySearchTitles, MPEntrySearchUsernames, MPEntrySearchPasswords, MPEntrySearchNotes, MPEntrySearchUrls, MPEntrySearchAllAttributes };
  NSArray<NSControl *> *buttons  = @[self.titleButton, self.usernameButton, self.passwordButton, self.notesButton, self.urlButton, self.everywhereButton ];
  for(NSUInteger iIndex = 0; iIndex < buttons.count; iIndex++) {
    buttons[iIndex].action = @selector(toggleSearchFlags:);
    buttons[iIndex].tag = tags[iIndex];
  }
  NSInteger specialTags[] = { MPEntrySearchDoublePasswords, MPEntrySearchExpiredEntries };
  NSArray *titles = @[ NSLocalizedString(@"SEARCH_DUPLICATE_PASSWORDS", "Search option: Find duplicate passwords"), NSLocalizedString(@"SEARCH_EXPIRED_ENTRIES", "Search option: Find expired entries") ];
  NSMenu *specialMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"CUSTOM_SEARCH_FILTER_MENU", @"Title for menu for custom search filters")];
  [specialMenu addItemWithTitle:self.selectMenuItemTitle action:NULL keyEquivalent:@""];
  NSMenuItem *selectItem = specialMenu.itemArray.firstObject;
  selectItem.enabled = NO;
  selectItem.tag = MPEntrySearchNone;
  for(NSInteger iIndex = 0; iIndex < (sizeof(specialTags)/sizeof(NSInteger)); iIndex++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:titles[iIndex] action:@selector(toggleSearchFlags:) keyEquivalent:@""];
    item.tag = specialTags[iIndex];
    [specialMenu addItem:item];
  }
  self.specialFilterPopUpButton.menu = specialMenu;
  [self _updateFilterButtons];
}

#pragma mark MPDocument Notifications
- (void)registerNotificationsForDocument:(MPDocument *)document {
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_updateFilterButtons) name:MPDocumentDidChangeSearchFlags object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didEnterSearch:) name:MPDocumentDidEnterSearchNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_showEntryHistory:) name:MPDocumentShowEntryHistoryNotification object:document];
  [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(_didChangeCurrentItem:) name:MPDocumentCurrentItemChangedNotification object:document];
}

- (void)_didEnterSearch:(NSNotification *)notification {
  /* Select text if already visible */
  self.activeTab = MPContextTabFilter;
  [self _updateFilterButtons];
}

- (void)_showEntryHistory:(NSNotification *)notification {
  self.activeTab = MPContextTabHistory;
}

- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = notification.object;
  KPKGroup *group = document.selectedGroups.firstObject;
  BOOL showTrash = document.tree.metaData.useTrash && group.isTrash;
  if(showTrash && ! document.hasSearch) {
    self.activeTab = MPContextTabTrash;
  }
}

- (void)stackView:(NSStackView *)stackView willDetachViews:(NSArray<NSView *> *)views {
  for(NSView *view in views) {
    if([view isKindOfClass:NSButton.class]) {
      NSButton *button = (NSButton *)view;
      NSMenu *menu = self.specialFilterPopUpButton.menu;
      NSMenuItem *item = [menu itemWithTag:button.tag];
      if(item) {
        return; // no duplicates
      }
      item = [self _menuItemForButton:button];
      if(item) {
        if(menu.itemArray.count == 3) {
          [menu addItem:[NSMenuItem separatorItem]];
        }
        [menu addItem:item];
      }
    }
  }
  [self _updateFilterButtons];
}

- (void)stackView:(NSStackView *)stackView didReattachViews:(NSArray<NSView *> *)views {
  for(NSView *view in views) {
    if([view isKindOfClass:NSButton.class]) {
      NSButton *button = (NSButton *)view;
      NSMenu *menu = self.specialFilterPopUpButton.menu;
      NSMenuItem *item = [menu itemWithTag:button.tag];
      if(item) {
        [menu removeItem:item];
        if(menu.itemArray.count == 4) {
          [menu removeItemAtIndex:3];
        }
      }
    }
  }
  [self _updateFilterButtons];
}

#pragma mark UI Helper
- (void)_updateFilterButtons {
  MPDocument *document = self.windowController.document;
  MPEntrySearchFlags currentFlags = document.searchContext.searchFlags;
  self.notesButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchNotes, currentFlags));
  self.passwordButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchPasswords, currentFlags));
  self.titleButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchTitles, currentFlags));
  self.urlButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchUrls, currentFlags));
  self.usernameButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchUsernames, currentFlags));
  self.everywhereButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchAllAttributes, currentFlags));
  NSMutableSet *activeTags = [[NSMutableSet alloc] init];
  for(NSMenuItem *item in self.specialFilterPopUpButton.menu.itemArray) {
    MPEntrySearchFlags flag = item.tag;
    if(flag == MPEntrySearchNone) {
      item.state = NSOffState;
      item.enabled = NO;
      continue;
    }
    
    BOOL isActive = MPIsFlagSetInOptions(flag, currentFlags);
    if(isActive) {
      [activeTags addObject:@(flag)];
    }
    item.state = HNHUIStateForBool(isActive);
  }
  NSMenuItem *item = [self.specialFilterPopUpButton.menu itemWithTag:MPEntrySearchNone];
  if(activeTags.count > 1) {
    item.title = self.multipleMenuItemTitle;
    [self.specialFilterPopUpButton selectItemWithTag:MPEntrySearchNone];
  }
  else {
    item.title = self.selectMenuItemTitle;
    if(activeTags.count == 1) {
      NSInteger tag = [activeTags.anyObject integerValue];
      [self.specialFilterPopUpButton selectItemWithTag:tag];
    }
    else {
      [self.specialFilterPopUpButton selectItemWithTag:MPEntrySearchNone];
    }
  }
}

- (NSMenuItem *)_menuItemForButton:(NSButton *)button {
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:button.title action:@selector(toggleSearchFlags:) keyEquivalent:@""];
  item.tag = button.tag;
  return item;
}

@end
