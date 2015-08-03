//
//  MPDocument+EditingSession.m
//  MacPass
//
//  Created by Michael Starke on 30/05/14.
//  Copyright (c) 2014 HicknHack Software GmbH. All rights reserved.
//

#import "MPDocument+EditingSession.h"

#import "KPKNode.h"
#import "MPEditingSession.h"

@implementation MPDocument (EditingSession)

- (BOOL)hasActiveSession {
  return (self.editingSession != nil);
}

- (void)commitEditingSession {
  [self _commitEditingSession:self.editingSession];
}

- (void)cancelEditingSession {
  [self _cancelEditingSession:self.editingSession];
}

#pragma mark Private
- (void)_commitEditingSession:(MPEditingSession *)session {
  if(nil == session) {
    return; // No session to commit
  }
  [[self.undoManager prepareWithInvocationTarget:self] _cancelEditingSession:session];
  if(session.hasChanges) {
  }
}

- (void)_cancelEditingSession:(MPEditingSession *)session {
  if(nil == session) {
    return; // No session to cancel
  }
  [[self.undoManager prepareWithInvocationTarget:self] _commitEditingSession:session];
  if(session.hasChanges) {
    [session.node updateToNode:session.rollbackNode];
  }
}

@end
