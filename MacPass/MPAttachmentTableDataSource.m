//
//  MPAttachmentTableDataSource.m
//  MacPass
//
//  Created by Michael Starke on 01.08.13.
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

#import "MPAttachmentTableDataSource.h"
#import "MPDocument.h"

@implementation MPAttachmentTableDataSource

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
  /* allow drag between databases? */
  NSPasteboard *draggingPasteBoard = [info draggingPasteboard];
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:@[NSURL.class] options:nil];
  NSUInteger numberOfDirectories = 0;
  for(NSURL *url in arrayOfURLs) {
    if(url.fileURL || url.fileReferenceURL) {
      NSError *error = nil;
      NSDictionary *resourceKeys = [url resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
      if([resourceKeys[NSURLIsDirectoryKey] boolValue] == YES) {
        numberOfDirectories++;
      }
      continue;
    }
    return NSDragOperationNone;
  }
  if(numberOfDirectories == arrayOfURLs.count) {
    return NSDragOperationNone;
  }
  
  if(dropOperation == NSTableViewDropOn) {
    [tableView setDropRow:row+1 dropOperation:NSTableViewDropAbove];
  }
  return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
  MPDocument *document = tableView.window.windowController.document;
  KPKEntry *entry = document.selectedEntries.count == 1 ? document.selectedEntries.lastObject : nil;
  
  NSArray *arrayOfURLs = [info.draggingPasteboard readObjectsForClasses:@[NSURL.class] options:nil];
  
  for(NSURL *fileUrl in arrayOfURLs) {
    [document addAttachment:fileUrl toEntry:entry];
  }
  return YES;
}

- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
  [pboard declareTypes:@[NSFilesPromisePboardType] owner:nil];
  MPDocument *document = tableView.window.windowController.document;
  KPKEntry *entry = document.selectedEntries.count == 1 ? document.selectedEntries.lastObject : nil;
  NSMutableArray *fileNames = [[NSMutableArray alloc] init];
  for(KPKBinary *binary in [entry.binaries objectsAtIndexes:rowIndexes]) {
    if(binary.name) {
      [fileNames addObject:binary.name];
    }
  }
  [pboard setPropertyList:fileNames forType:NSFilesPromisePboardType];
  return YES;
}

- (NSArray<NSString *> *)tableView:(NSTableView *)tableView namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination forDraggedRowsWithIndexes:(NSIndexSet *)indexSet {
  MPDocument *document = tableView.window.windowController.document;
  KPKEntry *entry = document.selectedEntries.count == 1 ? document.selectedEntries.lastObject : nil;
  NSMutableArray<NSString *> *fileNames = [[NSMutableArray alloc] init];
  NSArray<KPKBinary *> *draggedBinaries = [entry.binaries objectsAtIndexes:indexSet];
  for(KPKBinary *binary in draggedBinaries) {
    if(binary.name) {
      [fileNames addObject:binary.name];
      dispatch_queue_t queue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
      dispatch_async(queue, ^{
        NSError *error;
        NSURL *saveLocation = [dropDestination URLByAppendingPathComponent:binary.name];
        BOOL success = [binary saveToLocation:saveLocation error:&error];
        if(!success && error) {
          dispatch_async(dispatch_get_main_queue(), ^{
            [NSApp presentError:error];
          });
        }
      });
    }
  }
  return [fileNames copy];
}

/*
 - (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
  MPDocument *document = tableView.window.windowController.document;
  KPKEntry *entry = document.selectedEntries.count == 1 ? document.selectedEntries.lastObject : nil;

  if(!entry) {
    return nil;
  }
  if (@available(macOS 10.12, *)) {
    KPKBinary *binary = entry.binaries[row];
    NSFilePromiseProvider *provider = [[NSFilePromiseProvider alloc] initWithFileType:(NSString *)kUTTypeXML delegate:binary];
    return provider;
  }
  return nil;
}
 */

@end
