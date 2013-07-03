//
//  MPEntyTableDataSource.m
//  MacPass
//
//  Created by Michael Starke on 09.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryTableDataSource.h"
#import "MPEntryViewController.h"
#import "UUID.h"
#import "MPConstants.h"

@interface MPEntryTableDataSource ()

@end

@implementation MPEntryTableDataSource

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
  
  if([rowIndexes count] != 1) {
    return NO; // No valid drag
  }
  
  id entry = [self.viewController.entryArrayController arrangedObjects][[rowIndexes firstIndex]];
  
  if(![entry respondsToSelector:@selector(uuid)]) {
    return NO; // Invalid item for dragging
  }
  UUID *uuid = (UUID *)[entry uuid];
  NSPasteboardItem *pBoardItem = [[NSPasteboardItem alloc] init];
  [pBoardItem setString:[uuid description] forType:MPPasteBoardType];
  [pboard writeObjects:@[pBoardItem]];
  
  return YES;
}

//TODO: Validation and adding

@end
