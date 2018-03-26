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

#import "KeePassKit/KeePassKit.h"

@implementation MPDocumentWindowDelegate

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
  
  MPDocument *document = [[[sender draggingDestinationWindow] windowController] document];
  if(document.encrypted) {
    return NSDragOperationNone;
  }
  
  NSPasteboard *draggingPasteBoard = [sender draggingPasteboard];
  
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:@[NSURL.class] options:nil];
  BOOL ok = YES;
  for(NSURL *url in arrayOfURLs) {
    if(url.fileURL || url.fileReferenceURL) {
      ok = NO;
      break; // OK stays NO;
    }
  }
  return ok ? NSDragOperationCopy : NSDragOperationNone;
}

- (BOOL)wantsPeriodicDraggingUpdates {
  return NO;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
  NSPasteboard *draggingPasteBoard = [sender draggingPasteboard];
  NSArray *arrayOfURLs = [draggingPasteBoard readObjectsForClasses:@[NSURL.class] options:nil];
  
  NSURL *url = arrayOfURLs.lastObject;
  if(!url) {
    return NO;
  }
  /* Currently not working, as the underlying operations do not get the undomanager */
  MPDocument *document = [sender draggingDestinationWindow].windowController.document;
  KPKGroup *parentGroup = document.selectedGroups.count == 1 ? document.selectedGroups.firstObject : document.root;
  [document.undoManager beginUndoGrouping];
  KPKEntry *entry = [document createEntry:parentGroup];
  BOOL didOk = (entry != nil);
  if(url.absoluteString) {
    entry.url = url.absoluteString;
  }
  else {
    didOk = NO;
  }
  if(url.host) {
    entry.title = url.host;
  }
  [document.undoManager endUndoGrouping];
  [document.undoManager setActionName:NSLocalizedString(@"IMPORT_URL", @"Imports a dragged URL for a new entry")];
  return didOk;
}

@end
