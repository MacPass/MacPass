//
//  MPCustomFieldTableDelegate.m
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
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

#import "MPCustomFieldTableViewDelegate.h"
#import "MPCustomFieldTableCellView.h"
#import "MPEntryInspectorViewController.h"
#import "HNHUi/HNHUi.h"
#import "KeePassKit/KeePassKit.h"

NSInteger MPCustomFieldTagOffset = 50000;

NSInteger MPCustomFieldIndexFromTag(NSInteger tag) {
  return MAX(-1, tag - MPCustomFieldTagOffset);
}

@implementation MPCustomFieldTableViewDelegate


/*
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
  static NSTextFieldCell *cell;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
     cell = [[NSTextFieldCell alloc] init];
  });
  
  cell.stringValue = @"Mutli!";
  NSTableColumn *column = tableView.tableColumns.firstObject;
  NSRect frame = NSMakeRect(0, 0, column.width, CGFLOAT_MAX);
  return [cell cellSizeForBounds:frame].height + 38;
}
*/

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  MPCustomFieldTableCellView *view = [tableView makeViewWithIdentifier:@"SelectedCell" owner:tableView];
  
  [view.labelTextField bind:NSValueBinding
                   toObject:view
                withKeyPath:@"objectValue.key"
                    options:@{ NSValidatesImmediatelyBindingOption: @YES }];
  [view.valueTextField bind:NSValueBinding
                   toObject:view
                withKeyPath:@"objectValue.value"
                    options:nil];
  [view.protectedButton bind:NSValueBinding
                    toObject:view
                 withKeyPath:@"objectValue.isProtected"
                     options:nil];
  
  [view.valueTextField bind:NSStringFromSelector(@selector(showPassword))
                   toObject:view
                withKeyPath:@"objectValue.isProtected"
                    options:@{NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
  
  
  for(NSControl *control in @[view.labelTextField, view.valueTextField, view.removeButton, view.protectedButton ]) {
    [control bind:NSEnabledBinding
         toObject:view
      withKeyPath:@"objectValue.isEditable"
          options:@{NSConditionallySetsEditableBindingOption: @NO }];
    
  }
  view.valueTextField.tag = (MPCustomFieldTagOffset + row);
  view.valueTextField.delegate = self.viewController;
  
  view.removeButton.target = self.viewController;
  view.removeButton.action = @selector(removeCustomField:);
  view.removeButton.tag = row;
  
  view.observer = tableView.window.windowController.document;
  
  
  return view;
}


@end
