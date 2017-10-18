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

@property (nonatomic, assign) MPContextTab activeTab;

/* Filter */
@property (weak) IBOutlet NSButton *filterDoneButton;
@property (weak) IBOutlet NSTextField *filterLabelTextField;
/* History */
@property (weak) IBOutlet HNHUIGradientView *historyBar;
@property (weak) IBOutlet NSTextField *historyLabel;
@property (weak) IBOutlet NSButton *exitHistoryButton;
/* Trash*/
@property (weak) IBOutlet HNHUIGradientView *trashBar;
@property (weak) IBOutlet NSButton *emptyTrashButton;

@end

@implementation MPContextBarViewController

#pragma mark Nib handling
- (NSString *)nibName {
  return @"ContextBar";
}

#pragma mark Livecycle

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
  self.filterLabelTextField.cell.backgroundStyle = NSBackgroundStyleRaised;
  //self.historyBar.activeGradient = [[NSGradient alloc] initWithStartingColor:[[NSColor orangeColor] shadowWithLevel:0.2] endingColor:[[NSColor orangeColor] highlightWithLevel:0.2]];
  
  /* Setup Trash Bar color */
  if(!HNHUIIsRunningOnYosemiteOrNewer()) {
    NSArray *activeColors = @[[NSColor colorWithCalibratedWhite:0.2 alpha:1],[NSColor colorWithCalibratedWhite:0.4 alpha:1]];
    NSArray *inactiveColors = @[[NSColor colorWithCalibratedWhite:0.3 alpha:1],[NSColor colorWithCalibratedWhite:0.6 alpha:1]];
    self.trashBar.activeGradient = [[NSGradient alloc] initWithColors:activeColors];
    self.trashBar.inactiveGradient = [[NSGradient alloc] initWithColors:inactiveColors];
    //self.emptyTrashButton.textColor = [NSColor whiteColor];
  }
  
  [self.view bind:NSSelectedIndexBinding toObject:self withKeyPath:NSStringFromSelector(@selector(activeTab)) options:nil];
  
  /* Setup Filter Bar buttons and menu */
  NSInteger tags[] = { MPEntrySearchTitles, MPEntrySearchUsernames, MPEntrySearchPasswords, MPEntrySearchNotes, MPEntrySearchUrls };
  NSArray<NSControl *> *buttons  = @[self.titleButton, self.usernameButton, self.passwordButton, self.notesButton, self.urlButton ];
  for(NSUInteger iIndex = 0; iIndex < buttons.count; iIndex++) {
    buttons[iIndex].action = @selector(toggleSearchFlags:);
    buttons[iIndex].tag = tags[iIndex];
  }
  NSInteger specialTags[] = { MPEntrySearchDoublePasswords, MPEntrySearchExpiredEntries };
  NSArray *titles = @[ NSLocalizedString(@"SEARCH_DUPLICATE_PASSWORDS", ""), NSLocalizedString(@"SEARCH_EXPIRED_ENTRIES", "") ];
  NSMenu *specialMenu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"CUSTOM_SEARCH_FILTER_MENU", @"Title for menu for custom search filters")];
  [specialMenu addItemWithTitle:NSLocalizedString(@"SELECT_FILTER_WITH_DOTS", "") action:NULL keyEquivalent:@""];
  [specialMenu itemAtIndex:0].enabled = NO;
  [specialMenu itemAtIndex:0].tag = MPEntrySearchNone;
  [specialMenu itemAtIndex:0].action = @selector(toggleSearchFlags:);
  for(NSInteger iIndex = 0; iIndex < (sizeof(specialTags)/sizeof(NSInteger)); iIndex++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:titles[iIndex] action:@selector(toggleSearchFlags:) keyEquivalent:@""];
    item.tag = specialTags[iIndex];
    [specialMenu addItem:item];
  }
  [self.specialFilterPopUpButton setMenu:specialMenu];
  [self _updateFilterButtons];
}

#pragma mark MPDocument Notifications
- (void)registerNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateFilterButtons) name:MPDocumentDidChangeSearchFlags object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterSearch:) name:MPDocumentDidEnterSearchNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showEntryHistory:) name:MPDocumentShowEntryHistoryNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeCurrentItem:) name:MPDocumentCurrentItemChangedNotification object:document];
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

/*
 - (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector {
 if(commandSelector == @selector(insertNewline:)) {
 [self _didChangeFilter];
 }
 return NO;
 }
 */


#pragma mark UI Helper
- (void)_updateFilterButtons {
  MPDocument *document = self.windowController.document;
  MPEntrySearchFlags currentFlags = document.searchContext.searchFlags;
  self.duplicatePasswordsButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchDoublePasswords, currentFlags));
  self.notesButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchNotes, currentFlags));
  self.passwordButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchPasswords, currentFlags));
  self.titleButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchTitles, currentFlags));
  self.urlButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchUrls, currentFlags));
  self.usernameButton.state = HNHUIStateForBool(MPIsFlagSetInOptions(MPEntrySearchUsernames, currentFlags));
  NSInteger selectedTag = MPEntrySearchNone;
  for(NSMenuItem *item in [[self.specialFilterPopUpButton menu] itemArray]) {
    MPEntrySearchFlags flag = item.tag;
    if(flag == MPEntrySearchNone) {
      item.state = NSOffState;
      item.enabled = NO;
    }
    else {
      BOOL isActive = MPIsFlagSetInOptions(flag, currentFlags);
      if(isActive) {
        selectedTag = flag;
      }
      item.state = HNHUIStateForBool(isActive);
    }
  }
  [self.specialFilterPopUpButton selectItemWithTag:selectedTag];
}

@end
