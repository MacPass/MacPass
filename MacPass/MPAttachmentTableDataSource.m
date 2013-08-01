//
//  MPAttachmentTableDataSource.m
//  MacPass
//
//  Created by Michael Starke on 01.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPAttachmentTableDataSource.h"
#import "MPDocument.h"


@implementation MPAttachmentTableDataSource

- (NSDragOperation)tableView:(NSTableView *)tableView
                validateDrop:(id<NSDraggingInfo>)info
                 proposedRow:(NSInteger)row
       proposedDropOperation:(NSTableViewDropOperation)dropOperation {
  
  NSPasteboard *draggingPasteBoard = [info draggingPasteboard];
  NSArray *classArray = [NSArray arrayWithObject:[NSURL class]];
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:classArray options:nil];
  NSUInteger numberOfDirectories = 0;
  for(NSURL *url in arrayOfURLs) {
    if([url isFileURL] || [url isFileReferenceURL]) {
      NSError *error = nil;
      NSDictionary *resourceKeys = [url resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
      if( [resourceKeys[ NSURLIsDirectoryKey ] boolValue] == YES ) {
        numberOfDirectories++;
      }
      continue;
    }
    return NSDragOperationNone;
  }
  if(numberOfDirectories == [arrayOfURLs count]) {
    return NSDragOperationNone;
  }
  row = [tableView numberOfRows];
  return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView
       acceptDrop:(id<NSDraggingInfo>)info
              row:(NSInteger)row
    dropOperation:(NSTableViewDropOperation)dropOperation {
  
  MPDocument *document = [[[tableView window] windowController] document];
  id entry = document.selectedEntry;
  
  NSPasteboard *draggingPasteBoard = [info draggingPasteboard];
  NSArray *classArray = [NSArray arrayWithObject:[NSURL class]];
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:classArray options:nil];
  
  for(NSURL *fileUrl in arrayOfURLs) {
    [document addAttachment:fileUrl toEntry:entry];
  }
  return YES;
}

@end
