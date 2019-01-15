//
//  MPAttachmentTableViewDelegate.m
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

#import "MPAttachmentTableViewDelegate.h"

#import "MPDocument.h"
#import "MPEntryInspectorViewController.h"
#import "MPSelectedAttachmentTableCellView.h"

#import "KeePassKit/KeePassKit.h"

#import "HNHUi/HNHUi.h"

@implementation MPAttachmentTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *tableView = notification.object;
  NSIndexSet *allColumns = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tableView.numberOfColumns)];
  NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tableView.numberOfRows )];
  [tableView reloadDataForRowIndexes:indexSet columnIndexes:allColumns];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  /* Decide what view to use */
  NSIndexSet *selectedIndexes = [tableView selectedRowIndexes];
  NSTableCellView *view;
  if([selectedIndexes containsIndex:row]) {
    MPSelectedAttachmentTableCellView *cellView  = [tableView makeViewWithIdentifier:@"SelectedCell" owner:tableView];
    cellView.actionButton.menu = [self allocateActionMenu];
    view = cellView;
  }
  else {
    view = [tableView makeViewWithIdentifier:@"NormalCell" owner:tableView];
  }
  /* Bind view */
  KPKBinary *binary = view.objectValue;
  NSString *nameKeyPath = [NSString stringWithFormat:@"%@.%@", NSStringFromSelector(@selector(objectValue)), NSStringFromSelector(@selector(name))];
  [view.textField bind:NSValueBinding toObject:view withKeyPath:nameKeyPath options:nil];
  view.imageView.image = [[NSWorkspace sharedWorkspace] iconForFileType:binary.name.pathExtension];
  return view;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
  HNHUITableRowView *view = nil;
  view = [[HNHUITableRowView alloc] init];
  view.selectionCornerRadius = 7;
  return view;
}

- (NSMenu *)allocateActionMenu {
  NSMenu *menu = [[NSMenu alloc] init];
  /* Image for Popup button */
  NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"" action:NULL keyEquivalent:@""];
  item.image = [NSImage imageNamed:NSImageNameActionTemplate];
  [menu addItem:item];
  /* Quicklook */
  [menu addItemWithTitle:NSLocalizedString(@"PREVIEW", "Menu item to preview the selected attached file.") action:@selector(toggleQuicklookPreview:) keyEquivalent:@""];
  /* Save */
  item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"SAVE", "Menu item to save the selected attached file.") action:@selector(saveAttachment:) keyEquivalent:@""];
  item.target = self.viewController;
  [menu addItem:item];
  /* Remove */
  [menu addItem:[NSMenuItem separatorItem]];
  item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"DELETE", "Menu item to delete the selected attached file") action:@selector(removeAttachment:) keyEquivalent:@""];
  item.target = self.viewController;
  [menu addItem:item];
  
  return menu;
}

@end
