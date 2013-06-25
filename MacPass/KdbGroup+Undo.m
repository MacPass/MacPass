//
//  KdbGroup+Undo.m
//  MacPass
//
//  Created by Michael Starke on 18.05.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "KdbGroup+Undo.h"
#import "KdbGroup+KVOAdditions.h"

NSString *const MPGroupNameUndoableKey = @"nameUndoable";

@implementation KdbGroup (Undo)

- (NSUndoManager *)undoManager {
  return [[[NSDocumentController sharedDocumentController] currentDocument] undoManager];
}

- (NSString *)nameUndoable {
  return [self name];
}

- (void)setNameUndoable:(NSString *)newName {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setNameUndoable:) object:self.name];
  [[self undoManager] setActionName:NSLocalizedString(@"UNDO_SET_NAME", "Undo set name")];
  self.name = newName;
}

@end
