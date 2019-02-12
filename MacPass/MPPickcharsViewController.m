//
//  MPPickcharViewController.m
//  MacPass
//
//  Created by Michael Starke on 23.11.17.
//  Copyright © 2017 HicknHack Software GmbH. All rights reserved.
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

#import "MPPickcharsViewController.h"
#import "NSString+MPComposedCharacterAdditions.h"

#import <HNHUi/HNHUi.h>

@interface MPPickcharsViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *characterTableView;
@property (weak) IBOutlet NSTextField *pickedValueTextField;
@property (weak) IBOutlet NSButton *togglePasswordDisplayButton;
@property (weak) IBOutlet NSTextField *messageTextField;
@property (weak) IBOutlet NSTextField *pickedStatusTextField;
@property (weak) IBOutlet NSButton *submitButton;

@property (nonatomic) NSInteger availableCountToPick;

@end

@implementation MPPickcharsViewController

+ (NSSet<NSString *> *)keyPathsForValuesAffectingAvailableCountToPick {
  return [NSSet setWithArray:@[NSStringFromSelector(@selector(minimumCharacterCount)), NSStringFromSelector(@selector(pickedValue))]];
}

- (NSString *)nibName {
  return @"PickcharsView";
}

- (instancetype)initWithCoder:(NSCoder *)coder {
  self = [super initWithCoder:coder];
  if(self) {
    self.hidePickedCharacters = NO;
    self.minimumCharacterCount = 0;
  }
  return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if(self) {
    self.hidePickedCharacters = NO;
    self.minimumCharacterCount = 0;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  for(NSTableColumn *column in self.characterTableView.tableColumns) {
    [self.characterTableView removeTableColumn:column];
  }
  for(NSUInteger count = 0; count < self.sourceValue.composedCharacterLength; count++) {
    
    NSString *columnTitle = [NSString stringWithFormat:@"%ld", count+1];
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

- (void)setHidePickedCharacters:(BOOL)hide {
  if(_hidePickedCharacters != hide) {
    _hidePickedCharacters = hide;
    [self.characterTableView reloadData];
  }
}

- (void)setPickedValue:(NSString *)pickedValue {
  _pickedValue = [pickedValue copy];
  [self _updateContent];
}

- (NSInteger)availableCountToPick {
  return (self.minimumCharacterCount - self.pickedValue.composedCharacterLength);
}

- (void)_updateContent {
  self.messageTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"PICKCHAR_INFO_MESSAGE_PICK_CHARACTERS_%ld", "Info about how many character has to pick in pickchar dialog"), self.minimumCharacterCount];
  if(self.minimumCharacterCount == 0) {
    self.pickedStatusTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"PICKED_%ld_CHARACTERS", @"Count of picked characters in pickchars dialog if no limit is set"), self.pickedValue.composedCharacterLength];
  }
  else {
    self.pickedStatusTextField.stringValue = [NSString stringWithFormat:NSLocalizedString(@"%ld_CHARACTERS_TO_PICK_REMAINING", @"Count of characters remaining in pickchars dialog"), self.availableCountToPick];
  }
  self.submitButton.enabled = (self.availableCountToPick == 0 || self.minimumCharacterCount == 0);
  if(self.availableCountToPick == 0 && self.minimumCharacterCount > 0) {
    [self submitValue:self];
  }
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
  view.textField.stringValue = self.hidePickedCharacters ? @"•" : [self.sourceValue composedCharacterAtIndex:index];
  return view;
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn {
  if(self.minimumCharacterCount != 0 && self.availableCountToPick <= 0) {
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

- (void)submitValue:(id)sender {
  [NSApp stopModalWithCode:NSModalResponseOK];
}

- (void)reset:(id)sender {
  self.pickedValue = @"";
}


@end
