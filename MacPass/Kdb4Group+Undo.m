//
//  Kdb4Group+Undo.m
//  MacPass
//
//  Created by Michael Starke on 01.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Group+Undo.h"
#import "KdbGroup+Undo.h"

@implementation Kdb4Group (Undo)

- (NSString *)notesUndoable {
  return self.notes;
}

- (void)setNotesUndoable:(NSString *)newNotes {
  [[self undoManager] registerUndoWithTarget:self selector:@selector(setNotesUndoable:) object:self.notes];
  [[self undoManager] setActionName:NSLocalizedString(@"SET_NOTES", "")];
  self.notes = newNotes;
}

@end
