//
//  MPContextBarViewController.m
//  MacPass
//
//  Created by Michael Starke on 16/12/13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPContextBarViewController.h"
#import "HNHGradientView.h"

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
@property (weak) IBOutlet NSButton *filterDoneButton;
@property (weak) IBOutlet NSButton *filterTitleButton;
@property (weak) IBOutlet NSButton *filterUsernameButton;
@property (weak) IBOutlet NSButton *filterURLButton;
@property (weak) IBOutlet NSButton *filterPasswordButton;
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
  [self.filterURLButton setTag:MPFilterUrls];
  [self.filterUsernameButton setTag:MPFilterUsernames];
  [self.filterTitleButton setTag:MPFilterTitles];
  [self.filterPasswordButton setTag:MPFilterPasswords];
  [[self.filterLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  [self.filterDoneButton setAction:@selector(exitFilter)];
  [self.filterDoneButton setTarget:self];
  
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

  if(self.nextKeyView) {
    [self.exitHistoryButton setNextKeyView:self.nextKeyView];
    [self.emptyTrashButton setNextKeyView:self.nextKeyView];
    [self.filterDoneButton setNextKeyView:self.nextKeyView];
  }
}

#pragma mark Properties
- (void)setFilterMode:(MPFilterModeType)newFilterMode {
  if(_filterMode != newFilterMode) {
    if(newFilterMode == MPFilterNone) {
      newFilterMode = MPFilterTitles;
    }
    _filterMode = newFilterMode;
    [self _updateFilterButtons];
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

- (NSArray *)filterPredicates {
  if(![self hasFilter]) {
    return nil;
  }
  NSMutableArray *prediactes = [[NSMutableArray alloc] initWithCapacity:4];
  if([self _shouldFilterTitles]) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", [self filterString]]];
  }
  if([self _shouldFilterUsernames]) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.username CONTAINS[cd] %@", [self filterString]]];
  }
  if([self _shouldFilterURLs]) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.url CONTAINS[cd] %@", [self filterString]]];
  }
  if([self _shouldFilterPasswords]) {
    [prediactes addObject:[NSPredicate predicateWithFormat:@"SELF.password CONTAINS[cd] %@", [self filterString]]];
  }
  return prediactes;
}

- (IBAction)toggleFilterSpace:(id)sender {
  if(![sender isKindOfClass:[NSButton class]]) {
    return; // Wrong sender
  }
  NSButton *button = sender;
  MPFilterModeType toggledMode = [button tag];
  switch ([button state]) {
    case NSOnState:
      self.filterMode |= toggledMode;
      break;
      
    case NSOffState:
      self.filterMode ^= toggledMode;
      break;
      
    default:
      break;
  }
}

- (void)showFilter {
  self.hasFilter = YES;
  /* Select text if already visible */
  if([self showsFilter]) {
    [self.filterSearchField selectText:self];
  }
  self.activeTab = MPContextTabFilter;
  [self _updateFilterButtons];
}

- (void)showHistory {
  [self exitFilter];
  self.activeTab = MPContextTabHistory;
  [self _updateBindings];
}

- (void)showTrash {
  [self exitFilter];
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

- (void)exitFilter {
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

- (void)_didChangeFilter {
  if(_delegateRespondsToDidChangeFilter) {
    [self.delegate contextBarDidChangeFilter];
  }
}

- (void)_updateBindings {
  // only the entry view has to be bound, the rest not
}

- (void)_updateFilterButtons {
  [self.filterTitleButton setState:[self _shouldFilterTitles] ? NSOnState : NSOffState];
  [self.filterURLButton setState:[self _shouldFilterURLs] ? NSOnState : NSOffState ];
  [self.filterUsernameButton setState:[self _shouldFilterUsernames] ? NSOnState : NSOffState];
  [self.filterPasswordButton setState:[self _shouldFilterPasswords] ? NSOnState : NSOffState];
}

- (BOOL)_shouldFilterTitles {
  return (MPFilterNone != (self.filterMode & MPFilterTitles));
}

- (BOOL)_shouldFilterURLs {
  return (MPFilterNone != (self.filterMode & MPFilterUrls));
}

- (BOOL)_shouldFilterUsernames {
  return (MPFilterNone != (self.filterMode & MPFilterUsernames));
}

- (BOOL)_shouldFilterPasswords {
  return (MPFilterNone != (self.filterMode & MPFilterPasswords));
}


@end
