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
/*
- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
  NSString *extension;
  
  if([rowIndexes count] != 1) {
    return NO; // We only work with one file at a time
  }
  MPDocument *document = [[[tableView window] windowController] document];
  id entry = document.selectedEntry;
  NSUInteger row = [rowIndexes lastIndex];
  if([entry isKindOfClass:[Kdb3Entry class]]) {
    Kdb3Entry *entryV3 = (Kdb3Entry *)entry;
    extension = [entryV3.binaryDesc pathExtension];
  }
  else if([entry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entryV4 = (Kdb4Entry *)entry;
    BinaryRef *binaryRef = entryV4.binaries[row];
    extension = [binaryRef.key pathExtension];
  }
  NSString *uti = CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag( kUTTagClassFilenameExtension, (__bridge CFStringRef)(extension), NULL ));
  
  [pboard setPropertyList:@[uti] forType:(NSString *)kPasteboardTypeFilePromiseContent];
  [pboard setPropertyList:@[uti] forType:(NSString *)kPasteboardTypeFileURLPromise ];
  return YES;
}
- (NSArray *)tableView:(NSTableView *)tableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
  if([indexSet count] != 1) {
    return nil; // We only work with one file at a time
  }
  
  if(![dropDestination isFileURL]) {
    return nil;
  }
  
  NSUInteger row = [indexSet lastIndex];
  NSData *fileData;
  NSString *filename;
  
  MPDocument *document = [[[tableView window] windowController] document];
  id entry = document.selectedEntry;

  if([entry isKindOfClass:[Kdb3Entry class]]) {
    Kdb3Entry *entryV3 = (Kdb3Entry *)entry;
    filename = entryV3.binaryDesc;
    fileData = entryV3.binary;
  }
  else if([entry isKindOfClass:[Kdb4Entry class]]) {
    Kdb4Entry *entryV4 = (Kdb4Entry *)entry;
    BinaryRef *binaryRef = entryV4.binaries[row];
    filename = binaryRef.key;
    fileData = [document attachmentDataForItem:binaryRef];
  }
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSURL *writeURL = [dropDestination URLByAppendingPathComponent:filename];
      // Create unique filename if already present
    [fileData writeToURL:writeURL atomically:YES];
  });
  return @[filename];
}
 */

@end
