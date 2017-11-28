//
//  MPPickcharViewController.m
//  MacPass
//
//  Created by Michael Starke on 23.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
//

#import "MPPickcharViewController.h"
#import "NSString+MPComposedCharacterAdditions.h"

#import <HNHUi/HNHUi.h>

@interface MPPickcharViewController () <NSTableViewDelegate, NSTableViewDataSource>
@property (weak) IBOutlet NSTableView *characterTableView;
@property (weak) IBOutlet NSTextField *pickedValueTextField;
@property (weak) IBOutlet NSButton *togglePasswordDisplayButton;
@property (weak) IBOutlet NSTextField *pickedStatusTextField;
@property (nonatomic) NSInteger availableCountToPick;
@end

@implementation MPPickcharViewController

+ (NSSet<NSString *> *)keyPathsForValuesAffectingAvailableCountToPick {
  return [NSSet setWithArray:@[NSStringFromSelector(@selector(countToPick)), NSStringFromSelector(@selector(pickedValue))]];
}

- (NSString *)nibName {
  return @"PickcharView";
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.hideSource = NO;
  }
  return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    self.hideSource = NO;
  }
  return self;
}
- (void)reset:(id)sender {
  self.pickedValue = @"";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  for(NSTableColumn *column in self.characterTableView.tableColumns) {
    [self.characterTableView removeTableColumn:column];
  }
  for(NSUInteger count = 0; count < self.sourceValue.composedCharacterLength; count++) {
    
    NSString *columnTitle = [NSString stringWithFormat:@"%ld", count];
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:columnTitle];
    column.maxWidth = 32.0;
    column.minWidth = column.maxWidth;
    column.headerCell.stringValue = columnTitle;
    [self.characterTableView addTableColumn:column];
  }
  self.characterTableView.enclosingScrollView.horizontalScroller.scrollerStyle = NSScrollerStyleLegacy;
  [self.pickedValueTextField bind:NSValueBinding toObject:self withKeyPath:NSStringFromSelector(@selector(pickedValue)) options:nil];
  [self.togglePasswordDisplayButton bind:NSValueBinding toObject:self.pickedValueTextField withKeyPath:NSStringFromSelector(@selector(showPassword)) options:nil];

  [self reset:self];
}

- (void)setHideSource:(BOOL)hideSource {
  if(_hideSource != hideSource) {
    _hideSource = hideSource;
    [self.characterTableView reloadData];
  }
}

- (void)setPickedValue:(NSString *)pickedValue {
  _pickedValue = [pickedValue copy];
  [self _updatePickedStatus];
}

- (NSInteger)availableCountToPick {
  return (self.countToPick - self.pickedValue.composedCharacterLength);
}

- (void)_updatePickedStatus {
  self.pickedStatusTextField.stringValue = [NSString stringWithFormat:@"%ld characters remaining", self.availableCountToPick];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  if(tableView != self.characterTableView) {
    return 0;
  }
  return 1;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:@"Cell" owner:self];
  NSInteger index = [tableView.tableColumns indexOfObjectIdenticalTo:tableColumn];
  if(index == NSNotFound) {
    view.textField.stringValue = @"?";
  }
  view.textField.stringValue = self.hideSource ? @"•" : [self.sourceValue composedCharacterAtIndex:index];
  return view;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
  if(self.availableCountToPick <= 0) {
    return;
  }
  NSInteger index = [tableView.tableColumns indexOfObjectIdenticalTo:tableColumn];
  if(index == NSNotFound) {
    return;
  }
  if(self.pickedValue) {
    self.pickedValue = [self.pickedValue stringByAppendingString:[self.sourceValue composedCharacterAtIndex:index]];
  }
  else {
    self.pickedValue = [self.sourceValue composedCharacterAtIndex:index];
  }
}

- (IBAction)finishedPicking:(id)sender {
  [NSApp stopModalWithCode:NSModalResponseOK];
}

- (IBAction)cancelPicking:(id)sender {
  [NSApp stopModalWithCode:NSModalResponseCancel];
}

@end
