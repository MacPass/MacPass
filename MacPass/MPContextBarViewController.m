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
#import "MPDocumentSearchService.h"

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

- (instancetype)init {
  self = [self initWithNibName:@"ContextBar" bundle:nil];
  return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _hasFilter = NO;
    _delegateRespondsToDidExitFilter = NO;
    _delegateRespondsToDidExitHistory = NO;
    _delegateRespondsToShouldEmptyTrash = NO;
    _delegateRespondsToDidChangeFilter = NO;
  }
  return self;
}

- (void)didLoadView {
 
  [[self.filterLabelTextField cell] setBackgroundStyle:NSBackgroundStyleRaised];
  
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
  [self _updateFilterButtons];
}

#pragma mark Properties
- (void)setFilterMode:(MPFilterMode)newFilterMode {
  if(_filterMode != newFilterMode) {
    if(newFilterMode == MPEntrySearchNone) {
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

@end
