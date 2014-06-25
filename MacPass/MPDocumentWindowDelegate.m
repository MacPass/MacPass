//
//  MPDocumentWindowDelegate.m
//  MacPass
//
//  Created by Michael Starke on 25.07.13.
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

#import "MPDocumentWindowDelegate.h"
#import "MPDocument.h"

#import "KPKEntry.h"

@implementation MPDocumentWindowDelegate

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  
  MPDocument *document = [[[sender draggingDestinationWindow] windowController] document];
  if(document.encrypted) {
    return NSDragOperationNone;
  }
  
  NSPasteboard *draggingPasteBoard = [sender draggingPasteboard];
  
  NSArray *classArray = [NSArray arrayWithObject:[NSURL class]];
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:classArray options:nil];
  BOOL ok = NO;
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
    KPKEntry *entry = [document createEntry:document.selectedGroup];
    ok = (nil != entry);
    entry.url = [url absoluteString];
    [[document undoManager] endUndoGrouping];
    [[document undoManager] setActionName:NSLocalizedString(@"IMPORT_URL", @"Imports a dragged URL for a new entry")];
  }
  return ok;
}

@end
