//
//  MPPickfieldViewController.m
//  MacPass
//
//  Created by Michael Starke on 28.11.17.
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

#import "MPPickfieldViewController.h"
#import "MPPickfieldTableModel.h"

#import <KeePassKit/KeePassKit.h>

typedef NS_ENUM(NSUInteger, MPPickfieldTableColumn) {
  MPPickfieldNameTableColumn,
  MPPIckfieldValueTableColumn
};

@interface MPPickfieldViewController () <NSTableViewDelegate, NSTableViewDataSource>

@property (nonatomic, strong, readonly) KPKEntry *representedEntry;
@property (strong) MPPickfieldTableModel *tableModel;
@property (weak) IBOutlet NSTableView *tableView;
@property (copy) NSString *pickedValue;

@end

@implementation MPPickfieldViewController

@dynamic representedEntry;

- (NSString *)nibName {
  return @"PickfieldView";
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.tableModel = [[MPPickfieldTableModel alloc] initWithEntry:self.representedEntry];
}

- (KPKEntry *)representedEntry {
  if([self.representedObject isKindOfClass:KPKEntry.class]) {
    return self.representedObject;
  }
  return nil;
}

- (void)pickField:(id)sender {
  [NSApp stopModalWithCode:NSModalResponseOK];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
  return self.tableModel.items.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view;
  if(tableColumn) {
    view = [tableView makeViewWithIdentifier:@"DataCell" owner:self];
  }
  else {
    view = [tableView makeViewWithIdentifier:@"HeaderCell" owner:self];
  }
  MPPickfieldTableModelRowItem *rowItem = [self.tableModel itemAtIndex:row];
  view.textField.stringValue = @"";

  if(!rowItem) {
    return view;
  }
  
  MPPickfieldTableColumn columnIndex = (tableColumn == nil
                                        ? MPPickfieldNameTableColumn
                                        : [tableView.tableColumns indexOfObjectIdenticalTo:tableColumn]);
  
  /* group view or first column */
  switch (columnIndex) {
    case MPPickfieldNameTableColumn:
      view.textField.stringValue = rowItem.name;
      break;
    case MPPIckfieldValueTableColumn:
      view.textField.stringValue = rowItem.isProtected ? @"•••" : rowItem.value;
      break;
    default:
      break;
  }
  return view;
}

- (BOOL)tableView:(NSTableView *)tableView isGroupRow:(NSInteger)row {
  MPPickfieldTableModelRowItem *rowItem = [self.tableModel itemAtIndex:row];
  return rowItem.isGroup;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
  return ![self tableView:tableView isGroupRow:row];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *tableView = notification.object;
  if(tableView.selectedRow < 0) {
    self.pickedValue = @"";
  }
  else {
    MPPickfieldTableModelRowItem *item = [self.tableModel itemAtIndex:tableView.selectedRow];
    self.pickedValue = item ? item.value : @"";
  }
}

@end
