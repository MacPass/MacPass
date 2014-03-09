//
//  MPContextBarViewController.m
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPContextBarViewController.h"
#import "HNHGradientView.h"
#import "KPKEntry.h"
#import "MPDocument+HistoryBrowsing.h"
#import "MPDocument+Search.h"

#import "NSButton+HNHTextColor.h"
#import "MPFlagsHelper.h"
#import "HNHCommon.h"

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
@property (weak) IBOutlet HNHGradientView *historyBar;
@property (weak) IBOutlet NSTextField *historyLabel;
@property (weak) IBOutlet NSButton *exitHistoryButton;
/* Trash*/
@property (weak) IBOutlet HNHGradientView *trashBar;
@property (weak) IBOutlet NSButton *emptyTrashButton;

@end

@implementation MPContextBarViewController

#pragma mark Livecycle
- (instancetype)init {
  self = [self initWithNibName:@"ContextBar" bundle:nil];
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didLoadView {
  
  [[self.filterLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  
  self.historyBar.activeGradient = [[NSGradient alloc] initWithStartingColor:[NSColor redColor] endingColor:[NSColor greenColor]];
  
  NSArray *activeColors = @[[NSColor colorWithCalibratedWhite:0.2 alpha:1],[NSColor colorWithCalibratedWhite:0.4 alpha:1]];
  NSArray *inactiveColors = @[[NSColor colorWithCalibratedWhite:0.3 alpha:1],[NSColor colorWithCalibratedWhite:0.6 alpha:1]];
  self.trashBar.activeGradient = [[NSGradient alloc] initWithColors:activeColors];
  self.trashBar.inactiveGradient = [[NSGradient alloc] initWithColors:inactiveColors];
  [[self view] bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];
  
  self.emptyTrashButton.textColor = [NSColor whiteColor];
  
  NSInteger tags[] = { MPEntrySearchTitles, MPEntrySearchUsernames, MPEntrySearchPasswords, MPEntrySearchNotes, MPEntrySearchUrls, MPEntrySearchDoublePasswords };
  NSArray *buttons  = @[self.titleButton, self.usernameButton, self.passwordButton, self.notesButton, self.urlButton, self.duplicatePasswordsButton ];
  for(NSUInteger iIndex = 0; iIndex < [buttons count]; iIndex++) {
    [buttons[iIndex] setAction:@selector(toggleSearchFlags:)];
    [buttons[iIndex] setTag:tags[iIndex]];
  }
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
  BOOL showTrash = document.useTrash && (document.selectedGroup == document.trash || [document isItemTrashed:document.selectedItem]);
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
  [self.duplicatePasswordsButton setState:HNHStateForBool(MPTestFlagInOptions(MPEntrySearchDoublePasswords, document.activeFlags))];
  [self.notesButton setState:HNHStateForBool(MPTestFlagInOptions(MPEntrySearchNotes, document.activeFlags))];
  [self.passwordButton setState:HNHStateForBool(MPTestFlagInOptions(MPEntrySearchPasswords, document.activeFlags))];
  [self.titleButton setState:HNHStateForBool(MPTestFlagInOptions(MPEntrySearchTitles, document.activeFlags))];
  [self.urlButton setState:HNHStateForBool(MPTestFlagInOptions(MPEntrySearchUrls, document.activeFlags))];
  [self.usernameButton setState:HNHStateForBool(MPTestFlagInOptions(MPEntrySearchUsernames, document.activeFlags))];
}

@end
