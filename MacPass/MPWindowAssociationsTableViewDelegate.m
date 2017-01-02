//
//  MPWindowAssociationsTableViewDelegate.m
//  MacPass
//
//  Created by Michael Starke on 13.02.14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPWindowAssociationsTableViewDelegate.h"

#import "MPDocument.h"

#import "KeePassKit/KeePassKit.h"

@implementation MPWindowAssociationsTableViewDelegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
  // update add/remove buttons?
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
  NSTableCellView *view = [tableView makeViewWithIdentifier:@"WindowAssociationCell" owner:tableView];
  NSString *windowTitleKeyPath = [NSString stringWithFormat:@"%@.%@",
                                  NSStringFromSelector(@selector(objectValue)),
                                  NSStringFromSelector(@selector(windowTitle))];
  
  [view.textField bind:NSValueBinding toObject:view withKeyPath:windowTitleKeyPath options:nil];
  return view;
}

@end
