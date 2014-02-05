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
#import "MPEntryFilterHelper.h"

#import "NSButton+HNHTextColor.h"

NSUInteger const MPContextBarViewControllerActiveFilterMenuItemTag = 1000;

typedef NS_ENUM(NSUInteger, MPContextTab) {
  MPContextTabFilter,
  MPContextTabTrash,
  MPContextTabHistory
};


@interface MPContextBarViewController () {
@private
  BOOL _delegateRespondsToDidChangeFilter;
  BOOL _delegateRespondsToDidExitFilter;
  BOOL _delegateRespondsToDidExitHistory;
  BOOL _delegateRespondsToShouldEmptyTrash;
}

@property (nonatomic, assign) MPContextTab activeTab;
@property (nonatomic, assign) BOOL hasFilter;

/* Filter */
@property (weak) IBOutlet NSPopUpButton *filterTypePopupButton;
@property (weak) IBOutlet NSButton *filterDoneButton;
@property (weak) IBOutlet NSTextField *filterLabelTextField;
@property (weak) IBOutlet NSSearchField *filterSearchField;
/* History */
@property (weak) IBOutlet HNHGradientView *historyBar;
@property (weak) IBOutlet NSTextField *historyLabel;
@property (weak) IBOutlet NSButton *exitHistoryButton;
/* Trash*/
@property (weak) IBOutlet HNHGradientView *trashBar;
@property (weak) IBOutlet NSButton *emptyTrashButton;

@end

@implementation MPContextBarViewController

- (instancetype)init {
  self = [self initWithNibName:@"ContextBar" bundle:nil];
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _hasFilter = NO;
    _filterMode  = MPFilterTitles;
    _delegateRespondsToDidExitFilter = NO;
    _delegateRespondsToDidExitHistory = NO;
    _delegateRespondsToShouldEmptyTrash = NO;
    _delegateRespondsToDidChangeFilter = NO;
  }
  return self;
}

- (void)didLoadView {
 
  [[self.filterLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.filterTypePopupButton setMenu:[self _allocFilterMenu]];
 
  [self.filterSearchField setAction:@selector(_didChangeFilter)];
  [[self.filterSearchField cell] setSendsSearchStringImmediately:NO];
  
  self.historyBar.activeGradient = [[NSGradient alloc] initWithStartingColor:[NSColor redColor] endingColor:[NSColor greenColor]];
  
  NSArray *activeColors = @[
                            [NSColor colorWithCalibratedWhite:0.2 alpha:1],
                            [NSColor colorWithCalibratedWhite:0.4 alpha:1]
                            ];
  NSArray *inactiveColors = @[ [NSColor colorWithCalibratedWhite:0.3 alpha:1],
                               [NSColor colorWithCalibratedWhite:0.6 alpha:1]
                               ];
  self.trashBar.activeGradient = [[NSGradient alloc] initWithColors:activeColors];
  self.trashBar.inactiveGradient = [[NSGradient alloc] initWithColors:inactiveColors];
  [[self view] bind:NSSelectedIndexBinding toObject:self withKeyPath:@"activeTab" options:nil];

  self.emptyTrashButton.textColor = [NSColor whiteColor];
  
  if(self.nextKeyView) {
    [self.exitHistoryButton setNextKeyView:self.nextKeyView];
    [self.emptyTrashButton setNextKeyView:self.nextKeyView];
    [self.filterDoneButton setNextKeyView:self.nextKeyView];
  }
  
  [self _updateFilterMenu];
}

#pragma mark Properties
- (void)setFilterMode:(MPFilterMode)newFilterMode {
  if(_filterMode != newFilterMode) {
    if(newFilterMode == MPFilterNone) {
      newFilterMode = MPFilterTitles;
    }
    _filterMode = newFilterMode;
    [self _updateFilterMenu];
    [self _didChangeFilter];
  }
}

- (void)setDelegate:(id<MPContextBarDelegate>)delegate {
  if(self.delegate != delegate) {
    _delegate = delegate;
    _delegateRespondsToDidChangeFilter = [_delegate respondsToSelector:@selector(contextBarDidChangeFilter)];
    _delegateRespondsToDidExitFilter = [_delegate respondsToSelector:@selector(contextBarDidExitFilter)];
    _delegateRespondsToDidExitHistory = [_delegate respondsToSelector:@selector(contextBarDidExitHistory)];
    _delegateRespondsToShouldEmptyTrash = [_delegate respondsToSelector:@selector(contextBarShouldEmptyTrash)];
  }
}

- (void)disable {
  [self.filterSearchField setEnabled:NO];
}

- (void)enable {
  [self.filterSearchField setEnabled:YES];
  /* First responder handling */
  switch (self.activeTab) {
    case MPContextTabTrash:
      break;
      
    case MPContextTabFilter:
      [[[self view] window] makeFirstResponder:self.filterSearchField];
      break;
      
    case MPContextTabHistory:
      break;
      
    default:
      break;
  }
}

#pragma mark Actions
- (void)toggleFilterSpace:(id)sender {
  if(![sender isKindOfClass:[NSMenuItem class]]) {
    return; // Wrong sender
  }
  MPFilterMode toggledMode = [sender tag];
  if(toggledMode & self.filterMode) {
    /* Disable enabled flag */
    self.filterMode ^= toggledMode;
  }
  else {
    /* Enable disabled flag */
    self.filterMode |= toggledMode;
  }
}

- (void)exitFilter:(id)sender {
  if(!self.hasFilter) {
    return; // Nothing to do;
  }
  if(![self showsFilter]) {
    return; // We arent displaying the filter view
  }
  self.hasFilter = NO;
  [self.filterSearchField setStringValue:@""];
  if(_delegateRespondsToDidExitFilter) {
    [self.delegate contextBarDidExitFilter];
  }
}

- (void)showFilter {
  self.hasFilter = YES;
  /* Select text if already visible */
  if([self showsFilter]) {
    [self.filterSearchField selectText:self];
  }
  self.activeTab = MPContextTabFilter;
  [self _updateFilterMenu];
}

- (void)showHistory {
  [self exitFilter:self];
  self.activeTab = MPContextTabHistory;
  [self _updateBindings];
}

- (void)showTrash {
  [self exitFilter:self];
  self.activeTab = MPContextTabTrash;
  [self _updateBindings];
}

- (BOOL)showsFilter {
  return self.activeTab == MPContextTabFilter;
}

- (BOOL)showsHistory {
  return self.activeTab == MPContextTabHistory;
}

- (BOOL)showsTrash {
  return self.activeTab == MPContextTabTrash;
}

- (NSString *)filterString {
  return [self.filterSearchField stringValue];
}

- (BOOL)control:(NSControl*)control textView:(NSTextView*)textView doCommandBySelector:(SEL)commandSelector {
  if(commandSelector == @selector(insertNewline:)) {
    [self _didChangeFilter];
  }
  return NO;
}

- (void)_didChangeFilter {
  if(_delegateRespondsToDidChangeFilter) {
    [self.delegate contextBarDidChangeFilter];
  }
}

#pragma mark UI Helper
- (void)_updateBindings {
  // only the entry view has to be bound, the rest not
}

- (NSMenu *)_allocFilterMenu {
  NSMenu *searchMenu = [[NSMenu alloc] init];

  NSMenuItem *activeFilterItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SEARCH_IN", "") action:NULL keyEquivalent:@""];
  [activeFilterItem setTag:MPContextBarViewControllerActiveFilterMenuItemTag];
  [searchMenu addItem:activeFilterItem];
  [searchMenu addItem:[NSMenuItem separatorItem]];
  
  NSArray *titles = @[NSLocalizedString(@"TITLE", ""),
                      NSLocalizedString(@"PASSWORD", ""),
                      NSLocalizedString(@"URL", ""),
                      NSLocalizedString(@"USERNAME", "")
                      ];
  NSArray *tags = @[ @(MPFilterTitles),
                     @(MPFilterPasswords),
                     @(MPFilterUrls),
                     @(MPFilterUsernames) ];
  /* Attributes */
  for(NSUInteger index = 0; index < [tags count]; index++) {
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:titles[index] action:@selector(toggleFilterSpace:) keyEquivalent:@""];
    [item setTag:[tags[index] integerValue]];
    [item setTarget:self];
    [searchMenu addItem:item];
  }
  [searchMenu addItem:[NSMenuItem separatorItem]];
  /* Special Search */
  NSMenuItem *doublePasswordsItem = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DUPLICTE_PASSWORDS", "") action:NULL keyEquivalent:@""];
  [doublePasswordsItem setTag:MPFilterDoublePasswords];
  
  [searchMenu addItem:doublePasswordsItem];

  return searchMenu;
}

- (void)_updateFilterMenu {
  NSMenu *menu = [self.filterTypePopupButton menu];
  NSArray *allItems = [menu itemArray];
  NSArray *enabledItems = [self _filterItemsForMode:self.filterMode];
  for(NSMenuItem *item in allItems) {
    BOOL isSelected = [enabledItems containsObject:item];
    [item setState:(isSelected ? NSOnState : NSOffState)];
  }
  NSMenuItem *activeFilterItem = [menu itemWithTag:MPContextBarViewControllerActiveFilterMenuItemTag];
  __block NSMutableString *activeFilterTitle;
  [enabledItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    if(activeFilterTitle == nil) {
      activeFilterTitle = [[NSMutableString alloc] initWithString:[obj title]];
    }
    else {
      [activeFilterTitle appendFormat:@", %@", [obj title]];
    }
  }];
  [activeFilterItem setTitle:activeFilterTitle];
  [self.filterTypePopupButton selectItem:activeFilterItem];
}

- (NSArray *)_filterItemsForMode:(MPFilterMode)mode {
  NSArray *options = [MPEntryFilterHelper optionsEnabledInMode:mode];
  NSMenu *menu = [self.filterTypePopupButton menu];
  NSMutableArray *menuItems = [[NSMutableArray alloc] initWithCapacity:[[menu itemArray] count]];
  for(NSNumber *number in options) {
    MPFilterMode flag = [number integerValue];
    NSMenuItem *flagItem = [menu itemWithTag:flag];
    if(flagItem) {
      [menuItems addObject:flagItem];
    }
  }
  return menuItems;
}

@end
