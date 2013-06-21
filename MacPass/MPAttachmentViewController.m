//
//  MPAttachmentViewController.m
//  MacPass
//
//  Created by Michael Starke on 21.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAttachmentViewController.h"
#import "Kdb4Node.h"

@interface MPAttachmentViewController ()

@property (retain) NSArrayController *attachmentController;

@end

@implementation MPAttachmentViewController

- (id)init {
  self = [super initWithNibName:@"AttachmentView" bundle:nil];
  if(self) {
  }
  return self;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *tableCellView = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:tableView];
  BinaryRef *binaryRef = [self.attachmentController arrangedObjects][row];
  [tableCellView.textField bind:NSValueBinding toObject:binaryRef withKeyPath:@"key" options:nil];
  return tableCellView;
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row {
  NSLog(@"didAddRowView");
}

@end
