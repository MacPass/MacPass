//
//  MPContextBarViewController.m
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
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
@property (weak) IBOutlet HNHGradientView *trashBar;
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
  [[self.filterLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  /* Setup History Bar colors */
  self.historyBar.activeGradient = [[NSGradient alloc] initWithStartingColor:[[NSColor orangeColor] shadowWithLevel:0.2] endingColor:[[NSColor orangeColor] highlightWithLevel:0.2]];
  
  /* Setup Trash Bar color */
  if(!HNHUIIsRunningOnYosemiteOrNewer()) {
    NSArray *activeColors = @[[NSColor colorWithCalibratedWhite:0.2 alpha:1],[NSColor colorWithCalibratedWhite:0.4 alpha:1]];
    NSArray *inactiveColors = @[[NSColor colorWithCalibratedWhite:0.3 alpha:1],[NSColor colorWithCalibratedWhite:0.6 alpha:1]];
    self.trashBar.activeGradient = [[NSGradient alloc] initWithColors:activeColors];
    self.trashBar.inactiveGradient = [[NSGradient alloc] initWithColors:inactiveColors];
    //self.emptyTrashButton.textColor = [NSColor whiteColor];
  }
  
  [[self view] bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  
  /* Setup Filter Bar buttons and menu */
  NSInteger tags[] = { MPEntrySearchTitles, MPEntrySearchUsernames, MPEntrySearchPasswords, MPEntrySearchNotes, MPEntrySearchUrls };
  NSArray *buttons  = @[self.titleButton, self.usernameButton, self.passwordButton, self.notesButton, self.urlButton ];
  for(NSUInteger iIndex = 0; iIndex < [buttons count]; iIndex++) {
    [buttons[iIndex] setAction:@selector(toggleSearchFlags:)];
    [buttons[iIndex] setTag:tags[iIndex]];
  }
  NSInteger specialTags[] = { MPEntrySearchDoublePasswords, MPEntrySearchExpiredEntries };
  NSArray *titles = @[ NSLocalizedString(@"SEARCH_DUPLICATE_PASSWORDS", ""), NSLocalizedString(@"SEARCH_EXPIRED_ENTRIES", "") ];
  NSMenu *specialMenu = [[NSMenu alloc] initWithTitle:@"Special Filters Menu"];
  [specialMenu addItemWithTitle:NSLocalizedString(@"SELECT_FILTER_WITH_DOTS", "") action:NULL keyEquivalent:@""];
  [[specialMenu itemAtIndex:0] setEnabled:NO];
  [[specialMenu itemAtIndex:0] setTag:MPEntrySearchNone];
  [[specialMenu itemAtIndex:0] setAction:@selector(toggleSearchFlags:)];
  for(NSInteger iIndex = 0; iIndex < (sizeof(specialTags)/sizeof(NSInteger)); iIndex++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:titles[iIndex] action:@selector(toggleSearchFlags:) keyEquivalent:@""];
    [item setTag:specialTags[iIndex]];
    [specialMenu addItem:item];
  }
  [self.specialFilterPopUpButton setMenu:specialMenu];
  [self _updateFilterButtons];
}

#pragma mark MPDocument Notifications
- (void)registerNotificationsForDocument:(MPDocument *)document {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateFilterButtons) name:MPDocumentDidChangeSearchFlags object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterSearch:) name:MPDocumentDidEnterSearchNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didEnterHistory:) name:MPDocumentDidEnterHistoryNotification object:document];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didChangeCurrentItem:) name:MPDocumentCurrentItemChangedNotification object:document];
}

- (void)_didEnterSearch:(NSNotification *)notification {
  /* Select text if already visible */
  self.activeTab = MPContextTabFilter;
  [self _updateFilterButtons];
}

- (void)_didEnterHistory:(NSNotification *)notification {
  self.activeTab = MPContextTabHistory;
  [self _updateBindings];
}

- (void)_didChangeCurrentItem:(NSNotification *)notification {
  MPDocument *document = [notification object];

  BOOL showTrash = document.tree.metaData.useTrash && (document.selectedItem.isTrashed || document.selectedItem.isTrash);
  if(showTrash && ! document.hasSearch) {
    self.activeTab = MPContextTabTrash;
    [self _updateBindings];
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
- (void)_updateBindings {
  // only the entry view has to be bound, the rest not
}

- (void)_updateFilterButtons {
  MPDocument *document = [[self windowController] document];
  MPEntrySearchFlags currentFlags = document.searchContext.searchFlags;
  [self.duplicatePasswordsButton setState:HNHStateForBool(MPIsFlagSetInOptions(MPEntrySearchDoublePasswords, currentFlags))];
  [self.notesButton setState:HNHStateForBool(MPIsFlagSetInOptions(MPEntrySearchNotes, currentFlags))];
  [self.passwordButton setState:HNHStateForBool(MPIsFlagSetInOptions(MPEntrySearchPasswords, currentFlags))];
  [self.titleButton setState:HNHStateForBool(MPIsFlagSetInOptions(MPEntrySearchTitles, currentFlags))];
  [self.urlButton setState:HNHStateForBool(MPIsFlagSetInOptions(MPEntrySearchUrls, currentFlags))];
  [self.usernameButton setState:HNHStateForBool(MPIsFlagSetInOptions(MPEntrySearchUsernames, currentFlags))];
  NSInteger selectedTag = MPEntrySearchNone;
  for(NSMenuItem *item in [[self.specialFilterPopUpButton menu] itemArray]) {
    MPEntrySearchFlags flag = [item tag];
    if(flag == MPEntrySearchNone) {
      [item setState:NSOffState];
      [item setEnabled:NO];
    }
    else {
      BOOL isActive = MPIsFlagSetInOptions(flag, currentFlags);
      if(isActive) {
        selectedTag = flag;
      }
      [item setState:HNHStateForBool(isActive)];
    }
  }
  [self.specialFilterPopUpButton selectItemWithTag:selectedTag];
}

@end
