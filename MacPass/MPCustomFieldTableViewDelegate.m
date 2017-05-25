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

#import "KeePassKit/KeePassKit.h"

@implementation MPCustomFieldTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  MPCustomFieldTableCellView *view = [tableView makeViewWithIdentifier:@"SelectedCell" owner:tableView];
    
  [view.labelTextField bind:NSValueBinding
                   toObject:view
                withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(objectValue)), NSStringFromSelector(@selector(key))]
                    options:@{ NSValidatesImmediatelyBindingOption: @YES }];
  [view.valueTextField bind:NSValueBinding
                   toObject:view
                withKeyPath:[NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(objectValue)), NSStringFromSelector(@selector(value))]
                    options:nil];
  view.removeButton.target = self.viewController;
  view.removeButton.action = @selector(removeCustomField:);
  view.removeButton.tag = row;
  
  view.observer = tableView.window.windowController.document;
  
  return view;
}

@end
