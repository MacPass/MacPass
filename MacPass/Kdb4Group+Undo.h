//
//  Kdb4Group+Undo.h
//  MacPass
//
//  Created by Michael Starke on 01.08.13.
//  Copyright (c) 2013 HicknHack Software GmbH. All rights reserved.
//

#import "Kdb4Node.h"

@interface Kdb4Group (Undo)

- (NSString *)notesUndoable;
- (void)setNotesUndoable:(NSString *)newNotes;

@end
