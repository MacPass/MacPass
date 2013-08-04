//
//  MPEntyTableDataSource.m
//  MacPass
//
//  Created by Michael Starke on 09.06.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPEntryTableDataSource.h"
#import "MPEntryViewController.h"

#import "Kdb.h"
#import "UUID+Pasterboard.h"

#import "MPConstants.h"

@interface MPEntryTableDataSource ()

@end

@implementation MPEntryTableDataSource

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
  
  if([rowIndexes count] != 1) {
    return NO; // No valid drag
  }
  
  id item = [self.viewController.entryArrayController arrangedObjects][[rowIndexes firstIndex]];
  if(![item isKindOfClass:[KdbEntry class]]) {
    return NO;
  }
  KdbEntry *entry = (KdbEntry *)item;
  [pboard writeObjects:@[entry.uuid]];
  return YES;
}

@end
