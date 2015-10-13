//
//  MPDocument+EditingSession.m
//  MacPass
//
//  Created by Michael Starke on 30/05/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument.h"
#import "MPEditingSession.h"

#import "KPKNode.h"

NSString *const MPDocumentDidBeginEditingSelectedItem      = @"com.hicknhack.macpass.MPDocumentDidBeginEditingSelectedItem";
NSString *const MPDocumentDidCancelChangesToSelectedItem   = @"com.hicknhack.macpass.MPDocumentDidCancelChangesToSelectedItem";
NSString *const MPDocumentDidCommitChangesToSelectedItem   = @"com.hicknhack.macpass.MPDocumentDidCommitChangesToSelectedItem";

@implementation MPDocument (EditingSession)

- (BOOL)isEditing {
  return (self.editingSession != nil);
}

- (void)commitChangesToSelectedItem:(id)sender {
  if(nil == self.editingSession) {
    return; // No session to commit
  }
  /* Force any lingering updates to be written */
  /* FIXME explore potential usage of:
   * NSObject(NSEditorRegistration)
   * NSObject(NSEditor)
   */
  [((NSWindowController *)self.windowControllers.firstObject).window makeFirstResponder:nil];
  
  /* update the data */
  [self.editingSession.source updateToNode:self.editingSession.node];
  if(self.editingSession.node.asEntry) {
    [self.undoManager setActionName:NSLocalizedString(@"UPDATE_ENTRY", "")];
  }
  else if(self.editingSession.node.asGroup) {
    [self.undoManager setActionName:NSLocalizedString(@"UPDATE_GROUP", "")];
  }
  self.editingSession = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidCommitChangesToSelectedItem object:self];
}

- (void)cancelChangesToSelectedItem:(id)sender {
  if(nil == self.editingSession) {
    return; // No session to cancel
  }
  self.editingSession = nil;
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidCancelChangesToSelectedItem object:self];
}

- (void)beginEditingSelectedItem:(id)sender {
  if(nil == self.selectedItem) {
    return;
  }
  self.editingSession = [MPEditingSession editingSessionWithSource:self.selectedItem];
  [[NSNotificationCenter defaultCenter] postNotificationName:MPDocumentDidBeginEditingSelectedItem object:self];
}

@end
