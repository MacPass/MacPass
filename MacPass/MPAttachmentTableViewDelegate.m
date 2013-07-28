//
//  MPAttachmentTableViewDelegate.m
//  MacPass
//
//  Created by Michael Starke on 17.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAttachmentTableViewDelegate.h"

#import "MPDocument.h"
#import "MPSelectedAttachmentTableCellView.h"

#import "Kdb4Node.h"
#import "Kdb3Node.h"

#import "HNHTableRowView.h"

@implementation MPAttachmentTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  NSTableView *tableView = [notification object];
  MPDocument *document = [[[tableView window] windowController] document];
  NSIndexSet *allColumns = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[tableView tableColumns] count])];
  if([document.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entryv4 = (Kdb4Entry *)document.selectedEntry;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [entryv4.binaries count] )];
    [tableView reloadDataForRowIndexes:indexSet columnIndexes:allColumns];
  }
  if([document.selectedEntry isKindOfClass:[Kdb3Entry class]]) {
    Kdb3Entry *entryv3 = (Kdb3Entry *)document.selectedEntry;
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, (entryv3.binary ? 1 : 0 ))];
    [tableView reloadDataForRowIndexes:indexSet columnIndexes:allColumns];
  }
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  /* Decide what view to use */
  MPDocument *document = [[[tableView window] windowController] document];
  NSIndexSet *selectedIndexes = [tableView selectedRowIndexes];
  NSTableCellView *view;
  if([selectedIndexes containsIndex:row]) {
    MPSelectedAttachmentTableCellView *cellView  = [tableView makeViewWithIdentifier:@"SelectedCell" owner:tableView];
    [cellView.saveButton setTag:row];
    [cellView.saveButton setAction:@selector(saveAttachment:)];
    [cellView.saveButton setTarget:self.viewController];
    [cellView.removeButton setTag:row];
    [cellView.removeButton setAction:@selector(removeAttachment:)];
    [cellView.removeButton setTarget:nil];
    [cellView.removeButton setTarget:self.viewController];
    view = cellView;
  }
  else {
    view = [tableView makeViewWithIdentifier:@"NormalCell" owner:tableView];
  }
  /* Bind view */
  if([document.selectedEntry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entry = (Kdb4Entry *)document.selectedEntry;
    BinaryRef *binaryRef = entry.binaries[row];
    [[view textField] bind:NSValueBinding toObject:binaryRef withKeyPath:@"key" options:nil];
    [[view imageView] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:[binaryRef.key pathExtension]]];
  }
  else {
    Kdb3Entry *entry= (Kdb3Entry *)document.selectedEntry;
    [[view textField] bind:NSValueBinding toObject:entry withKeyPath:@"binaryDesc" options:nil];
    [[view imageView] setImage:[[NSWorkspace sharedWorkspace] iconForFileType:[entry.binaryDesc pathExtension]]];
  }
  return view;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
  HNHTableRowView *view = nil;
  view = [[HNHTableRowView alloc] init];
  view.selectionCornerRadius = 7;
  return view;
}

@end
