//
//  MPDocumentWindowDelegate.m
//  MacPass
//
//  Created by Michael Starke on 25.07.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocumentWindowDelegate.h"
#import "MPDocument.h"
#import "Kdb.h"
#import "KdbEntry+Undo.h"

@implementation MPDocumentWindowDelegate

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  
  MPDocument *document = [[[sender draggingDestinationWindow] windowController] document];
  if(document.isLocked || !document.decrypted) {
    return NSDragOperationNone;
  }
  
  NSPasteboard *draggingPasteBoard = [sender draggingPasteboard];
  
  NSArray *classArray = [NSArray arrayWithObject:[NSURL class]];
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:classArray options:nil];
  BOOL ok;
  for(NSURL *url in arrayOfURLs) {
    if([url isFileURL] || [url isFileReferenceURL]) {
      continue;
      ok = NO;
    }
    ok = YES;
  }
  return ok ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
  return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  

  NSPasteboard *draggingPasteBoard = [sender draggingPasteboard];
  NSArray *classArray = [NSArray arrayWithObject:[NSURL class]];
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:classArray options:nil];
  
  NSURL *url = [arrayOfURLs lastObject];
  if(!url) {
    return NO;
  }
  /* Currently not working, as the underlying operations do not get the unomanager */
  MPDocument *document = [[[sender draggingDestinationWindow] windowController] document];
  BOOL ok = NO;
  if(document.selectedGroup) {
    [[document undoManager] beginUndoGrouping];
    KdbEntry *entry = [document createEntry:document.selectedGroup];
    ok = (nil != entry);
    entry.urlUndoable = [url absoluteString];
    [[document undoManager] endUndoGrouping];
    [[document undoManager] setActionName:NSLocalizedString(@"IMPORT_URL", @"Imports a dragged URL for a new entry")];
  }
  return ok;
}
@end
